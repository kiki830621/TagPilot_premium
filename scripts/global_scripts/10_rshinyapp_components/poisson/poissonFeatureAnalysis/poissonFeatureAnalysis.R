#LOCK FILE
#
# poissonFeatureAnalysis.R
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
#   • All product attributes Poisson regression analysis
#   • Price effects, brand effects, category effects
#   • Feature importance ranking and comparison
#   • Comprehensive attribute impact visualization
#   • Cross product line attribute comparison
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
#' poissonFeatureAnalysisFilterUI
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param translate Function. Translation function for UI text elements (defaults to identity function).
#'        Should accept a string and return a translated string.
#' @return shiny.tag. A Shiny UI component containing the filter controls for the feature analysis component.
poissonFeatureAnalysisFilterUI <- function(id, translate = identity) {
  ns <- NS(id)
  
  wellPanel(
    style = "padding:15px;",
    h4(translate("精準模型篩選")),
    
    # Feature type filter
    checkboxGroupInput(
      inputId = ns("feature_types"),
      label = translate("特徵類型"),
      choices = list(
        "價格特徵" = "price",
        "品牌特徵" = "brand", 
        "數值特徵" = "numeric",
        "類別特徵" = "factor",
        "定位特徵" = "positioning"
      ),
      selected = c("price", "brand", "numeric", "factor", "positioning")
    ),
    
    # Significance filter
    checkboxInput(
      inputId = ns("show_significant_only"),
      label = translate("只顯示顯著結果 (p<0.05)"),
      value = FALSE
    ),
    
    # Top N filter
    numericInput(
      inputId = ns("top_n_features"),
      label = translate("顯示前N個重要特徵"),
      value = 20,
      min = 5,
      max = 100,
      step = 5
    ),
    
    # Display options
    hr(),
    h4(translate("顯示選項")),
    
    # Sort by
    selectInput(
      inputId = ns("sort_by"),
      label = translate("排序依據"),
      choices = list(
        "P值 (顯著性)" = "p_value",
        "發生率比大小" = "irr_magnitude",
        "係數絕對值" = "coefficient_abs",
        "AIC值" = "aic"
      ),
      selected = "p_value"
    ),
    
    # Chart orientation
    radioButtons(
      inputId = ns("chart_orientation"),
      label = translate("圖表方向"),
      choices = list(
        "水平" = "horizontal",
        "垂直" = "vertical"
      ),
      selected = "horizontal"
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
#' poissonFeatureAnalysisDisplayUI
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param translate Function. Translation function for UI text elements (defaults to identity function).
#' @return shiny.tag. A Shiny UI component containing the display elements for the feature analysis.
poissonFeatureAnalysisDisplayUI <- function(id, translate = identity) {
  ns <- NS(id)
  
  tagList(
    div(class = "component-header mb-3 text-center",
        h3(translate("精準模型分析")),
        p(translate("全面分析商品屬性對銷售的影響：價格、品牌、類別、定位等因素效應"))),
    
    # Summary cards row
    fluidRow(
      column(3,
        div(class = "info-box bg-primary",
            div(class = "info-box-content",
                h4(textOutput(ns("total_features")), class = "text-white"),
                p(translate("總特徵數"), class = "text-white")))),
      column(3,
        div(class = "info-box bg-success", 
            div(class = "info-box-content",
                h4(textOutput(ns("significant_features")), class = "text-white"),
                p(translate("顯著特徵"), class = "text-white")))),
      column(3,
        div(class = "info-box bg-warning",
            div(class = "info-box-content",
                h4(textOutput(ns("top_feature")), class = "text-white"),
                p(translate("最重要特徵"), class = "text-white")))),
      column(3,
        div(class = "info-box bg-info",
            div(class = "info-box-content",
                h4(textOutput(ns("feature_types_count")), class = "text-white"),
                p(translate("特徵類型數"), class = "text-white"))))
    ),
    
    # Main visualization
    div(class = "component-output p-3",
        tabsetPanel(
          id = ns("analysis_tabs"),
          
          # Feature importance overview
          tabPanel(
            title = translate("特徵重要性"),
            value = "importance",
            br(),
            plotly::plotlyOutput(ns("feature_importance_plot"), height = "600px")
          ),
          
          # Price analysis
          tabPanel(
            title = translate("價格效應分析"),
            value = "price", 
            br(),
            fluidRow(
              column(6, plotly::plotlyOutput(ns("price_effects_plot"), height = "400px")),
              column(6, plotly::plotlyOutput(ns("price_comparison_plot"), height = "400px"))
            )
          ),
          
          # Brand and category analysis
          tabPanel(
            title = translate("品牌類別分析"),
            value = "brand_category",
            br(),
            fluidRow(
              column(12, plotly::plotlyOutput(ns("brand_category_plot"), height = "500px"))
            )
          ),
          
          # Product line comparison
          tabPanel(
            title = translate("產品線比較"),
            value = "comparison",
            br(),
            plotly::plotlyOutput(ns("product_line_comparison_plot"), height = "600px")
          ),
          
          # Detailed table
          tabPanel(
            title = translate("詳細數據"),
            value = "table",
            br(),
            DTOutput(ns("feature_analysis_table"), width = "100%")
          ),
          
          # Model quality
          tabPanel(
            title = translate("模型品質"),
            value = "quality",
            br(),
            fluidRow(
              column(6, plotly::plotlyOutput(ns("r_squared_plot"), height = "400px")),
              column(6, plotly::plotlyOutput(ns("model_performance_plot"), height = "400px"))
            )
          )
        ))
  )
}

# Server ----------------------------------------------------------------------
#' poissonFeatureAnalysisServer
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param app_data_connection Database connection object or list. Any connection type supported by tbl2.
#'        Can be a DBI connection, a list with getter functions, a file path, or NULL if no database access is needed.
#' @param config List or reactive expression. Optional configuration settings that can customize behavior.
#'        If reactive, will be re-evaluated when dependencies change.
#' @param session Shiny session object. The current Shiny session (defaults to getDefaultReactiveDomain()).
#' @return list. A list of reactive values providing access to component state and data.
poissonFeatureAnalysisServer <- function(id, app_data_connection = NULL, config = NULL,
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
        
        platform <- platform_id()
        table_name <- paste0("df_", platform, "_poisson_analysis_all")
        tbl <- tbl2(app_data_connection, table_name)
        
        # Filter for non-time features (all attributes except comment/rating which have their own component)
        feature_data <- tbl %>% 
          dplyr::filter(predictor_type != "time_feature" & predictor_type != "comment_rating") %>%
          collect()
        
        component_status("ready")
        return(feature_data)
        
      }, error = function(e) {
        warning("Error fetching Poisson data: ", e$message)
        component_status("error")
        data.frame()
      })
      
      return(result)
    })
    
    # ------------ Feature classification function ------------------
    classify_feature_type <- function(predictor, predictor_type) {
      case_when(
        grepl("price|cost|amount", predictor, ignore.case = TRUE) ~ "price",
        grepl("brand|manufacturer", predictor, ignore.case = TRUE) ~ "brand",
        predictor_type == "comment_rating" ~ "positioning",  # comment_rating already classified should be positioning
        grepl("position|factor|component", predictor, ignore.case = TRUE) ~ "positioning", 
        predictor_type == "numeric" ~ "numeric",
        predictor_type == "factor" ~ "factor",
        TRUE ~ "other"
      )
    }
    
    # ------------ Filter Options -----------------------------------------
    # No additional filter options needed - platform and product line come from config
    
    # ------------ Filtered Data ----------------------------------------
    filtered_data <- reactive({
      data <- poisson_data()
      
      if (is.null(data) || nrow(data) == 0) return(data.frame())
      
      # Add feature type classification
      data <- data %>%
        dplyr::mutate(feature_type = classify_feature_type(predictor, predictor_type))
      
      # Filter by product line from config
      current_product_line <- product_line_id()
      if (!is.null(current_product_line) && current_product_line != "all") {
        data <- data %>% dplyr::filter(product_line_id == current_product_line)
      }
      
      # Filter by feature types
      if (length(input$feature_types) > 0) {
        data <- data %>% dplyr::filter(feature_type %in% input$feature_types)
      }
      
      # Filter by significance
      if (input$show_significant_only) {
        data <- data %>% 
          dplyr::filter(!is.na(p_value) & p_value < 0.05 & convergence == "converged")
      }
      
      # Add sorting metrics
      data <- data %>%
        dplyr::mutate(
          irr_magnitude = abs(log(ifelse(is.na(incidence_rate_ratio), 1, incidence_rate_ratio))),
          coefficient_abs = abs(ifelse(is.na(coefficient), 0, coefficient))
        )
      
      # Sort data
      data <- switch(input$sort_by,
        "p_value" = data %>% dplyr::arrange(p_value, desc(irr_magnitude)),
        "irr_magnitude" = data %>% dplyr::arrange(desc(irr_magnitude)),
        "coefficient_abs" = data %>% dplyr::arrange(desc(coefficient_abs)),
        "aic" = data %>% dplyr::arrange(aic),
        data
      )
      
      # Limit to top N
      if (!is.null(input$top_n_features) && input$top_n_features > 0) {
        data <- data %>% dplyr::slice_head(n = input$top_n_features)
      }
      
      return(data)
    })
    
    # ------------ Summary Statistics --------------------------------
    output$total_features <- renderText({
      data <- filtered_data()
      if (nrow(data) == 0) return("0")
      formatC(nrow(data), format = "d", big.mark = ",")
    })
    
    output$significant_features <- renderText({
      data <- filtered_data()
      if (nrow(data) == 0) return("0")
      sig_count <- sum(!is.na(data$p_value) & data$p_value < 0.05 & data$convergence == "converged", na.rm = TRUE)
      formatC(sig_count, format = "d", big.mark = ",")
    })
    
    output$top_feature <- renderText({
      data <- filtered_data()
      if (nrow(data) == 0) return("--")
      
      top_row <- data %>% 
        dplyr::filter(!is.na(p_value) & convergence == "converged") %>%
        dplyr::slice_head(n = 1)
      
      if (nrow(top_row) == 0) return("無資料")
      
      predictor_short <- if (nchar(top_row$predictor[1]) > 15) {
        paste0(substr(top_row$predictor[1], 1, 12), "...")
      } else {
        top_row$predictor[1]
      }
      
      predictor_short
    })
    
    output$feature_types_count <- renderText({
      data <- filtered_data()
      if (nrow(data) == 0) return("0")
      length(unique(data$feature_type))
    })
    
    # ------------ Visualizations ------------------------------------
    
    # Feature importance plot
    output$feature_importance_plot <- plotly::renderPlotly({
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
          predictor_short = ifelse(nchar(predictor) > 25, 
                                  paste0(substr(predictor, 1, 22), "..."), 
                                  predictor),
          # Order for plotting
          predictor_ordered = factor(predictor_short, levels = rev(predictor_short))
        )
      
      # Choose orientation
      if (input$chart_orientation == "horizontal") {
        p <- ggplot2::ggplot(plot_data, ggplot2::aes(y = predictor_ordered, x = incidence_rate_ratio,
                                                    color = feature_type, shape = is_significant)) +
          ggplot2::geom_point(size = 3, alpha = 0.7) +
          ggplot2::geom_vline(xintercept = 1, linetype = "dashed", alpha = 0.5) +
          ggplot2::labs(
            title = "特徵重要性分析",
            y = "特徵名稱",
            x = "發生率比 (IRR)"
          )
      } else {
        p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = predictor_ordered, y = incidence_rate_ratio,
                                                    color = feature_type, shape = is_significant)) +
          ggplot2::geom_point(size = 3, alpha = 0.7) +
          ggplot2::geom_hline(yintercept = 1, linetype = "dashed", alpha = 0.5) +
          ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)) +
          ggplot2::labs(
            title = "特徵重要性分析",
            x = "特徵名稱",
            y = "發生率比 (IRR)"
          )
      }
      
      p <- p +
        ggplot2::theme_minimal() +
        ggplot2::labs(
          color = "特徵類型",
          shape = "顯著性 (p<0.05)"
        ) +
        ggplot2::scale_shape_manual(values = c(1, 16), labels = c("否", "是"))
      
      plotly::ggplotly(p, tooltip = c("x", "y", "colour", "shape"))
    })
    
    # Price effects plot
    output$price_effects_plot <- plotly::renderPlotly({
      data <- filtered_data()
      
      if (nrow(data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No data available"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      # Filter for price-related features
      price_data <- data %>%
        dplyr::filter(feature_type == "price" & !is.na(incidence_rate_ratio) & convergence == "converged") %>%
        dplyr::mutate(
          is_significant = !is.na(p_value) & p_value < 0.05,
          price_effect = case_when(
            incidence_rate_ratio > 1 ~ "正向效應",
            incidence_rate_ratio < 1 ~ "負向效應",
            TRUE ~ "無效應"
          )
        )
      
      if (nrow(price_data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No price data"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      p <- ggplot2::ggplot(price_data, ggplot2::aes(x = predictor, y = incidence_rate_ratio,
                                                   color = product_line_id, shape = is_significant)) +
        ggplot2::geom_point(size = 4, alpha = 0.7) +
        ggplot2::geom_hline(yintercept = 1, linetype = "dashed", alpha = 0.5) +
        ggplot2::theme_minimal() +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)) +
        ggplot2::labs(
          title = "價格因素效應分析",
          x = "價格特徵",
          y = "發生率比 (IRR)",
          color = "產品線",
          shape = "顯著性"
        ) +
        ggplot2::scale_shape_manual(values = c(1, 16), labels = c("否", "是"))
      
      plotly::ggplotly(p, tooltip = c("x", "y", "colour", "shape"))
    })
    
    # Price comparison plot
    output$price_comparison_plot <- plotly::renderPlotly({
      data <- filtered_data()
      
      price_data <- data %>%
        dplyr::filter(feature_type == "price" & !is.na(incidence_rate_ratio) & convergence == "converged")
      
      if (nrow(price_data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No price data"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      # Summary by product line
      price_summary <- price_data %>%
        dplyr::group_by(product_line_id) %>%
        dplyr::summarise(
          avg_price_effect = mean(incidence_rate_ratio, na.rm = TRUE),
          max_price_effect = max(incidence_rate_ratio, na.rm = TRUE),
          min_price_effect = min(incidence_rate_ratio, na.rm = TRUE),
          .groups = "drop"
        )
      
      p <- ggplot2::ggplot(price_summary, ggplot2::aes(x = product_line_id)) +
        ggplot2::geom_col(ggplot2::aes(y = avg_price_effect), alpha = 0.7, fill = "steelblue") +
        ggplot2::geom_errorbar(ggplot2::aes(ymin = min_price_effect, ymax = max_price_effect), 
                              width = 0.2) +
        ggplot2::geom_hline(yintercept = 1, linetype = "dashed", alpha = 0.5) +
        ggplot2::theme_minimal() +
        ggplot2::labs(
          title = "產品線價格效應比較",
          x = "產品線",
          y = "平均發生率比"
        )
      
      plotly::ggplotly(p)
    })
    
    # Brand and category plot
    output$brand_category_plot <- plotly::renderPlotly({
      data <- filtered_data()
      
      brand_data <- data %>%
        dplyr::filter(feature_type %in% c("brand", "factor") & !is.na(incidence_rate_ratio) & convergence == "converged") %>%
        dplyr::mutate(
          is_significant = !is.na(p_value) & p_value < 0.05,
          effect_magnitude = abs(log(incidence_rate_ratio))
        ) %>%
        dplyr::arrange(desc(effect_magnitude)) %>%
        dplyr::slice_head(n = 15)  # Top 15 for readability
      
      if (nrow(brand_data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No brand/category data"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      p <- ggplot2::ggplot(brand_data, ggplot2::aes(y = reorder(predictor, effect_magnitude), 
                                                   x = incidence_rate_ratio,
                                                   color = product_line_id, 
                                                   shape = is_significant)) +
        ggplot2::geom_point(size = 3, alpha = 0.7) +
        ggplot2::geom_vline(xintercept = 1, linetype = "dashed", alpha = 0.5) +
        ggplot2::theme_minimal() +
        ggplot2::labs(
          title = "品牌與類別效應分析",
          y = "特徵名稱",
          x = "發生率比 (IRR)",
          color = "產品線",
          shape = "顯著性"
        ) +
        ggplot2::scale_shape_manual(values = c(1, 16), labels = c("否", "是"))
      
      plotly::ggplotly(p, tooltip = c("x", "y", "colour", "shape"))
    })
    
    # Product line comparison plot
    output$product_line_comparison_plot <- plotly::renderPlotly({
      data <- filtered_data()
      
      if (nrow(data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No data available"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      # Summary by product line and feature type
      comparison_data <- data %>%
        dplyr::filter(!is.na(incidence_rate_ratio) & convergence == "converged") %>%
        dplyr::group_by(product_line_id, feature_type) %>%
        dplyr::summarise(
          avg_effect = mean(incidence_rate_ratio, na.rm = TRUE),
          significant_count = sum(!is.na(p_value) & p_value < 0.05, na.rm = TRUE),
          total_count = n(),
          .groups = "drop"
        ) %>%
        dplyr::mutate(significance_rate = significant_count / total_count)
      
      p <- ggplot2::ggplot(comparison_data, ggplot2::aes(x = product_line_id, y = avg_effect, 
                                                        fill = feature_type)) +
        ggplot2::geom_col(position = "dodge", alpha = 0.7) +
        ggplot2::geom_hline(yintercept = 1, linetype = "dashed", alpha = 0.5) +
        ggplot2::theme_minimal() +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)) +
        ggplot2::labs(
          title = "產品線特徵效應比較",
          x = "產品線",
          y = "平均發生率比",
          fill = "特徵類型"
        )
      
      plotly::ggplotly(p)
    })
    
    # Detailed table
    output$feature_analysis_table <- renderDT({
      data <- filtered_data()
      
      if (nrow(data) == 0) {
        return(data.frame(Message = "無可用資料"))
      }
      
      # Prepare table data
      table_data <- data %>%
        dplyr::filter(convergence == "converged") %>%
        dplyr::select(product_line_id, predictor, feature_type, coefficient, incidence_rate_ratio, 
                     std_error, p_value, conf_low, conf_high, aic, sample_size) %>%
        dplyr::mutate(
          coefficient = round(coefficient, 4),
          incidence_rate_ratio = round(incidence_rate_ratio, 4),
          std_error = round(std_error, 4),
          p_value = round(p_value, 6),
          conf_low = round(conf_low, 4),
          conf_high = round(conf_high, 4),
          significance = ifelse(!is.na(p_value) & p_value < 0.05, "顯著", "不顯著"),
          feature_type_chinese = case_when(
            feature_type == "price" ~ "價格",
            feature_type == "brand" ~ "品牌",
            feature_type == "numeric" ~ "數值",
            feature_type == "factor" ~ "類別",
            feature_type == "positioning" ~ "定位",
            TRUE ~ feature_type
          )
        ) %>%
        dplyr::select(product_line_id, predictor, feature_type_chinese, coefficient, incidence_rate_ratio,
                     std_error, p_value, significance, conf_low, conf_high, aic, sample_size)
      
      # Create column names in Chinese
      colnames(table_data) <- c("產品線", "特徵名稱", "特徵類型", "係數", "發生率比", "標準誤", 
                               "P值", "顯著性", "信賴區間下限", "信賴區間上限", "AIC", "樣本數")
      
      datatable(table_data,
                options = list(
                  pageLength = 15,
                  scrollX = TRUE,
                  dom = 'Bfrtip',
                  buttons = list(
                    list(extend = 'excel', text = '下載Excel', filename = '精準模型分析結果')
                  )
                ),
                extensions = c("Buttons"),
                rownames = FALSE) %>%
        formatStyle("顯著性", 
                   backgroundColor = styleEqual("顯著", "#d4edda"),
                   color = styleEqual("顯著", "#155724"))
    })
    
    # Model quality plots
    output$r_squared_plot <- plotly::renderPlotly({
      data <- filtered_data()
      
      if (nrow(data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No data available"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      # Calculate pseudo R-squared based on deviance
      quality_data <- data %>%
        dplyr::filter(!is.na(aic) & convergence == "converged") %>%
        dplyr::group_by(product_line_id) %>%
        dplyr::summarise(
          avg_aic = mean(aic, na.rm = TRUE),
          min_aic = min(aic, na.rm = TRUE),
          model_count = n(),
          .groups = "drop"
        )
      
      if (nrow(quality_data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No quality data"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      p <- ggplot2::ggplot(quality_data, ggplot2::aes(x = product_line_id, y = avg_aic)) +
        ggplot2::geom_col(fill = "lightblue", alpha = 0.7) +
        ggplot2::theme_minimal() +
        ggplot2::labs(
          title = "產品線模型品質 (AIC值)",
          x = "產品線",
          y = "平均AIC值"
        ) +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
      
      plotly::ggplotly(p)
    })
    
    # Model performance plot
    output$model_performance_plot <- plotly::renderPlotly({
      data <- filtered_data()
      
      if (nrow(data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No data available"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      # Model convergence summary
      performance_data <- data %>%
        dplyr::count(product_line_id, convergence) %>%
        dplyr::group_by(product_line_id) %>%
        dplyr::mutate(
          total = sum(n),
          percentage = n / total * 100
        ) %>%
        dplyr::ungroup() %>%
        dplyr::mutate(
          convergence_chinese = case_when(
            convergence == "converged" ~ "收斂",
            convergence == "failed" ~ "失敗",
            grepl("error", convergence) ~ "錯誤",
            TRUE ~ "其他"
          )
        )
      
      p <- ggplot2::ggplot(performance_data, ggplot2::aes(x = product_line_id, y = percentage, 
                                                         fill = convergence_chinese)) +
        ggplot2::geom_col(position = "stack") +
        ggplot2::theme_minimal() +
        ggplot2::labs(
          title = "模型收斂表現",
          x = "產品線",
          y = "百分比 (%)",
          fill = "收斂狀態"
        ) +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
      
      plotly::ggplotly(p)
    })
    
    # Reset filters
    observeEvent(input$reset_filters, {
      updateCheckboxGroupInput(session, "feature_types", 
                             selected = c("price", "brand", "numeric", "factor", "positioning"))
      updateCheckboxInput(session, "show_significant_only", value = FALSE)
      updateNumericInput(session, "top_n_features", value = 20)
      updateSelectInput(session, "sort_by", selected = "p_value")
      updateRadioButtons(session, "chart_orientation", selected = "horizontal")
    })
    
    # Component status
    output$component_status <- renderText({
      switch(component_status(),
             idle = "準備顯示特徵分析",
             loading = "載入分析資料中...",
             ready = paste0("已載入 ", nrow(poisson_data()), " 筆特徵分析結果"),
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
#' poissonFeatureAnalysisComponent
#' 
#' Implements a comprehensive product feature Poisson analysis component.
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
#' featureComp <- poissonFeatureAnalysisComponent("feature_analysis")
#' 
#' # Usage with database connection
#' featureComp <- poissonFeatureAnalysisComponent(
#'   id = "feature_analysis",
#'   app_data_connection = app_conn,
#'   config = list(platform_id = "cbz")
#' )
#' @export
poissonFeatureAnalysisComponent <- function(id, app_data_connection = NULL, config = NULL, translate = identity) {
  list(
    ui = list(filter = poissonFeatureAnalysisFilterUI(id, translate),
              display = poissonFeatureAnalysisDisplayUI(id, translate)),
    server = function(input, output, session) {
      poissonFeatureAnalysisServer(id, app_data_connection, config, session)
    }
  )
}