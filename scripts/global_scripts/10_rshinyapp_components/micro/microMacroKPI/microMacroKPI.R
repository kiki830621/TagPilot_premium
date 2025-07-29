#LOCK FILE
#
# microMacroKPI.R
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
#   • KPI summary statistics display (mean, total, count, proportion)
#   • Multiple summary boxes for different metrics
#   • Real-time filtering and dynamic updates
#   • Responsive layout with colored summary cards
#   • Platform and product line filtering capabilities
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
#' Calculate KPI summary statistics
#' @param data data.frame. Input data with KPI metrics
#' @param metric_columns character vector. Column names to calculate statistics for
#' @return list. Contains summary statistics for each metric
calculate_kpi_statistics <- function(data, metric_columns = NULL) {
  if (is.null(data) || nrow(data) == 0) {
    return(list())
  }
  
  # Default metric columns if not specified
  if (is.null(metric_columns)) {
    numeric_cols <- data %>% 
      dplyr::select_if(is.numeric) %>%
      names()
    
    # Prioritize common KPI columns
    priority_cols <- c("revenue", "sales", "rating", "conversion_rate", "click_through_rate", 
                       "cost_per_click", "return_on_ad_spend", "impressions", "clicks")
    
    metric_columns <- intersect(priority_cols, numeric_cols)
    
    # If no priority columns found, use first few numeric columns
    if (length(metric_columns) == 0) {
      metric_columns <- head(numeric_cols, 4)
    }
  }
  
  if (length(metric_columns) == 0) {
    return(list())
  }
  
  # Calculate statistics for each metric
  kpi_stats <- list()
  
  for (col in metric_columns) {
    if (col %in% names(data) && is.numeric(data[[col]])) {
      values <- data[[col]]
      values_clean <- values[!is.na(values)]
      
      if (length(values_clean) > 0) {
        kpi_stats[[col]] <- list(
          name = stringr::str_to_title(stringr::str_replace_all(col, "_", " ")),
          mean = mean(values_clean, na.rm = TRUE),
          total = sum(values_clean, na.rm = TRUE),
          count = length(values_clean),
          count_total = length(values),
          median = median(values_clean, na.rm = TRUE),
          min = min(values_clean, na.rm = TRUE),
          max = max(values_clean, na.rm = TRUE),
          na_count = sum(is.na(values)),
          proportion_valid = length(values_clean) / length(values)
        )
      }
    }
  }
  
  return(kpi_stats)
}

#' Format number for display
#' @param value numeric. Value to format
#' @param type character. Type of formatting ("currency", "percentage", "decimal", "integer")
#' @return character. Formatted string
format_kpi_value <- function(value, type = "decimal") {
  if (is.na(value) || !is.numeric(value)) {
    return("N/A")
  }
  
  switch(type,
    "currency" = paste0("$", format(round(value, 2), big.mark = ",", nsmall = 2)),
    "percentage" = paste0(format(round(value * 100, 1), nsmall = 1), "%"),
    "decimal" = format(round(value, 2), big.mark = ",", nsmall = 2),
    "integer" = format(round(value, 0), big.mark = ","),
    format(round(value, 2), big.mark = ",", nsmall = 2)
  )
}

#' Determine appropriate formatting type for a metric
#' @param metric_name character. Name of the metric
#' @return character. Formatting type
get_format_type <- function(metric_name) {
  metric_lower <- tolower(metric_name)
  
  if (grepl("revenue|cost|spend|price", metric_lower)) {
    return("currency")
  } else if (grepl("rate|conversion|percentage|pct", metric_lower)) {
    return("percentage")
  } else if (grepl("count|sales|impressions|clicks|views", metric_lower)) {
    return("integer")
  } else {
    return("decimal")
  }
}

# Filter UI -------------------------------------------------------------------
#' microMacroKPIFilterUI
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param translate Function. Translation function for UI text elements (defaults to identity function).
#'        Should accept a string and return a translated string.
#' @return shiny.tag. A Shiny UI component containing the filter controls for the KPI component.
microMacroKPIFilterUI <- function(id, translate = identity) {
  ns <- NS(id)
  
  wellPanel(
    style = "padding:15px;",
    h4(translate("Macro KPI Dashboard")),
    p(translate("Customer DNA summary statistics across all metrics")),
    
    hr(),
    textOutput(ns("component_status"))
  )
}

# Display UI ------------------------------------------------------------------
#' microMacroKPIDisplayUI
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param translate Function. Translation function for UI text elements (defaults to identity function).
#' @return shiny.tag. A Shiny UI component containing the display elements for the KPI component.
microMacroKPIDisplayUI <- function(id, translate = identity) {
  ns <- NS(id)
  
  tagList(
    # KPI Summary Section
    fluidRow(
      column(width = 12,
        div(class = "kpi-summary mb-3 text-center",
            h4(translate("KPI Overview")),
            verbatimTextOutput(ns("data_summary")))
      )
    ),
    
    # KPI ValueBoxes - Row 1: Revenue & Sales Metrics
    fluidRow(
      column(width = 4, valueBoxOutput(ns("kpi_revenue"), width = NULL)),
      column(width = 4, valueBoxOutput(ns("kpi_sales"), width = NULL)),
      column(width = 4, valueBoxOutput(ns("kpi_rating"), width = NULL))
    ),
    
    # KPI ValueBoxes - Row 2: Performance Metrics
    fluidRow(
      column(width = 4, valueBoxOutput(ns("kpi_cost"), width = NULL)),
      column(width = 4, valueBoxOutput(ns("kpi_roas"), width = NULL)),
      column(width = 4, valueBoxOutput(ns("kpi_impressions"), width = NULL))
    ),
    
    # KPI ValueBoxes - Row 3: Transaction Metrics
    fluidRow(
      column(width = 4, valueBoxOutput(ns("kpi_clicks"), width = NULL)),
      column(width = 4, valueBoxOutput(ns("kpi_metric1"), width = NULL)),
      column(width = 4, valueBoxOutput(ns("kpi_metric2"), width = NULL))
    )
  )
}

# Server ----------------------------------------------------------------------
#' microMacroKPIServer
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param app_data_connection Database connection object or list. Any connection type supported by tbl2.
#'        Can be a DBI connection, a list with getter functions, a file path, or NULL if no database access is needed.
#' @param config List or reactive expression. Optional configuration settings that can customize behavior.
#'        If reactive, will be re-evaluated when dependencies change.
#' @param session Shiny session object. The current Shiny session (defaults to getDefaultReactiveDomain()).
#' @return list. A list of reactive values providing access to component state and data.
microMacroKPIServer <- function(id, app_data_connection = NULL, config = NULL,
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
    kpi_data <- reactive({
      component_status("loading")
      
      result <- tryCatch({
        if (is.null(app_data_connection)) {
          warning("No valid database connection available")
          return(data.frame())
        }
        
        # Access DNA data using tbl2 (same as microCustomer)
        tbl <- tbl2(app_data_connection, "df_dna_by_customer")
        
        # Apply platform filter if specified
        platform_val <- platform_id()
        
        if (!is.null(platform_val) && platform_val != "0") {
          # Convert numeric platform_id to character for filtering
          platform_char <- case_when(
            platform_val == "2" ~ "amz",
            platform_val == "1" ~ "eby", 
            TRUE ~ "all"
          )
          if (platform_char != "all") {
            tbl <- tbl %>% dplyr::filter(platform_id == platform_char)
          }
        }
        
        # Apply product line filter if specified
        prod_line_val <- product_line_id()
        
        if (!is.null(prod_line_val) && prod_line_val != "all") {
          tbl <- tbl %>% dplyr::filter(product_line_id_filter == !!prod_line_val)
        }
        
        # Collect results
        filtered_data <- tbl %>% collect()
        
        component_status("ready")
        return(filtered_data)
      }, error = function(e) {
        warning("Error fetching KPI data: ", e$message)
        component_status("error")
        data.frame()
      })
      
      return(result)
    })
    
    # ------------ KPI Statistics reactive -------------------------
    kpi_statistics <- reactive({
      data <- kpi_data()
      if (is.null(data) || nrow(data) == 0) {
        return(list())
      }
      
      # Calculate statistics using the helper function
      calculate_kpi_statistics(data)
    })
    
    # ------------ Helper function for safe value extraction --------
    safeValue <- function(data, field_name, default = 0) {
      if (is.null(data) || nrow(data) == 0 || !field_name %in% names(data)) {
        return(default)
      }
      
      values <- data[[field_name]]
      values_clean <- values[!is.na(values) & is.finite(values)]
      
      if (length(values_clean) == 0) {
        return(default)
      }
      
      return(values_clean)
    }
    
    # ------------ Output Rendering ----------------------------------
    output$data_summary <- renderText({
      data <- kpi_data()
      
      if (is.null(data) || nrow(data) == 0) {
        return("No data available for KPI analysis")
      }
      
      platform_val <- platform_id()
      prod_line <- product_line_id()
      
      platform_text <- if (is.null(platform_val) || platform_val == "0") "All Platforms" else paste("Platform", platform_val)
      product_text <- if (prod_line == "all") "All Product Lines" else paste("Product Line", prod_line)
      
      paste0("Data: ", platform_text, " | ", product_text, " | Records: ", nrow(data))
    })
    
    # Render individual KPI valueBoxes (similar to microCustomer approach)
    
    # Row 1: Customer Value Metrics (based on Customer DNA data)
    output$kpi_revenue <- renderValueBox({
      data <- kpi_data()
      values <- safeValue(data, "m_value", default = c(0))  # Monetary value from RFM
      
      if (length(values) > 0) {
        mean_val <- mean(values, na.rm = TRUE)
        total_val <- sum(values, na.rm = TRUE)
        display_val <- format_kpi_value(mean_val, "currency")
        subtitle_text <- paste0("Total: ", format_kpi_value(total_val, "currency"), 
                               " | Count: ", length(values))
      } else {
        display_val <- "$0.00"
        subtitle_text <- "No monetary data available"
      }
      
      valueBox(
        value = display_val,
        subtitle = "Monetary Value (RFM-M)",
        icon = icon("dollar-sign"),
        color = "success"
      )
    })
    
    output$kpi_sales <- renderValueBox({
      data <- kpi_data()
      values <- safeValue(data, "f_value", default = c(0))  # Frequency value from RFM
      
      if (length(values) > 0) {
        mean_val <- mean(values, na.rm = TRUE)
        total_val <- sum(values, na.rm = TRUE)
        display_val <- format_kpi_value(mean_val, "decimal")
        subtitle_text <- paste0("Total: ", format_kpi_value(total_val, "integer"), 
                               " | Count: ", length(values))
      } else {
        display_val <- "0.00"
        subtitle_text <- "No frequency data available"
      }
      
      valueBox(
        value = display_val,
        subtitle = "Frequency (RFM-F)",
        icon = icon("shopping-cart"),
        color = "primary"
      )
    })
    
    
    # Row 2: Customer Activity Metrics
    output$kpi_rating <- renderValueBox({
      data <- kpi_data()
      values <- safeValue(data, "cai", default = c(0))  # Customer Activity Index
      
      if (length(values) > 0) {
        mean_val <- mean(values, na.rm = TRUE)
        display_val <- format_kpi_value(mean_val, "decimal")
        subtitle_text <- paste0("Count: ", length(values), 
                               " | Range: ", format_kpi_value(min(values, na.rm = TRUE), "decimal"),
                               " - ", format_kpi_value(max(values, na.rm = TRUE), "decimal"))
      } else {
        display_val <- "0.00"
        subtitle_text <- "No CAI data available"
      }
      
      valueBox(
        value = display_val,
        subtitle = "Customer Activity Index",
        icon = icon("chart-line"),
        color = "warning"
      )
    })
    
    output$kpi_cost <- renderValueBox({
      data <- kpi_data()
      values <- safeValue(data, "ipt_mean", default = c(0))  # Inter-Purchase Time
      
      if (length(values) > 0) {
        mean_val <- mean(values, na.rm = TRUE)
        display_val <- format_kpi_value(mean_val, "decimal")
        subtitle_text <- paste0("Avg IPT: ", display_val, " days", 
                               " | Count: ", length(values))
      } else {
        display_val <- "0.00"
        subtitle_text <- "No IPT data available"
      }
      
      valueBox(
        value = display_val,
        subtitle = "Inter-Purchase Time",
        icon = icon("calendar-alt"),
        color = "danger"
      )
    })
    
    output$kpi_roas <- renderValueBox({
      data <- kpi_data()
      values <- safeValue(data, "pcv", default = c(0))  # Past Customer Value
      
      if (length(values) > 0) {
        mean_val <- mean(values, na.rm = TRUE)
        total_val <- sum(values, na.rm = TRUE)
        display_val <- format_kpi_value(mean_val, "currency")
        subtitle_text <- paste0("Total: ", format_kpi_value(total_val, "currency"), 
                               " | Count: ", length(values))
      } else {
        display_val <- "$0.00"
        subtitle_text <- "No PCV data available"
      }
      
      valueBox(
        value = display_val,
        subtitle = "Past Customer Value",
        icon = icon("chart-bar"),
        color = "teal"
      )
    })
    
    # Row 3: Customer Lifetime Metrics
    output$kpi_impressions <- renderValueBox({
      data <- kpi_data()
      values <- safeValue(data, "clv", default = c(0))  # Customer Lifetime Value
      
      if (length(values) > 0) {
        mean_val <- mean(values, na.rm = TRUE)
        total_val <- sum(values, na.rm = TRUE)
        display_val <- format_kpi_value(mean_val, "currency")
        subtitle_text <- paste0("Total: ", format_kpi_value(total_val, "currency"), 
                               " | Count: ", length(values))
      } else {
        display_val <- "$0.00"
        subtitle_text <- "No CLV data available"
      }
      
      valueBox(
        value = display_val,
        subtitle = "Customer Lifetime Value",
        icon = icon("gem"),
        color = "lightblue"
      )
    })
    
    output$kpi_clicks <- renderValueBox({
      data <- kpi_data()
      values <- safeValue(data, "cri", default = c(0))  # Customer Retention Index
      
      if (length(values) > 0) {
        mean_val <- mean(values, na.rm = TRUE)
        display_val <- format_kpi_value(mean_val, "decimal")
        subtitle_text <- paste0("Avg CRI: ", display_val, 
                               " | Count: ", length(values))
      } else {
        display_val <- "0.00"
        subtitle_text <- "No CRI data available"
      }
      
      valueBox(
        value = display_val,
        subtitle = "Customer Retention Index",
        icon = icon("shield-alt"),
        color = "orange"
      )
    })
    
    
    # Row 4: Transaction Metrics
    output$kpi_metric1 <- renderValueBox({
      data <- kpi_data()
      values <- safeValue(data, "nt", default = c(0))  # New customer transaction value
      
      if (length(values) > 0) {
        mean_val <- mean(values, na.rm = TRUE)
        total_val <- sum(values, na.rm = TRUE)
        display_val <- format_kpi_value(mean_val, "currency")
        subtitle_text <- paste0("Total: ", format_kpi_value(total_val, "currency"), 
                               " | Count: ", length(values))
      } else {
        display_val <- "$0.00"
        subtitle_text <- "No new customer transaction data"
      }
      
      valueBox(
        value = display_val,
        subtitle = "New Customer Transaction",
        icon = icon("user-plus"),
        color = "navy"
      )
    })
    
    output$kpi_metric2 <- renderValueBox({
      data <- kpi_data()
      values <- safeValue(data, "e0t", default = c(0))  # Existing customer transaction value
      
      if (length(values) > 0) {
        mean_val <- mean(values, na.rm = TRUE)
        total_val <- sum(values, na.rm = TRUE)
        display_val <- format_kpi_value(mean_val, "currency")
        subtitle_text <- paste0("Total: ", format_kpi_value(total_val, "currency"), 
                               " | Count: ", length(values))
      } else {
        display_val <- "$0.00"
        subtitle_text <- "No existing customer transaction data"
      }
      
      valueBox(
        value = display_val,
        subtitle = "Existing Customer Transaction",
        icon = icon("user-check"),
        color = "olive"
      )
    })
    
    
    # Display component status
    output$component_status <- renderText({
      switch(component_status(),
             idle = "Ready for KPI analysis",
             loading = "Loading KPI data...",
             ready = paste0("Analysis complete - ", length(kpi_statistics()), " KPIs calculated"),
             computing = "Computing KPI statistics...",
             error = "Error in KPI analysis",
             component_status())
    })
    
    # Return reactive values for external use
    return(list(
      kpi_data = kpi_data,
      component_status = component_status
    ))
  })
}

# Component wrapper -----------------------------------------------------------
#' microMacroKPIComponent
#' 
#' Implements a KPI analysis component with summary statistics display
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
#' kpiComp <- microMacroKPIComponent("kpi_analysis")
#' 
#' # Usage with database connection
#' kpiComp <- microMacroKPIComponent(
#'   id = "kpi_analysis",
#'   app_data_connection = app_conn, 
#'   config = list(platform_id = "2")
#' )
#'
#' # Usage with reactive configuration
#' kpiComp <- microMacroKPIComponent(
#'   id = "kpi_analysis",
#'   app_data_connection = app_conn,
#'   config = reactive({ list(filters = list(platform_id = input$platform)) })
#' )
#' @export
microMacroKPIComponent <- function(id, app_data_connection = NULL, config = NULL, translate = identity) {
  list(
    ui = list(filter = microMacroKPIFilterUI(id, translate),
              display = microMacroKPIDisplayUI(id, translate)),
    server = function(input, output, session) {
      microMacroKPIServer(id, app_data_connection, config, session)
    }
  )
}