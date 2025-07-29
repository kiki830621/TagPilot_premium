#LOCK FILE
#
# poissonCommentAnalysis.R
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
#   • Rating and comment related Poisson regression analysis
#   • Product competitiveness analysis (similar to KitchenMAMA)
#   • Track positioning and competitive advantage
#   • Comment quality impact on sales
#   • Rating-based market positioning analysis
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
#' poissonCommentAnalysisFilterUI
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param translate Function. Translation function for UI text elements (defaults to identity function).
#'        Should accept a string and return a translated string.
#' @return shiny.tag. A Shiny UI component containing the filter controls for the comment analysis component.
poissonCommentAnalysisFilterUI <- function(id, translate = identity) {
  ns <- NS(id)
  
  wellPanel(
    style = "padding:15px;",
    h4(translate("產品賽道分析篩選")),
    
    # Rating dimension filter
    checkboxGroupInput(
      inputId = ns("rating_dimensions"),
      label = translate("評分維度"),
      choices = list(
        "整體評分" = "overall_rating",
        "評論數量" = "review_count", 
        "評分品質" = "rating_quality",
        "競爭力指標" = "competitive_metrics",
        "其他評分屬性" = "other_rating"
      ),
      selected = c("overall_rating", "review_count", "rating_quality", "competitive_metrics")
    ),
    
    # Competitiveness view
    radioButtons(
      inputId = ns("analysis_view"),
      label = translate("分析視角"),
      choices = list(
        "競爭優勢分析" = "competitive",
        "評分效應分析" = "rating_effect",
        "市場定位分析" = "positioning"
      ),
      selected = "competitive"
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
    
    # Competitive threshold
    sliderInput(
      inputId = ns("competitive_threshold"),
      label = translate("競爭優勢閾值 (IRR)"),
      min = 0.5,
      max = 2.0,
      value = 1.2,
      step = 0.1
    ),
    
    # Top N filter
    numericInput(
      inputId = ns("top_n_factors"),
      label = translate("顯示前N個因子"),
      value = 15,
      min = 5,
      max = 50,
      step = 5
    ),
    
    # Chart style
    selectInput(
      inputId = ns("chart_style"),
      label = translate("圖表風格"),
      choices = list(
        "賽道視圖" = "track",
        "競爭矩陣" = "matrix",
        "趨勢分析" = "trend"
      ),
      selected = "track"
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
#' poissonCommentAnalysisDisplayUI
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param translate Function. Translation function for UI text elements (defaults to identity function).
#' @return shiny.tag. A Shiny UI component containing the display elements for the comment analysis.
poissonCommentAnalysisDisplayUI <- function(id, translate = identity) {
  ns <- NS(id)
  
  tagList(
    div(class = "component-header mb-3 text-center",
        h3(translate("產品賽道分析")),
        p(translate("基於評分和評論的競爭力分析：市場定位、競爭優勢、賽道表現"))),
    
    # Summary cards row
    fluidRow(
      column(3,
        div(class = "info-box bg-primary",
            div(class = "info-box-content",
                h4(textOutput(ns("total_rating_factors")), class = "text-white"),
                p(translate("評分因子數"), class = "text-white")))),
      column(3,
        div(class = "info-box bg-success", 
            div(class = "info-box-content",
                h4(textOutput(ns("competitive_advantages")), class = "text-white"),
                p(translate("競爭優勢"), class = "text-white")))),
      column(3,
        div(class = "info-box bg-warning",
            div(class = "info-box-content",
                h4(textOutput(ns("strongest_rating_factor")), class = "text-white"),
                p(translate("最強評分因子"), class = "text-white")))),
      column(3,
        div(class = "info-box bg-info",
            div(class = "info-box-content",
                h4(textOutput(ns("market_position")), class = "text-white"),
                p(translate("市場定位"), class = "text-white"))))
    ),
    
    # Main visualization
    div(class = "component-output p-3",
        tabsetPanel(
          id = ns("analysis_tabs"),
          
          # Competitive landscape
          tabPanel(
            title = translate("競爭賽道"),
            value = "competitive",
            br(),
            plotly::plotlyOutput(ns("competitive_landscape_plot"), height = "600px")
          ),
          
          # Rating effects analysis
          tabPanel(
            title = translate("評分效應"),
            value = "rating_effects", 
            br(),
            fluidRow(
              column(6, plotly::plotlyOutput(ns("rating_impact_plot"), height = "400px")),
              column(6, plotly::plotlyOutput(ns("review_volume_plot"), height = "400px"))
            )
          ),
          
          # Market positioning
          tabPanel(
            title = translate("市場定位"),
            value = "positioning",
            br(),
            fluidRow(
              column(12, plotly::plotlyOutput(ns("market_positioning_plot"), height = "500px"))
            )
          ),
          
          # Competitive matrix
          tabPanel(
            title = translate("競爭矩陣"),
            value = "matrix",
            br(),
            plotly::plotlyOutput(ns("competitive_matrix_plot"), height = "600px")
          ),
          
          # Detailed table
          tabPanel(
            title = translate("詳細數據"),
            value = "table",
            br(),
            DTOutput(ns("comment_analysis_table"), width = "100%")
          ),
          
          # Performance insights
          tabPanel(
            title = translate("洞察報告"),
            value = "insights",
            br(),
            div(
              h4("競爭力洞察"),
              htmlOutput(ns("competitive_insights")),
              hr(),
              h4("評分策略建議"),
              htmlOutput(ns("rating_strategy_recommendations"))
            )
          )
        ))
  )
}

# Server ----------------------------------------------------------------------
#' poissonCommentAnalysisServer
#' @param id Character string. The module ID used for namespacing inputs and outputs.
#' @param app_data_connection Database connection object or list. Any connection type supported by tbl2.
#'        Can be a DBI connection, a list with getter functions, a file path, or NULL if no database access is needed.
#' @param config List or reactive expression. Optional configuration settings that can customize behavior.
#'        If reactive, will be re-evaluated when dependencies change.
#' @param session Shiny session object. The current Shiny session (defaults to getDefaultReactiveDomain()).
#' @return list. A list of reactive values providing access to component state and data.
poissonCommentAnalysisServer <- function(id, app_data_connection = NULL, config = NULL,
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
        
        # Filter for rating and comment related features
        rating_data <- tbl %>% 
          dplyr::filter(
            predictor_type == "comment_rating" |
            (predictor_type != "time_feature" &
            (grepl("rating|review|comment|score|quality|star", predictor, ignore.case = TRUE) |
             grepl("rating|review|comment|score|quality|star", predictor_type, ignore.case = TRUE)))
          ) %>%
          collect()
        
        component_status("ready")
        return(rating_data)
        
      }, error = function(e) {
        warning("Error fetching Poisson data: ", e$message)
        component_status("error")
        data.frame()
      })
      
      return(result)
    })
    
    # ------------ Rating classification function ------------------
    classify_rating_dimension <- function(predictor, predictor_type = NULL) {
      # If it's already classified as comment_rating, classify by content
      if (!is.null(predictor_type) && predictor_type == "comment_rating") {
        return(case_when(
          grepl("^rating$|overall.*rating|total.*rating", predictor, ignore.case = TRUE) ~ "overall_rating",
          grepl("review.*count|count.*review|number.*review", predictor, ignore.case = TRUE) ~ "review_count",
          grepl("rating.*quality|quality.*rating|star.*quality", predictor, ignore.case = TRUE) ~ "rating_quality",
          grepl("competitive|competitor|market.*position|rank", predictor, ignore.case = TRUE) ~ "competitive_metrics",
          TRUE ~ "other_rating"
        ))
      }
      
      # Fallback to original classification
      case_when(
        grepl("^rating$|overall.*rating|total.*rating", predictor, ignore.case = TRUE) ~ "overall_rating",
        grepl("review.*count|count.*review|number.*review", predictor, ignore.case = TRUE) ~ "review_count",
        grepl("rating.*quality|quality.*rating|star.*quality", predictor, ignore.case = TRUE) ~ "rating_quality",
        grepl("competitive|competitor|market.*position|rank", predictor, ignore.case = TRUE) ~ "competitive_metrics",
        TRUE ~ "other_rating"
      )
    }
    
    # ------------ Filter Options -----------------------------------------
    # No additional filter options needed - platform and product line come from config
    
    # ------------ Filtered Data ----------------------------------------
    filtered_data <- reactive({
      data <- poisson_data()
      
      if (is.null(data) || nrow(data) == 0) return(data.frame())
      
      # Add rating dimension classification
      data <- data %>%
        dplyr::mutate(rating_dimension = classify_rating_dimension(predictor, predictor_type))
      
      # Filter by product line from config
      current_product_line <- product_line_id()
      if (!is.null(current_product_line) && current_product_line != "all") {
        data <- data %>% dplyr::filter(product_line_id == current_product_line)
      }
      
      # Filter by rating dimensions
      if (length(input$rating_dimensions) > 0) {
        data <- data %>% dplyr::filter(rating_dimension %in% input$rating_dimensions)
      }
      
      # Filter by significance
      if (input$show_significant_only) {
        data <- data %>% 
          dplyr::filter(!is.na(p_value) & p_value < 0.05 & convergence == "converged")
      }
      
      # Add competitive analysis metrics
      data <- data %>%
        dplyr::mutate(
          is_competitive_advantage = !is.na(incidence_rate_ratio) & incidence_rate_ratio > input$competitive_threshold,
          competitive_strength = case_when(
            is.na(incidence_rate_ratio) ~ "未知",
            incidence_rate_ratio >= 1.5 ~ "強勢",
            incidence_rate_ratio >= 1.2 ~ "優勢",
            incidence_rate_ratio >= 0.8 ~ "平均",
            TRUE ~ "劣勢"
          ),
          effect_magnitude = abs(log(ifelse(is.na(incidence_rate_ratio), 1, incidence_rate_ratio)))
        )
      
      # Limit to top N if specified
      if (!is.null(input$top_n_factors) && input$top_n_factors > 0) {
        data <- data %>% 
          dplyr::arrange(desc(effect_magnitude)) %>%
          dplyr::slice_head(n = input$top_n_factors)
      }
      
      return(data)
    })
    
    # ------------ Summary Statistics --------------------------------
    output$total_rating_factors <- renderText({
      data <- filtered_data()
      if (nrow(data) == 0) return("0")
      formatC(nrow(data), format = "d", big.mark = ",")
    })
    
    output$competitive_advantages <- renderText({
      data <- filtered_data()
      if (nrow(data) == 0) return("0")
      advantage_count <- sum(data$is_competitive_advantage, na.rm = TRUE)
      formatC(advantage_count, format = "d", big.mark = ",")
    })
    
    output$strongest_rating_factor <- renderText({
      data <- filtered_data()
      if (nrow(data) == 0) return("--")
      
      strongest <- data %>% 
        dplyr::filter(!is.na(incidence_rate_ratio) & convergence == "converged") %>%
        dplyr::arrange(desc(effect_magnitude)) %>%
        dplyr::slice_head(n = 1)
      
      if (nrow(strongest) == 0) return("無資料")
      
      predictor_short <- if (nchar(strongest$predictor[1]) > 15) {
        paste0(substr(strongest$predictor[1], 1, 12), "...")
      } else {
        strongest$predictor[1]
      }
      
      predictor_short
    })
    
    output$market_position <- renderText({
      data <- filtered_data()
      if (nrow(data) == 0) return("--")
      
      # Calculate overall competitive position
      avg_effect <- mean(data$incidence_rate_ratio[data$convergence == "converged"], na.rm = TRUE)
      
      if (is.na(avg_effect)) return("未知")
      
      position <- case_when(
        avg_effect >= 1.3 ~ "領先",
        avg_effect >= 1.1 ~ "優勢",
        avg_effect >= 0.9 ~ "穩定",
        TRUE ~ "落後"
      )
      
      position
    })
    
    # ------------ Visualizations ------------------------------------
    
    # Competitive landscape plot
    output$competitive_landscape_plot <- plotly::renderPlotly({
      data <- filtered_data()
      
      if (nrow(data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No data available"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      # Prepare data for competitive landscape
      plot_data <- data %>%
        dplyr::filter(!is.na(incidence_rate_ratio) & convergence == "converged") %>%
        dplyr::mutate(
          is_significant = !is.na(p_value) & p_value < 0.05,
          predictor_short = ifelse(nchar(predictor) > 20, 
                                  paste0(substr(predictor, 1, 17), "..."), 
                                  predictor)
        )
      
      # Track view style
      if (input$chart_style == "track") {
        p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = effect_magnitude, y = incidence_rate_ratio,
                                                    color = product_line_id, 
                                                    size = ifelse(is_significant, 4, 2),
                                                    shape = competitive_strength)) +
          ggplot2::geom_point(alpha = 0.7) +
          ggplot2::geom_hline(yintercept = 1, linetype = "dashed", alpha = 0.5) +
          ggplot2::geom_hline(yintercept = input$competitive_threshold, linetype = "dotted", color = "red", alpha = 0.7) +
          ggplot2::theme_minimal() +
          ggplot2::labs(
            title = "競爭賽道視圖",
            x = "效應強度",
            y = "發生率比 (IRR)",
            color = "產品線",
            size = "顯著性",
            shape = "競爭力"
          ) +
          ggplot2::scale_size_identity()
      } else {
        # Matrix or trend style
        p <- ggplot2::ggplot(plot_data, ggplot2::aes(y = reorder(predictor_short, effect_magnitude), 
                                                    x = incidence_rate_ratio,
                                                    color = product_line_id,
                                                    shape = is_significant)) +
          ggplot2::geom_point(size = 3, alpha = 0.7) +
          ggplot2::geom_vline(xintercept = 1, linetype = "dashed", alpha = 0.5) +
          ggplot2::geom_vline(xintercept = input$competitive_threshold, linetype = "dotted", color = "red", alpha = 0.7) +
          ggplot2::theme_minimal() +
          ggplot2::labs(
            title = "評分因子競爭力分析",
            y = "評分因子",
            x = "發生率比 (IRR)",
            color = "產品線",
            shape = "顯著性"
          ) +
          ggplot2::scale_shape_manual(values = c(1, 16), labels = c("否", "是"))
      }
      
      plotly::ggplotly(p, tooltip = c("x", "y", "colour", "shape"))
    })
    
    # Rating impact plot
    output$rating_impact_plot <- plotly::renderPlotly({
      data <- filtered_data()
      
      if (nrow(data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No data available"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      # Filter for overall rating effects
      rating_data <- data %>%
        dplyr::filter(rating_dimension == "overall_rating" & !is.na(incidence_rate_ratio) & convergence == "converged") %>%
        dplyr::mutate(is_significant = !is.na(p_value) & p_value < 0.05)
      
      if (nrow(rating_data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No rating data"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      p <- ggplot2::ggplot(rating_data, ggplot2::aes(x = product_line_id, y = incidence_rate_ratio,
                                                    fill = competitive_strength, alpha = is_significant)) +
        ggplot2::geom_col(position = "dodge") +
        ggplot2::geom_hline(yintercept = 1, linetype = "dashed", alpha = 0.5) +
        ggplot2::scale_alpha_manual(values = c(0.5, 0.9), labels = c("不顯著", "顯著")) +
        ggplot2::theme_minimal() +
        ggplot2::labs(
          title = "整體評分影響力",
          x = "產品線",
          y = "發生率比 (IRR)",
          fill = "競爭力等級",
          alpha = "顯著性"
        ) +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
      
      plotly::ggplotly(p)
    })
    
    # Review volume plot
    output$review_volume_plot <- plotly::renderPlotly({
      data <- filtered_data()
      
      review_data <- data %>%
        dplyr::filter(rating_dimension == "review_count" & !is.na(incidence_rate_ratio) & convergence == "converged")
      
      if (nrow(review_data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No review data"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      p <- ggplot2::ggplot(review_data, ggplot2::aes(x = predictor, y = incidence_rate_ratio,
                                                    color = product_line_id)) +
        ggplot2::geom_point(size = 4, alpha = 0.7) +
        ggplot2::geom_hline(yintercept = 1, linetype = "dashed", alpha = 0.5) +
        ggplot2::theme_minimal() +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)) +
        ggplot2::labs(
          title = "評論數量效應",
          x = "評論相關因子",
          y = "發生率比 (IRR)",
          color = "產品線"
        )
      
      plotly::ggplotly(p)
    })
    
    # Market positioning plot
    output$market_positioning_plot <- plotly::renderPlotly({
      data <- filtered_data()
      
      if (nrow(data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No data available"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      # Create positioning matrix
      positioning_data <- data %>%
        dplyr::filter(!is.na(incidence_rate_ratio) & convergence == "converged") %>%
        dplyr::group_by(product_line_id, rating_dimension) %>%
        dplyr::summarise(
          avg_effect = mean(incidence_rate_ratio, na.rm = TRUE),
          effect_count = n(),
          significant_count = sum(!is.na(p_value) & p_value < 0.05, na.rm = TRUE),
          .groups = "drop"
        ) %>%
        dplyr::mutate(significance_rate = significant_count / effect_count)
      
      p <- ggplot2::ggplot(positioning_data, ggplot2::aes(x = rating_dimension, y = product_line_id,
                                                        fill = avg_effect, size = significance_rate)) +
        ggplot2::geom_point(shape = 21, alpha = 0.8) +
        ggplot2::scale_fill_gradient2(low = "red", mid = "white", high = "blue", midpoint = 1,
                                     name = "平均IRR") +
        ggplot2::scale_size_continuous(range = c(2, 8), name = "顯著性比例") +
        ggplot2::theme_minimal() +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)) +
        ggplot2::labs(
          title = "市場定位矩陣",
          x = "評分維度",
          y = "產品線"
        )
      
      plotly::ggplotly(p)
    })
    
    # Competitive matrix plot
    output$competitive_matrix_plot <- plotly::renderPlotly({
      data <- filtered_data()
      
      if (nrow(data) == 0) {
        p <- ggplot2::ggplot() + 
          ggplot2::geom_text(ggplot2::aes(x = 0.5, y = 0.5, label = "No data available"), size = 6) +
          ggplot2::theme_void()
        return(plotly::ggplotly(p))
      }
      
      # Create competitive matrix comparing product lines
      matrix_data <- data %>%
        dplyr::filter(!is.na(incidence_rate_ratio) & convergence == "converged") %>%
        dplyr::select(product_line_id, predictor, incidence_rate_ratio, p_value) %>%
        dplyr::mutate(
          competitive_score = case_when(
            incidence_rate_ratio >= 1.5 ~ 5,
            incidence_rate_ratio >= 1.2 ~ 4,
            incidence_rate_ratio >= 1.0 ~ 3,
            incidence_rate_ratio >= 0.8 ~ 2,
            TRUE ~ 1
          ),
          is_significant = !is.na(p_value) & p_value < 0.05
        ) %>%
        dplyr::group_by(product_line_id) %>%
        dplyr::slice_head(n = 10) %>%  # Top 10 factors per product line
        dplyr::ungroup()
      
      p <- ggplot2::ggplot(matrix_data, ggplot2::aes(x = predictor, y = product_line_id,
                                                    fill = competitive_score, 
                                                    alpha = ifelse(is_significant, 1, 0.5))) +
        ggplot2::geom_tile() +
        ggplot2::scale_fill_gradient(low = "white", high = "darkgreen", name = "競爭分數") +
        ggplot2::scale_alpha_identity() +
        ggplot2::theme_minimal() +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)) +
        ggplot2::labs(
          title = "競爭力熱力圖",
          x = "評分因子",
          y = "產品線"
        )
      
      plotly::ggplotly(p)
    })
    
    # Detailed table
    output$comment_analysis_table <- renderDT({
      data <- filtered_data()
      
      if (nrow(data) == 0) {
        return(data.frame(Message = "無可用資料"))
      }
      
      # Prepare table data
      table_data <- data %>%
        dplyr::filter(convergence == "converged") %>%
        dplyr::select(product_line_id, predictor, rating_dimension, coefficient, incidence_rate_ratio, 
                     std_error, p_value, competitive_strength, conf_low, conf_high, aic, sample_size) %>%
        dplyr::mutate(
          coefficient = round(coefficient, 4),
          incidence_rate_ratio = round(incidence_rate_ratio, 4),
          std_error = round(std_error, 4),
          p_value = round(p_value, 6),
          conf_low = round(conf_low, 4),
          conf_high = round(conf_high, 4),
          significance = ifelse(!is.na(p_value) & p_value < 0.05, "顯著", "不顯著"),
          rating_dimension_chinese = case_when(
            rating_dimension == "overall_rating" ~ "整體評分",
            rating_dimension == "review_count" ~ "評論數量",
            rating_dimension == "rating_quality" ~ "評分品質",
            rating_dimension == "competitive_metrics" ~ "競爭力指標",
            TRUE ~ "其他評分"
          )
        ) %>%
        dplyr::select(product_line_id, predictor, rating_dimension_chinese, coefficient, incidence_rate_ratio,
                     competitive_strength, std_error, p_value, significance, conf_low, conf_high, aic, sample_size)
      
      # Create column names in Chinese
      colnames(table_data) <- c("產品線", "評分因子", "評分維度", "係數", "發生率比", "競爭力",
                               "標準誤", "P值", "顯著性", "信賴區間下限", "信賴區間上限", "AIC", "樣本數")
      
      datatable(table_data,
                options = list(
                  pageLength = 15,
                  scrollX = TRUE,
                  dom = 'Bfrtip',
                  buttons = list(
                    list(extend = 'excel', text = '下載Excel', filename = '產品賽道分析結果')
                  )
                ),
                extensions = c("Buttons"),
                rownames = FALSE) %>%
        formatStyle("顯著性", 
                   backgroundColor = styleEqual("顯著", "#d4edda"),
                   color = styleEqual("顯著", "#155724")) %>%
        formatStyle("競爭力",
                   backgroundColor = styleEqual(c("強勢", "優勢", "平均", "劣勢"), 
                                               c("#28a745", "#6c757d", "#ffc107", "#dc3545")),
                   color = styleEqual(c("強勢", "優勢", "平均", "劣勢"), 
                                     c("white", "white", "black", "white")))
    })
    
    # Competitive insights
    output$competitive_insights <- renderUI({
      data <- filtered_data()
      
      if (nrow(data) == 0) {
        return(HTML("<p>暫無可用資料進行洞察分析</p>"))
      }
      
      # Generate insights
      strong_factors <- data %>%
        dplyr::filter(competitive_strength == "強勢" & !is.na(p_value) & p_value < 0.05) %>%
        nrow()
      
      weak_factors <- data %>%
        dplyr::filter(competitive_strength == "劣勢") %>%
        nrow()
      
      best_product_line <- data %>%
        dplyr::filter(!is.na(incidence_rate_ratio) & convergence == "converged") %>%
        dplyr::group_by(product_line_id) %>%
        dplyr::summarise(avg_irr = mean(incidence_rate_ratio, na.rm = TRUE), .groups = "drop") %>%
        dplyr::arrange(desc(avg_irr)) %>%
        dplyr::slice_head(n = 1) %>%
        dplyr::pull(product_line_id)
      
      insights_html <- paste0(
        "<ul>",
        "<li><strong>競爭優勢：</strong>發現 ", strong_factors, " 個強勢競爭因子</li>",
        "<li><strong>改善空間：</strong>識別出 ", weak_factors, " 個需要改進的劣勢因子</li>",
        "<li><strong>表現最佳：</strong>產品線 ", ifelse(length(best_product_line) > 0, best_product_line, "無"), " 在評分競爭力方面表現最佳</li>",
        "<li><strong>策略建議：</strong>專注提升評分品質和評論數量，這些是關鍵競爭因子</li>",
        "</ul>"
      )
      
      HTML(insights_html)
    })
    
    # Rating strategy recommendations
    output$rating_strategy_recommendations <- renderUI({
      data <- filtered_data()
      
      if (nrow(data) == 0) {
        return(HTML("<p>暫無可用資料提供策略建議</p>"))
      }
      
      # Generate strategy recommendations
      top_rating_factors <- data %>%
        dplyr::filter(!is.na(incidence_rate_ratio) & convergence == "converged" & 
                     !is.na(p_value) & p_value < 0.05) %>%
        dplyr::arrange(desc(incidence_rate_ratio)) %>%
        dplyr::slice_head(n = 3) %>%
        dplyr::pull(predictor)
      
      recommendations_html <- paste0(
        "<ul>",
        "<li><strong>重點優化：</strong>集中資源改善前三大影響因子：",
        paste(head(top_rating_factors, 3), collapse = "、"), "</li>",
        "<li><strong>評分策略：</strong>建立系統化的評分管理流程，定期監控評分變化</li>",
        "<li><strong>競爭分析：</strong>定期比較競品評分表現，識別差距和機會</li>",
        "<li><strong>客戶體驗：</strong>從評分反饋中提取改善建議，提升產品品質</li>",
        "</ul>"
      )
      
      HTML(recommendations_html)
    })
    
    # Reset filters
    observeEvent(input$reset_filters, {
      updateCheckboxGroupInput(session, "rating_dimensions", 
                             selected = c("overall_rating", "review_count", "rating_quality", "competitive_metrics"))
      updateRadioButtons(session, "analysis_view", selected = "competitive")
      updateCheckboxInput(session, "show_significant_only", value = FALSE)
      updateSliderInput(session, "competitive_threshold", value = 1.2)
      updateNumericInput(session, "top_n_factors", value = 15)
      updateSelectInput(session, "chart_style", selected = "track")
    })
    
    # Component status
    output$component_status <- renderText({
      switch(component_status(),
             idle = "準備顯示賽道分析",
             loading = "載入分析資料中...",
             ready = paste0("已載入 ", nrow(poisson_data()), " 筆評分分析結果"),
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
#' poissonCommentAnalysisComponent
#' 
#' Implements a rating and comment-based competitive analysis component.
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
#' commentComp <- poissonCommentAnalysisComponent("comment_analysis")
#' 
#' # Usage with database connection
#' commentComp <- poissonCommentAnalysisComponent(
#'   id = "comment_analysis",
#'   app_data_connection = app_conn,
#'   config = list(platform_id = "cbz")
#' )
#' @export
poissonCommentAnalysisComponent <- function(id, app_data_connection = NULL, config = NULL, translate = identity) {
  list(
    ui = list(filter = poissonCommentAnalysisFilterUI(id, translate),
              display = poissonCommentAnalysisDisplayUI(id, translate)),
    server = function(input, output, session) {
      poissonCommentAnalysisServer(id, app_data_connection, config, session)
    }
  )
}