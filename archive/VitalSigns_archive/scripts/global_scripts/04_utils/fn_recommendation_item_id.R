#' Item Recommendation Function Using Random Forest and Conditional Probabilities
#'
#' This function recommends items to customers based on their purchase history.
#' Uses Random Forest to predict the first recommended item based on the n-1 and n records,
#' and conditional probabilities for subsequent recommendations.
#'
#' @param df A data frame containing customer purchase data.
#' @param customer_id_col Character. Name of the column containing customer IDs.
#' @param item_id_col Character. Name of the column containing item IDs.
#' @param time_col Character. Name of the column containing purchase timestamps.
#' @param covariate_cols Character vector. Names of columns to use as predictors. Defaults to all columns
#'        except customer_id, item_id, and time columns.
#' @param recommended_choice_set Character/Numeric vector. Pool of item IDs to recommend from.
#'        Defaults to all unique item IDs in the data.
#' @param recommended_number Integer. Number of items to recommend per customer. Default is 10.
#' @param seed Integer. Random seed for reproducibility. Default is 42.
#' @param min_purchases Integer. Minimum number of purchases needed to make recommendations. Default is 2.
#' @param rf_trees Integer. Number of trees in the random forest model. Default is 100.
#'
#' @return A data frame with columns:
#'   - customer_id: Customer identifiers
#'   - recommended_next_item_id01, recommended_next_item_id02, ...: Recommended items
#'
#' @examples
#' # Basic usage
#' # recommendations <- recommend_next_items(
#' #   purchase_data,
#' #   customer_id_col = "customer_id",
#' #   item_id_col = "product_id",
#' #   time_col = "purchase_date"
#' # )
#'
#' # Custom covariates and recommendation set
#' # recommendations <- recommend_next_items(
#' #   purchase_data,
#' #   customer_id_col = "customer_id",
#' #   item_id_col = "product_id",
#' #   time_col = "purchase_date",
#' #   covariate_cols = c("price", "category", "season"),
#' #   recommended_choice_set = top_selling_items,
#' #   recommended_number = 5
#' # )
#'
#' @importFrom randomForest randomForest
#' @importFrom dplyr arrange group_by summarize n filter select mutate lag left_join
#' @importFrom tidyr pivot_wider
#' @importFrom stats predict
#' @export
recommend_next_items <- function(df,
                                customer_id_col,
                                item_id_col,
                                time_col,
                                covariate_cols = NULL,
                                recommended_choice_set = NULL,
                                recommended_number = 10,
                                seed = 42,
                                min_purchases = 2,
                                rf_trees = 100) {
  # Validate required packages
  required_packages <- c("dplyr", "randomForest", "tidyr")
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop(paste0("Package '", pkg, "' is required. Please install it: install.packages('", pkg, "')"))
    }
  }
  
  # Set random seed for reproducibility
  set.seed(seed)
  
  # Validate input parameters
  if (!all(c(customer_id_col, item_id_col, time_col) %in% colnames(df))) {
    stop("One or more specified column names not found in the data frame")
  }
  
  # Create standardized column names for easier processing
  df_std <- df
  colnames(df_std)[colnames(df_std) == customer_id_col] <- "customer_id"
  colnames(df_std)[colnames(df_std) == item_id_col] <- "item_id"
  colnames(df_std)[colnames(df_std) == time_col] <- "time"
  
  # Determine covariates if not provided
  if (is.null(covariate_cols)) {
    covariate_cols <- setdiff(colnames(df_std), 
                             c("customer_id", "item_id", "time", 
                               customer_id_col, item_id_col, time_col))
  } else {
    # Validate if specified covariates exist in the data frame
    if (!all(covariate_cols %in% colnames(df))) {
      stop("One or more specified covariate columns not found in the data frame")
    }
    
    # Rename covariates if they match one of the standard names
    for (col in covariate_cols) {
      if (col %in% c(customer_id_col, item_id_col, time_col)) {
        next  # Skip if it's one of the primary columns
      }
      colnames(df_std)[colnames(df_std) == col] <- col
    }
  }
  
  # If recommended_choice_set not provided, use all unique item IDs
  if (is.null(recommended_choice_set)) {
    recommended_choice_set <- unique(df_std$item_id)
  } else {
    # Validate if recommended items exist in the data
    if (!all(recommended_choice_set %in% df$item_id)) {
      warning("Some items in recommended_choice_set are not present in the data")
    }
  }
  
  # Sort data by customer and time
  df_sorted <- df_std %>%
    dplyr::arrange(customer_id, time)
  
  # Create sequence numbers for each purchase within customer
  df_sorted <- df_sorted %>%
    dplyr::group_by(customer_id) %>%
    dplyr::mutate(
      purchase_seq = 1:dplyr::n(),
      total_purchases = dplyr::n(),
      prev_item_id = dplyr::lag(item_id, default = NA)
    ) %>%
    dplyr::ungroup()  # Explicitly ungroup following R115 dplyr rules
  
  # Filter for customers with sufficient purchase history
  customers_with_history <- df_sorted %>%
    dplyr::group_by(customer_id) %>%
    dplyr::summarize(
      purchase_count = dplyr::n(),
      .groups = "drop"  # Explicitly drop grouping per R115
    ) %>%
    dplyr::filter(purchase_count >= min_purchases) %>%
    dplyr::pull(customer_id)
  
  if (length(customers_with_history) == 0) {
    warning("No customers with sufficient purchase history found")
    return(data.frame(customer_id = character(0)))
  }
  
  # Prepare training data for random forest (records with previous purchases)
  train_data <- df_sorted %>%
    dplyr::filter(
      customer_id %in% customers_with_history,
      !is.na(prev_item_id)
    ) %>%
    dplyr::select(
      customer_id, 
      item_id, 
      prev_item_id, 
      dplyr::all_of(covariate_cols)
    )
  
  message("Training random forest model...")
  
  # Convert categorical variables to factors with proper dplyr syntax
  train_data <- train_data %>% 
    dplyr::mutate(
      item_id = as.factor(item_id),
      prev_item_id = as.factor(prev_item_id)
    )
  
  # Build the formula properly - reference the column names directly since they're already factors
  formula_str <- paste(
    "item_id ~", 
    paste(c("prev_item_id", covariate_cols), collapse = " + ")
  )
  
  # Train the random forest model
  rf_model <- randomForest::randomForest(
    formula = as.formula(formula_str),
    data = train_data,
    ntree = rf_trees,
    importance = TRUE
  )
  
  message("Preparing data for recommendations...")
  
  # Prepare data for first recommendation (using the last two purchases)
  last_purchases <- df_sorted %>%
    dplyr::filter(customer_id %in% customers_with_history) %>%
    dplyr::group_by(customer_id) %>%
    dplyr::filter(
      purchase_seq == max(purchase_seq) | purchase_seq == max(purchase_seq) - 1
    ) %>%
    dplyr::arrange(customer_id, purchase_seq) %>%
    dplyr::ungroup()  # Explicitly ungroup
  
  # Get latest purchase for each customer
  latest_purchases <- last_purchases %>%
    dplyr::group_by(customer_id) %>%
    dplyr::filter(purchase_seq == max(purchase_seq)) %>%
    dplyr::select(
      customer_id, 
      item_id, 
      prev_item_id, 
      dplyr::all_of(covariate_cols)
    ) %>%
    dplyr::ungroup()  # Explicitly ungroup
  
  # Calculate conditional probabilities matrix for item transitions
  item_transitions <- df_sorted %>%
    dplyr::filter(!is.na(prev_item_id)) %>%
    dplyr::group_by(prev_item_id, item_id) %>%
    dplyr::summarize(
      count = dplyr::n(), 
      .groups = "drop"  # Explicitly drop grouping
    ) %>%
    dplyr::group_by(prev_item_id) %>%
    dplyr::mutate(prob = count / sum(count)) %>%
    dplyr::select(prev_item_id, item_id, prob) %>%
    dplyr::ungroup()  # Explicitly ungroup
  
  message("Making recommendations...")
  
  # Function to get recommendations for a single customer
  get_customer_recommendations <- function(customer_data) {
    # Get the customer ID
    cust_id <- customer_data$customer_id[1]
    
    recommendations <- character(recommended_number)
    
    # First recommendation using random forest
    prediction_data <- customer_data
    
    # If the customer has only one purchase, we can't use prev_item_id for prediction
    if (nrow(prediction_data) == 1 || is.na(prediction_data$prev_item_id[1])) {
      # Use simplified model without prev_item_id
      simple_formula_str <- paste(
        "as.factor(item_id) ~", 
        paste(covariate_cols, collapse = " + ")
      )
      
      # Check if we have enough data for a simplified model
      if (length(covariate_cols) > 0) {
        simple_data <- df_sorted %>%
          dplyr::select(item_id, dplyr::all_of(covariate_cols)) %>%
          dplyr::mutate(item_id = as.factor(item_id))  # Ensure factor conversion
        
        simple_rf <- randomForest::randomForest(
          formula = as.formula(simple_formula_str),
          data = simple_data,
          ntree = rf_trees/2
        )
        
        # Properly convert prediction data factors
        prediction_data <- prediction_data %>%
          dplyr::mutate(
            item_id = as.factor(item_id),
            prev_item_id = as.factor(NA)  # Add NA prev_item_id as factor
          )
        
        pred_probs <- predict(simple_rf, prediction_data, type = "prob")
      } else {
        # If no covariates, use item frequency
        item_freqs <- table(df_sorted$item_id)
        item_probs <- prop.table(item_freqs)
        pred_probs <- matrix(
          item_probs, 
          nrow = 1, 
          dimnames = list(NULL, names(item_probs))
        )
      }
    } else {
      # Properly convert prediction data factors
      prediction_data <- prediction_data %>%
        dplyr::mutate(
          item_id = as.factor(item_id),
          prev_item_id = as.factor(prev_item_id)
        )
      
      # Use full model with prev_item_id
      pred_probs <- predict(rf_model, prediction_data, type = "prob")
    }
    
    # Convert to data frame if it's not already
    if (!is.data.frame(pred_probs)) {
      pred_probs <- as.data.frame(pred_probs)
    }
    
    # Get first recommendation based on highest probability
    valid_choices <- intersect(colnames(pred_probs), as.character(recommended_choice_set))
    
    if (length(valid_choices) == 0) {
      # If no valid choices, use random selection from recommended_choice_set
      recommendations[1] <- sample(recommended_choice_set, 1)
    } else {
      pred_probs_valid <- pred_probs[, valid_choices, drop = FALSE]
      first_rec <- colnames(pred_probs_valid)[which.max(as.numeric(pred_probs_valid[1, ]))]
      recommendations[1] <- first_rec
    }
    
    # Subsequent recommendations using conditional probabilities
    prev_rec <- recommendations[1]
    
    for (i in 2:recommended_number) {
      # Get conditional probabilities for previous recommendation
      cond_probs <- item_transitions %>%
        dplyr::filter(prev_item_id == prev_rec)
      
      if (nrow(cond_probs) == 0) {
        # If no transitions observed for this item, use random selection
        remaining_choices <- setdiff(recommended_choice_set, recommendations[1:(i-1)])
        if (length(remaining_choices) == 0) {
          # If all recommended items used, allow repeats but avoid the most recent
          remaining_choices <- setdiff(recommended_choice_set, prev_rec)
        }
        recommendations[i] <- sample(remaining_choices, 1)
      } else {
        # Filter for items in the choice set and not already recommended
        valid_next_items <- cond_probs %>%
          dplyr::filter(
            item_id %in% recommended_choice_set,
            !(item_id %in% recommendations[1:(i-1)])
          )
        
        if (nrow(valid_next_items) == 0) {
          # If no valid transitions, use random selection
          remaining_choices <- setdiff(recommended_choice_set, recommendations[1:(i-1)])
          if (length(remaining_choices) == 0) {
            remaining_choices <- setdiff(recommended_choice_set, prev_rec)
          }
          recommendations[i] <- sample(remaining_choices, 1)
        } else {
          # Select item with highest probability
          recommendations[i] <- valid_next_items$item_id[which.max(valid_next_items$prob)]
        }
      }
      
      prev_rec <- recommendations[i]
    }
    
    # Format results
    result <- data.frame(
      customer_id = cust_id,
      t(recommendations)
    )
    
    # Rename columns
    colnames(result)[2:(recommended_number+1)] <- sprintf(
      "recommended_next_item_id%02d", 
      1:recommended_number
    )
    
    return(result)
  }
  
  # Process each customer
  all_recommendations <- lapply(
    split(latest_purchases, latest_purchases$customer_id), 
    get_customer_recommendations
  )
  
  # Combine all recommendations
  result_df <- do.call(rbind, all_recommendations)
  rownames(result_df) <- NULL
  
  # Restore original customer_id column name if it's different
  if (customer_id_col != "customer_id") {
    colnames(result_df)[colnames(result_df) == "customer_id"] <- customer_id_col
  }
  
  message("Recommendation complete.")
  return(result_df)
}