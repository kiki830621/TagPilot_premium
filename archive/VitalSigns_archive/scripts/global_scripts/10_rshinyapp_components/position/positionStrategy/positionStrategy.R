#LOCK FILE
#
# positionStrategy.R
#
# Following principles:
# - MP56: Connected Component Principle (component structure)
# - MP81: Explicit Parameter Specification (function arguments)
# - R116: Enhanced Data Access with tbl2 (data access)
# - R09: UI-Server-Defaults Triple (component organization)
# - MP88: Immediate Feedback (real-time filtering without Apply button)
# - MP47: Functional Programming (data transformation functions)
# - MP73: Interactive Visualization Preference (Plotly for interactive charts)
#
# Required packages (initialized by framework):
# - shiny (core functions: showNotification, withProgress, incProgress, HTML, etc.)
# - shinycssloaders (withSpinner - optional with fallback)
# - plotly (plotlyOutput, renderPlotly)
# - dplyr (data manipulation)
# - httr2 (API calls - optional with fallback)
# - jsonlite (toJSON)
# - stringr (str_replace_all - optional with fallback)
# - markdown (markdownToHTML - optional with fallback)
#

#
# Features:
#   • Strategic positioning analysis based on key factors
#   • Four-quadrant strategy visualization (Argument/Improvement/Weakness/Change)
#   • Dynamic font sizing based on content length
#   • Interactive Plotly visualization with responsive text
#   • Product-specific strategy recommendations
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
#' Remove columns that are entirely NA
#' @param data data.frame. Input data frame
#' @return data.frame. Data frame with NA-only columns removed
remove_na_columns <- function(data) {
  data %>% dplyr::select_if(~!all(is.na(.)))
}

#' Strip code fences from GPT response
#' @param txt character. Text containing potential code fences
#' @return character. Text with code fences removed
strip_code_fence <- function(txt) {
  if (requireNamespace("stringr", quietly = TRUE)) {
    stringr::str_replace_all(
      txt,
      stringr::regex("^```[A-Za-z0-9]*[ \\t]*\\r?\\n|\\r?\\n```[ \\t]*$", multiline = TRUE),
      ""
    )
  } else {
    # Fallback: simple gsub approach
    gsub("^```[A-Za-z0-9]*[ \t]*\r?\n|\r?\n```[ \t]*$", "", txt, perl = TRUE)
  }
}

#' Call OpenAI chat completion API
#' @param messages list. List of message objects with role and content
#' @param api_key character. OpenAI API key
#' @param model character. Model name to use (default: "o4-mini")
#' @return character. GPT response content
chat_api <- function(messages, api_key, model = "o4-mini") {
  
  # Load required packages
  if (!requireNamespace("httr2", quietly = TRUE)) {
    warning("httr2 package not available, cannot perform API call")
    return("❌ httr2 package not available")
  }
  
  if (is.null(api_key) || !nzchar(api_key)) {
    warning("OpenAI API key not provided")
    return("❌ OpenAI API key not provided")
  }
  
  # Basic validation of API key format
  if (!grepl("^sk-", api_key)) {
    warning("OpenAI API key format appears incorrect. Should start with 'sk-'")
  }
  
  tryCatch({
    # Use simplified httr2 syntax (matching positionMSPlotly)
    response <- httr2::request("https://api.openai.com/v1/chat/completions") |>
      httr2::req_auth_bearer_token(api_key) |>
      httr2::req_body_json(list(
        model = model,
        messages = messages,
        max_completion_tokens = 4000  # Increased for o4-mini model
      )) |>
      httr2::req_perform() |>
      httr2::resp_body_json()
    
    # Check if we have choices
    if (length(response$choices) == 0) {
      warning("No choices in API response")
      return("❌ No response from API")
    }
    
    # Extract and return content
    content <- response$choices[[1]]$message$content
    return(trimws(content))
    
  }, error = function(e) {
    warning("Error calling OpenAI API: ", e$message)
    return(paste("❌ API Error:", e$message))
  })
}

#' Format keys for display with improved spacing
#' @param keys character vector. Keys to format
#' @param max_per_line integer. Maximum items per line (default: 2)
#' @return character. Formatted string with proper spacing
format_keys <- function(keys, max_per_line = 2) {
  if (length(keys) == 0) {
    return("")
  }
  
  result <- ""
  for (i in seq_along(keys)) {
    if (i %% max_per_line == 1 && i > 1) {
      # Start new line after every max_per_line items
      result <- paste0(result, "\n", keys[i])
    } else if (i == 1) {
      # First item
      result <- keys[i]
    } else {
      # Add tab spacing
      result <- paste0(result, "\t\t", keys[i])
    }
  }
  
  return(result)
}

#' Improved dynamic font size calculation
#' @param text character. Text to calculate font size for
#' @param base_size numeric. Base font size (default: 16)
#' @param min_size numeric. Minimum font size (default: 10)
#' @param max_size numeric. Maximum font size (default: 24)
#' @return numeric. Calculated font size
calculate_dynamic_font_size <- function(text, base_size = 16, min_size = 10, max_size = 24) {
  if (is.null(text) || text == "") {
    return(base_size)
  }
  
  n_chars <- nchar(text)
  n_lines <- length(strsplit(text, "\n")[[1]])
  
  # Calculate based on character count and line count
  # More characters = smaller font, more lines = smaller font
  size_factor <- 1 - (n_chars / 200) - (n_lines / 10)
  
  # Apply bounds
  calculated_size <- base_size * pmax(0.5, pmin(1.5, size_factor))
  
  # Ensure within min/max bounds
  return(pmax(min_size, pmin(max_size, calculated_size)))
}

#' Perform strategy analysis for a specific product
#' @param data data.frame. Position data with numerical attributes
#' @param selected_item_id character. Item ID of the selected product
#' @param key_factors character vector. List of key factors
#' @param exclude_vars character vector. Variables to exclude from analysis
#' @return list. Contains strategy analysis results
perform_strategy_analysis <- function(data, selected_item_id, key_factors, exclude_vars = NULL) {
  if (is.null(selected_item_id) || selected_item_id == "" || length(key_factors) == 0) {
    return(list(
      argument_text = "",
      improvement_text = "",
      weakness_text = "",
      changing_text = "",
      selected_product = NULL
    ))
  }
  
  # Remove NA columns (equivalent to SA_token <- SA %>% remove_na_columns())
  sa_token <- remove_na_columns(data)
  
  # Check if item_id column exists, if not look for platform-specific columns
  if (!"item_id" %in% names(sa_token)) {
    # Try common platform-specific columns
    if ("asin" %in% names(sa_token)) {
      sa_token <- sa_token %>% dplyr::rename(item_id = asin)
    } else if ("ebay_item_number" %in% names(sa_token)) {
      sa_token <- sa_token %>% dplyr::rename(item_id = ebay_item_number)
    } else {
      warning("No item identifier column found in strategy analysis data")
      return(list(
        argument_text = "Error: No item identifier column found",
        improvement_text = "",
        weakness_text = "",
        changing_text = "",
        selected_product = NULL
      ))
    }
  }
  
  # Ensure item_id column is character type to avoid comparison issues
  sa_token <- sa_token %>%
    dplyr::mutate(item_id = as.character(item_id))
  
  # Filter for the selected Item ID
  sub_sa <- sa_token %>% dplyr::filter(item_id == selected_item_id)
  
  if (nrow(sub_sa) == 0) {
    warning("Selected Item ID not found in data")
    return(list(
      argument_text = "Product not found",
      improvement_text = "",
      weakness_text = "",
      changing_text = "",
      selected_product = NULL
    ))
  }
  
  # Get numeric columns, excluding specified variables
  key_cols <- c("item_id", "brand", "product_line_id", "platform_id")
  exclude_all <- c(key_cols, exclude_vars)
  
  numeric_data <- sub_sa %>% 
    dplyr::select(-dplyr::any_of(exclude_all)) %>%
    dplyr::select_if(is.numeric)
  
  if (ncol(numeric_data) == 0) {
    return(list(
      argument_text = "No numeric data available",
      improvement_text = "",
      weakness_text = "",
      changing_text = "",
      selected_product = sub_sa
    ))
  }
  
  # Calculate sums for key factors and non-key factors
  key_factors_present <- intersect(key_factors, names(numeric_data))
  non_key_factors <- setdiff(names(numeric_data), key_factors_present)
  
  if (length(key_factors_present) > 0) {
    sub_dir <- colSums(numeric_data %>% dplyr::select(dplyr::all_of(key_factors_present)), na.rm = TRUE)
    key_mean <- mean(sub_dir, na.rm = TRUE)
  } else {
    sub_dir <- numeric()
    key_mean <- 0
  }
  
  if (length(non_key_factors) > 0) {
    sub_dir_not_key <- colSums(numeric_data %>% dplyr::select(dplyr::all_of(non_key_factors)), na.rm = TRUE)
    non_key_mean <- mean(sub_dir_not_key, na.rm = TRUE)
  } else {
    sub_dir_not_key <- numeric()
    non_key_mean <- 0
  }
  
  # Generate strategy texts
  argument_factors <- names(sub_dir[sub_dir > key_mean])
  improvement_factors <- names(sub_dir_not_key[sub_dir_not_key > non_key_mean])
  weakness_factors <- names(sub_dir_not_key[sub_dir_not_key <= non_key_mean])
  changing_factors <- names(sub_dir[sub_dir <= key_mean])
  
  # Format the strategy texts
  argument_text <- format_keys(argument_factors)
  improvement_text <- format_keys(improvement_factors)
  weakness_text <- format_keys(weakness_factors)
  changing_text <- format_keys(changing_factors)
  
  return(list(
    argument_text = argument_text,
    improvement_text = improvement_text,
    weakness_text = weakness_text,
    changing_text = changing_text,
    selected_product = sub_sa,
    key_factors_used = key_factors_present,
    non_key_factors_used = non_key_factors
  ))
}

# Filter UI -------------------------------------------------------------------
#' positionStrategyFilterUI
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param translate Function. Translation function for UI text elements (defaults to identity function).
#'        Should accept a string and return a translated string.
#' @return shiny.tag. A Shiny UI component containing the filter controls for the Strategy component.
positionStrategyFilterUI <- function(id, translate = identity) {
  ns <- NS(id)
  
  wellPanel(
    style = "padding:15px;",
    h4(translate("Strategy Analysis Settings")),
    
    # Product selection
    selectizeInput(
      inputId = ns("selected_item_id"),
      label = translate("Select Product (Item ID)"),
      choices = NULL,
      options = list(
        placeholder = translate("Choose a product..."),
        maxOptions = 1000
      )
    ),
    
    # Hide visualization settings with CSS
    tags$style(HTML(paste0("
      #", ns("visualization_settings"), " { display: none; }
    "))),
    
    # Hidden visualization options (keep for functionality but hide visually)
    div(id = ns("visualization_settings"),
        hr(),
        h4(translate("Visualization Options")),
        
        # Font size controls
        sliderInput(
          inputId = ns("base_font_size"),
          label = translate("Base Font Size"),
          min = 10,
          max = 30,
          value = 16,
          step = 2
        ),
        
        # Quadrant labels language
        radioButtons(
          inputId = ns("label_language"),
          label = translate("Quadrant Labels"),
          choices = c(
            "Chinese" = "zh",
            "English" = "en"
          ),
          selected = "zh",
          inline = TRUE
        ),
        
        # Reset button
        actionButton(
          inputId = ns("reset_filters"),
          label = translate("Reset Settings"),
          class = "btn-outline-secondary btn-block mt-3"
        )
    ),
    
    # AI Analysis Options
    hr(),
    h4(translate("AI Strategy Analysis")),
    
    # Generate analysis button
    actionButton(
      inputId = ns("generate_analysis"),
      label = translate("Generate Strategy Analysis"),
      class = "btn-primary btn-block mt-2",
      icon = icon("brain")
    ),
    
    hr(),
    textOutput(ns("component_status"))
  )
}

# Display UI ------------------------------------------------------------------
#' positionStrategyDisplayUI
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param translate Function. Translation function for UI text elements (defaults to identity function).
#' @return shiny.tag. A Shiny UI component containing the display elements for the Strategy component.
positionStrategyDisplayUI <- function(id, translate = identity) {
  ns <- NS(id)
  
  tagList(
    div(class = "component-header mb-3 text-center",
        h3(translate("Strategic Position Analysis")),
        p(translate("Four-quadrant strategy visualization based on key factor performance"))),
    
    # Strategy Matrix (first, without title)
    div(class = "strategy-visualization mb-4",
        plotlyOutput(ns("strategy_plot"), height = "600px")),
    
    # Selected Product Info (second)
    div(class = "strategy-summary mb-4",
        h5(translate("Selected Product:")),
        verbatimTextOutput(ns("selected_product_info"))),
    
    # AI Strategy Analysis Results (last, without extra titles)
    div(class = "ai-strategy-output mb-4",
        h4(translate("AI Strategy Analysis Results")),
        div(class = "card",
            div(class = "card-body",
                div(id = ns("strategy_analysis_content"),
                    style = "min-height: 200px;",
                    if (requireNamespace("shinycssloaders", quietly = TRUE)) {
                      shinycssloaders::withSpinner(
                        htmlOutput(ns("strategy_analysis_output")),
                        type = 6,
                        color = "#0d6efd"
                      )
                    } else {
                      htmlOutput(ns("strategy_analysis_output"))
                    }
                )
            )
        )
    )
  )
}

# Server ----------------------------------------------------------------------
#' positionStrategyServer
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param app_data_connection Database connection object or list. Any connection type supported by tbl2.
#'        Can be a DBI connection, a list with getter functions, a file path, or NULL if no database access is needed.
#' @param config List or reactive expression. Optional configuration settings that can customize behavior.
#'        If reactive, will be re-evaluated when dependencies change.
#' @param session Shiny session object. The current Shiny session (defaults to getDefaultReactiveDomain()).
#' @return list. A list of reactive values providing access to component state and data.
positionStrategyServer <- function(id, app_data_connection = NULL, config = NULL,
                                  session = getDefaultReactiveDomain()) {
  moduleServer(id, function(input, output, session) {
    
    # ------------ Get OpenAI API key from app_configs --------------
    gpt_key <- if (exists("app_configs") && !is.null(app_configs$OPENAI_API_KEY)) {
      key <- app_configs$OPENAI_API_KEY
      # Basic validation of API key format
      if (!grepl("^sk-", key)) {
        warning("OpenAI API key format appears incorrect. Should start with 'sk-'")
      }
      key
    } else {
      warning("OpenAI API key not found in app_configs. AI analysis features will be disabled.")
      NULL
    }
    
    # ------------ Status tracking ----------------------------------
    component_status <- reactiveVal("idle")
    ai_analysis_result <- reactiveVal(NULL)
    
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
      component_status("loading")
      
      prod_line <- product_line_id()
      
      result <- tryCatch({
        if (is.null(app_data_connection)) {
          warning("No valid database connection available")
          return(data.frame())
        }
        
        # Use complete case function to get position data with type filtering (Strategy needs Ideal row for key factors)
        filtered_data <- fn_get_position_complete_case(
          app_data_connection = app_data_connection,
          product_line_id = prod_line,
          include_special_rows = TRUE,  # Strategy analysis needs Ideal row for key factors
          apply_type_filter = TRUE
        )
        
        component_status("ready")
        return(filtered_data)
      }, error = function(e) {
        warning("Error fetching position data: ", e$message)
        component_status("error")
        data.frame()
      })
      
      return(result)
    })
    
    # ------------ Key Factors (from KFE analysis) -------------------
    key_factors <- reactive({
      data <- position_data()
      if (is.null(data) || nrow(data) == 0) return(character(0))
      
      # Simple key factor identification (reuse logic from KFE component)
      # This could be extracted into a shared utility function
      
      # Check if item_id column exists, if not try to find platform-specific column
      if (!"item_id" %in% names(data)) {
        platform <- platform_id()
        item_col <- switch(platform,
          "2" = "asin",  # Amazon
          "3" = "ebay_item_number",  # eBay
          "item_id"  # Default fallback
        )
        
        if (item_col %in% names(data)) {
          data <- data %>% dplyr::rename(item_id = !!sym(item_col))
        } else {
          warning("No item identifier column found in key_factors data")
          return(character(0))
        }
      }
      
      # First ensure item_id column is character type to avoid comparison issues
      data <- data %>%
        dplyr::mutate(item_id = as.character(item_id))
      
      # First filter for special rows and extract Ideal row
      df_analysis <- data %>%
        dplyr::filter(!item_id %in% c("Rating", "Revenue"))
      
      # Extract Ideal row if it exists
      ideal_row <- df_analysis %>% dplyr::filter(item_id == "Ideal")
      
      if (nrow(ideal_row) == 0) {
        return(character(0))
      }
      
      # Now remove excluded variables including item_id and brand
      exclude_vars <- c("product_line_id", "platform_id", "rating", "sales", "revenue", "item_id", "brand")
      df_analysis <- df_analysis %>% dplyr::select(-dplyr::any_of(exclude_vars))
      ideal_row <- ideal_row %>% dplyr::select(-dplyr::any_of(exclude_vars))
      
      # Get numeric columns for analysis
      numeric_cols <- df_analysis %>% 
        dplyr::select_if(is.numeric) %>%
        names()
      
      if (length(numeric_cols) == 0) {
        return(character(0))
      }
      
      # Simple key factor identification based on ideal values
      key_factors <- character(0)
      for (col in numeric_cols) {
        ideal_val <- ideal_row[[col]][1]
        if (!is.na(ideal_val) && is.numeric(ideal_val) && is.finite(ideal_val) && ideal_val > 0) {
          key_factors <- c(key_factors, col)
        }
      }
      
      return(key_factors)
    })
    
    # ------------ Update Item ID choices ----------------------------
    observe({
      data <- position_data()
      # MP035: Null Special Treatment - Handle NA and NULL values safely
      if (is.null(data)) {
        updateSelectizeInput(session, "selected_item_id", choices = character(0))
        return()
      }
      
      # Safe nrow check - handle potential NA values
      n_rows <- tryCatch(nrow(data), error = function(e) NA)
      if (is.na(n_rows) || n_rows == 0) {
        updateSelectizeInput(session, "selected_item_id", choices = character(0))
        return()
      }
      
      # Debug: Check what columns are available
      message("DEBUG: Available columns in position_data: ", paste(names(data), collapse = ", "))
      
      # Check if item_id column exists, if not try to find platform-specific column
      if (!"item_id" %in% names(data)) {
        # Try to find platform-specific column
        platform <- platform_id()
        item_col <- switch(platform,
          "2" = "asin",  # Amazon
          "3" = "ebay_item_number",  # eBay
          "item_id"  # Default fallback
        )
        
        if (item_col %in% names(data)) {
          message("DEBUG: Using platform-specific column '", item_col, "' and renaming to 'item_id'")
          data <- data %>% dplyr::rename(item_id = !!sym(item_col))
        } else {
          warning("No item identifier column found in data. Available columns: ", paste(names(data), collapse = ", "))
          updateSelectizeInput(session, "selected_item_id", choices = character(0))
          return()
        }
      }
      
      # Get available Item IDs (excluding special rows)
      available_item_ids <- data %>%
        dplyr::mutate(item_id = as.character(item_id)) %>%
        dplyr::filter(!item_id %in% c("Ideal", "Rating", "Revenue")) %>%
        dplyr::select(item_id, brand) %>%
        dplyr::distinct() %>%
        dplyr::arrange(brand, item_id)
      
      if (nrow(available_item_ids) > 0) {
        # Create named vector for choices
        choices <- setNames(available_item_ids$item_id, paste0(available_item_ids$brand, " (", available_item_ids$item_id, ")"))
        updateSelectizeInput(session, "selected_item_id", choices = choices)
      }
    })
    
    # ------------ Strategy Analysis -----------------------------------
    strategy_result <- reactive({
      data <- position_data()
      selected <- input$selected_item_id %||% ""
      key_fac <- key_factors()
      
      if (is.null(data) || nrow(data) == 0 || selected == "") {
        return(NULL)
      }
      
      component_status("computing")
      
      # Define variables to exclude from analysis
      exclude_vars <- c("product_line_id", "platform_id", "rating", "sales", "revenue")
      
      result <- perform_strategy_analysis(
        data = data,
        selected_item_id = selected,
        key_factors = key_fac,
        exclude_vars = exclude_vars
      )
      
      component_status("ready")
      return(result)
    })
    
    # ------------ Reset filters ------------------------------------
    observeEvent(input$reset_filters, {
      updateSliderInput(session, "base_font_size", value = 16)
      updateRadioButtons(session, "label_language", selected = "zh")
      
      message("Strategy settings reset")
    })
    
    # ------------ AI Strategy Analysis ----------------------------
    observeEvent(input$generate_analysis, {
      data <- position_data()
      selected_item_id <- input$selected_item_id
      
      if (is.null(data) || nrow(data) == 0) {
        showNotification("No data available for analysis", type = "warning")
        return()
      }
      
      if (is.null(selected_item_id) || selected_item_id == "") {
        showNotification("Please select a product first", type = "warning")
        return()
      }
      
      if (is.null(gpt_key)) {
        showNotification("OpenAI API key not configured. AI analysis features are disabled.", type = "error")
        return()
      }
      
      withProgress(message = "Generating strategy analysis for selected product...", value = 0, {
        incProgress(0.2, detail = "Preparing data...")
        
        # Get the current strategy result for the four-quadrant analysis
        current_strategy <- strategy_result()
        
        if (is.null(current_strategy)) {
          showNotification("Please select a product to see strategy analysis", type = "warning")
          return()
        }
        
        incProgress(0.4, detail = "Analyzing four-quadrant strategy...")
        
        # Prepare the four-quadrant data
        quadrant_data <- list(
          product_info = list(
            item_id = selected_item_id,
            brand = if (!is.null(current_strategy$selected_product) && "brand" %in% names(current_strategy$selected_product)) {
              current_strategy$selected_product$brand[1]
            } else "Unknown"
          ),
          strategy_analysis = list(
            argument_factors = current_strategy$argument_text,      # 訴求 - 可以強調的優勢
            improvement_factors = current_strategy$improvement_text, # 改善 - 可以改善的地方
            weakness_factors = current_strategy$weakness_text,      # 劣勢 - 需要解決的弱點
            changing_factors = current_strategy$changing_text       # 改變 - 需要調整的關鍵因素
          )
        )
        
        # Convert to JSON for GPT analysis (fix jsonlite warning by using named list instead of named vector)
        strategy_txt <- jsonlite::toJSON(quadrant_data, dataframe = "rows", auto_unbox = TRUE, 
                                        keep_vec_names = FALSE)
        
        incProgress(0.6, detail = "Calling AI analysis...")
        
        # Create prompt based on four-quadrant strategy analysis
        sys <- list(role = "system", content = "You are a professional marketing strategist. Please respond in Traditional Chinese.")
        usr <- list(
          role = "user",
          content = paste0(
            "根據四象限策略分析結果，為該產品提供具體的行銷策略建議。請使用以下 markdown 架構，但**只顯示該產品實際有因素的部分**：",
            "\n\n## 產品策略分析",
            "\n\n### 訴求策略",
            "\n（僅當 argument_factors 有內容時顯示此部分）",
            "\n基於該產品的優勢因素，建議如何在行銷中突出這些優勢。",
            "\n\n### 改善策略", 
            "\n（僅當 improvement_factors 有內容時顯示此部分）",
            "\n基於可改善因素，提出產品優化方向。",
            "\n\n### 劣勢應對",
            "\n（僅當 weakness_factors 有內容時顯示此部分）",
            "\n基於弱勢因素，建議如何在行銷中減少負面影響。",
            "\n\n### 關鍵調整",
            "\n（僅當 changing_factors 有內容時顯示此部分）",
            "\n基於需要改變的因素，提出重點改進建議。",
            "\n\n**重要規則**：",
            "\n- 如果某個象限沒有因素（空白或無內容），請完全跳過該部分的標題和內容",
            "\n- 針對具體的因素變數提供實用的策略建議和廣告文案方向",
            "\n- 保持 markdown 格式，不要用程式碼區塊包起來",
            "\n- 字數限制300字內",
            "\n\n四象限分析資料：", strategy_txt
          )
        )
        
        incProgress(0.8, detail = "Processing AI response...")
        
        txt <- chat_api(list(sys, usr), gpt_key)
        
        incProgress(0.9, detail = "Finalizing results...")
        
        ai_analysis_result(txt)
        
        incProgress(1.0, detail = "Analysis complete!")
      })
    })
    
    # ------------ Output Rendering ------------------------------------
    
    # AI Strategy Analysis Output
    output$strategy_analysis_output <- renderUI({
      txt <- ai_analysis_result()
      
      if (is.null(txt)) {
        return(HTML("<i style='color:gray;'>Click 'Generate Strategy Analysis' to create comprehensive brand strategy recommendations based on positioning data.</i>"))
      }
      
      # Clean the text and convert to HTML
      res <- strip_code_fence(txt)
      if (requireNamespace("markdown", quietly = TRUE)) {
        html <- markdown::markdownToHTML(text = res, fragment.only = TRUE)
        HTML(html)
      } else {
        # Fallback: return text wrapped in <p> tags
        HTML(paste0("<p>", gsub("\n", "</p><p>", res), "</p>"))
      }
    })
    
    output$selected_product_info <- renderText({
      result <- strategy_result()
      
      if (is.null(result) || is.null(result$selected_product)) {
        return("No product selected or product not found")
      }
      
      product <- result$selected_product
      brand <- if ("brand" %in% names(product)) product$brand[1] else "Unknown"
      item_id <- if ("item_id" %in% names(product)) product$item_id[1] else "Unknown"
      
      paste0("Brand: ", brand, "\nItem ID: ", item_id, "\nKey Factors Available: ", length(result$key_factors_used))
    })
    
    # Render the strategy plot
    output$strategy_plot <- renderPlotly({
      result <- strategy_result()
      
      if (is.null(result)) {
        # Return empty plot with message
        return(plot_ly() %>%
          add_annotations(
            text = "Please select a product to view strategy analysis",
            x = 0.5, y = 0.5,
            xref = "paper", yref = "paper",
            showarrow = FALSE,
            font = list(size = 16)
          ) %>%
          layout(xaxis = list(visible = FALSE), yaxis = list(visible = FALSE)) %>%
          plotly::config(
            displayModeBar = FALSE,  # Hide the toolbar completely
            displaylogo = FALSE,     # Hide plotly logo
            scrollZoom = FALSE,      # Disable scroll zoom
            doubleClick = FALSE      # Disable double click zoom
          ))
      }
      
      # Get quadrant labels based on language selection
      labels <- if (input$label_language == "zh") {
        c("訴求", "改善", "劣勢", "改變")
      } else {
        c("Argument", "Improvement", "Weakness", "Change")
      }
      
      # Get font size - make it larger for better visibility
      base_size <- (input$base_font_size %||% 16) + 4  # Increase base size
      
      # Calculate dynamic font sizes for each text - use larger minimum size
      argument_size <- calculate_dynamic_font_size(result$argument_text, base_size, min_size = 14, max_size = 28)
      improvement_size <- calculate_dynamic_font_size(result$improvement_text, base_size, min_size = 14, max_size = 28)
      weakness_size <- calculate_dynamic_font_size(result$weakness_text, base_size, min_size = 14, max_size = 28)
      changing_size <- calculate_dynamic_font_size(result$changing_text, base_size, min_size = 14, max_size = 28)
      
      # Create the plot
      p <- plot_ly() %>%
        # Add quadrant labels
        add_trace(
          type = 'scatter', mode = 'text',
          x = c(5, -5, -5, 5), y = c(9, 9, -2, -2),
          text = labels,
          textfont = list(color = "blue", size = base_size + 4),
          showlegend = FALSE,
          hoverinfo = 'none'
        ) %>%
        # Add strategy content
        add_trace(
          type = 'scatter', mode = 'text',
          x = c(5, -5, -5, 5), y = c(5, 5, -7, -7),
          text = c(result$argument_text, result$improvement_text, result$weakness_text, result$changing_text),
          textfont = list(
            size = c(argument_size, improvement_size, weakness_size, changing_size), 
            color = "darkblue"
          ),
          showlegend = FALSE,
          hoverinfo = 'text',
          hovertext = c(
            paste("Argument Factors:", result$argument_text),
            paste("Improvement Areas:", result$improvement_text),
            paste("Weakness Areas:", result$weakness_text),
            paste("Change Needed:", result$changing_text)
          )
        ) %>%
        layout(
          xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE, range = c(-10, 10), fixedrange = TRUE),
          yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE, range = c(-10, 10), fixedrange = TRUE),
          plot_bgcolor = 'white',
          showlegend = FALSE,
          # Add cross-hairs
          shapes = list(
            list(
              type = 'line', x0 = 0, x1 = 0, y0 = -10, y1 = 10,
              line = list(color = "black", width = 2)
            ),
            list(
              type = 'line', x0 = -10, x1 = 10, y0 = 0, y1 = 0,
              line = list(color = "black", width = 2)
            )
          )
        ) %>%
        plotly::config(
          displayModeBar = FALSE,  # Hide the toolbar completely
          displaylogo = FALSE,     # Hide plotly logo
          modeBarButtonsToRemove = c('zoom2d', 'pan2d', 'select2d', 'lasso2d', 'zoomIn2d', 'zoomOut2d', 'autoScale2d', 'resetScale2d'),
          scrollZoom = FALSE,      # Disable scroll zoom
          doubleClick = FALSE      # Disable double click zoom
        )
      
      return(p)
    })
    
    # Display component status
    output$component_status <- renderText({
      prod_line <- product_line_id()
      status_prefix <- if (prod_line == "all") "All product lines - " else paste0("Product line ", prod_line, " - ")
      
      switch(component_status(),
             idle = paste0(status_prefix, "Ready for strategy analysis"),
             loading = paste0(status_prefix, "Loading position data..."),
             ready = paste0(status_prefix, "Analysis ready - ", length(key_factors()), " key factors identified"),
             computing = paste0(status_prefix, "Computing strategy analysis..."),
             error = paste0(status_prefix, "Error in strategy analysis"),
             paste0(status_prefix, component_status()))
    })
    
    # Return reactive values for external use
    return(list(
      position_data = position_data,
      strategy_result = strategy_result,
      key_factors = key_factors,
      component_status = component_status,
      ai_analysis_result = ai_analysis_result
    ))
  })
}

# Component wrapper -----------------------------------------------------------
#' positionStrategyComponent
#' 
#' Implements a strategic position analysis component 
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
#' strategyComp <- positionStrategyComponent("strategy_analysis")
#' 
#' # Usage with database connection
#' strategyComp <- positionStrategyComponent(
#'   id = "strategy_analysis",
#'   app_data_connection = app_conn, 
#'   config = list(platform_id = "amz")
#' )
#'
#' # Usage with reactive configuration
#' strategyComp <- positionStrategyComponent(
#'   id = "strategy_analysis",
#'   app_data_connection = app_conn,
#'   config = reactive({ list(filters = list(platform_id = input$platform)) })
#' )
#' @export
positionStrategyComponent <- function(id, app_data_connection = NULL, config = NULL, translate = identity) {
  list(
    ui = list(filter = positionStrategyFilterUI(id, translate),
              display = positionStrategyDisplayUI(id, translate)),
    server = function(input, output, session) {
      positionStrategyServer(id, app_data_connection, config, session)
    }
  )
}