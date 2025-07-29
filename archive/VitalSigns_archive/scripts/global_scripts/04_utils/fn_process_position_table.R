#' Process Position Table for a Product Line
#'
#' Processes position data for a specific product line, integrating comment properties, 
#' competitor data, and sales data. Calculates ideal values for positioning analysis.
#' Part of the D03_11 step in the Positioning Analysis derivation flow.
#'
#' @param product_line_id Character. The product line ID to process.
#' @param raw_data A DBI connection to the raw data database.
#' @param processed_data A DBI connection to the processed data database.
#' @param app_data A DBI connection to the app data database.
#' @param paste_ Function. The string concatenation function.
#' @param platform Character. Platform identifier ("amz" or "eby") (default: "amz").
#'
#' @return Logical. TRUE if processing succeeded, FALSE otherwise.
#'
#' @examples
#' \dontrun{
#' # Process a single product line
#' # Process for Amazon
#' process_position_table(
#'   product_line_id = "jew",
#'   raw_data = raw_data,
#'   processed_data = processed_data,
#'   app_data = app_data,
#'   paste_ = paste_,
#'   platform = "amz"
#' )
#' 
#' # Process for eBay
#' process_position_table(
#'   product_line_id = "tur",
#'   raw_data = raw_data,
#'   processed_data = processed_data,
#'   app_data = app_data,
#'   paste_ = paste_,
#'   platform = "eby"
#' )
#' }
#'
#' @export
process_position_table <- function(product_line_id, 
                                  raw_data, 
                                  processed_data, 
                                  app_data,
                                  paste_,
                                  platform = "amz") {
  # Required packages
  if (!requireNamespace("dplyr", quietly = TRUE)) library(dplyr)
  if (!requireNamespace("DBI", quietly = TRUE)) library(DBI)
  
  message("\n▶ Processing product line: ", product_line_id, " (Platform: ", platform, ")")
  
  # Define platform-specific variables
  item_col <- switch(platform,
    "amz" = "asin",
    "eby" = "ebay_item_number",
    stop(paste("Unknown platform:", platform))
  )
  
  # Table name patterns
  rating_table_suffix <- if (platform == "amz") "by_asin" else "by_item"
  competitor_table <- switch(platform,
    "amz" = "df_competitor_item_id",  # Fixed typo from original
    "eby" = "df_eby_competitor_item_id"
  )
  sales_table <- switch(platform,
    "amz" = "df_amz_competitor_sales",
    "eby" = "df_eby_competitor_sales"  # May not exist
  )
  
  # 1. Read original property ratings
  orig_table_name <- paste0("df_comment_property_ratingonly_", rating_table_suffix, "_", product_line_id)
  
  if (!DBI::dbExistsTable(processed_data, orig_table_name)) {
    message("  ⚠️ Table not found in database: ", orig_table_name, 
            ", skipping product line ", product_line_id)
    return(FALSE)
  }
  
  Dta <- dplyr::tbl(processed_data, orig_table_name) %>% 
    dplyr::collect()
  
  message("  ✓ Read ", nrow(Dta), " records")
  
  # 2. Filter product data and apply type filtering
  # Get item list for this product line
  item_list <- dplyr::tbl(raw_data, competitor_table) %>% 
    dplyr::collect() %>% 
    dplyr::filter(product_line_id == !!product_line_id) %>% 
    dplyr::select(!!sym(item_col)) %>% 
    dplyr::pull()
  
  # Keep only items in the list
  Dta <- Dta %>% dplyr::filter(!!sym(item_col) %in% item_list)
  message("  ✓ After filtering: ", nrow(Dta), " records")
  
  # 2a. Get property type information to filter out non-"屬性" columns
  property_types <- dplyr::tbl(raw_data, "df_all_comment_property") %>%
    dplyr::filter(product_line_id == !!product_line_id) %>%
    dplyr::select(property_name, type) %>%
    dplyr::collect()
  
  # Only keep columns for properties with type = "屬性"
  if (nrow(property_types) > 0) {
    # Get property names that should be kept (type = "屬性")
    properties_to_keep <- property_types %>%
      dplyr::filter(type == "屬性") %>%
      dplyr::pull(property_name) %>%
      janitor::make_clean_names(ascii = FALSE)
    
    # Identify system columns to always keep
    system_cols <- c(item_col, "brand", "rating", "sales", "product_line_id")
    
    # Get current column names and filter to keep only desired properties
    current_cols <- colnames(Dta)
    cols_to_keep <- c(
      intersect(system_cols, current_cols),  # System columns that exist
      intersect(properties_to_keep, current_cols)  # Property columns that should be kept
    )
    
    # Select only the columns we want to keep
    Dta <- Dta %>% dplyr::select(dplyr::all_of(cols_to_keep))
    
    message("  ✓ Applied type='屬性' filter: keeping ", length(properties_to_keep), " property columns")
    message("    Properties kept: ", paste(properties_to_keep, collapse = ", "))
  } else {
    message("  ⚠️ No property type information found, keeping all columns")
  }
  
  # 3. Remove columns with too many missing values
  # Keep columns with less than 50% missing values
  threshold <- nrow(Dta) / 2
  Dta <- Dta[, colSums(is.na(Dta)) <= threshold]
  
  # 4. Read sales data (if available)
  if (DBI::dbExistsTable(raw_data, sales_table)) {
    cl_used_sales <- dplyr::tbl(raw_data, sales_table) %>% 
      dplyr::group_by(!!sym(item_col)) %>% 
      dplyr::summarise(sales = sum(sales, na.rm = TRUE)) %>% 
      dplyr::collect()
  } else {
    message("  ⚠️ Sales table not found: ", sales_table, ", using review counts as proxy")
    # For eBay, use review counts as a proxy for sales
    if (platform == "eby") {
      cl_used_sales <- dplyr::tbl(processed_data, "df_eby_review") %>%
        dplyr::group_by(!!sym(item_col)) %>%
        dplyr::summarise(sales = n()) %>%  # Count of reviews as proxy
        dplyr::collect()
    } else {
      cl_used_sales <- data.frame()  # Empty dataframe
      cl_used_sales[[item_col]] <- character()
      cl_used_sales$sales <- numeric()
    }
  }
  
  # 5. Integrate data
  combined_position <- dplyr::tbl(raw_data, competitor_table) %>% 
    dplyr::collect() %>% 
    dplyr::filter(product_line_id == !!product_line_id) %>% 
    dplyr::select(brand, !!sym(item_col)) %>% 
    dplyr::left_join(Dta, by = item_col) %>% 
    dplyr::left_join(cl_used_sales, by = item_col) %>% 
    dplyr::mutate(brand = dplyr::na_if(brand, NA_character_) %>% 
                   tidyr::replace_na("UNKNOWN"))
  
  # 6. Calculate ideal values
  ideal_data <- calculate_ideal_values(combined_position, item_col = item_col)
  
  # 7. Integrate and store data
  combined_position___with_ideal <- combined_position %>% 
    dplyr::rows_append(ideal_data) %>% 
    dplyr::relocate(!!sym(item_col), brand, .before = dplyr::everything()) %>%  # Move item ID and brand to the front
    dplyr::relocate(dplyr::any_of("rating"), .after = dplyr::last_col()) %>%    # Move rating to the end if exists
    dplyr::mutate(product_line_id = product_line_id) %>%
    # Rename item column to standardized item_id
    dplyr::rename(item_id = !!sym(item_col))
  
  # Save to temporary table
  new_table_name <- paste_("df_position", product_line_id)
  DBI::dbWriteTable(
    app_data, 
    new_table_name, 
    combined_position___with_ideal, 
    temporary = TRUE, 
    overwrite = TRUE
  )
  
  message("  ✅ Product line processing complete, saved to table ", new_table_name)
  return(TRUE)
}

#' Calculate Ideal Values for Positioning
#'
#' Calculates ideal values for product positioning based on ratings and sales data.
#' Creates a weighted average where ideal values are 60% sales-based and 40% rating-based.
#'
#' @param combined_position Data frame. The combined position data with brand, item ID, ratings, and sales.
#' @param item_col Character. The name of the item ID column ("asin" or "ebay_item_number").
#'
#' @return Data frame. The ideal values for the "Ideal" row.
#'
#' @noRd
calculate_ideal_values <- function(combined_position, item_col = "asin") {
  # Required packages
  if (!requireNamespace("dplyr", quietly = TRUE)) library(dplyr)
  
  # Prepare calculation data
  combined_position___without_brand_item <- combined_position %>% 
    dplyr::select(-dplyr::any_of(c(item_col, "brand")))
  
  columns_to_remove <- c("rating", "sales")
  
  # Rating-based ideal calculation
  rating_ideal <- combined_position___without_brand_item %>% 
    dplyr::select(-dplyr::any_of(columns_to_remove)) %>% 
    dplyr::summarise(dplyr::across(dplyr::everything(), 
                    ~ sum(.x * combined_position___without_brand_item$rating / 
                           sum(combined_position___without_brand_item$rating, na.rm = TRUE), 
                         na.rm = TRUE)))
  
  # Sales-based ideal calculation
  sales_ideal <- combined_position___without_brand_item %>% 
    dplyr::select(-dplyr::any_of(columns_to_remove)) %>% 
    dplyr::summarise(dplyr::across(dplyr::everything(), 
                    ~ sum(.x * combined_position___without_brand_item$sales / 
                           sum(combined_position___without_brand_item$sales, na.rm = TRUE), 
                         na.rm = TRUE)))
  
  # Combined ideal: 60% sales + 40% rating  
  Ideal <- dplyr::bind_rows(rating_ideal, sales_ideal, 0.6 * sales_ideal + 0.4 * rating_ideal)
  
  if (ncol(Ideal) > 0) {
    Ideal <- Ideal %>% dplyr::mutate(
      brand = c("Rating", "Revenue", "Ideal")
    )
    Ideal[[item_col]] <- c("Rating", "Revenue", "Ideal")
    # Return all three special records: Rating, Revenue, and Ideal
    return(Ideal)
  } else {
    # If no numeric columns, create minimal special records
    special_records <- data.frame(
      brand = c("Rating", "Revenue", "Ideal")
    )
    special_records[[item_col]] <- c("Rating", "Revenue", "Ideal")
    return(special_records)
  }
  
  # This line should never be reached, but keep for safety
  return(Ideal)
}