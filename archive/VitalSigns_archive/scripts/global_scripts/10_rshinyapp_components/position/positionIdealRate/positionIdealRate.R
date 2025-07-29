#LOCK FILE
#
# positionIdealRate.R
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
#   • Ideal Rate Analysis based on key factors
#   • Interactive data table display with scoring
#   • Brand and Item ID ranking by ideal distance
#   • Automatic key factor identification
#   • Real-time filtering and sorting capabilities
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
#' Perform ideal rate analysis
#' @param data data.frame. Position data with numerical attributes
#' @param exclude_vars character vector. Variables to exclude from analysis
#' @param threshold_multiplier numeric. Multiplier for the threshold (default: 1.0)
#' @return list. Contains ideal analysis results with scores and rankings
perform_ideal_rate_analysis <- function(data, exclude_vars = NULL, threshold_multiplier = 1.0) {
  # Check if item_id column exists, if not look for platform-specific columns
  if (!"item_id" %in% names(data)) {
    # Try common platform-specific columns
    if ("asin" %in% names(data)) {
      data <- data %>% dplyr::rename(item_id = asin)
    } else if ("ebay_item_number" %in% names(data)) {
      data <- data %>% dplyr::rename(item_id = ebay_item_number)
    } else {
      warning("No item identifier column found in ideal rate analysis data")
      return(list(
        ideal_analysis = data.frame(),
        key_factors = character(0),
        indicators = data.frame()
      ))
    }
  }
  
  # Remove excluded variables and special rows
  df_analysis <- data %>%
    dplyr::filter(!item_id %in% c("Rating", "Revenue")) %>%
    dplyr::select(-dplyr::any_of(exclude_vars))
  
  # Extract Ideal row if it exists
  ideal_row <- df_analysis %>% dplyr::filter(item_id == "Ideal")
  
  if (nrow(ideal_row) == 0) {
    warning("No Ideal row found for ideal rate analysis")
    return(list(
      ideal_analysis = data.frame(),
      key_factors = character(0),
      indicators = data.frame()
    ))
  }
  
  # Get numeric columns for analysis
  key_cols <- c("item_id", "brand", "product_line_id", "platform_id")
  numeric_cols <- df_analysis %>% 
    dplyr::select(-dplyr::any_of(key_cols)) %>%
    dplyr::select_if(is.numeric) %>%
    names()
  
  if (length(numeric_cols) == 0) {
    warning("No numeric columns found for ideal rate analysis")
    return(list(
      ideal_analysis = data.frame(),
      key_factors = character(0),
      indicators = data.frame()
    ))
  }
  
  # Create indicators matrix
  df_no_ideal <- df_analysis %>% dplyr::filter(item_id != "Ideal")
  
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
  
  # Create ideal analysis (IA) - following KitchenMAMA methodology
  if (length(key_factors) > 0) {
    # Select only key factors from indicators
    IA <- indicators %>% dplyr::select(dplyr::any_of(key_factors))
    
    # Calculate score as row sum
    IA <- IA %>% dplyr::mutate(Score = rowSums(IA, na.rm = TRUE))
    
    # Add brand and item_id information
    IA <- IA %>%
      dplyr::bind_cols(
        brand = df_no_ideal$brand,
        item_id = df_no_ideal$item_id
      )
    
    # Arrange by score descending (IA_lis equivalent)
    ideal_analysis <- IA %>% 
      dplyr::arrange(dplyr::desc(Score)) %>%
      dplyr::filter(item_id != "Ideal") %>%
      dplyr::select(Score, brand, item_id, dplyr::everything())
    
  } else {
    ideal_analysis <- data.frame()
  }
  
  return(list(
    ideal_analysis = ideal_analysis,
    key_factors = key_factors,
    indicators = indicators,
    gate_threshold = mean(gate, na.rm = TRUE)
  ))
}

# Filter UI -------------------------------------------------------------------
#' positionIdealRateFilterUI
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param translate Function. Translation function for UI text elements (defaults to identity function).
#'        Should accept a string and return a translated string.
#' @return shiny.tag. A Shiny UI component containing the filter controls for the IdealRate component.
positionIdealRateFilterUI <- function(id, translate = identity) {
  ns <- NS(id)
  
  wellPanel(
    style = "padding:15px;",
    h4(translate("Ideal Rate Analysis Settings")),
    
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
    
    # Maximum rows to display
    sliderInput(
      inputId = ns("max_rows"),
      label = translate("Maximum products to display"),
      min = 10,
      max = 100,
      value = 50,
      step = 10
    ),
    
    # Show all columns
    checkboxInput(
      inputId = ns("show_all_columns"),
      label = translate("Show all factor columns"),
      value = FALSE
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
#' positionIdealRateDisplayUI
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param translate Function. Translation function for UI text elements (defaults to identity function).
#' @return shiny.tag. A Shiny UI component containing the display elements for the IdealRate component.
positionIdealRateDisplayUI <- function(id, translate = identity) {
  ns <- NS(id)
  
  tagList(
    div(class = "component-header mb-3 text-center",
        h3(translate("Ideal Rate Analysis")),
        p(translate("Product ranking based on ideal point distance and key factor performance"))),
    div(class = "component-output p-3",
        div(class = "ideal-rate-table",
            DT::DTOutput(ns("ideal_rate_table")))
    )
  )
}

# Server ----------------------------------------------------------------------
#' positionIdealRateServer
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param app_data_connection Database connection object or list. Any connection type supported by tbl2.
#'        Can be a DBI connection, a list with getter functions, a file path, or NULL if no database access is needed.
#' @param config List or reactive expression. Optional configuration settings that can customize behavior.
#'        If reactive, will be re-evaluated when dependencies change.
#' @param session Shiny session object. The current Shiny session (defaults to getDefaultReactiveDomain()).
#' @return list. A list of reactive values providing access to component state and data.
positionIdealRateServer <- function(id, app_data_connection = NULL, config = NULL,
                             session = getDefaultReactiveDomain()) {
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
        
        # Use complete case function to get position data with type filtering (IdealRate needs Ideal row)
        filtered_data <- fn_get_position_complete_case(
          app_data_connection = app_data_connection,
          product_line_id = prod_line,
          include_special_rows = TRUE,  # IdealRate analysis needs Ideal row
          apply_type_filter = TRUE
        )
        
        # Check if item_id column exists, if not try to find platform-specific column
        if (!"item_id" %in% names(filtered_data) && nrow(filtered_data) > 0) {
          platform <- platform_id()
          item_col <- switch(platform,
            "2" = "asin",  # Amazon
            "3" = "ebay_item_number",  # eBay
            "item_id"  # Default fallback
          )
          
          if (item_col %in% names(filtered_data)) {
            message("DEBUG: Renaming '", item_col, "' to 'item_id' in positionIdealRate")
            filtered_data <- filtered_data %>% dplyr::rename(item_id = !!sym(item_col))
          } else {
            warning("No item identifier column found in IdealRate position data. Available columns: ", paste(names(filtered_data), collapse = ", "))
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
    
    # ------------ Ideal Rate Analysis -----------------------------------
    ideal_rate_result <- reactive({
      data <- position_data()
      if (is.null(data) || nrow(data) == 0) return(NULL)
      
      component_status("computing")
      
      # Define variables to exclude from analysis
      exclude_vars <- c("product_line_id", "platform_id", "rating", "sales", "revenue")
      
      result <- perform_ideal_rate_analysis(
        data = data,
        exclude_vars = exclude_vars,
        threshold_multiplier = input$threshold_multiplier %||% 1.0
      )
      
      if (nrow(result$ideal_analysis) > 0) {
        component_status("ready")
      } else {
        component_status("idle")
      }
      
      return(result)
    })
    
    # ------------ Reset filters ------------------------------------
    observeEvent(input$reset_filters, {
      updateSliderInput(session, "threshold_multiplier", value = 1.0)
      updateSliderInput(session, "max_rows", value = 50)
      updateCheckboxInput(session, "show_all_columns", value = FALSE)
      
      message("Ideal Rate settings reset")
    })
    
    # ------------ Output Rendering ------------------------------------
    # Render the main data table
    output$ideal_rate_table <- DT::renderDT({
      result <- ideal_rate_result()
      
      if (is.null(result) || nrow(result$ideal_analysis) == 0) {
        return(data.frame(Message = "No data available for analysis"))
      }
      
      # Prepare data for display
      display_data <- result$ideal_analysis
      
      # Limit number of rows
      max_rows <- input$max_rows %||% 50
      if (nrow(display_data) > max_rows) {
        display_data <- display_data[1:max_rows, ]
      }
      
      # Select columns based on display options
      if (input$show_all_columns %||% FALSE) {
        # Show all columns
        final_data <- display_data
      } else {
        # Show only essential columns (Score, brand, item_id)
        final_data <- display_data %>%
          dplyr::select(Score, brand, item_id)
      }
      
      return(final_data)
    }, options = list(
      pageLength = -1,  # Show all rows
      searching = FALSE,  # Disable search box
      lengthChange = FALSE,  # Don't show "Show [number] entries" option
      info = FALSE,  # Don't show "Showing 1 to X of X entries" info
      paging = FALSE,  # Disable pagination
      scrollX = TRUE,  # Enable horizontal scrolling
      columnDefs = list(
        list(visible = FALSE, targets = 0)  # Hide row numbers
      )
    ))
    
    # Display component status
    output$component_status <- renderText({
      if (product_line_id() == "all") {
        return("Please select a specific product line for ideal rate analysis")
      }
      
      switch(component_status(),
             idle = "Ready for ideal rate analysis",
             loading = "Loading position data...",
             ready = paste0("Analysis complete with ", 
                          nrow(ideal_rate_result()$ideal_analysis %||% data.frame()), 
                          " products ranked"),
             computing = "Computing ideal rate analysis...",
             error = "Error in ideal rate analysis",
             component_status())
    })
    
    # Return reactive values for external use
    return(list(
      position_data = position_data,
      ideal_rate_result = ideal_rate_result,
      component_status = component_status
    ))
  })
}

# Component wrapper -----------------------------------------------------------
#' positionIdealRateComponent
#' 
#' Implements an ideal rate analysis component for position analysis
#' following the Connected Component principle.
#' 
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param app_data_connection Database connection object or list. The data connection supporting Enhanced Data Access pattern (R116).
#'        Can be a DBI connection, a list with getter functions, a file path, or NULL if no database access is needed.
#' @param config List or reactive expression. Configuration parameters for customizing component behavior (optional).
#'        If reactive, will be re-evaluated when dependencies change.
#' @param translate Function. Translation function for UI text elements (defaults to identity function).
#'        Should accept a string and return a translated string.
#' @return A list containing UI and server functions structured according to the Connected Component Principle (MP56).
#'         The UI element contains 'filter' and 'display' components, and the server function initializes component functionality.
#' @examples
#' # Basic usage with default settings
#' idealRateComp <- positionIdealRateComponent("ideal_rate_analysis")
#' 
#' # Usage with database connection
#' idealRateComp <- positionIdealRateComponent(
#'   id = "ideal_rate_analysis",
#'   app_data_connection = app_conn, 
#'   config = list(platform_id = "amz")
#' )
#'
#' # Usage with reactive configuration
#' idealRateComp <- positionIdealRateComponent(
#'   id = "ideal_rate_analysis",
#'   app_data_connection = app_conn,
#'   config = reactive({ list(filters = list(platform_id = input$platform)) })
#' )
#' @export
positionIdealRateComponent <- function(id, app_data_connection = NULL, config = NULL, translate = identity) {
  list(
    ui = list(filter = positionIdealRateFilterUI(id, translate),
              display = positionIdealRateDisplayUI(id, translate)),
    server = function(input, output, session) {
      positionIdealRateServer(id, app_data_connection, config, session)
    }
  )
}