# ============================================================================
# 第三列：顧客活躍度模組 (Customer Activity Index Module)
# ============================================================================
# Req #4.1: 新增顧客活躍度分析頁面
# CAI (Customer Activity Index) = 購買次數 / 距離最後購買天數
# 用於評估客戶的活躍程度

library(shiny)
library(bs4Dash)
library(DT)
library(plotly)
library(dplyr)

#' 顧客活躍度模組 UI
#'
#' @param id Module ID
#' @return UI elements
customerActivityUI <- function(id) {
  ns <- NS(id)

  tagList(
    # === 第一列：平均 CAI 值卡片 ===
    h4("📊 顧客活躍度總覽", style = "margin-bottom: 20px;"),

    fluidRow(
      column(3,
        bs4ValueBox(
          value = textOutput(ns("avg_cai"), inline = TRUE),
          subtitle = "平均 CAI 值",
          icon = icon("chart-line"),
          color = "info",
          width = 12
        )
      ),
      column(3,
        bs4ValueBox(
          value = textOutput(ns("active_pct"), inline = TRUE),
          subtitle = "活躍客戶比例",
          icon = icon("users"),
          color = "success",
          width = 12
        )
      ),
      column(3,
        bs4ValueBox(
          value = textOutput(ns("stable_pct"), inline = TRUE),
          subtitle = "穩定客戶比例",
          icon = icon("hand-point-right"),
          color = "warning",
          width = 12
        )
      ),
      column(3,
        bs4ValueBox(
          value = textOutput(ns("inactive_pct"), inline = TRUE),
          subtitle = "靜止客戶比例",
          icon = icon("bed"),
          color = "danger",
          width = 12
        )
      )
    ),

    # === 第二列：活躍度分群表格與圓餅圖 ===
    h4("📋 活躍度分群分析", style = "margin: 30px 0 20px 0;"),

    fluidRow(
      column(6,
        bs4Card(
          title = "活躍度分群統計",
          status = "info",
          solidHeader = TRUE,
          width = 12,
          DTOutput(ns("activity_segment_table"))
        )
      ),
      column(6,
        bs4Card(
          title = "活躍度分群佔比",
          status = "info",
          solidHeader = FALSE,
          width = 12,
          plotlyOutput(ns("activity_segment_pie"), height = "300px")
        )
      )
    ),

    # === 第三列：CAI 分布圖表（兩張圖）===
    h4("📈 CAI 分布分析", style = "margin: 30px 0 20px 0;"),

    fluidRow(
      column(6,
        bs4Card(
          title = "CAI 數值分布",
          status = "primary",
          solidHeader = FALSE,
          width = 12,
          plotlyOutput(ns("cai_distribution"), height = "350px")
        )
      ),
      column(6,
        bs4Card(
          title = "CAI × 購買金額關係",
          status = "primary",
          solidHeader = FALSE,
          width = 12,
          plotlyOutput(ns("cai_vs_monetary"), height = "350px")
        )
      )
    ),

    # === 第四列：客戶 CAI 詳細資料表 ===
    h4("📄 客戶 CAI 詳細資料", style = "margin: 30px 0 20px 0;"),

    fluidRow(
      column(12,
        bs4Card(
          title = "客戶活躍度詳細列表（前 100 筆）",
          status = "success",
          solidHeader = TRUE,
          width = 12,
          div(style = "margin-bottom: 10px;",
            downloadButton(ns("download_cai"), "下載完整資料",
                           class = "btn-success btn-sm", style = "margin-right: 10px;"),
            actionButton(ns("show_download_warning"), "下載說明",
                         icon = icon("info-circle"), class = "btn-info btn-sm")
          ),
          DTOutput(ns("cai_detail_table"))
        )
      )
    )
  )
}

#' 顧客活躍度模組 Server
#'
#' @param id Module ID
#' @param processed_data Reactive containing processed customer data
customerActivityServer <- function(id, processed_data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Reactive values
    values <- reactiveValues(
      cai_data = NULL,
      segment_data = NULL
    )

    # ==========================================================================
    # 計算 CAI 和分群
    # ==========================================================================
    observe({
      req(processed_data())

      tryCatch({
        # 計算 CAI = times / r_value
        # times = 購買次數（來自 tag_010_rfm_f）
        # r_value = 距離最後購買天數（來自 tag_009_rfm_r）

        cai_df <- processed_data() %>%
          filter(!is.na(tag_010_rfm_f) & !is.na(tag_009_rfm_r) & tag_009_rfm_r > 0) %>%
          mutate(
            cai = tag_010_rfm_f / tag_009_rfm_r  # CAI 計算公式
          )

        # 根據 CAI 值進行分群
        # 使用三分位數切分
        if (nrow(cai_df) > 0 && sum(!is.na(cai_df$cai)) > 0) {
          p33 <- quantile(cai_df$cai, 0.33, na.rm = TRUE)
          p67 <- quantile(cai_df$cai, 0.67, na.rm = TRUE)

          cai_df <- cai_df %>%
            mutate(
              activity_segment = case_when(
                is.na(cai) ~ "未知",
                cai >= p67 ~ "漸趨活躍戶",
                cai >= p33 ~ "穩定消費戶",
                TRUE ~ "漸趨靜止戶"
              )
            )

          values$cai_data <- cai_df

          # 計算分群統計
          values$segment_data <- cai_df %>%
            group_by(activity_segment) %>%
            summarise(
              客戶數量 = n(),
              百分比 = sprintf("%.1f%%", n() / nrow(cai_df) * 100),
              平均CAI值 = round(mean(cai, na.rm = TRUE), 2),
              .groups = "drop"
            ) %>%
            mutate(
              activity_segment = factor(activity_segment,
                                        levels = c("漸趨活躍戶", "穩定消費戶", "漸趨靜止戶", "未知"))
            ) %>%
            arrange(activity_segment)
        }
      }, error = function(e) {
        showNotification(
          paste("計算 CAI 時發生錯誤:", e$message),
          type = "error",
          duration = 5
        )
      })
    })

    # ==========================================================================
    # 第一列：總覽指標
    # ==========================================================================

    output$avg_cai <- renderText({
      req(values$cai_data)
      avg <- mean(values$cai_data$cai, na.rm = TRUE)
      format(round(avg, 2), big.mark = ",")
    })

    output$active_pct <- renderText({
      req(values$segment_data)
      seg <- values$segment_data %>% filter(activity_segment == "漸趨活躍戶")
      if (nrow(seg) > 0) {
        seg$百分比[1]
      } else {
        "0%"
      }
    })

    output$stable_pct <- renderText({
      req(values$segment_data)
      seg <- values$segment_data %>% filter(activity_segment == "穩定消費戶")
      if (nrow(seg) > 0) {
        seg$百分比[1]
      } else {
        "0%"
      }
    })

    output$inactive_pct <- renderText({
      req(values$segment_data)
      seg <- values$segment_data %>% filter(activity_segment == "漸趨靜止戶")
      if (nrow(seg) > 0) {
        seg$百分比[1]
      } else {
        "0%"
      }
    })

    # ==========================================================================
    # 第二列：活躍度分群表格與圓餅圖
    # ==========================================================================

    output$activity_segment_table <- renderDT({
      req(values$segment_data)

      datatable(
        values$segment_data %>% rename(分群 = activity_segment),
        options = list(
          dom = 't',
          ordering = FALSE,
          pageLength = 10
        ),
        rownames = FALSE
      ) %>%
        formatStyle(
          '分群',
          backgroundColor = styleEqual(
            c("漸趨活躍戶", "穩定消費戶", "漸趨靜止戶"),
            c("#d4edda", "#fff3cd", "#f8d7da")
          )
        )
    })

    output$activity_segment_pie <- renderPlotly({
      req(values$segment_data)

      plot_data <- values$segment_data %>%
        filter(activity_segment != "未知")

      plot_ly(
        data = plot_data,
        labels = ~activity_segment,
        values = ~客戶數量,
        type = 'pie',
        marker = list(
          colors = c("#28a745", "#ffc107", "#dc3545"),
          line = list(color = '#FFFFFF', width = 2)
        ),
        textinfo = 'label+percent',
        hovertemplate = paste0(
          "<b>%{label}</b><br>",
          "客戶數：%{value}<br>",
          "佔比：%{percent}<br>",
          "<extra></extra>"
        )
      ) %>%
        layout(
          showlegend = TRUE,
          legend = list(orientation = "v", x = 1, y = 0.5)
        )
    })

    # ==========================================================================
    # 第三列：CAI 分布圖表
    # ==========================================================================

    output$cai_distribution <- renderPlotly({
      req(values$cai_data)

      plot_ly(
        data = values$cai_data,
        x = ~cai,
        type = "histogram",
        marker = list(color = "#17a2b8"),
        nbinsx = 30
      ) %>%
        layout(
          xaxis = list(title = "CAI 數值"),
          yaxis = list(title = "客戶數"),
          title = ""
        )
    })

    output$cai_vs_monetary <- renderPlotly({
      req(values$cai_data)

      plot_ly(
        data = values$cai_data,
        x = ~tag_011_rfm_m,
        y = ~cai,
        color = ~activity_segment,
        colors = c("漸趨活躍戶" = "#28a745", "穩定消費戶" = "#ffc107", "漸趨靜止戶" = "#dc3545"),
        type = "scatter",
        mode = "markers",
        marker = list(size = 8, opacity = 0.6),
        text = ~paste0(
          "客戶ID: ", customer_id, "<br>",
          "購買金額: $", format(round(tag_011_rfm_m, 0), big.mark = ","), "<br>",
          "CAI: ", round(cai, 2), "<br>",
          "分群: ", activity_segment
        ),
        hoverinfo = "text"
      ) %>%
        layout(
          xaxis = list(title = "購買金額 M（元）"),
          yaxis = list(title = "CAI 值"),
          title = "",
          showlegend = TRUE
        )
    })

    # ==========================================================================
    # 第四列：客戶 CAI 詳細資料表
    # ==========================================================================

    output$cai_detail_table <- renderDT({
      req(values$cai_data)

      display_data <- values$cai_data %>%
        select(
          客戶ID = customer_id,
          CAI係數 = cai,
          顧客活躍度分群 = activity_segment,
          購買次數 = tag_010_rfm_f,
          最近購買天數 = tag_009_rfm_r,
          購買金額 = tag_011_rfm_m
        ) %>%
        arrange(desc(CAI係數)) %>%
        head(100)

      # 格式化數值
      display_data <- display_data %>%
        mutate(
          CAI係數 = round(CAI係數, 3),
          購買次數 = round(購買次數, 1),
          最近購買天數 = round(最近購買天數, 0),
          購買金額 = round(購買金額, 0)
        )

      datatable(
        display_data,
        options = list(
          pageLength = 20,
          scrollX = TRUE,
          dom = 'Bfrtip',
          buttons = c('copy', 'csv', 'excel')
        ),
        rownames = FALSE
      ) %>%
        formatStyle(
          '顧客活躍度分群',
          backgroundColor = styleEqual(
            c("漸趨活躍戶", "穩定消費戶", "漸趨靜止戶"),
            c("#d4edda", "#fff3cd", "#f8d7da")
          )
        ) %>%
        formatCurrency('購買金額', currency = "$", digits = 0)
    })

    # ==========================================================================
    # 下載功能
    # ==========================================================================

    # 下載說明 Modal
    observeEvent(input$show_download_warning, {
      showModal(modalDialog(
        title = "📥 下載說明",
        HTML("
          <p><strong>下載提醒：</strong></p>
          <p>若使用 EXCEL 開啟檔案出現亂碼，請用記事本重新開啟檔案，並點選：<strong>使用 BOM 的 UTF-8 儲存檔案</strong>後，再用 EXCEL 重新開啟檔案。</p>
          <hr>
          <p><strong>檔案內容：</strong></p>
          <ul>
            <li>客戶ID</li>
            <li>CAI 係數</li>
            <li>顧客活躍度分群（漸趨活躍戶/穩定消費戶/漸趨靜止戶）</li>
            <li>購買次數</li>
            <li>最近購買天數</li>
            <li>購買金額</li>
          </ul>
        "),
        easyClose = TRUE,
        footer = modalButton("關閉")
      ))
    })

    # 下載 CAI 資料
    output$download_cai <- downloadHandler(
      filename = function() {
        paste0("customer_activity_index_", Sys.Date(), ".csv")
      },
      content = function(file) {
        req(values$cai_data)

        export_data <- values$cai_data %>%
          select(
            客戶ID = customer_id,
            CAI係數 = cai,
            顧客活躍度分群 = activity_segment,
            購買次數 = tag_010_rfm_f,
            最近購買天數 = tag_009_rfm_r,
            購買金額 = tag_011_rfm_m
          ) %>%
          arrange(desc(CAI係數))

        write.csv(export_data, file, row.names = FALSE, fileEncoding = "UTF-8")
      }
    )
  })
}
