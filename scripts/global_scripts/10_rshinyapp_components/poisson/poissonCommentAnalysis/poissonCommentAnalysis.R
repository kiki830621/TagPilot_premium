#LOCK FILE
#
# poissonCommentAnalysis.R
# 產品賽道分析組件 - 專注於口碑評分效果
#
# Following principles:
# - MP56: Connected Component Principle
# - MP73: Interactive Visualization Preference 
# - R116: Enhanced Data Access with tbl2
# - R09: UI-Server-Defaults Triple
# -----------------------------------------------------------------------------

# helper ----------------------------------------------------------------------
`%+%` <- function(x, y) paste0(x, y)
`%||%` <- function(x, y) if (is.null(x)) y else x

# Filter UI --------------------------
poissonCommentAnalysisFilterUI <- function(id, translate = identity) {
  ns <- NS(id)
  
  wellPanel(
    style = "padding:15px;",
    h4(translate("市場賽道分析")),
    p(translate("分析口碑評分對銷量的影響力")),
    
    hr(),
    
    # AI Analysis button at the bottom
    actionButton(
      inputId = ns("generate_market_track_insight"),
      label = translate("生成 AI 市場賽道策略"),
      class = "btn-primary btn-block",
      icon = icon("magic")
    )
  )
}

# Display UI -------------------------
poissonCommentAnalysisUI <- function(id, translate = identity) {
  ns <- NS(id)
  
  tagList(
    # Include shinyjs dependency
    shinyjs::useShinyjs(),
    div(class = "component-header mb-3 text-center",
        h3(translate("⭐ 市場賽道分析")),
        p(translate("深入分析評分對銷量的影響，運用賽道倍數識別口碑管理的關鍵"))),
    
    # InsightForge 風格的摘要卡片
    fluidRow(
      column(3,
        div(class = "info-box bg-primary",
            div(class = "info-box-content",
                h4(textOutput(ns("rating_champion")), class = "text-white"),
                p(translate("⭐ 評分冠軍"), class = "text-white")))),
      column(3,
        div(class = "info-box bg-primary", 
            div(class = "info-box-content",
                h4(textOutput(ns("rating_multiplier_value")), class = "text-white"),
                p(translate("最大評分倍數"), class = "text-white")))),
      column(3,
        div(class = "info-box bg-info",
            div(class = "info-box-content",
                h4(textOutput(ns("review_champion")), class = "text-white"),
                p(translate("📝 評論冠軍"), class = "text-white")))),
      column(3,
        div(class = "info-box bg-info",
            div(class = "info-box-content",
                h4(textOutput(ns("review_effect_value")), class = "text-white"),
                p(translate("評論影響力"), class = "text-white"))))
    ),
    
    # 決策指南
    div(class = "alert alert-primary mb-3",
        h5("🎯 市場賽道決策指南"),
        tags$ul(
          tags$li("賽道倍數 > 3.0：核心競爭因素，決定市場地位"),
          tags$li("賽道倍數 2.0-3.0：重要影響指標，需重點優化"),
          tags$li("邊際效應 > 50%：每提升1分評分，銷量大幅增長"),
          tags$li("評分影響顯著：口碑管理是成功關鍵")
        )
    ),
    
    # 主要視覺化區域
    div(class = "component-output p-3",
        fluidRow(
          column(12,
            div(class = "card",
                div(class = "card-header",
                    h4("🏁 市場賽道倍數分析")),
                div(class = "card-body",
                    plotly::plotlyOutput(ns("rating_multiplier_plot"), height = "500px")))
          )
        ),
        br(),
        fluidRow(
          column(6,
            div(class = "card",
                div(class = "card-header",
                    h4("📈 評分維度影響力")),
                div(class = "card-body",
                    plotly::plotlyOutput(ns("rating_dimension_plot"), height = "400px")))
          ),
          column(6,
            div(class = "card",
                div(class = "card-header",
                    h4("💡 口碑策略建議")),
                div(class = "card-body",
                    htmlOutput(ns("rating_recommendation"))))
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
        # AI Market Track Insights Section
        fluidRow(
          column(12,
            div(class = "card",
                id = ns("ai_market_insights_section"),
                style = "display: none;",  # Initially hidden
                div(class = "card-header bg-info text-white",
                    h4("🤖 AI 市場賽道策略報告", style = "margin: 0; padding: 10px 0;")),
                div(class = "card-body", style = "padding: 30px;",
                    if (requireNamespace("shinycssloaders", quietly = TRUE)) {
                      shinycssloaders::withSpinner(
                        htmlOutput(ns("market_track_insight_output")),
                        type = 6,
                        color = "#17a2b8"
                      )
                    } else {
                      htmlOutput(ns("market_track_insight_output"))
                    }
                )
            )
          )
        )
    )
  )
}

# Server ------------------------------
poissonCommentAnalysisServer <- function(id, app_data_connection = NULL, config = NULL,
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
      
      # 固定使用 Cyberbiz
      "cbz"
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
        platform <- "cbz"  # 固定使用 Cyberbiz
        prod_line <- product_line_id()
        
        # 根據產品線選擇適當的表格
        if (prod_line == "all") {
          table_name <- paste0("df_", platform, "_poisson_analysis_all")
        } else {
          table_name <- paste0("df_", platform, "_poisson_analysis_", prod_line)
        }
        
        # 載入數據並篩選口碑相關屬性
        data <- tbl2(app_data_connection, table_name) %>%
          filter(convergence == "converged") %>%
          collect()
        
        # 篩選市場賽道屬性 - 選擇 numeric 類型且符合條件的變數
        data <- data %>%
          filter(predictor_type == "numeric" &
                 (grepl("[\u4e00-\u9fa5]", predictor) |  # 包含中文字元
                  grepl("rating", predictor, ignore.case = TRUE)) &  # 或包含 rating
                 !grepl("^[a-zA-Z_]+$", predictor) &  # 排除純英文變數（如 material）
                 !grepl("missing", predictor, ignore.case = TRUE) &  # 排除包含 missing 的變數
                 abs(coefficient) <= 5) %>%  # 排除係數過大的異常值
          mutate(
            # 分類市場競爭因素
            rating_type = case_when(
              grepl("customer_rating", predictor, ignore.case = TRUE) ~ "客戶評分",
              grepl("^rating$", predictor) ~ "整體評分",
              grepl("品質|質量|quality", predictor, ignore.case = TRUE) ~ "品質指標",
              grepl("價格|price|cost", predictor, ignore.case = TRUE) ~ "價格因素",
              grepl("配送|delivery|shipping", predictor, ignore.case = TRUE) ~ "配送服務",
              grepl("售後|服務|service|support", predictor, ignore.case = TRUE) ~ "服務品質",
              grepl("賣家|seller|vendor", predictor, ignore.case = TRUE) ~ "賣家信譽",
              grepl("diameter|height|size|mm|ratio", predictor, ignore.case = TRUE) ~ "產品規格",
              TRUE ~ "其他因素"
            ),
            # 限制邊際效應在合理範圍內
            marginal_effect_pct = round(ifelse(abs(coefficient) > 5,
                                              sign(coefficient) * 500,
                                              (exp(coefficient) - 1) * 100), 1),
            # 計算賽道倍數（對極大值進行更嚴格的限制）
            track_multiplier = round(
              ifelse(abs(coefficient) > 10, 
                     100,  # 極大係數直接設為 100
                     ifelse(abs(coefficient) > 2, 
                            exp(2) * (1 + (abs(coefficient) - 2) * 0.5),
                            exp(abs(coefficient)))), 1),
            # 商業意義解讀
            practical_meaning = case_when(
              track_multiplier >= 3.0 ~ "核心口碑因素，決定市場地位",
              track_multiplier >= 2.0 ~ "重要口碑指標，需持續優化",
              track_multiplier >= 1.5 ~ "有影響力，值得關注改進",
              TRUE ~ "影響較小，維持現狀即可"
            ),
            # 口碑解釋
            rating_explanation = paste0(rating_type, "從最低到最高，銷量可相差", track_multiplier, "倍")
          )
        
        component_status("ready")
        return(data)
        
      }, error = function(e) {
        warning("Error loading rating analysis data: ", e$message)
        component_status("error")
        data.frame()
      })
    })
    
    # 篩選顯示所有口碑屬性（包含正向和負向影響）
    positive_data <- reactive({
      data <- analysis_data()
      
      # 先看看有多少資料
      if (nrow(data) > 0) {
        cat("找到", nrow(data), "筆評分相關資料\n")
      }
      
      # 只顯示正向影響的因素（coefficient > 0），以便更好解釋
      # 在呈現層級過濾負係數，避免混淆
      data %>%
        filter(!is.na(coefficient) & !is.na(p_value) & 
               coefficient > 0) %>%
        arrange(desc(track_multiplier))  # 按倍數從大到小排序
    })
    
    # 摘要統計 - 評分冠軍（影響力最大的）
    output$rating_champion <- renderText({
      data <- positive_data()
      
      if (nrow(data) == 0) return("--")
      
      # 選擇影響力最大的（不論正負）- 直接使用第一筆（已按 track_multiplier 排序）
      top <- data[1, ]
      if (nchar(top$predictor) > 15) {
        paste0(substr(top$predictor, 1, 12), "...")
      } else {
        top$predictor
      }
    })
    
    output$rating_multiplier_value <- renderText({
      data <- positive_data()
      
      if (nrow(data) == 0) return("--")
      # 直接使用第一筆資料的賽道倍數（已按倍數排序）
      paste0(data$track_multiplier[1], " 倍")
    })
    
    # 評論冠軍（第二大影響力）
    output$review_champion <- renderText({
      data <- positive_data()
      
      if (nrow(data) < 2) return("--")
      
      # 使用第二筆資料
      top <- data[2, ]
      if (nchar(top$predictor) > 15) {
        paste0(substr(top$predictor, 1, 12), "...")
      } else {
        top$predictor
      }
    })
    
    output$review_effect_value <- renderText({
      data <- positive_data()
      
      if (nrow(data) < 2) return("--")
      
      # 使用第二筆資料的邊際效應
      paste0(abs(data$marginal_effect_pct[2]), "%")
    })
    
    # 口碑賽道倍數圖
    output$rating_multiplier_plot <- plotly::renderPlotly({
      # 顯示所有評分資料，不限於正向
      data <- positive_data() %>% 
        filter(!is.na(track_multiplier)) %>%
        slice_head(n = 15)  # 顯示前15筆
      
      if (nrow(data) == 0) {
        plotly::plot_ly() %>%
          plotly::add_text(x = 0.5, y = 0.5, text = "無口碑相關資料",
                          textposition = "center", showlegend = FALSE)
      } else {
        data <- data %>%
          mutate(
            hover_text = paste0(
              "口碑指標: ", predictor, "<br>",
              "類型: ", rating_type, "<br>",
              "賽道倍數: ", track_multiplier, " 倍<br>",
              "邊際效應: ", marginal_effect_pct, "%<br>",
              "商業意義: ", practical_meaning
            ),
            predictor_short = ifelse(nchar(predictor) > 25,
                                   paste0(substr(predictor, 1, 22), "..."),
                                   predictor)
          )
        
        plotly::plot_ly(data, 
                       x = ~track_multiplier,
                       y = ~reorder(predictor_short, track_multiplier),
                       type = "bar",
                       orientation = "h",
                       marker = list(color = ~track_multiplier,
                                   colorscale = list(c(0, "#E3F2FD"), c(0.5, "#2196F3"), c(1, "#0D47A1")),
                                   cmin = 1, cmax = max(data$track_multiplier)),
                       text = ~hover_text,
                       textposition = "none",
                       hoverinfo = "text") %>%
          plotly::layout(
            title = "",
            xaxis = list(title = "口碑賽道倍數（評分差異對銷量的影響倍數）"),
            yaxis = list(title = ""),
            shapes = list(
              list(type = "line", x0 = 3, x1 = 3, y0 = -0.5, y1 = length(unique(data$predictor)) - 0.5,
                   line = list(color = "darkblue", dash = "dash")),
              list(type = "line", x0 = 2, x1 = 2, y0 = -0.5, y1 = length(unique(data$predictor)) - 0.5,
                   line = list(color = "blue", dash = "dot"))
            )
          )
      }
    })
    
    # 評分維度影響力圖
    output$rating_dimension_plot <- plotly::renderPlotly({
      data <- positive_data() %>%
        group_by(rating_type) %>%
        summarise(
          avg_multiplier = mean(track_multiplier, na.rm = TRUE),
          avg_marginal = mean(abs(marginal_effect_pct), na.rm = TRUE),
          count = n()
        ) %>%
        arrange(desc(avg_multiplier))
      
      if (nrow(data) == 0) {
        plotly::plot_ly() %>%
          plotly::add_text(x = 0.5, y = 0.5, text = "無資料", showlegend = FALSE)
      } else {
        plotly::plot_ly(data,
                       x = ~rating_type,
                       y = ~avg_multiplier,
                       type = "bar",
                       marker = list(color = c("#0D47A1", "#1976D2", "#2196F3", "#64B5F6")),
                       text = ~paste0("平均倍數: ", round(avg_multiplier, 1), "倍<br>",
                                     "屬性數量: ", count),
                       textposition = "none",
                       hoverinfo = "text") %>%
          plotly::layout(
            title = "",
            xaxis = list(title = ""),
            yaxis = list(title = "平均賽道倍數"),
            showlegend = FALSE
          )
      }
    })
    
    # 口碑策略建議
    output$rating_recommendation <- renderUI({
      data <- positive_data()
      
      if (nrow(data) == 0) {
        return(p("暫無分析結果"))
      }
      
      # 找出最重要的口碑因素
      rating_top <- data %>% filter(rating_type == "整體評分") %>% slice(1)
      customer_top <- data %>% filter(rating_type == "客戶評分") %>% slice(1)
      
      recommendation <- tags$div(
        h5("⭐ 基於分析結果的口碑管理建議："),
        tags$ul(
          if (nrow(rating_top) > 0) {
            tags$li(tags$strong("評分優化："), 
                    paste0("重點提升「", rating_top$predictor, "」，",
                          "每提升1分可增加銷量", abs(rating_top$marginal_effect_pct), "%"))
          },
          if (nrow(customer_top) > 0) {
            tags$li(tags$strong("客戶評分："),
                    paste0("優化「", customer_top$predictor, "」，",
                          "從最低到最高可讓銷量相差", customer_top$track_multiplier, "倍"))
          },
          tags$li(tags$strong("資源配置："),
                  "優先改善賽道倍數>3的口碑指標，這些是決定市場地位的關鍵")
        ),
        br(),
        tags$div(class = "alert alert-primary",
          tags$strong("執行策略："),
          "建立「評分提升+評論增長」雙軌策略，持續監控口碑指標變化"
        )
      )
      
      return(recommendation)
    })
    
    # 詳細表格
    output$analysis_table <- DT::renderDT({
      # 使用 positive_data，只顯示正向影響的資料
      data <- positive_data()
      
      # 除錯訊息
      cat("分析表格資料筆數:", nrow(data), "\n")
      
      if (nrow(data) == 0) {
        return(data.frame(訊息 = "無口碑相關資料"))
      }
      
      table_data <- data %>%
        dplyr::select(
          predictor,
          rating_type,
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
      
      colnames(table_data) <- c("口碑指標", "類型", "賽道倍數", "邊際效應%", 
                               "商業意義", "係數", "P值", "樣本數", "顯著性")
      
      DT::datatable(table_data,
                options = list(
                  pageLength = 10,
                  scrollX = TRUE,
                  dom = 'Bfrtip',
                  buttons = list(
                    list(extend = 'excel', text = '下載Excel', 
                         filename = 'InsightForge_口碑影響力分析')
                  ),
                  order = list(list(2, 'desc'))  # 預設按賽道倍數排序
                ),
                extensions = c("Buttons"),
                rownames = FALSE) %>%
        formatStyle("賽道倍數",
                   backgroundColor = styleInterval(c(2.0, 3.0), 
                                                 c("white", "#E3F2FD", "#BBDEFB")),
                   fontWeight = styleInterval(3.0, c("normal", "bold"))) %>%
        formatStyle("顯著性",
                   color = styleEqual(c("*", "**", "***"), 
                                    c("#2196F3", "#1976D2", "#0D47A1")))
    })
    
    # ------------ AI Market Track Insights Generation --------------------
    ai_insight_result <- reactiveVal(NULL)
    
    # Get OpenAI API key from environment
    gpt_key <- Sys.getenv("OPENAI_API_KEY", "")
    if (!nzchar(gpt_key)) {
      gpt_key <- NULL
    }
    
    observeEvent(input$generate_market_track_insight, {
      data <- positive_data()
      
      if (is.null(data) || nrow(data) == 0) {
        showNotification("無可用的市場賽道分析資料", type = "warning")
        return()
      }
      
      if (is.null(gpt_key)) {
        showNotification("OpenAI API 金鑰未設定。AI 分析功能已停用。", type = "error")
        return()
      }
      
      withProgress(message = "生成 AI 市場賽道策略報告中...", value = 0, {
        incProgress(0.2, detail = "準備口碑數據...")
        
        # Prepare rating/review data for AI analysis
        rating_summary <- data %>%
          group_by(rating_type) %>%
          summarise(
            avg_track_multiplier = round(mean(track_multiplier, na.rm = TRUE), 2),
            max_track_multiplier = round(max(track_multiplier, na.rm = TRUE), 2),
            avg_marginal_effect = round(mean(abs(marginal_effect_pct), na.rm = TRUE), 1),
            count = n()
          ) %>%
          arrange(desc(avg_track_multiplier))
        
        # Get top individual factors
        top_factors <- data %>%
          slice_head(n = 8) %>%
          mutate(
            factor_summary = paste0(
              predictor, " (", rating_type, "): ",
              "賽道倍數=", track_multiplier, 
              ", 邊際效應=", abs(marginal_effect_pct), "%"
            )
          ) %>%
          pull(factor_summary)
        
        incProgress(0.4, detail = "分析口碑影響...")
        
        # OpenAI functions should already be loaded from union_production_test.R
        if (!exists("fn_chat_api")) {
          stop("OpenAI functions not loaded. Please check union_production_test.R initialization.")
        }
        
        # Create prompt
        sys <- list(role = "system", content = "你是專業的電商口碑管理顧問，擅長評分優化和市場定位策略。請用繁體中文回答。")
        usr <- list(
          role = "user",
          content = paste0(
            "根據以下市場賽道（口碑評分）分析數據，提供策略報告。",
            "\n\n## 口碑類型影響力統計：",
            "\n", jsonlite::toJSON(rating_summary, dataframe = "rows", auto_unbox = TRUE),
            "\n\n## 前8大影響因素：",
            "\n", paste(top_factors, collapse = "\n"),
            "\n\n請按以下格式輸出：",
            "\n\n## 🌟 市場賽道策略報告",
            "\n\n### 1. 口碑影響力診斷",
            "\n分析哪些口碑因素對銷量影響最大，說明賽道倍數的商業意義。",
            "\n\n### 2. 評分提升行動方案",
            "\n針對影響力最大的3個因素，各提供一項具體改善建議，格式：",
            "\n- 因素名稱：具體行動（20字內）",
            "\n\n### 3. 競爭者對比策略",
            "\n基於口碑賽道分析，建議：",
            "\n- 如何突出優勢評分",
            "\n- 如何改善劣勢評分",
            "\n- 市場定位調整方向",
            "\n\n### 4. 新產品開發建議",
            "\n根據高影響力的口碑因素，建議下一代產品應：",
            "\n- 強化哪些屬性（基於高賽道倍數因素）",
            "\n- 改進哪些功能（基於負面評價因素）",
            "\n- 創新方向（基於市場缺口）",
            "\n\n**注意**：",
            "\n- 保持專業但易懂的語言",
            "\n- 提供具體可執行的建議",
            "\n- 限制在 450 字內"
          )
        )
        
        incProgress(0.6, detail = "呼叫 AI 分析...")
        
        txt <- fn_chat_api(list(sys, usr), gpt_key)
        
        incProgress(0.8, detail = "處理 AI 回應...")
        
        ai_insight_result(txt)
        
        # Show AI insights section
        shinyjs::show("ai_market_insights_section")
        
        # Scroll to AI insights
        shinyjs::runjs(paste0("document.getElementById('", session$ns("ai_market_insights_section"), "').scrollIntoView({behavior: 'smooth'});"))
        
        incProgress(1.0, detail = "分析完成！")
      })
    })
    
    # Render AI insights
    output$market_track_insight_output <- renderUI({
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
    
    # 返回響應式值
    return(list(
      analysis_data = analysis_data,
      positive_data = positive_data,
      component_status = component_status,
      ai_insight_result = ai_insight_result
    ))
  })
}

# 組件包裝器 ------------------------------------------------------------------
poissonCommentAnalysisComponent <- function(id, app_data_connection = NULL, 
                                          config = NULL, translate = identity) {
  list(
    ui = list(
      filter = poissonCommentAnalysisFilterUI(id, translate),
      display = poissonCommentAnalysisUI(id, translate)
    ),
    server = function(input, output, session) {
      poissonCommentAnalysisServer(id, app_data_connection, config, session)
    }
  )
}