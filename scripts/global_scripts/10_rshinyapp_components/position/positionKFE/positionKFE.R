#LOCK FILE
#
# positionKFE.R
#
# Following principles:
# - MP56: Connected Component Principle (component structure)
# - MP81: Explicit Parameter Specification (function arguments)
# - R116: Enhanced Data Access with tbl2 (data access)
# - R09: UI-Server-Defaults Triple (component organization)
# - MP88: Immediate Feedback (real-time filtering without Apply button)
# - MP47: Functional Programming (data transformation functions)
#

#
# Features:
#   • Key Factor Evaluation (KFE) analysis
#   • Automatic identification of critical success factors
#   • Benchmark analysis for each key factor
#   • Ideal point analysis and scoring
#   • Interactive display of key factors and recommendations
# -----------------------------------------------------------------------------

# helper ----------------------------------------------------------------------
#' Paste operator for string concatenation
#' @param x Character string. First string to concatenate.
#' @param y Character string. Second string to concatenate.
#' @return Character string. The concatenated result of x and y.
`%+%` <- function(x, y) paste0(x, y)

#' NULL coalescing operator
#' @param x Any value. The value to use if not NULL.
#' @param y Any value. The fallback value to use if x is NULL.
#' @return Either x or y. Returns x if it's not NULL, otherwise returns y.
`%||%` <- function(x, y) if (is.null(x)) y else x

# Data transformation functions (MP47) ----------------------------------------
#' Perform key factor evaluation analysis
#' @param data data.frame. Position data with numerical attributes
#' @param exclude_vars character vector. Variables to exclude from analysis
#' @param threshold_multiplier numeric. Multiplier for the threshold (default: 1.0)
#' @return list. Contains key factors, indicators, and benchmarks
perform_kfe_analysis <- function(data, exclude_vars = NULL, threshold_multiplier = 1.0) {
  # Check if product_id column exists, if not look for platform-specific columns
  if (!"product_id" %in% names(data)) {
    # Try common platform-specific columns
    if ("asin" %in% names(data)) {
      data <- data %>% dplyr::rename(product_id = asin)
    } else if ("ebay_product_number" %in% names(data)) {
      data <- data %>% dplyr::rename(product_id = ebay_product_number)
    } else {
      warning("No product identifier column found in KFE analysis data")
      return(list(
        key_factors = character(0),
        indicators = data.frame(),
        benchmarks = list(),
        ideal_analysis = data.frame()
      ))
    }
  }
  
  # Remove excluded variables and special rows
  df_analysis <- data %>%
    dplyr::filter(!product_id %in% c("Rating", "Revenue")) %>%
    dplyr::select(-dplyr::any_of(exclude_vars))
  
  # Extract Ideal row if it exists
  ideal_row <- df_analysis %>% dplyr::filter(product_id == "Ideal")
  
  if (nrow(ideal_row) == 0) {
    warning("No Ideal row found for KFE analysis")
    return(list(
      key_factors = character(0),
      indicators = data.frame(),
      benchmarks = list(),
      ideal_analysis = data.frame()
    ))
  }
  
  # Get numeric columns for analysis
  key_cols <- c("product_id", "brand", "product_line_id", "platform_id")
  numeric_cols <- df_analysis %>% 
    dplyr::select(-dplyr::any_of(key_cols)) %>%
    dplyr::select_if(is.numeric) %>%
    names()
  
  if (length(numeric_cols) == 0) {
    warning("No numeric columns found for KFE analysis")
    return(list(
      key_factors = character(0),
      indicators = data.frame(),
      benchmarks = list(),
      ideal_analysis = data.frame()
    ))
  }
  
  # Create indicators matrix
  df_no_ideal <- df_analysis %>% dplyr::filter(product_id != "Ideal")
  
  # Calculate ideal comparison for each numeric column
  indicators <- data.frame(matrix(0, nrow = nrow(df_no_ideal), ncol = length(numeric_cols)))
  colnames(indicators) <- numeric_cols
  
  for (col in numeric_cols) {
    ideal_val <- ideal_row[[col]][1]
    if (!is.na(ideal_val) && is.numeric(ideal_val) && is.finite(ideal_val)) {
      # Compare each value to ideal, handling NA values explicitly
      col_values <- df_no_ideal[[col]]
      # Only include non-NA values in comparison, set NA values to 0
      comparison_result <- ifelse(is.na(col_values), 0, ifelse(col_values >= ideal_val, 1, 0))
      indicators[[col]] <- comparison_result
    } else {
      # If ideal value is NA or invalid, set all indicators to 0
      indicators[[col]] <- rep(0, nrow(df_no_ideal))
    }
  }
  
  # Calculate gate (threshold) for key factor identification
  gate <- rowSums(indicators, na.rm = TRUE) / ncol(indicators) * threshold_multiplier
  
  # Identify key factors (columns where ideal comparison > gate)
  col_sums <- colSums(indicators, na.rm = TRUE)
  key_factors <- names(col_sums[col_sums > mean(gate, na.rm = TRUE)])
  
  # Create benchmarks for each key factor
  benchmarks <- list()
  for (factor in key_factors) {
    if (factor %in% colnames(indicators)) {
      # Get indices where the factor equals 1
      factor_indices <- which(indicators[[factor]] == 1)
      
      if (length(factor_indices) > 0) {
        # Get product IDs for those indices, filtering out NA values
        benchmark_product_ids <- df_no_ideal$product_id[factor_indices]
        benchmark_product_ids <- benchmark_product_ids[!is.na(benchmark_product_ids)]
        benchmark_product_ids <- unique(benchmark_product_ids)
        
        # Only include if we have valid product IDs
        if (length(benchmark_product_ids) > 0) {
          benchmarks[[factor]] <- benchmark_product_ids
        }
      }
    }
  }
  
  # Create ideal analysis (scoring based on key factors)
  if (length(key_factors) > 0) {
    ideal_analysis <- df_no_ideal %>%
      dplyr::select(product_id, brand, dplyr::all_of(key_factors)) %>%
      dplyr::mutate(
        Score = rowSums(dplyr::select(., dplyr::all_of(key_factors)), na.rm = TRUE)
      ) %>%
      dplyr::arrange(dplyr::desc(Score))
  } else {
    ideal_analysis <- data.frame()
  }
  
  return(list(
    key_factors = key_factors,
    indicators = indicators,
    benchmarks = benchmarks,
    ideal_analysis = ideal_analysis,
    gate_threshold = mean(gate, na.rm = TRUE)
  ))
}

#' Format key factors for display
#' @param factors character vector. List of key factors
#' @return character. Formatted string of key factors
format_key_factors <- function(factors) {
  if (length(factors) == 0) {
    return("No key factors identified")
  }
  
  # Clean up factor names for display
  clean_factors <- factors %>%
    stringr::str_replace_all("_", " ") %>%
    stringr::str_to_title()
  
  paste(clean_factors, collapse = ", ")
}

# Filter UI -------------------------------------------------------------------
#' positionKFEFilterUI
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param translate Function. Translation function for UI text elements (defaults to identity function).
#'        Should accept a string and return a translated string.
#' @return shiny.tag. A Shiny UI component containing the filter controls for the KFE component.
positionKFEFilterUI <- function(id, translate = identity) {
  ns <- NS(id)
  
  wellPanel(
    style = "padding:15px;",
    h4(translate("Key Factor Analysis Settings")),
    
    # Threshold multiplier
    sliderInput(
      inputId = ns("threshold_multiplier"),
      label = translate("Analysis Sensitivity"),
      min = 0.5,
      max = 2.0,
      value = 1.0,
      step = 0.1
    ),
    
    # Display options
    hr(),
    h4(translate("Display Options")),
    
    # Show detailed analysis
    checkboxInput(
      inputId = ns("show_details"),
      label = translate("Show detailed factor analysis"),
      value = TRUE
    ),
    
    # Show benchmarks
    checkboxInput(
      inputId = ns("show_benchmarks"),
      label = translate("Show benchmark products"),
      value = FALSE
    ),
    
    # Maximum factors to display
    sliderInput(
      inputId = ns("max_factors"),
      label = translate("Maximum factors to display"),
      min = 3,
      max = 15,
      value = 8,
      step = 1
    ),
    
    # Reset button
    actionButton(
      inputId = ns("reset_filters"),
      label = translate("Reset Settings"),
      class = "btn-outline-secondary btn-block mt-3"
    ),
    
    hr(),
    textOutput(ns("component_status"))
  )
}

# Display UI ------------------------------------------------------------------
#' positionKFEDisplayUI
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param translate Function. Translation function for UI text elements (defaults to identity function).
#' @param mode Character string. Display mode - "compact" for summary view, "full" for detailed view (default: "full").
#' @return shiny.tag. A Shiny UI component containing the display elements for the KFE component.
positionKFEDisplayUI <- function(id, translate = identity, mode = "full") {
  ns <- NS(id)
  
  if (mode == "compact") {
    # Compact mode for use alongside other components
    tagList(
      div(class = "component-output p-2",
          div(class = "kfe-main-output",
              h5(translate("Key Factors:")),
              div(class = "kfe-factors-display",
                  verbatimTextOutput(ns("key_factors_text"))))
      )
    )
  } else {
    # Full mode for dedicated view
    tagList(
      div(class = "component-header mb-3 text-center",
          h3(translate("Key Factor Evaluation")),
          p(translate("Automatic identification and analysis of critical success factors"))),
      div(class = "component-output p-3",
          div(class = "kfe-main-output",
              h4(translate("Key Factors:")),
              div(class = "kfe-factors-display",
                  verbatimTextOutput(ns("key_factors_text")))),
          conditionalPanel(
            condition = paste0("input['", ns("show_benchmarks"), "']"),
            div(class = "kfe-benchmarks mt-4",
                h5(translate("Benchmark Products:")),
                verbatimTextOutput(ns("benchmark_details")))
          ))
    )
  }
}

# Server ----------------------------------------------------------------------
#' positionKFEServer
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param app_data_connection Database connection object or list. Any connection type supported by tbl2.
#'        Can be a DBI connection, a list with getter functions, a file path, or NULL if no database access is needed.
#' @param config List or reactive expression. Optional configuration settings that can customize behavior.
#'        If reactive, will be re-evaluated when dependencies change.
#' @param session Shiny session object. The current Shiny session (defaults to getDefaultReactiveDomain()).
#' @param display_mode Character string. Display mode - "compact" or "full" (default: "full").
#' @return list. A list of reactive values providing access to component state and data.
positionKFEServer <- function(id, app_data_connection = NULL, config = NULL,
                              session = getDefaultReactiveDomain(), display_mode = "full") {
  moduleServer(id, function(input, output, session) {
    
    # ------------ Status tracking ----------------------------------
    component_status <- reactiveVal("idle")
    
    # ------------ Extract configuration parameters -----------------
    platform_id <- reactive({
      tryCatch({
        if (is.null(config)) return(NULL)
        
        cfg <- if (is.function(config)) config() else config
        
        if (!is.null(cfg[["platform_id"]])) {
          return(as.character(cfg[["platform_id"]]))
        }
        if (!is.null(cfg[["filters"]]) && !is.null(cfg[["filters"]][["platform_id"]])) {
          return(as.character(cfg[["filters"]][["platform_id"]]))
        }
        
        NULL
      }, error = function(e) {
        warning("Error extracting platform_id from config: ", e$message)
        NULL
      })
    })
    
    product_line_id <- reactive({
      tryCatch({
        if (is.null(config)) return("all")
        
        cfg <- if (is.function(config)) config() else config
        
        if (!is.null(cfg[["product_line_id"]])) {
          return(as.character(cfg[["product_line_id"]]))
        }
        if (!is.null(cfg[["filters"]]) && !is.null(cfg[["filters"]][["product_line_id"]])) {
          return(as.character(cfg[["filters"]][["product_line_id"]]))
        }
        
        "all"
      }, error = function(e) {
        warning("Error extracting product_line_id: ", e$message)
        "all"
      })
    })
    
    # ------------ Data access (R116) -----------------------------------
    position_data <- reactive({
      if (product_line_id() == "all") {
        component_status("idle")
        return(data.frame())
      }
      
      component_status("loading")
      
      prod_line <- product_line_id()
      
      result <- tryCatch({
        if (is.null(app_data_connection)) {
          warning("No valid database connection available")
          return(data.frame())
        }
        
        # Use complete case function to get position data with type filtering (KFE needs Ideal row)
        filtered_data <- fn_get_position_complete_case(
          app_data_connection = app_data_connection,
          product_line_id = prod_line,
          include_special_rows = TRUE,  # KFE analysis needs Ideal row
          apply_type_filter = TRUE
        )
        
        # Check if product_id column exists, if not try to find platform-specific column
        if (!"product_id" %in% names(filtered_data) && nrow(filtered_data) > 0) {
          platform <- platform_id()
          product_col <- switch(platform,
            "2" = "asin",  # Amazon
            "3" = "ebay_product_number",  # eBay
            "product_id"  # Default fallback
          )
          
          if (product_col %in% names(filtered_data)) {
            message("DEBUG: Renaming '", product_col, "' to 'product_id' in positionKFE")
            filtered_data <- filtered_data %>% dplyr::rename(product_id = !!sym(product_col))
          } else {
            warning("No product identifier column found in KFE position data. Available columns: ", paste(names(filtered_data), collapse = ", "))
          }
        }
        
        component_status("ready")
        return(filtered_data)
      }, error = function(e) {
        warning("Error fetching position data: ", e$message)
        component_status("error")
        data.frame()
      })
      
      return(result)
    })
    
    # ------------ KFE Analysis -----------------------------------
    kfe_result <- reactive({
      data <- position_data()
      if (is.null(data) || nrow(data) == 0) return(NULL)
      
      component_status("computing")
      
      # Define variables to exclude from KFE analysis
      exclude_vars <- c("product_line_id", "platform_id", "rating", "sales", "revenue")
      
      # Use default values when in compact mode (no filter UI available)
      threshold_mult <- if (display_mode == "compact") {
        1.0  # Default threshold multiplier
      } else {
        input$threshold_multiplier %||% 1.0
      }
      
      result <- perform_kfe_analysis(
        data = data,
        exclude_vars = exclude_vars,
        threshold_multiplier = threshold_mult
      )
      
      if (length(result$key_factors) > 0) {
        component_status("ready")
      } else {
        component_status("idle")
      }
      
      return(result)
    })
    
    # ------------ Reset filters ------------------------------------
    # Only set up reset observer in full mode
    if (display_mode == "full") {
      observeEvent(input$reset_filters, {
        updateSliderInput(session, "threshold_multiplier", value = 1.0)
        updateCheckboxInput(session, "show_details", value = TRUE)
        updateCheckboxInput(session, "show_benchmarks", value = FALSE)
        updateSliderInput(session, "max_factors", value = 8)
        
        message("KFE settings reset")
      })
    }
    
    # ------------ Output Rendering ------------------------------------
    output$key_factors_text <- renderText({
      result <- kfe_result()
      
      if (is.null(result) || length(result$key_factors) == 0) {
        return("No key factors identified. Try adjusting the analysis sensitivity.")
      }
      
      # Use default max_factors in compact mode
      max_factors <- if (display_mode == "compact") {
        8  # Default max factors
      } else {
        input$max_factors %||% 8
      }
      
      # Limit the number of factors displayed
      factors_to_show <- head(result$key_factors, max_factors)
      
      formatted_factors <- format_key_factors(factors_to_show)
      
      if (length(result$key_factors) > max_factors) {
        formatted_factors <- paste0(formatted_factors, 
                                  " (showing ", max_factors, " of ", 
                                  length(result$key_factors), " factors)")
      }
      
      return(formatted_factors)
    })
    
    output$benchmark_details <- renderText({
      result <- kfe_result()
      
      if (is.null(result) || length(result$benchmarks) == 0) {
        return("No benchmark information available.")
      }
      
      benchmark_text <- "Benchmark Products by Factor:\n\n"
      factors_with_benchmarks <- 0
      
      for (factor in names(result$benchmarks)) {
        products <- result$benchmarks[[factor]]
        
        # Only process factors that have valid benchmark products
        if (!is.null(products) && length(products) > 0 && !all(is.na(products))) {
          # Filter out any NA values that might have slipped through
          valid_products <- products[!is.na(products) & nchar(products) > 0]
          
          if (length(valid_products) > 0) {
            clean_factor <- stringr::str_replace_all(factor, "_", " ") %>% 
                           stringr::str_to_title()
            benchmark_text <- paste0(
              benchmark_text,
              clean_factor, ": ", 
              paste(head(valid_products, 5), collapse = ", "),
              if (length(valid_products) > 5) paste0(" (and ", length(valid_products) - 5, " more)") else "",
              "\n"
            )
            factors_with_benchmarks <- factors_with_benchmarks + 1
          }
        }
      }
      
      if (factors_with_benchmarks == 0) {
        return("No valid benchmark products found. This may indicate data quality issues or that no products meet the benchmark criteria.")
      }
      
      return(benchmark_text)
    })
    
    # Display component status
    output$component_status <- renderText({
      if (product_line_id() == "all") {
        return("Please select a specific product line for key factor analysis")
      }
      
      switch(component_status(),
             idle = "Ready for key factor evaluation",
             loading = "Loading position data...",
             ready = paste0("Analysis complete with ", 
                          length(kfe_result()$key_factors %||% character(0)), 
                          " key factors identified"),
             computing = "Computing key factor analysis...",
             error = "Error in key factor evaluation",
             component_status())
    })
    
    # Return reactive values for external use
    return(list(
      position_data = position_data,
      kfe_result = kfe_result,
      component_status = component_status
    ))
  })
}

# Component wrapper -----------------------------------------------------------
#' positionKFEComponent
#' 
#' Implements a key factor evaluation component for position analysis
#' following the Connected Component principle.
#' 
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param app_data_connection Database connection object or list. The data connection supporting Enhanced Data Access pattern (R116).
#'        Can be a DBI connection, a list with getter functions, a file path, or NULL if no database access is needed.
#' @param config List or reactive expression. Configuration parameters for customizing component behavior (optional).
#'        If reactive, will be re-evaluated when dependencies change.
#' @param translate Function. Translation function for UI text elements (defaults to identity function).
#'        Should accept a string and return a translated string.
#' @param display_mode Character string. Display mode - "compact" for summary view, "full" for detailed view (default: "full").
#' @return A list containing UI and server functions structured according to the Connected Component Principle (MP56).
#'         The UI element contains 'filter' and 'display' components, and the server function initializes component functionality.
#' @examples
#' # Basic usage with default settings
#' kfeComp <- positionKFEComponent("kfe_analysis")
#' 
#' # Usage with database connection
#' kfeComp <- positionKFEComponent(
#'   id = "kfe_analysis",
#'   app_data_connection = app_conn, 
#'   config = list(platform_id = "amz")
#' )
#'
#' # Usage with reactive configuration
#' kfeComp <- positionKFEComponent(
#'   id = "kfe_analysis",
#'   app_data_connection = app_conn,
#'   config = reactive({ list(filters = list(platform_id = input$platform)) })
#' )
#' @export
positionKFEComponent <- function(id, app_data_connection = NULL, config = NULL, translate = identity, display_mode = "full") {
  list(
    ui = list(filter = if (display_mode == "full") positionKFEFilterUI(id, translate) else NULL,
              display = positionKFEDisplayUI(id, translate, mode = display_mode)),
    server = function(input, output, session) {
      positionKFEServer(id, app_data_connection, config, session, display_mode = display_mode)
    }
  )
}