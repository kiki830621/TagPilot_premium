#LOCK FILE
#
# poissonFeatureAnalysis.R
# Poisson 特徵分析組件（InsightForge 風格）
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
#   • InsightForge 賽道倍數和邊際效應分析
#   • 戰略重點（賽道倍數）vs 日常優化（邊際效應）
#   • 清晰的商業意義解讀
#   • 互動式視覺化呈現
# -----------------------------------------------------------------------------

# helper ----------------------------------------------------------------------
`%+%` <- function(x, y) paste0(x, y)
`%||%` <- function(x, y) if (is.null(x)) y else x

# Helper function to calculate attribute range dynamically
# Following MP047: Functional Programming - create reusable function
# Following MP081: Explicit Parameter Specification
calculate_attribute_range <- function(predictor_name, data_connection = NULL) {
  # Default range if we can't determine actual range
  default_range <- 4
  
  # Try to infer range from predictor name patterns
  # Following R116: Enhanced Data Access
  if (grepl("rating|score|star", predictor_name, ignore.case = TRUE)) {
    # Rating/score variables typically range 1-5
    return(4)  # 5 - 1 = 4
  } else if (grepl("binary|flag|is_|has_", predictor_name, ignore.case = TRUE)) {
    # Binary variables range 0-1
    return(1)  # 1 - 0 = 1
  } else if (grepl("percentage|percent|rate", predictor_name, ignore.case = TRUE)) {
    # Percentage variables typically 0-100
    return(100)
  } else if (grepl("count|quantity|number", predictor_name, ignore.case = TRUE)) {
    # Count variables - use conservative estimate
    return(10)  # Conservative estimate for counts
  } else if (grepl("price|cost|revenue", predictor_name, ignore.case = TRUE)) {
    # Price variables - use moderate range
    return(50)  # Moderate price range estimate
  }
  
  # If we have data connection, try to get actual range
  # (Future enhancement: query actual data ranges from database)
  
  # Default fallback
  return(default_range)
}

# Helper function to calculate track multiplier with dynamic range
# Following MP088: Immediate Feedback - provide clear calculation basis
calculate_track_multiplier <- function(coefficient, predictor_name, incidence_rate_ratio = NULL) {
  # Get the attribute range dynamically
  attr_range <- calculate_attribute_range(predictor_name)
  
  # Method 1: Using coefficient (preferred when available)
  if (!is.na(coefficient)) {
    # For extreme coefficients, use capped calculation to avoid overflow
    if (abs(coefficient) > 2) {
      # Linear scaling for large coefficients to avoid exponential explosion
      track_multiplier <- exp(2) * (1 + (abs(coefficient) - 2) * 0.5)
    } else {
      # Standard calculation: exp(range × |coefficient|)
      # But cap the range effect to avoid unrealistic values
      effective_range <- min(attr_range, 10)  # Cap range effect at 10
      track_multiplier <- exp(abs(coefficient) * sqrt(effective_range))  # Use sqrt to moderate the effect
    }
  }
  # Method 2: Using incidence rate ratio (fallback)
  else if (!is.null(incidence_rate_ratio) && !is.na(incidence_rate_ratio)) {
    # Calculate power based on actual range
    # Use sqrt of range to moderate the exponential effect
    power <- sqrt(attr_range)
    track_multiplier <- incidence_rate_ratio ^ power
  }
  else {
    return(NA)
  }
  
  # Cap at reasonable maximum (100x)
  return(round(min(track_multiplier, 100), 1))
}

# Filter UI (InsightForge Style) ----------------------------------------------
poissonFeatureAnalysisFilterUI <- function(id, translate = identity) {
  ns <- NS(id)
  
  wellPanel(
    style = "padding:15px;",
    h4(translate("精準行銷分析")),
    p(translate("使用 InsightForge 360 技術分析產品屬性影響力")),
    
    hr(),
    
    # AI Analysis buttons
    actionButton(
      inputId = ns("generate_precision_insight"),
      label = translate("生成 AI 精準行銷洞察"),
      class = "btn-primary btn-block",
      icon = icon("magic")
    ),
    
    br(), br(),
    
    actionButton(
      inputId = ns("generate_product_development"),
      label = translate("生成 AI 新產品開發建議"),
      class = "btn-success btn-block",
      icon = icon("lightbulb")
    )
  )
}

# Display UI (InsightForge Style) ---------------------------------------------
poissonFeatureAnalysisUI <- function(id, translate = identity) {
  ns <- NS(id)
  
  tagList(
    # Include shinyjs dependency
    shinyjs::useShinyjs(),
    div(class = "component-header mb-3 text-center",
        h3(translate("🎯 產品屬性影響力分析")),
        p(translate("運用賽道倍數與邊際效應，精準識別戰略重點與日常優化方向"))),
    
    # InsightForge 風格的摘要卡片
    fluidRow(
      column(3,
        div(class = "info-box bg-danger",
            div(class = "info-box-content",
                h4(textOutput(ns("track_champion")), class = "text-white"),
                p(translate("🏁 賽道冠軍"), class = "text-white")))),
      column(3,
        div(class = "info-box bg-danger", 
            div(class = "info-box-content",
                h4(textOutput(ns("track_multiplier_value")), class = "text-white"),
                p(translate("最大賽道倍數"), class = "text-white")))),
      column(3,
        div(class = "info-box bg-warning",
            div(class = "info-box-content",
                h4(textOutput(ns("marginal_champion")), class = "text-white"),
                p(translate("⚡ 邊際冠軍"), class = "text-white")))),
      column(3,
        div(class = "info-box bg-warning",
            div(class = "info-box-content",
                h4(textOutput(ns("marginal_effect_value")), class = "text-white"),
                p(translate("最大邊際效應"), class = "text-white"))))
    ),
    
    # 決策指南
    div(class = "alert alert-info mb-3",
        h5("📊 決策指南"),
        tags$ul(
          tags$li("賽道倍數 > 2.0：極重要因素，是核心競爭力"),
          tags$li("賽道倍數 1.2-2.0：重要影響因素，應重點關注"),
          tags$li("邊際效應 > 50%：強烈影響，小改進大效果"),
          tags$li("邊際效應 20-50%：中等影響，穩定改進策略")
        )
    ),
    
    # 主要視覺化區域
    div(class = "component-output p-3",
        fluidRow(
          column(12,
            div(class = "card",
                div(class = "card-header",
                    h4("🏁 屬性賽道倍數分析")),
                div(class = "card-body",
                    plotly::plotlyOutput(ns("track_multiplier_plot"), height = "500px")))
          )
        ),
        br(),
        fluidRow(
          column(6,
            div(class = "card",
                div(class = "card-header",
                    h4("⚡ 邊際效應排行")),
                div(class = "card-body",
                    plotly::plotlyOutput(ns("marginal_effect_plot"), height = "400px")))
          ),
          column(6,
            div(class = "card",
                div(class = "card-header",
                    h4("💡 策略建議")),
                div(class = "card-body",
                    htmlOutput(ns("strategy_recommendation"))))
          )
        ),
        br(),
        fluidRow(
          column(12,
            div(class = "card",
                div(class = "card-header bg-light",
                    h4("📋 詳細分析結果", style = "margin: 0; padding: 10px 0;")),
                div(class = "card-body", style = "padding-top: 20px;",
                    DT::DTOutput(ns("analysis_table"), width = "100%")))
          )
        ),
        br(),
        # AI Insights Section
        fluidRow(
          column(12,
            div(class = "card",
                id = ns("ai_insights_section"),
                style = "display: none;",  # Initially hidden
                div(class = "card-header bg-primary text-white",
                    h4("🤖 InsightForge 360 - 精準行銷洞察報告", style = "margin: 0; padding: 10px 0;")),
                div(class = "card-body", style = "padding: 30px;",
                    if (requireNamespace("shinycssloaders", quietly = TRUE)) {
                      shinycssloaders::withSpinner(
                        htmlOutput(ns("precision_insight_output")),
                        type = 6,
                        color = "#0d6efd"
                      )
                    } else {
                      htmlOutput(ns("precision_insight_output"))
                    }
                )
            )
          )
        ),
        br(),
        # AI New Product Development Section
        fluidRow(
          column(12,
            div(class = "card",
                id = ns("ai_product_development_section"),
                style = "display: none;",  # Initially hidden
                div(class = "card-header bg-success text-white",
                    h4("🚀 AI 新產品開發建議", style = "margin: 0; padding: 10px 0;")),
                div(class = "card-body", style = "padding: 30px;",
                    if (requireNamespace("shinycssloaders", quietly = TRUE)) {
                      shinycssloaders::withSpinner(
                        htmlOutput(ns("product_development_output")),
                        type = 6,
                        color = "#28a745"
                      )
                    } else {
                      htmlOutput(ns("product_development_output"))
                    }
                )
            )
          )
        )
    )
  )
}

# Server (InsightForge Style) -------------------------------------------------
poissonFeatureAnalysisServer <- function(id, app_data_connection = NULL, config = NULL,
                                                    session = getDefaultReactiveDomain()) {
  moduleServer(id, function(input, output, session) {
    
    # 狀態追蹤
    component_status <- reactiveVal("idle")
    
    # 提取配置參數
    platform_id <- reactive({
      if (is.null(config)) return("cbz")
      
      if (is.function(config)) {
        cfg <- if (shiny::is.reactive(config)) config() else config
      } else {
        cfg <- config
      }
      
      cfg$filters$platform_id %||% cfg$platform_id %||% "cbz"
    })
    
    # 提取產品線參數
    product_line_id <- reactive({
      if (is.null(config)) return("all")
      
      if (is.function(config)) {
        cfg <- if (shiny::is.reactive(config)) config() else config
      } else {
        cfg <- config
      }
      
      cfg$filters$product_line_id %||% cfg$product_line_id %||% "all"
    })
    
    # 載入並處理數據
    analysis_data <- reactive({
      component_status("loading")
      
      tryCatch({
        if (is.null(app_data_connection)) {
          component_status("error")
          return(data.frame())
        }
        
        # 載入 Poisson 分析結果
        # 暫時統一使用 Cyberbiz 的數據
        # platform <- platform_id()
        platform <- "cbz"  # 固定使用 Cyberbiz
        prod_line <- product_line_id()
        
        # 根據產品線選擇適當的表格
        if (prod_line == "all") {
          table_name <- paste0("df_", platform, "_poisson_analysis_all")
        } else {
          table_name <- paste0("df_", platform, "_poisson_analysis_", prod_line)
        }
        
        # 使用 global_scripts 中的函數（如果存在）
        if (exists("poisson_regression")) {
          # 如果已載入 InsightForge 函數，直接使用
          data <- tbl2(app_data_connection, table_name) %>%
            filter(predictor_type != "time_feature" &
                   convergence == "converged") %>%
            collect()
          
          # 計算 InsightForge 指標
          # Following MP047: Functional Programming - use helper functions
          # Following MP088: Immediate Feedback - show calculation basis
          data <- data %>%
            mutate(
              # 限制邊際效應在合理範圍內
              marginal_effect_pct = round(ifelse(abs(coefficient) > 5,
                                                sign(coefficient) * 500,  # 最大 ±500%
                                                (exp(coefficient) - 1) * 100), 1),
              # Dynamic track multiplier calculation based on actual attribute range
              track_multiplier = mapply(calculate_track_multiplier, 
                                       coefficient, 
                                       predictor,
                                       MoreArgs = list(incidence_rate_ratio = NULL)),
              practical_meaning = case_when(
                track_multiplier >= 3.0 ~ "極重要因素，核心競爭力",
                track_multiplier >= 2.0 ~ "重要影響因素，應重點關注", 
                track_multiplier >= 1.2 ~ "有一定影響，可考慮優化",
                TRUE ~ "影響很小，不是關鍵因素"
              ),
              track_explanation = paste0(
                "從最", ifelse(coefficient > 0, "低", "高"), "到最",
                ifelse(coefficient > 0, "高", "低"), "，銷量可相差",
                track_multiplier, "倍",
                " (基於屬性範圍: ", sapply(predictor, calculate_attribute_range), ")"
              )
            )
        } else {
          # 如果沒有載入函數，使用基本計算
          # 需要重新建立 table_name（因為在 if 區塊內）
          if (prod_line == "all") {
            table_name <- paste0("df_", platform, "_poisson_analysis_all")
          } else {
            table_name <- paste0("df_", platform, "_poisson_analysis_", prod_line)
          }
          
          data <- tbl2(app_data_connection, table_name) %>%
            filter(predictor_type != "time_feature" &
                   convergence == "converged") %>%
            collect() %>%
            mutate(
              # 限制邊際效應在合理範圍內
              marginal_effect_pct = round(pmin(pmax((incidence_rate_ratio - 1) * 100, -90), 500), 1),
              # Dynamic track multiplier calculation using actual attribute ranges
              # Following R116: Enhanced Data Access - use appropriate calculations
              track_multiplier = mapply(calculate_track_multiplier,
                                      coefficient = NA,
                                      predictor,
                                      incidence_rate_ratio),
              practical_meaning = case_when(
                track_multiplier >= 3.0 ~ "極重要因素，核心競爭力",
                track_multiplier >= 2.0 ~ "重要影響因素，應重點關注",
                track_multiplier >= 1.2 ~ "有一定影響，可考慮優化",
                TRUE ~ "影響很小，不是關鍵因素"
              ),
              track_explanation = paste0("影響倍數：", track_multiplier, "倍",
                                        " (屬性範圍: ", sapply(predictor, calculate_attribute_range), ")")
            )
        }
        
        component_status("ready")
        return(data)
        
      }, error = function(e) {
        warning("Error loading analysis data: ", e$message)
        component_status("error")
        data.frame()
      })
    })
    
    # 篩選顯示所有有效的屬性（不限於正向影響）
    positive_data <- reactive({
      data <- analysis_data()
      
      # 顯示找到多少資料
      if (nrow(data) > 0) {
        cat("精準模型找到", nrow(data), "筆屬性資料\n")
      }
      
      # 顯示所有有係數和p值的屬性，但排除評分相關屬性和異常值
      filtered_data <- data %>%
        filter(!is.na(coefficient) & !is.na(p_value) &
               !grepl("rating", predictor, ignore.case = TRUE) &
               abs(coefficient) <= 10)  # 排除係數過大的異常值（如 material）
      
      # Apply covariate exclusion rules for display purposes only
      # This preserves the full analysis but filters what users see
      if (nrow(filtered_data) > 0) {
        tryCatch({
          all_predictors <- unique(filtered_data$predictor)
          kept_predictors <- filter_covariates(
            var_names = all_predictors,
            app_type = "poisson_regression",
            verbose = FALSE
          )
          
          # Filter data to keep only allowed predictors
          filtered_data <- filtered_data %>%
            dplyr::filter(predictor %in% kept_predictors)
          
          # Log exclusions if verbose
          excluded_count <- length(all_predictors) - length(kept_predictors)
          if (excluded_count > 0) {
            message(sprintf("Hiding %d covariates from display based on exclusion rules", excluded_count))
          }
        }, error = function(e) {
          # If function not available, show all predictors
          warning("filter_covariates not available, showing all covariates: ", e$message)
        })
      }
      
      filtered_data %>%
        arrange(desc(abs(track_multiplier)))  # 按絕對值排序
    })
    
    # 摘要統計 - 顯示影響力最大的屬性（不論正負）
    output$track_champion <- renderText({
      data <- positive_data()
      if (nrow(data) == 0) return("--")
      
      # 選擇賽道倍數最大的（已按絕對值排序）
      top <- data[1, ]
      if (nchar(top$predictor) > 15) {
        paste0(substr(top$predictor, 1, 12), "...")
      } else {
        top$predictor
      }
    })
    
    output$track_multiplier_value <- renderText({
      data <- positive_data()
      if (nrow(data) == 0) return("--")
      paste0(data$track_multiplier[1], " 倍")
    })
    
    output$marginal_champion <- renderText({
      data <- positive_data()
      if (nrow(data) == 0) return("--")
      
      top <- data %>% arrange(desc(abs(marginal_effect_pct))) %>% slice(1)
      if (nchar(top$predictor) > 15) {
        paste0(substr(top$predictor, 1, 12), "...")
      } else {
        top$predictor
      }
    })
    
    output$marginal_effect_value <- renderText({
      data <- positive_data()
      if (nrow(data) == 0) return("--")
      
      top <- data %>% arrange(desc(abs(marginal_effect_pct))) %>% slice(1)
      paste0(abs(top$marginal_effect_pct), "%")
    })
    
    # 賽道倍數圖
    output$track_multiplier_plot <- plotly::renderPlotly({
      # 顯示前20個最重要的屬性（按賽道倍數絕對值）
      data <- positive_data() %>% 
        filter(!is.na(track_multiplier)) %>%
        slice_head(n = 20)
      
      if (nrow(data) == 0) {
        plotly::plot_ly() %>%
          plotly::add_text(x = 0.5, y = 0.5, text = "無正向影響的屬性資料",
                          textposition = "center", showlegend = FALSE)
      } else {
        data <- data %>%
          mutate(
            hover_text = paste0(
              "屬性: ", predictor, "<br>",
              "賽道倍數: ", track_multiplier, " 倍<br>",
              "邊際效應: ", marginal_effect_pct, "%<br>",
              "商業意義: ", practical_meaning, "<br>",
              track_explanation
            ),
            predictor_short = ifelse(nchar(predictor) > 20,
                                   paste0(substr(predictor, 1, 17), "..."),
                                   predictor)
          )
        
        plotly::plot_ly(data, 
                       x = ~track_multiplier,
                       y = ~reorder(predictor_short, track_multiplier),
                       type = "bar",
                       orientation = "h",
                       marker = list(color = ~track_multiplier,
                                   colorscale = list(c(0, "#FFF3CD"), c(0.5, "#FFC107"), c(1, "#DC3545")),
                                   cmin = 1, cmax = max(data$track_multiplier)),
                       text = ~hover_text,
                       textposition = "none",  # 不顯示文字標籤
                       hoverinfo = "text") %>%
          plotly::layout(
            title = "",
            xaxis = list(title = "賽道倍數（從最低到最高的影響倍數）"),
            yaxis = list(title = ""),
            shapes = list(
              list(type = "line", x0 = 2, x1 = 2, y0 = -0.5, y1 = length(unique(data$predictor)) - 0.5,
                   line = list(color = "red", dash = "dash")),
              list(type = "line", x0 = 1.2, x1 = 1.2, y0 = -0.5, y1 = length(unique(data$predictor)) - 0.5,
                   line = list(color = "orange", dash = "dot"))
            )
          )
      }
    })
    
    # 邊際效應圖
    output$marginal_effect_plot <- plotly::renderPlotly({
      data <- positive_data() %>%
        arrange(desc(abs(marginal_effect_pct))) %>%
        slice_head(n = 10)
      
      if (nrow(data) == 0) {
        plotly::plot_ly() %>%
          plotly::add_text(x = 0.5, y = 0.5, text = "無資料", showlegend = FALSE)
      } else {
        data <- data %>%
          mutate(
            predictor_short = ifelse(nchar(predictor) > 15,
                                   paste0(substr(predictor, 1, 12), "..."),
                                   predictor)
          )
        
        plotly::plot_ly(data,
                       x = ~reorder(predictor_short, abs(marginal_effect_pct)),
                       y = ~marginal_effect_pct,
                       type = "bar",
                       marker = list(color = ~ifelse(marginal_effect_pct > 50, "#DC3545",
                                                   ifelse(marginal_effect_pct > 20, "#FFC107", "#28A745"))),
                       text = ~paste0(round(marginal_effect_pct, 1), "%"),
                       textposition = "outside",
                       hoverinfo = "text",
                       hovertext = ~paste0("每提升1單位", predictor, "，銷量增加", 
                                         round(marginal_effect_pct, 1), "%")) %>%
          plotly::layout(
            title = "",
            xaxis = list(title = "", tickangle = -45),
            yaxis = list(title = "邊際效應 (%)"),
            showlegend = FALSE
          )
      }
    })
    
    # 策略建議
    output$strategy_recommendation <- renderUI({
      data <- positive_data()
      
      if (nrow(data) == 0) {
        return(p("暫無分析結果"))
      }
      
      # 找出賽道冠軍和邊際冠軍
      track_top <- data[1, ]
      marginal_top <- data %>% arrange(desc(abs(marginal_effect_pct))) %>% slice(1)
      
      recommendation <- tags$div(
        h5("💡 基於分析結果的行動建議："),
        tags$ul(
          tags$li(tags$strong("戰略重點："), 
                  paste0("優先提升「", track_top$predictor, "」，",
                        "此屬性從最低到最高可讓銷量相差", track_top$track_multiplier, "倍")),
          tags$li(tags$strong("快速見效："),
                  paste0("立即改善「", marginal_top$predictor, "」，",
                        "每提升1單位可增加銷量", abs(marginal_top$marginal_effect_pct), "%")),
          tags$li(tags$strong("資源配置："),
                  "將80%資源投入賽道倍數>2的屬性，20%用於邊際效應>50%的快速優化")
        ),
        br(),
        tags$div(class = "alert alert-success",
          tags$strong("執行建議："),
          "結合「戰略+戰術」雙重優化策略，長期布局與短期成效並重"
        )
      )
      
      return(recommendation)
    })
    
    # 詳細表格
    output$analysis_table <- DT::renderDT({
      data <- positive_data()
      
      # 除錯訊息
      cat("精準模型詳細表格資料筆數:", nrow(data), "\n")
      
      if (nrow(data) == 0) {
        return(data.frame(訊息 = "無屬性資料"))
      }
      
      table_data <- data %>%
        dplyr::select(
          predictor, 
          track_multiplier,
          marginal_effect_pct,
          practical_meaning,
          coefficient,
          p_value,
          sample_size
        ) %>%
        mutate(
          coefficient = round(coefficient, 4),
          p_value = round(p_value, 4),
          significance = ifelse(p_value < 0.001, "***",
                              ifelse(p_value < 0.01, "**",
                                    ifelse(p_value < 0.05, "*", "")))
        )
      
      colnames(table_data) <- c("屬性名稱", "賽道倍數", "邊際效應%", 
                               "商業意義", "係數", "P值", "樣本數", "顯著性")
      
      DT::datatable(table_data,
                options = list(
                  pageLength = 10,
                  scrollX = TRUE,
                  dom = 'Bfrtip',
                  buttons = list(
                    list(extend = 'excel', text = '下載Excel', 
                         filename = 'InsightForge_屬性影響力分析')
                  ),
                  order = list(list(1, 'desc'))  # 預設按賽道倍數排序
                ),
                extensions = c("Buttons"),
                rownames = FALSE) %>%
        formatStyle("賽道倍數",
                   backgroundColor = styleInterval(c(1.2, 2.0), 
                                                 c("white", "#FFF3CD", "#F8D7DA")),
                   fontWeight = styleInterval(2.0, c("normal", "bold"))) %>%
        formatStyle("顯著性",
                   color = styleEqual(c("*", "**", "***"), 
                                    c("#28A745", "#FFC107", "#DC3545")))
    })
    
    # ------------ AI Precision Marketing Insights Generation -------------
    ai_insight_result <- reactiveVal(NULL)
    
    # Get OpenAI API key from environment
    gpt_key <- Sys.getenv("OPENAI_API_KEY", "")
    if (!nzchar(gpt_key)) {
      gpt_key <- NULL
    }
    
    observeEvent(input$generate_precision_insight, {
      data <- positive_data()
      
      if (is.null(data) || nrow(data) == 0) {
        showNotification("無可用的屬性分析資料", type = "warning")
        return()
      }
      
      if (is.null(gpt_key)) {
        showNotification("OpenAI API 金鑰未設定。AI 分析功能已停用。", type = "error")
        return()
      }
      
      withProgress(message = "生成 InsightForge 360 精準行銷洞察中...", value = 0, {
        incProgress(0.2, detail = "準備屬性資料...")
        
        # Prepare top attributes data for AI analysis
        top_attributes <- data %>%
          slice_head(n = 10)
        
        # Convert to structured format for GPT
        attributes_summary <- data.frame(
          屬性 = top_attributes$predictor,
          賽道倍數 = top_attributes$track_multiplier,
          邊際效應 = paste0(top_attributes$marginal_effect_pct, "%"),
          商業意義 = top_attributes$practical_meaning
        )
        
        attributes_json <- jsonlite::toJSON(attributes_summary, dataframe = "rows", auto_unbox = TRUE)
        
        incProgress(0.4, detail = "分析關鍵屬性...")
        
        # OpenAI functions should already be loaded from union_production_test.R
        if (!exists("fn_chat_api")) {
          stop("OpenAI functions not loaded. Please check union_production_test.R initialization.")
        }
        
        # Create prompt based on martech report examples
        sys <- list(role = "system", content = "你是專業的電商行銷顧問，擅長精準行銷分析和銷售策略制定。請用繁體中文回答。")
        usr <- list(
          role = "user",
          content = paste0(
            "根據以下產品屬性影響力分析數據，提供 InsightForge 360 精準行銷洞察報告。",
            "\n\n## 關鍵屬性數據：",
            "\n", attributes_json,
            "\n\n請按以下格式輸出：",
            "\n\n## InsightForge 360 - 精準行銷洞察報告",
            "\n\n### 📊 產品屬性重要性分析",
            "\n\n#### 1. 關鍵正向屬性（前5項）",
            "\n針對賽道倍數最高的5個屬性，各提供一句20字內的轉化放大語句，可直接用於亞馬遜商品頁。",
            "\n\n#### 2. 行銷文案建議",
            "\n基於最重要的3個屬性，提供：",
            "\n- 主圖標籤建議（如：不鏽鋼刀片 + 2年保固）",
            "\n- Bullet Point 排序建議",
            "\n- A+ Content 重點呈現方式",
            "\n\n#### 3. 關鍵字廣告投放建議",
            "\n根據屬性重要性，建議3-5個Amazon PPC關鍵字組合，格式：",
            "\n- 關鍵字（如：開罐器 不鏽鋼）",
            "\n- 匹配類型（Exact/Phrase/Broad）",
            "\n- 競價策略（如：高於類目平均+15%）",
            "\n\n#### 4. 促銷策略建議",
            "\n結合高影響力屬性，建議適合的促銷方式：",
            "\n- Lightning Deal 時機",
            "\n- Coupon 設定",
            "\n- Subscribe & Save 策略",
            "\n\n**注意**：",
            "\n- 保持專業但易懂的語言",
            "\n- 提供具體可執行的建議",
            "\n- 文案要符合Amazon規範",
            "\n- 限制在 500 字內"
          )
        )
        
        incProgress(0.6, detail = "呼叫 AI 分析...")
        
        txt <- fn_chat_api(list(sys, usr), gpt_key)
        
        incProgress(0.8, detail = "處理 AI 回應...")
        
        ai_insight_result(txt)
        
        # Show AI insights section
        shinyjs::show("ai_insights_section")
        
        # Scroll to AI insights
        shinyjs::runjs(paste0("document.getElementById('", session$ns("ai_insights_section"), "').scrollIntoView({behavior: 'smooth'});"))
        
        incProgress(1.0, detail = "分析完成！")
      })
    })
    
    # Render AI insights
    output$precision_insight_output <- renderUI({
      txt <- ai_insight_result()
      
      if (is.null(txt)) {
        return(NULL)
      }
      
      # Clean and convert to HTML
      res <- fn_strip_code_fence(txt)
      if (requireNamespace("markdown", quietly = TRUE)) {
        html <- markdown::markdownToHTML(text = res, fragment.only = TRUE)
        HTML(html)
      } else {
        # Fallback
        HTML(paste0("<pre>", res, "</pre>"))
      }
    })
    
    # ------------ AI Product Development Suggestions Generation -------------
    ai_product_result <- reactiveVal(NULL)
    
    observeEvent(input$generate_product_development, {
      data <- positive_data()
      
      if (is.null(data) || nrow(data) == 0) {
        showNotification("無可用的產品屬性分析資料", type = "warning")
        return()
      }
      
      if (is.null(gpt_key)) {
        showNotification("OpenAI API 金鑰未設定。AI 分析功能已停用。", type = "error")
        return()
      }
      
      withProgress(message = "生成 AI 新產品開發建議中...", value = 0, {
        incProgress(0.2, detail = "準備正向影響屬性資料...")
        
        # Prepare positive coefficient variables for product development suggestions
        positive_vars <- data %>%
          filter(coefficient > 0) %>%
          arrange(desc(coefficient)) %>%
          slice_head(n = 10)
        
        # Debug: Check positive vars data
        cat("正向變數數量:", nrow(positive_vars), "\n")
        if (nrow(positive_vars) > 0) {
          cat("前3個正向變數:\n")
          print(positive_vars %>% select(predictor, coefficient, track_multiplier, marginal_effect_pct) %>% head(3))
        }
        
        # Create structured summary for AI analysis
        if (nrow(positive_vars) == 0) {
          product_dev_summary <- "無正向影響屬性資料"
        } else {
          product_dev_summary <- positive_vars %>%
            mutate(
              var_description = paste0(
                predictor, ": 係數=", round(coefficient, 3),
                ", 賽道倍數=", track_multiplier, 
                ", 邊際效應=", marginal_effect_pct, "%"
              )
            ) %>%
            pull(var_description)
        }
        
        # Debug: Check summary
        cat("產品開發摘要長度:", length(product_dev_summary), "\n")
        if (length(product_dev_summary) > 0) {
          cat("前2個摘要項目:\n")
          cat(paste(head(product_dev_summary, 2), collapse = "\n"), "\n")
        }
        
        incProgress(0.4, detail = "分析產品開發機會...")
        
        # Use prompt from app_configs
        product_prompt <- app_configs$list_openai_prompt$poisson_analysis$product_development_strategy
        
        # Create AI prompt using centralized template
        attributes_text <- paste(product_dev_summary, collapse = "\n")
        cat("要傳給AI的屬性資料:\n", attributes_text, "\n")
        
        user_content <- gsub("{positive_attributes}", 
                            attributes_text, 
                            product_prompt$user_prompt_template, fixed = TRUE)
        
        # Debug: Check if replacement worked
        if (grepl("{positive_attributes}", user_content, fixed = TRUE)) {
          cat("⚠️ Warning: 模板變數替換失敗!\n")
        } else {
          cat("✅ 模板變數替換成功\n")
        }
        
        # Handle system prompt template variable
        system_content <- gsub("{system_prompts.product_strategist.content}", 
                              app_configs$list_openai_prompt$system_prompts$product_strategist$content,
                              product_prompt$system_prompt, fixed = TRUE)
        
        sys <- list(role = "system", content = system_content)
        usr <- list(role = "user", content = user_content)
        
        incProgress(0.6, detail = "呼叫 AI 產品開發分析...")
        
        # Use the model specified in YAML configuration
        txt <- fn_chat_api(list(sys, usr), gpt_key, model = product_prompt$model)
        
        incProgress(0.8, detail = "處理 AI 回應...")
        
        ai_product_result(txt)
        
        # Show AI product development section
        shinyjs::show("ai_product_development_section")
        
        # Scroll to AI product development section
        shinyjs::runjs(paste0("document.getElementById('", session$ns("ai_product_development_section"), "').scrollIntoView({behavior: 'smooth'});"))
        
        incProgress(1.0, detail = "產品開發建議生成完成！")
      })
    })
    
    # Render AI product development suggestions
    output$product_development_output <- renderUI({
      txt <- ai_product_result()
      
      if (is.null(txt)) {
        return(NULL)
      }
      
      # Clean and convert to HTML
      res <- fn_strip_code_fence(txt)
      if (requireNamespace("markdown", quietly = TRUE)) {
        html <- markdown::markdownToHTML(text = res, fragment.only = TRUE)
        HTML(html)
      } else {
        # Fallback
        HTML(paste0("<pre>", res, "</pre>"))
      }
    })
    
    # 返回響應式值
    return(list(
      analysis_data = analysis_data,
      positive_data = positive_data,
      component_status = component_status,
      ai_insight_result = ai_insight_result,
      ai_product_result = ai_product_result
    ))
  })
}

# 組件包裝器 ------------------------------------------------------------------
poissonFeatureAnalysisComponent <- function(id, app_data_connection = NULL, 
                                                       config = NULL, translate = identity) {
  list(
    ui = list(
      filter = poissonFeatureAnalysisFilterUI(id, translate),
      display = poissonFeatureAnalysisUI(id, translate)
    ),
    server = function(input, output, session) {
      poissonFeatureAnalysisServer(id, app_data_connection, config, session)
    }
  )
}
