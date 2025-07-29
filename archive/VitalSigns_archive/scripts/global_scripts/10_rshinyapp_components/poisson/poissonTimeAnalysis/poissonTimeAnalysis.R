#LOCK FILE
#
# poissonTimeAnalysis.R
#
# Following principles:
# - MP56: Connected Component Principle (component structure)
# - MP73: Interactive Visualization Preference (DT and plotly for visualizations)
# - MP81: Explicit Parameter Specification (function arguments)
# - R116: Enhanced Data Access with tbl2 (data access)
# - R09: UI-Server-Defaults Triple (component organization)
# - MP88: Immediate Feedback (real-time filtering without Apply button)
#
# Features:
#   • Time dimension Poisson regression analysis display
#   • Year, month, day, weekday effects visualization
#   • Incidence Rate Ratio (IRR) interpretation
#   • Confidence intervals and significance testing
#   • Product line filtering and comparison
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

# Filter UI -------------------------------------------------------------------
#' poissonTimeAnalysisFilterUI
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param translate Function. Translation function for UI text elements (defaults to identity function).
#'        Should accept a string and return a translated string.
#' @return shiny.tag. A Shiny UI component containing the filter controls for the time analysis component.
poissonTimeAnalysisFilterUI <- function(id, translate = identity) {
  ns <- NS(id)
  
  wellPanel(
    style = "padding:15px;",
    h4(translate("時間區段分析篩選")),
    
    # Time dimension filter
    checkboxGroupInput(
      inputId = ns("time_dimensions"),
      label = translate("時間維度"),
      choices = list(
        "年度效應" = "year",
        "月份季節性" = "monthly",
        "日期效應" = "day", 
        "星期效應" = "weekday"
      ),
      selected = c("year", "monthly", "day", "weekday")
    ),
    
    # Significance filter
    checkboxInput(
      inputId = ns("show_significant_only"),
      label = translate("只顯示顯著結果 (p<0.05)"),
      value = FALSE
    ),
    
    # Display options
    hr(),
    h4(translate("顯示選項")),
    
    # Chart type
    radioButtons(
      inputId = ns("chart_type"),
      label = translate("圖表類型"),
      choices = list(
        "係數圖" = "coefficient",
        "發生率比圖" = "irr",
        "信賴區間圖" = "confidence"
      ),
      selected = "irr"
    ),
    
    # Reset button
    actionButton(
      inputId = ns("reset_filters"),
      label = translate("重置篩選"),
      class = "btn-outline-secondary btn-block mt-3"
    ),
    
    hr(),
    textOutput(ns("component_status"))
  )
}

# Display UI ------------------------------------------------------------------
#' poissonTimeAnalysisDisplayUI
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param translate Function. Translation function for UI text elements (defaults to identity function).
#' @return shiny.tag. A Shiny UI component containing the display elements for the time analysis.
poissonTimeAnalysisDisplayUI <- function(id, translate = identity) {
  ns <- NS(id)
  
  tagList(
    div(class = "component-header mb-3 text-center",
        h3(translate("時間區段分析")),
        p(translate("分析時間因素對銷售的影響：年度趨勢、季節性、週期性效應"))),
    
    # Summary cards row
    fluidRow(
      column(3,
        div(class = "info-box bg-primary",
            div(class = "info-box-content",
                h4(textOutput(ns("total_analyses")), class = "text-white"),
                p(translate("總分析數"), class = "text-white")))),
      column(3,
        div(class = "info-box bg-success", 
            div(class = "info-box-content",
                h4(textOutput(ns("significant_count")), class = "text-white"),
                p(translate("顯著結果"), class = "text-white")))),
      column(3,
        div(class = "info-box bg-warning",
            div(class = "info-box-content",
                h4(textOutput(ns("strongest_effect")), class = "text-white"),
                p(translate("最強效應"), class = "text-white")))),
      column(3,
        div(class = "info-box bg-info",
            div(class = "info-box-content",
                h4(textOutput(ns("product_line_count")), class = "text-white"),
                p(translate("產品線數"), class = "text-white"))))
    ),
    
    # Main visualization
    div(class = "component-output p-3",
        tabsetPanel(
          id = ns("analysis_tabs"),
          
          # Time effects overview
          tabPanel(
            title = translate("時間效應總覽"),
            value = "overview",
            br(),
            plotly::plotlyOutput(ns("time_effects_plot"), height = "500px")
          ),
          
          # Seasonal analysis
          tabPanel(
            title = translate("季節性分析"),
            value = "seasonal", 
            br(),
            fluidRow(
              column(6, plotly::plotlyOutput(ns("monthly_effects_plot"), height = "400px")),
              column(6, plotly::plotlyOutput(ns("weekday_effects_plot"), height = "400px"))
            )
          ),
          
          # Detailed table
          tabPanel(
            title = translate("詳細數據"),
            value = "table",
            br(),
            DTOutput(ns("time_analysis_table"), width = "100%")
          ),
          
          # Model diagnostics
          tabPanel(
            title = translate("模型診斷"),
            value = "diagnostics",
            br(),
            fluidRow(
              column(6, plotly::plotlyOutput(ns("aic_distribution_plot"), height = "400px")),
              column(6, plotly::plotlyOutput(ns("convergence_status_plot"), height = "400px"))
            )
          )
        ))
  )
}

# Server ----------------------------------------------------------------------
#' poissonTimeAnalysisServer
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param app_data_connection Database connection object or list. Any connection type supported by tbl2.
#'        Can be a DBI connection, a list with getter functions, a file path, or NULL if no database access is needed.
#' @param config List or reactive expression. Optional configuration settings that can customize behavior.
#'        If reactive, will be re-evaluated when dependencies change.
#' @param session Shiny session object. The current Shiny session (defaults to getDefaultReactiveDomain()).
#' @return list. A list of reactive values providing access to component state and data.
poissonTimeAnalysisServer <- function(id, app_data_connection = NULL, config = NULL,
                                     session = getDefaultReactiveDomain()) {
  moduleServer(id, function(input, output, session) {
    
    # ------------ Status tracking ----------------------------------
    component_status <- reactiveVal("idle")
    
    # ------------ Extract configuration parameters -----------------
    platform_id <- reactive({
      tryCatch({
        if (is.null(config)) return("cbz")
        
        if (is.function(config)) {
          if (shiny::is.reactive(config) || "reactive" %in% class(config)) {
            cfg <- config()
          } else {
            cfg <- config
          }
        } else {
          cfg <- config
        }
        
        if (!is.null(cfg)) {
          if (!is.null(cfg[["filters"]]) && !is.null(cfg[["filters"]][["platform_id"]])) {
            return(as.character(cfg[["filters"]][["platform_id"]]))
          }
          if (!is.null(cfg[["platform_id"]])) {
            return(as.character(cfg[["platform_id"]]))
          }
        }
        
        "cbz"  # Default platform
      }, error = function(e) {
        warning("Error extracting platform_id: ", e$message)
        "cbz"
      })
    })
    
    product_line_id <- reactive({
      tryCatch({
        if (is.null(config)) return("all")
        
        if (is.function(config)) {
          if (shiny::is.reactive(config) || "reactive" %in% class(config)) {
            cfg <- config()
          } else {
            cfg <- config
          }
        } else {
          cfg <- config
        }
        
        if (!is.null(cfg)) {
          if (!is.null(cfg[["filters"]]) && !is.null(cfg[["filters"]][["product_line_id"]])) {
            return(as.character(cfg[["filters"]][["product_line_id"]]))
          }
          if (!is.null(cfg[["product_line_id"]])) {
            return(as.character(cfg[["product_line_id"]]))
          }
        }
        
        "all"  # Default product line
      }, error = function(e) {
        warning("Error extracting product_line_id: ", e$message)
        "all"
      })
    })
    
    # ------------ Data access (R116) -----------------------------------
    poisson_data <- reactive({
      component_status("loading")
      
      result <- tryCatch({
        if (is.null(app_data_connection)) {
          warning("No valid database connection available")
          return(data.frame())
        }
        
        # Get platform
        platform <- platform_id()
        
        # Access Poisson analysis results using tbl2
        table_name <- paste0("df_", platform, "_poisson_analysis_all")
        tbl <- tbl2(app_data_connection, table_name)
        
        # Filter for time features only
        time_data <- tbl %>% 
          dplyr::filter(predictor_type == "time_feature") %>%
          collect()
        
        component_status("ready")
        return(time_data)
        
      }, error = function(e) {
        warning("Error fetching Poisson data: ", e$message)
        component_status("error")
        data.frame()
      })
      
      return(result)
    })
    
    # ------------ Filter Options -----------------------------------------
    # No additional filter options needed - platform and product line come from config
    
    # ------------ Filtered Data ----------------------------------------
    filtered_data <- reactive({
      data <- poisson_data()
      
      if (is.null(data) || nrow(data) == 0) return(data.frame())
      
      # Filter by product line from config
      current_product_line <- product_line_id()
      if (!is.null(current_product_line) && current_product_line != "all") {
        data <- data %>% dplyr::filter(product_line_id == current_product_line)
      }
      
      # Filter by time dimensions
      if (length(input$time_dimensions) > 0) {
        time_filters <- character()
        
        if ("year" %in% input$time_dimensions) {
          time_filters <- c(time_filters, "year")
        }
        if ("monthly" %in% input$time_dimensions) {
          time_filters <- c(time_filters, paste0("month_", 1:12))
        }
        if ("day" %in% input$time_dimensions) {
          time_filters <- c(time_filters, "day")
        }
        if ("weekday" %in% input$time_dimensions) {
          time_filters <- c(time_filters, "monday", "tuesday", "wednesday", 
                           "thursday", "friday", "saturday", "sunday")
        }
        
        data <- data %>% dplyr::filter(predictor %in% time_filters)
      }
      
      # Filter by significance
      if (input$show_significant_only) {
        data <- data %>% 
          dplyr::filter(!is.na(p_value) & p_value < 0.05 & convergence == "converged")
      }
      
      return(data)
    })
    
    # ------------ Summary Statistics --------------------------------
    output$total_analyses <- renderText({
      data <- filtered_data()
      if (nrow(data) == 0) return("0")
      formatC(nrow(data), format = "d", big.mark = ",")
    })
    
    output$significant_count <- renderText({
      data <- filtered_data()
      if (nrow(data) == 0) return("0")
      sig_count <- sum(!is.na(data$p_value) & data$p_value < 0.05 & data$convergence == "converged", na.rm = TRUE)
      formatC(sig_count, format = "d", big.mark = ",")
    })
    
    output$strongest_effect <- renderText({
      data <- filtered_data()
      if (nrow(data) == 0) return("--")
      
      # Find strongest significant effect (highest absolute IRR deviation from 1)
      sig_data <- data %>% 
        dplyr::filter(!is.na(incidence_rate_ratio) & !is.na(p_value) & p_value < 0.05) %>%
        dplyr::mutate(irr_deviation = abs(log(incidence_rate_ratio))) %>%
        dplyr::arrange(desc(irr_deviation))
      
      if (nrow(sig_data) == 0) return("無顯著")
      
      strongest <- sig_data[1, ]
      paste0(strongest$predictor, " (", round(strongest$incidence_rate_ratio, 2), "×)")
    })
    
    output$product_line_count <- renderText({
      data <- filtered_data()
      if (nrow(data) == 0) return("0")
      length(unique(data$product_line_id))
    })
    
    # ------------ Visualizations ------------------------------------
    
    # Time effects overview plot
    output$time_effects_plot <- plotly::renderPlotly({
      data <- filtered_data()
      
      if (nrow(data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No data available"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      # Prepare data for plotting
      plot_data <- data %>%
        dplyr::filter(!is.na(incidence_rate_ratio) & convergence == "converged") %>%
        dplyr::mutate(
          is_significant = !is.na(p_value) & p_value < 0.05,
          predictor_clean = case_when(
            predictor == "year" ~ "年度",
            grepl("^month_", predictor) ~ paste0("月份", gsub("month_", "", predictor)),
            predictor == "day" ~ "日期",
            predictor %in% c("monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday") ~ 
              recode(predictor, "monday" = "週一", "tuesday" = "週二", "wednesday" = "週三",
                     "thursday" = "週四", "friday" = "週五", "saturday" = "週六", "sunday" = "週日"),
            TRUE ~ predictor
          )
        )
      
      # Choose y-axis based on chart type
      y_var <- switch(input$chart_type,
                     "coefficient" = "coefficient",
                     "irr" = "incidence_rate_ratio", 
                     "confidence" = "incidence_rate_ratio")
      
      p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = predictor_clean, y = .data[[y_var]], 
                                                  color = product_line_id, shape = is_significant)) +
        ggplot2::geom_point(size = 3, alpha = 0.7) +
        ggplot2::theme_minimal() +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)) +
        ggplot2::labs(
          title = "時間因素效應分析",
          x = "時間維度",
          y = switch(input$chart_type,
                    "coefficient" = "回歸係數",
                    "irr" = "發生率比 (IRR)",
                    "confidence" = "發生率比 (IRR)"),
          color = "產品線",
          shape = "顯著性 (p<0.05)"
        ) +
        ggplot2::scale_shape_manual(values = c(1, 16), labels = c("否", "是"))
      
      # Add reference lines
      if (input$chart_type == "coefficient") {
        p <- p + ggplot2::geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.5)
      } else {
        p <- p + ggplot2::geom_hline(yintercept = 1, linetype = "dashed", alpha = 0.5)
      }
      
      # Add confidence intervals for confidence chart
      if (input$chart_type == "confidence") {
        p <- p + ggplot2::geom_errorbar(ggplot2::aes(ymin = irr_conf_low, ymax = irr_conf_high), 
                                       width = 0.2, alpha = 0.6)
      }
      
      plotly::ggplotly(p, tooltip = c("x", "y", "colour", "shape"))
    })
    
    # Monthly effects plot
    output$monthly_effects_plot <- plotly::renderPlotly({
      data <- filtered_data()
      
      if (nrow(data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No data available"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      # Filter for monthly data
      monthly_data <- data %>%
        dplyr::filter(grepl("^month_", predictor) & !is.na(incidence_rate_ratio) & convergence == "converged") %>%
        dplyr::mutate(
          month_num = as.numeric(gsub("month_", "", predictor)),
          month_name = month.abb[month_num],
          is_significant = !is.na(p_value) & p_value < 0.05
        ) %>%
        dplyr::arrange(month_num)
      
      if (nrow(monthly_data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No monthly data"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      p <- ggplot2::ggplot(monthly_data, ggplot2::aes(x = factor(month_num), y = incidence_rate_ratio,
                                                     color = product_line_id, shape = is_significant)) +
        ggplot2::geom_point(size = 3, alpha = 0.7) +
        ggplot2::geom_line(ggplot2::aes(group = product_line_id), alpha = 0.5) +
        ggplot2::geom_hline(yintercept = 1, linetype = "dashed", alpha = 0.5) +
        ggplot2::theme_minimal() +
        ggplot2::labs(
          title = "月份季節性效應",
          x = "月份",
          y = "發生率比 (IRR)",
          color = "產品線",
          shape = "顯著性"
        ) +
        ggplot2::scale_x_discrete(labels = month.abb) +
        ggplot2::scale_shape_manual(values = c(1, 16), labels = c("否", "是"))
      
      plotly::ggplotly(p, tooltip = c("x", "y", "colour", "shape"))
    })
    
    # Weekday effects plot
    output$weekday_effects_plot <- plotly::renderPlotly({
      data <- filtered_data()
      
      if (nrow(data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No data available"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      # Filter for weekday data
      weekdays_order <- c("monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday")
      weekdays_labels <- c("週一", "週二", "週三", "週四", "週五", "週六", "週日")
      
      weekday_data <- data %>%
        dplyr::filter(predictor %in% weekdays_order & !is.na(incidence_rate_ratio) & convergence == "converged") %>%
        dplyr::mutate(
          weekday_num = match(predictor, weekdays_order),
          weekday_name = weekdays_labels[weekday_num],
          is_significant = !is.na(p_value) & p_value < 0.05
        ) %>%
        dplyr::arrange(weekday_num)
      
      if (nrow(weekday_data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No weekday data"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      p <- ggplot2::ggplot(weekday_data, ggplot2::aes(x = factor(weekday_num), y = incidence_rate_ratio,
                                                     color = product_line_id, shape = is_significant)) +
        ggplot2::geom_point(size = 3, alpha = 0.7) +
        ggplot2::geom_line(ggplot2::aes(group = product_line_id), alpha = 0.5) +
        ggplot2::geom_hline(yintercept = 1, linetype = "dashed", alpha = 0.5) +
        ggplot2::theme_minimal() +
        ggplot2::labs(
          title = "星期效應分析",
          x = "星期",
          y = "發生率比 (IRR)",
          color = "產品線",
          shape = "顯著性"
        ) +
        ggplot2::scale_x_discrete(labels = weekdays_labels) +
        ggplot2::scale_shape_manual(values = c(1, 16), labels = c("否", "是"))
      
      plotly::ggplotly(p, tooltip = c("x", "y", "colour", "shape"))
    })
    
    # Detailed table
    output$time_analysis_table <- renderDT({
      data <- filtered_data()
      
      if (nrow(data) == 0) {
        return(data.frame(Message = "無可用資料"))
      }
      
      # Prepare table data
      table_data <- data %>%
        dplyr::filter(convergence == "converged") %>%
        dplyr::select(product_line_id, predictor, coefficient, incidence_rate_ratio, 
                     std_error, p_value, conf_low, conf_high, aic, sample_size) %>%
        dplyr::mutate(
          predictor_chinese = case_when(
            predictor == "year" ~ "年度",
            grepl("^month_", predictor) ~ paste0("月份", gsub("month_", "", predictor)),
            predictor == "day" ~ "日期",
            predictor == "monday" ~ "週一",
            predictor == "tuesday" ~ "週二", 
            predictor == "wednesday" ~ "週三",
            predictor == "thursday" ~ "週四",
            predictor == "friday" ~ "週五",
            predictor == "saturday" ~ "週六",
            predictor == "sunday" ~ "週日",
            TRUE ~ predictor
          ),
          coefficient = round(coefficient, 4),
          incidence_rate_ratio = round(incidence_rate_ratio, 4),
          std_error = round(std_error, 4),
          p_value = round(p_value, 6),
          conf_low = round(conf_low, 4),
          conf_high = round(conf_high, 4),
          significance = ifelse(!is.na(p_value) & p_value < 0.05, "顯著", "不顯著")
        ) %>%
        dplyr::select(product_line_id, predictor_chinese, coefficient, incidence_rate_ratio,
                     std_error, p_value, significance, conf_low, conf_high, aic, sample_size)
      
      # Create column names in Chinese
      colnames(table_data) <- c("產品線", "時間維度", "係數", "發生率比", "標準誤", 
                               "P值", "顯著性", "信賴區間下限", "信賴區間上限", "AIC", "樣本數")
      
      datatable(table_data,
                options = list(
                  pageLength = 15,
                  scrollX = TRUE,
                  dom = 'Bfrtip',
                  buttons = list(
                    list(extend = 'excel', text = '下載Excel', filename = '時間區段分析結果')
                  )
                ),
                extensions = c("Buttons"),
                rownames = FALSE) %>%
        formatStyle("顯著性", 
                   backgroundColor = styleEqual("顯著", "#d4edda"),
                   color = styleEqual("顯著", "#155724"))
    })
    
    # AIC distribution plot
    output$aic_distribution_plot <- plotly::renderPlotly({
      data <- filtered_data()
      
      if (nrow(data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No data available"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      aic_data <- data %>%
        dplyr::filter(!is.na(aic) & convergence == "converged")
      
      if (nrow(aic_data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No AIC data"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      p <- ggplot2::ggplot(aic_data, ggplot2::aes(x = aic, fill = product_line_id)) +
        ggplot2::geom_histogram(bins = 30, alpha = 0.7, position = "identity") +
        ggplot2::theme_minimal() +
        ggplot2::labs(
          title = "AIC 分布 (模型品質指標)",
          x = "AIC 值",
          y = "頻率",
          fill = "產品線"
        )
      
      plotly::ggplotly(p)
    })
    
    # Convergence status plot
    output$convergence_status_plot <- plotly::renderPlotly({
      data <- filtered_data()
      
      if (nrow(data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No data available"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      convergence_data <- data %>%
        dplyr::count(product_line_id, convergence) %>%
        dplyr::mutate(
          convergence_chinese = case_when(
            convergence == "converged" ~ "收斂",
            convergence == "failed" ~ "失敗",
            grepl("error", convergence) ~ "錯誤",
            TRUE ~ "其他"
          )
        )
      
      p <- ggplot2::ggplot(convergence_data, ggplot2::aes(x = product_line_id, y = n, fill = convergence_chinese)) +
        ggplot2::geom_col(position = "stack") +
        ggplot2::theme_minimal() +
        ggplot2::labs(
          title = "模型收斂狀態統計",
          x = "產品線",
          y = "模型數量",
          fill = "收斂狀態"
        ) +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
      
      plotly::ggplotly(p)
    })
    
    # Reset filters
    observeEvent(input$reset_filters, {
      updateCheckboxGroupInput(session, "time_dimensions", 
                             selected = c("year", "monthly", "day", "weekday"))
      updateCheckboxInput(session, "show_significant_only", value = FALSE)
      updateRadioButtons(session, "chart_type", selected = "irr")
    })
    
    # Component status
    output$component_status <- renderText({
      switch(component_status(),
             idle = "準備顯示時間分析",
             loading = "載入分析資料中...",
             ready = paste0("已載入 ", nrow(poisson_data()), " 筆時間分析結果"),
             error = "載入資料時發生錯誤",
             component_status())
    })
    
    # Return reactive values
    return(list(
      poisson_data = poisson_data,
      filtered_data = filtered_data,
      component_status = component_status
    ))
  })
}

# Component wrapper -----------------------------------------------------------
#' poissonTimeAnalysisComponent
#' 
#' Implements a time dimension Poisson analysis component following the Connected Component principle.
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
#' # Basic usage
#' timeComp <- poissonTimeAnalysisComponent("time_analysis")
#' 
#' # Usage with database connection
#' timeComp <- poissonTimeAnalysisComponent(
#'   id = "time_analysis",
#'   app_data_connection = app_conn,
#'   config = list(platform_id = "cbz")
#' )
#' @export
poissonTimeAnalysisComponent <- function(id, app_data_connection = NULL, config = NULL, translate = identity) {
  list(
    ui = list(filter = poissonTimeAnalysisFilterUI(id, translate),
              display = poissonTimeAnalysisDisplayUI(id, translate)),
    server = function(input, output, session) {
      poissonTimeAnalysisServer(id, app_data_connection, config, session)
    }
  )
}