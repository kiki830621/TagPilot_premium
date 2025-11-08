# ==============================================================================
# R/S/V Matrix Module (Risk-Stability-Value)
# ==============================================================================
# Purpose: Customer vitality analysis using three dimensions:
#   - R (Risk): Dormancy risk based on recency
#   - S (Stability): Transaction regularity based on IPT variance
#   - V (Value): Customer lifetime value prediction
#
# Author: Claude AI Assistant
# Date: 2025-10-25
# Version: 1.0
# ==============================================================================

library(shiny)
library(bs4Dash)
library(dplyr)
library(DT)
library(plotly)
library(purrr)

# ==============================================================================
# UI Function
# ==============================================================================

rsvMatrixUI <- function(id) {
  ns <- NS(id)

  div(
    h3("R/S/V 顧客生命力矩陣"),
    p(class = "text-muted",
      "整合三維度分析：R (靜止風險) × S (交易穩定度) × V (終生價值)，提供 27 種客戶類型與策略建議"),

    # Status panel
    wellPanel(
      style = "background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none;",
      h4("📊 分析狀態", style = "color: white; margin-top: 0;"),
      verbatimTextOutput(ns("status"))
    ),

    # Key metrics cards
    fluidRow(
      column(4,
        bs4Card(
          title = "🔴 高風險客戶",
          status = "danger",
          solidHeader = TRUE,
          width = 12,
          div(
            h2(textOutput(ns("high_risk_count")), style = "margin: 0;"),
            p(textOutput(ns("high_risk_pct")), class = "text-muted")
          )
        )
      ),
      column(4,
        bs4Card(
          title = "⭐ 高穩定客戶",
          status = "success",
          solidHeader = TRUE,
          width = 12,
          div(
            h2(textOutput(ns("high_stability_count")), style = "margin: 0;"),
            p(textOutput(ns("high_stability_pct")), class = "text-muted")
          )
        )
      ),
      column(4,
        bs4Card(
          title = "💎 高價值客戶",
          status = "warning",
          solidHeader = TRUE,
          width = 12,
          div(
            h2(textOutput(ns("high_value_count")), style = "margin: 0;"),
            p(textOutput(ns("high_value_pct")), class = "text-muted")
          )
        )
      )
    ),

    # R/S/V Distribution Charts
    fluidRow(
      column(4,
        bs4Card(
          title = "R - 靜止風險分布",
          status = "info",
          solidHeader = TRUE,
          width = 12,
          plotlyOutput(ns("risk_distribution"))
        )
      ),
      column(4,
        bs4Card(
          title = "S - 交易穩定度分布",
          status = "info",
          solidHeader = TRUE,
          width = 12,
          plotlyOutput(ns("stability_distribution"))
        )
      ),
      column(4,
        bs4Card(
          title = "V - 終生價值分布",
          status = "info",
          solidHeader = TRUE,
          width = 12,
          plotlyOutput(ns("value_distribution"))
        )
      )
    ),

    # 3D Matrix Visualization
    bs4Card(
      title = "R × S × V 生命力矩陣（三維可視化）",
      status = "primary",
      solidHeader = TRUE,
      width = 12,
      p(class = "text-muted", "點擊任一格查看該類客戶名單與策略建議"),
      plotlyOutput(ns("rsv_3d_scatter"), height = "600px")
    ),

    # Matrix Heatmap (R × S with V as color)
    bs4Card(
      title = "R × S 矩陣（V 作為顏色深度）",
      status = "primary",
      solidHeader = TRUE,
      width = 12,
      plotlyOutput(ns("rsv_heatmap"), height = "500px")
    ),

    # Strategy Table
    bs4Card(
      title = "客戶類型與策略對應表",
      status = "success",
      solidHeader = TRUE,
      width = 12,
      DTOutput(ns("strategy_table"))
    ),

    # Customer Detail Table
    bs4Card(
      title = "客戶明細（含 R/S/V 標籤）",
      status = "info",
      solidHeader = TRUE,
      width = 12,
      DTOutput(ns("customer_table")),
      downloadButton(ns("download_data"), "📥 下載完整資料 (CSV)", class = "btn-primary mt-3")
    )
  )
}

# ==============================================================================
# Server Function
# ==============================================================================

rsvMatrixServer <- function(id, customer_data) {
  moduleServer(id, function(input, output, session) {

    # Reactive values
    values <- reactiveValues(
      processed_data = NULL,
      strategy_summary = NULL
    )

    # ===========================================================================
    # Data Processing
    # ===========================================================================

    observe({
      req(customer_data())

      tryCatch({
        df <- customer_data()

        # Calculate R/S/V metrics
        df_rsv <- df %>%
          # R (Risk): Based on recency
          mutate(
            r_percentile_80 = quantile(r_value, 0.8, na.rm = TRUE),
            r_percentile_20 = quantile(r_value, 0.2, na.rm = TRUE),
            r_level = case_when(
              r_value >= r_percentile_80 ~ "高",
              r_value >= r_percentile_20 ~ "中",
              TRUE ~ "低"
            ),
            tag_032_dormancy_risk = case_when(
              r_level == "高" ~ "高靜止戶",
              r_level == "中" ~ "中靜止戶",
              TRUE ~ "低靜止戶"
            )
          ) %>%
          # S (Stability): Based on transaction frequency
          mutate(
            # Use transaction count (ni) as stability proxy
            # More transactions = more stable behavior pattern
            # If ipt_sd exists, use it; otherwise use ni
            stability_metric = if("ipt_sd" %in% names(.)) {
              ifelse(ipt_mean > 0, ipt_sd / ipt_mean, 0)
            } else {
              ni  # Use transaction count as proxy
            },
            stability_metric = ifelse(is.na(stability_metric) | is.infinite(stability_metric), 0, stability_metric),
            s_percentile_20 = quantile(stability_metric, 0.2, na.rm = TRUE),
            s_percentile_80 = quantile(stability_metric, 0.8, na.rm = TRUE),
            # For ni-based: higher ni = higher stability
            # For CV-based: lower CV = higher stability
            s_level = if("ipt_sd" %in% names(.)) {
              case_when(
                stability_metric <= s_percentile_20 ~ "高",  # Low CV = High stability
                stability_metric <= s_percentile_80 ~ "中",
                TRUE ~ "低"
              )
            } else {
              case_when(
                stability_metric >= s_percentile_80 ~ "高",  # High ni = High stability
                stability_metric >= s_percentile_20 ~ "中",
                TRUE ~ "低"
              )
            },
            tag_033_transaction_stability = case_when(
              s_level == "高" ~ "高穩定",
              s_level == "中" ~ "中穩定",
              TRUE ~ "低穩定"
            ),
            # Store the actual metric for display
            stability_cv = stability_metric
          ) %>%
          # V (Value): Simplified CLV calculation
          mutate(
            # CLV = Average Order Value × Purchase Frequency × Expected Lifetime
            # Simplified: use historical M value as proxy
            clv = m_value * (f_value / 365) * 365,  # Annualized value
            v_percentile_80 = quantile(clv, 0.8, na.rm = TRUE),
            v_percentile_20 = quantile(clv, 0.2, na.rm = TRUE),
            v_level = case_when(
              clv >= v_percentile_80 ~ "高",
              clv >= v_percentile_20 ~ "中",
              TRUE ~ "低"
            ),
            tag_034_customer_lifetime_value = case_when(
              v_level == "高" ~ "高價值",
              v_level == "中" ~ "中價值",
              TRUE ~ "低價值"
            )
          ) %>%
          # Combine R/S/V for customer type
          mutate(
            rsv_key = paste0(r_level, s_level, v_level),
            customer_type = map_chr(rsv_key, get_customer_type),
            strategy = map_chr(rsv_key, get_strategy_text),
            action = map_chr(rsv_key, get_action_text)
          )

        values$processed_data <- df_rsv

        # Generate strategy summary
        strategy_summary <- df_rsv %>%
          group_by(customer_type, r_level, s_level, v_level, strategy, action) %>%
          summarise(
            customer_count = n(),
            percentage = round(n() / nrow(df_rsv) * 100, 1),
            avg_clv = round(mean(clv, na.rm = TRUE), 0),
            .groups = "drop"
          ) %>%
          arrange(desc(customer_count))

        values$strategy_summary <- strategy_summary

      }, error = function(e) {
        showNotification(
          paste("R/S/V 矩陣計算錯誤:", e$message),
          type = "error",
          duration = 10
        )
      })
    })

    # ===========================================================================
    # Status Output
    # ===========================================================================

    output$status <- renderText({
      if (is.null(values$processed_data)) {
        return("⏳ 等待資料...")
      }

      df <- values$processed_data
      n_total <- nrow(df)
      n_types <- length(unique(df$customer_type))

      paste0(
        "✅ R/S/V 矩陣計算完成\n",
        "總客戶數：", n_total, " 人\n",
        "客戶類型數：", n_types, " 種\n",
        "分析維度：R (風險) × S (穩定) × V (價值)"
      )
    })

    # ===========================================================================
    # Key Metrics
    # ===========================================================================

    output$high_risk_count <- renderText({
      req(values$processed_data)
      df <- values$processed_data
      high_risk <- sum(df$r_level == "高", na.rm = TRUE)
      paste0(high_risk, " 人")
    })

    output$high_risk_pct <- renderText({
      req(values$processed_data)
      df <- values$processed_data
      pct <- round(sum(df$r_level == "高", na.rm = TRUE) / nrow(df) * 100, 1)
      paste0(pct, "% 客戶處於高流失風險")
    })

    output$high_stability_count <- renderText({
      req(values$processed_data)
      df <- values$processed_data
      high_stable <- sum(df$s_level == "高", na.rm = TRUE)
      paste0(high_stable, " 人")
    })

    output$high_stability_pct <- renderText({
      req(values$processed_data)
      df <- values$processed_data
      pct <- round(sum(df$s_level == "高", na.rm = TRUE) / nrow(df) * 100, 1)
      paste0(pct, "% 客戶交易穩定")
    })

    output$high_value_count <- renderText({
      req(values$processed_data)
      df <- values$processed_data
      high_value <- sum(df$v_level == "高", na.rm = TRUE)
      paste0(high_value, " 人")
    })

    output$high_value_pct <- renderText({
      req(values$processed_data)
      df <- values$processed_data
      pct <- round(sum(df$v_level == "高", na.rm = TRUE) / nrow(df) * 100, 1)
      paste0(pct, "% 客戶為高終生價值")
    })

    # ===========================================================================
    # Distribution Charts
    # ===========================================================================

    output$risk_distribution <- renderPlotly({
      req(values$processed_data)
      df <- values$processed_data

      dist_data <- df %>%
        group_by(tag_032_dormancy_risk) %>%
        summarise(count = n(), .groups = "drop") %>%
        mutate(
          percentage = round(count / sum(count) * 100, 1),
          label = paste0(tag_032_dormancy_risk, "\n", count, " 人 (", percentage, "%)")
        )

      plot_ly(dist_data,
              labels = ~tag_032_dormancy_risk,
              values = ~count,
              type = 'pie',
              marker = list(colors = c("高靜止戶" = "#ef4444", "中靜止戶" = "#f59e0b", "低靜止戶" = "#10b981")),
              textinfo = 'label+percent',
              hoverinfo = 'text',
              text = ~label) %>%
        layout(showlegend = TRUE,
               legend = list(orientation = "h", y = -0.1))
    })

    output$stability_distribution <- renderPlotly({
      req(values$processed_data)
      df <- values$processed_data

      dist_data <- df %>%
        group_by(tag_033_transaction_stability) %>%
        summarise(count = n(), .groups = "drop") %>%
        mutate(
          percentage = round(count / sum(count) * 100, 1),
          label = paste0(tag_033_transaction_stability, "\n", count, " 人 (", percentage, "%)")
        )

      plot_ly(dist_data,
              labels = ~tag_033_transaction_stability,
              values = ~count,
              type = 'pie',
              marker = list(colors = c("高穩定" = "#10b981", "中穩定" = "#f59e0b", "低穩定" = "#ef4444")),
              textinfo = 'label+percent',
              hoverinfo = 'text',
              text = ~label) %>%
        layout(showlegend = TRUE,
               legend = list(orientation = "h", y = -0.1))
    })

    output$value_distribution <- renderPlotly({
      req(values$processed_data)
      df <- values$processed_data

      dist_data <- df %>%
        group_by(tag_034_customer_lifetime_value) %>%
        summarise(count = n(), .groups = "drop") %>%
        mutate(
          percentage = round(count / sum(count) * 100, 1),
          label = paste0(tag_034_customer_lifetime_value, "\n", count, " 人 (", percentage, "%)")
        )

      plot_ly(dist_data,
              labels = ~tag_034_customer_lifetime_value,
              values = ~count,
              type = 'pie',
              marker = list(colors = c("高價值" = "#8b5cf6", "中價值" = "#3b82f6", "低價值" = "#6b7280")),
              textinfo = 'label+percent',
              hoverinfo = 'text',
              text = ~label) %>%
        layout(showlegend = TRUE,
               legend = list(orientation = "h", y = -0.1))
    })

    # ===========================================================================
    # 3D Scatter Plot (R × S × V)
    # ===========================================================================

    output$rsv_3d_scatter <- renderPlotly({
      req(values$processed_data)
      df <- values$processed_data

      # Map levels to numeric values for 3D plot
      df_plot <- df %>%
        mutate(
          r_numeric = case_when(r_level == "低" ~ 1, r_level == "中" ~ 2, r_level == "高" ~ 3),
          s_numeric = case_when(s_level == "低" ~ 1, s_level == "中" ~ 2, s_level == "高" ~ 3),
          v_numeric = case_when(v_level == "低" ~ 1, v_level == "中" ~ 2, v_level == "高" ~ 3),
          hover_text = paste0(
            "客戶類型：", customer_type, "<br>",
            "R (風險)：", tag_032_dormancy_risk, "<br>",
            "S (穩定)：", tag_033_transaction_stability, "<br>",
            "V (價值)：", tag_034_customer_lifetime_value, "<br>",
            "策略：", strategy
          )
        )

      plot_ly(df_plot,
              x = ~r_numeric,
              y = ~s_numeric,
              z = ~v_numeric,
              color = ~customer_type,
              type = 'scatter3d',
              mode = 'markers',
              marker = list(size = 5, opacity = 0.7),
              hovertext = ~hover_text,
              hoverinfo = 'text') %>%
        layout(
          scene = list(
            xaxis = list(title = "R - 靜止風險", tickvals = c(1, 2, 3), ticktext = c("低", "中", "高")),
            yaxis = list(title = "S - 交易穩定度", tickvals = c(1, 2, 3), ticktext = c("低", "中", "高")),
            zaxis = list(title = "V - 終生價值", tickvals = c(1, 2, 3), ticktext = c("低", "中", "高"))
          ),
          legend = list(orientation = "v", x = 1.05, y = 1)
        )
    })

    # ===========================================================================
    # Heatmap (R × S with V as color)
    # ===========================================================================

    output$rsv_heatmap <- renderPlotly({
      req(values$processed_data)
      df <- values$processed_data

      # Create heatmap data
      heatmap_data <- df %>%
        group_by(r_level, s_level, v_level) %>%
        summarise(count = n(), .groups = "drop") %>%
        group_by(r_level, s_level) %>%
        summarise(
          total_count = sum(count),
          high_value_pct = round(sum(count[v_level == "高"]) / sum(count) * 100, 1),
          .groups = "drop"
        )

      # Create matrix
      matrix_data <- heatmap_data %>%
        tidyr::pivot_wider(
          names_from = s_level,
          values_from = total_count,
          values_fill = 0
        ) %>%
        arrange(desc(r_level))

      plot_ly(
        x = c("低", "中", "高"),
        y = c("高", "中", "低"),
        z = as.matrix(matrix_data[, -1]),
        type = "heatmap",
        colorscale = "Viridis",
        hovertemplate = "R風險: %{y}<br>S穩定: %{x}<br>客戶數: %{z}<extra></extra>"
      ) %>%
        layout(
          xaxis = list(title = "S - 交易穩定度"),
          yaxis = list(title = "R - 靜止風險"),
          title = "客戶分布熱力圖（顏色深度代表客戶數量）"
        )
    })

    # ===========================================================================
    # Strategy Table
    # ===========================================================================

    output$strategy_table <- renderDT({
      req(values$strategy_summary)

      datatable(
        values$strategy_summary %>%
          select(
            `客戶類型` = customer_type,
            `R風險` = r_level,
            `S穩定` = s_level,
            `V價值` = v_level,
            `客戶數` = customer_count,
            `占比(%)` = percentage,
            `平均CLV` = avg_clv,
            `建議策略` = strategy,
            `行動方案` = action
          ),
        options = list(
          pageLength = 10,
          scrollX = TRUE,
          order = list(list(4, 'desc'))  # Sort by customer count
        ),
        rownames = FALSE,
        class = 'cell-border stripe hover'
      )
    })

    # ===========================================================================
    # Customer Detail Table
    # ===========================================================================

    output$customer_table <- renderDT({
      req(values$processed_data)

      datatable(
        values$processed_data %>%
          select(
            `客戶ID` = customer_id,
            `R風險` = tag_032_dormancy_risk,
            `S穩定` = tag_033_transaction_stability,
            `V價值` = tag_034_customer_lifetime_value,
            `客戶類型` = customer_type,
            `建議策略` = strategy,
            `R值(天)` = r_value,
            `穩定係數` = stability_cv,
            `預估CLV` = clv,
            `交易次數` = ni,
            `歷史總額` = m_value
          ) %>%
          mutate(
            `R值(天)` = round(`R值(天)`, 1),
            `穩定係數` = round(`穩定係數`, 2),
            `預估CLV` = round(`預估CLV`, 0)
          ),
        options = list(
          pageLength = 25,
          scrollX = TRUE,
          order = list(list(8, 'desc'))  # Sort by CLV
        ),
        rownames = FALSE,
        class = 'cell-border stripe hover',
        filter = 'top'
      )
    })

    # ===========================================================================
    # Download Handler
    # ===========================================================================

    output$download_data <- downloadHandler(
      filename = function() {
        paste0("rsv_matrix_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
      },
      content = function(file) {
        req(values$processed_data)

        export_df <- values$processed_data %>%
          select(
            customer_id,
            tag_032_dormancy_risk,
            tag_033_transaction_stability,
            tag_034_customer_lifetime_value,
            customer_type,
            strategy,
            action,
            r_value,
            stability_cv,
            clv,
            ni,
            m_value,
            ipt_mean,
            ipt_sd
          )

        write.csv(export_df, file, row.names = FALSE, fileEncoding = "UTF-8")
      }
    )

    # ===========================================================================
    # Return processed data for downstream modules
    # ===========================================================================

    return(reactive({ values$processed_data }))
  })
}

# ==============================================================================
# Helper Functions: Customer Type & Strategy Mapping
# ==============================================================================

get_customer_type <- function(rsv_key) {
  # Map 27 combinations to customer types
  type_map <- list(
    "低高高" = "金鑽客",
    "低高中" = "成長型忠誠客",
    "低高低" = "穩定小資客",
    "低中高" = "潛力VIP",
    "低中中" = "標準優質客",
    "低中低" = "一般穩定客",
    "低低高" = "不規律高值客",
    "低低中" = "偶發型消費者",
    "低低低" = "散客",

    "中高高" = "預警高值客",
    "中高中" = "預警成長客",
    "中高低" = "穩定觀望客",
    "中中高" = "觀察期VIP",
    "中中中" = "觀察期標準客",
    "中中低" = "觀察期小客",
    "中低高" = "不穩定高值客",
    "中低中" = "不穩定中值客",
    "中低低" = "不穩定小客",

    "高高高" = "流失風險VIP",
    "高高中" = "流失風險忠誠客",
    "高高低" = "流失風險穩定客",
    "高中高" = "待喚回高值客",
    "高中中" = "待喚回中值客",
    "高中低" = "待喚回小客",
    "高低高" = "沉睡VIP",
    "高低中" = "沉睡中客",
    "高低低" = "沉睡客"
  )

  type_map[[rsv_key]] %||% "一般客群"
}

get_strategy_text <- function(rsv_key) {
  # Map 27 combinations to strategies
  strategy_map <- list(
    "低高高" = "VIP體驗 + 品牌共創",
    "低高中" = "升級誘因",
    "低高低" = "穩定維護",
    "低中高" = "VIP培育",
    "低中中" = "標準服務",
    "低中低" = "基礎維護",
    "低低高" = "行為穩定化",
    "低低中" = "促進復購",
    "低低低" = "基本接觸",

    "中高高" = "早期挽回",
    "中高中" = "活躍度提升",
    "中高低" = "持續關注",
    "中中高" = "VIP預警",
    "中中中" = "觀察維護",
    "中中低" = "輕度喚醒",
    "中低高" = "行為穩定 + VIP保留",
    "中低中" = "促進規律化",
    "中低低" = "最低成本維護",

    "高高高" = "頂級挽回",
    "高高中" = "忠誠客挽回",
    "高高低" = "穩定客喚回",
    "高中高" = "VIP喚回",
    "高中中" = "中值客喚回",
    "高中低" = "低成本喚回",
    "高低高" = "VIP再激活",
    "高低中" = "中客再激活",
    "高低低" = "冷啟策略"
  )

  strategy_map[[rsv_key]] %||% "標準行銷"
}

get_action_text <- function(rsv_key) {
  # Map 27 combinations to action plans
  action_map <- list(
    "低高高" = "專屬客服、新品搶先體驗、會員大使計畫",
    "低高中" = "搭售組合、滿額升級、會員積分任務",
    "低高低" = "定期EDM、節慶問候、小額回饋",
    "低中高" = "VIP邀請、專屬優惠、升級路徑",
    "低中中" = "定期促銷、會員福利、推薦獎勵",
    "低中低" = "基礎EDM、通用優惠券",
    "低低高" = "購買提醒、定期回購方案、行為培養",
    "低低中" = "促銷推播、回購優惠",
    "低低低" = "廣告曝光、基本聯繫",

    "中高高" = "VIP喚醒禮、定向廣告、回購提醒",
    "中高中" = "活躍度挑戰、積分加碼、限時優惠",
    "中高低" = "關懷訊息、小額誘因",
    "中中高" = "VIP專線、專屬折扣、早鳥通知",
    "中中中" = "標準促銷、會員關懷",
    "中中低" = "溫和提醒、通用優惠",
    "中低高" = "行為穩定方案 + VIP保留策略",
    "中低中" = "購買週期提醒、規律化激勵",
    "中低低" = "低成本EDM、自動化提醒",

    "高高高" = "專人致電、超值挽回禮、VIP特權恢復",
    "高高中" = "忠誠客專屬挽回、深度折扣",
    "高高低" = "回流優惠券、再行銷廣告",
    "高中高" = "VIP喚回專案、專屬優惠、客服致電",
    "高中中" = "回購大禮包、限時折扣",
    "高中低" = "基本回流券、廣告再觸及",
    "高低高" = "VIP再激活計畫、高價值誘因",
    "高低中" = "再註冊誘因、廣告曝光",
    "高低低" = "低成本廣告、冷啟動優惠"
  )

  action_map[[rsv_key]] %||% "常規促銷活動"
}
