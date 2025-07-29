# Multi-File DNA Analysis Module
# Supports Amazon sales data and general transaction files

library(shiny)
library(shinyjs)
library(dplyr)
library(DT)
library(plotly)
library(readxl)
library(later)

# Helper functions from microDNADistribution component
`%+%` <- function(x, y) paste0(x, y)
`%||%` <- function(x, y) if (is.null(x)) y else x
nrow2 <- function(x) {
  if (is.null(x)) return(0)
  if (!is.data.frame(x) && !is.matrix(x)) return(0)
  return(nrow(x))
}

# Source DNA analysis function
if (file.exists("scripts/global_scripts/04_utils/fn_analysis_dna.R")) {
  source("scripts/global_scripts/04_utils/fn_left_join_remove_duplicate2.R")
source("scripts/global_scripts/04_utils/fn_fct_na_value_to_level.R")
source("scripts/global_scripts/04_utils/fn_analysis_dna.R")
}

# UI Function
dnaMultiModuleUI <- function(id) {
  ns <- NS(id)
  
  div(
    h3("🧬 客戶 DNA 分析"),
    
    # Conditional File Upload Section (only show if no data uploaded from step 1)
    conditionalPanel(
      condition = paste0("output['", ns("has_uploaded_data"), "'] == false"),
      h4("📁 額外檔案上傳 (可選)"),
      fluidRow(
        column(6,
          wellPanel(
            h4("📁 多檔案上傳"),
            fileInput(ns("multi_files"), 
                     "選擇多個CSV檔案",
                     multiple = TRUE,
                     accept = c(".csv", ".xlsx", ".xls")),
            
            p("支援: Amazon銷售報告、一般交易記錄"),
            p("自動偵測: Buyer Email (客戶ID), Purchase Date (時間), Item Price (金額)"),
            
            verbatimTextOutput(ns("file_info"))
          )
        ),
        
        column(6,
          wellPanel(
            h4("⚙️ 分析設定"),
            numericInput(ns("min_transactions"), "最少交易次數", value = 2, min = 1),
            numericInput(ns("delta_factor"), "時間折扣因子", value = 0.1, min = 0.001, max = 1),
            checkboxInput(ns("auto_detect"), "自動偵測欄位", value = TRUE),
            br(),
            actionButton(ns("process_files"), "🚀 合併檔案並分析", class = "btn-success")
          )
        )
      )
    ),
    
    # Analysis controls (always show)
    conditionalPanel(
      condition = paste0("output['", ns("has_uploaded_data"), "'] == true"),
      wellPanel(
        h4("⚙️ 分析設定"),
        fluidRow(
          column(3, numericInput(ns("min_transactions_2"), "最少交易次數", value = 2, min = 1)),
          column(3, numericInput(ns("delta_factor_2"), "時間折扣因子", value = 0.1, min = 0.001, max = 1)),
          column(6, div(style = "margin-top: 25px;", 
                       actionButton(ns("analyze_uploaded"), "🚀 開始分析", class = "btn-success", style = "width: 100%;")))
        )
      )
    ),
    
    # Status
    wellPanel(
      h4("📊 處理狀態"),
      verbatimTextOutput(ns("status"))
    ),
    
    # Results
    conditionalPanel(
      condition = paste0("output['", ns("show_results"), "'] == true"),
      
      h4("📈 DNA 分析結果"),
      
      # Visualization controls
      div(style = "text-align: center; margin: 20px;",
        actionButton(ns("show_m"), "金額 (M)", class = "btn-info", style = "margin: 5px;"),
        actionButton(ns("show_r"), "最近性 (R)", class = "btn-info", style = "margin: 5px;"),
        actionButton(ns("show_f"), "頻率 (F)", class = "btn-info", style = "margin: 5px;"),
        actionButton(ns("show_nes"), "參與度 (NES)", class = "btn-warning", style = "margin: 5px;")
      ),
      
      # Results tabs
      tabsetPanel(
        tabPanel("📊 視覺化",
          fluidRow(
            column(6, plotlyOutput(ns("plot_ecdf"))),
            column(6, plotlyOutput(ns("plot_hist")))
          )
        ),
        tabPanel("📋 資料表", DTOutput(ns("dna_table"))),
        tabPanel("📈 統計", DTOutput(ns("summary_table"))),
        tabPanel("📖 結果說明", 
          div(style = "padding: 20px;",
            htmlOutput(ns("dna_explanation"))
          )
        ),
        # Email mapping tab (only show if email mapping exists)
        conditionalPanel(
          condition = paste0("output['", ns("has_email_mapping"), "'] == true"),
          tabPanel("📧 客戶ID映射", DTOutput(ns("email_mapping_table")))
        )
      )
    )
  )
}

# Server Function
dnaMultiModuleServer <- function(id, con, user_info, uploaded_dna_data = NULL) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Reactive values
    values <- reactiveValues(
      files_info = NULL,
      combined_data = NULL,
      dna_results = NULL,
      current_metric = "M",
      status_text = "等待檔案上傳..."
    )
    
    # 檢查是否有從步驟1傳來的資料
    observe({
      if (!is.null(uploaded_dna_data) && !is.null(uploaded_dna_data())) {
        values$combined_data <- uploaded_dna_data()
        values$status_text <- paste("✅ 已從步驟1載入資料，共", nrow(uploaded_dna_data()), "筆記錄，", 
                                   length(unique(uploaded_dna_data()$customer_id)), "位客戶。點擊「開始分析」進行DNA分析。")
        
        # 設置標記表示資料已準備好自動分析
        values$auto_analyze_ready <- TRUE
      }
    })
    
    # 控制是否顯示上傳區塊
    output$has_uploaded_data <- reactive({
      !is.null(uploaded_dna_data) && !is.null(uploaded_dna_data()) && nrow(uploaded_dna_data()) > 0
    })
    outputOptions(output, "has_uploaded_data", suspendWhenHidden = FALSE)
    
    # 自動分析觸發器
    observe({
      if (!is.null(values$auto_analyze_ready) && values$auto_analyze_ready && 
          !is.null(values$combined_data) && is.null(values$dna_results)) {
        values$auto_analyze_ready <- FALSE  # 防止重複觸發
        values$status_text <- "🚀 自動開始DNA分析..."
        analyze_data(values$combined_data, 2, 0.1)
      }
    })
    
    # File upload handler
    observeEvent(input$multi_files, {
      req(input$multi_files)
      
      values$files_info <- input$multi_files
      file_names <- input$multi_files$name
      
      output$file_info <- renderText({
        paste("已選擇", length(file_names), "個檔案:\n",
              paste(file_names, collapse = "\n"))
      })
      
      values$status_text <- paste("已上傳", length(file_names), "個檔案，準備處理...")
    })
    
    # Field detection function
    detect_fields <- function(df) {
      cols <- tolower(names(df))
      original_names <- names(df)
      
      # Customer ID (prioritize email)
      customer_field <- NULL
      email_patterns <- c("buyer email", "buyer_email", "buyer.email", "email")
      id_patterns <- c("customer_id", "customer", "buyer_id")
      
      # 先檢查電子郵件欄位（優先）
      for (pattern in email_patterns) {
        matches <- grepl(pattern, cols, fixed = TRUE)
        if (any(matches)) {
          customer_field <- original_names[matches][1]
          break
        }
      }
      
      # 如果沒找到電子郵件欄位，檢查一般ID欄位
      if (is.null(customer_field)) {
        for (pattern in id_patterns) {
          matches <- grepl(pattern, cols, fixed = TRUE)
          if (any(matches)) {
            customer_field <- original_names[matches][1]
            break
          }
        }
      }
      
      # Time field (包含Amazon格式)
      time_field <- NULL
      time_patterns <- c("purchase date", "purchase.date", "payments date", "payments.date", 
                        "payment_time", "date", "time")
      for (pattern in time_patterns) {
        matches <- grepl(pattern, cols, fixed = TRUE)
        if (any(matches)) {
          time_field <- original_names[matches][1]
          break
        }
      }
      
      # Amount field (包含Amazon格式)
      amount_field <- NULL
      amount_patterns <- c("item price", "item.price", "lineitem_price", "amount", "sales", "price")
      for (pattern in amount_patterns) {
        matches <- grepl(pattern, cols, fixed = TRUE)
        if (any(matches)) {
          amount_field <- original_names[matches][1]
          break
        }
      }
      
      return(list(customer_id = customer_field, time = time_field, amount = amount_field))
    }
    
    # 通用分析函數
    analyze_data <- function(data, min_transactions, delta_factor) {
      tryCatch({
        values$status_text <- "📊 準備分析資料..."
        
        # Filter by minimum transactions
        customer_counts <- data %>%
          group_by(customer_id) %>%
          summarise(n_transactions = n(), .groups = "drop")
        
        valid_customers <- customer_counts %>%
          filter(n_transactions >= min_transactions) %>%
          pull(customer_id)
        
        filtered_data <- data %>%
          filter(customer_id %in% valid_customers)
        
        values$status_text <- paste("✅ 篩選後客戶:", length(valid_customers), "筆交易:", nrow(filtered_data))
        
        if (nrow(filtered_data) == 0) {
          values$status_text <- "❌ 沒有符合最少交易次數的客戶"
          return()
        }
        
        # 確保platform_id欄位存在
        if (!"platform_id" %in% names(filtered_data)) {
          filtered_data$platform_id <- "upload"
        }
        
        # Prepare data for DNA analysis
        sales_by_customer_by_date <- filtered_data %>%
          mutate(
            date = as.Date(payment_time)
            # customer_id 已經是數值型，不需要再次轉換
          ) %>%
          group_by(customer_id, date) %>%
          summarise(
            sum_spent_by_date = sum(lineitem_price),
            count_transactions_by_date = n(),
            payment_time = min(payment_time),  # 添加時間欄位供analysis_dna使用
            platform_id = "upload",  # 固定值，避免first()錯誤
            .groups = "drop"
          )
        
        sales_by_customer <- filtered_data %>%
          # customer_id 已經是數值型，不需要再次轉換
          group_by(customer_id) %>%
          summarise(
            total_spent = sum(lineitem_price),
            times = n(),
            first_purchase = min(payment_time),
            last_purchase = max(payment_time),
            platform_id = "upload",  # 固定值，避免first()錯誤
            .groups = "drop"
          ) %>%
          mutate(
            # customer_id 已經是數值型，不需要再次轉換
            ipt = pmax(as.numeric(difftime(last_purchase, first_purchase, units = "days")), 1),  # 避免0值
            r_value = as.numeric(difftime(Sys.time(), last_purchase, units = "days")),
            f_value = times,
            m_value = total_spent / times,
            ni = times
          ) %>%
          # 確保所有必要欄位存在且有正確的資料類型
          select(customer_id, total_spent, times, first_purchase, last_purchase, 
                 ipt, r_value, f_value, m_value, ni, platform_id)
        
        # Run DNA analysis
        values$status_text <- "🧬 執行 DNA 分析..."
        
        if (exists("analysis_dna")) {
          # 設定完整的全域參數
          complete_global_params <- list(
            delta = delta_factor,
            ni_threshold = min_transactions,
            cai_breaks = c(0, 0.1, 0.9, 1),
            text_cai_label = c("逐漸不活躍", "穩定", "日益活躍"),
            f_breaks = c(-0.0001, 1.1, 2.1, Inf),
            text_f_label = c("低頻率", "中頻率", "高頻率"),
            r_breaks = c(-0.0001, 0.1, 0.9, 1.0001),
            text_r_label = c("長期不活躍", "中期不活躍", "近期購買"),
            m_breaks = c(-0.0001, 0.1, 0.9, 1.0001),
            text_m_label = c("低價值", "中價值", "高價值"),
            nes_breaks = c(0, 1, 2, 2.5, Inf),
            text_nes_label = c("E0", "S1", "S2", "S3")
          )
          
          dna_results <- analysis_dna(
            df_sales_by_customer = sales_by_customer,
            df_sales_by_customer_by_date = sales_by_customer_by_date,
            skip_within_subject = FALSE,
            verbose = TRUE,  # 啟用詳細訊息以便診斷問題
            global_params = complete_global_params
          )
          
          values$dna_results <- dna_results
          values$status_text <- "🎉 DNA 分析完成！"
          
          output$show_results <- reactive(TRUE)
          outputOptions(output, "show_results", suspendWhenHidden = FALSE)
          
        } else {
          values$status_text <- "❌ analysis_dna 函數不存在，請檢查 global_scripts"
        }
        
      }, error = function(e) {
        values$status_text <- paste("❌ 分析錯誤:", e$message)
      })
    }
    
    # 分析已上傳的資料
    observeEvent(input$analyze_uploaded, {
      req(values$combined_data)
      
      min_trans <- ifelse(is.null(input$min_transactions_2), 2, input$min_transactions_2)
      delta_val <- ifelse(is.null(input$delta_factor_2), 0.1, input$delta_factor_2)
      
      analyze_data(values$combined_data, min_trans, delta_val)
    })
    
    # Process files
    observeEvent(input$process_files, {
      req(values$files_info)
      
      values$status_text <- "開始處理檔案..."
      
      tryCatch({
        all_data <- list()
        
        # Read all files
        for (i in seq_len(nrow(values$files_info))) {
          file_path <- values$files_info$datapath[i]
          file_name <- values$files_info$name[i]
          
          values$status_text <- paste("讀取檔案:", file_name)
          
          if (grepl("\\.csv$", file_name, ignore.case = TRUE)) {
            df <- read.csv(file_path, stringsAsFactors = FALSE)
          } else if (grepl("\\.(xlsx|xls)$", file_name, ignore.case = TRUE)) {
            df <- readxl::read_excel(file_path)
            df <- as.data.frame(df)
          }
          
          df$source_file <- file_name
          all_data[[i]] <- df
        }
        
        values$status_text <- "合併檔案..."
        
        # Combine files
        all_columns <- unique(unlist(lapply(all_data, names)))
        for (i in seq_along(all_data)) {
          missing_cols <- setdiff(all_columns, names(all_data[[i]]))
          for (col in missing_cols) {
            all_data[[i]][[col]] <- NA
          }
          all_data[[i]] <- all_data[[i]][all_columns]
        }
        
        combined_raw <- do.call(rbind, all_data)
        
        # 如果已有從步驟1的資料，合併它們
        if (!is.null(values$combined_data)) {
          existing_data <- values$combined_data
          # 確保欄位一致
          all_cols_combined <- unique(c(names(combined_raw), names(existing_data)))
          for (col in setdiff(all_cols_combined, names(combined_raw))) {
            combined_raw[[col]] <- NA
          }
          for (col in setdiff(all_cols_combined, names(existing_data))) {
            existing_data[[col]] <- NA
          }
          combined_raw <- rbind(existing_data, combined_raw)
        }
        
        values$status_text <- paste("合併完成，共", nrow(combined_raw), "筆記錄")
        
        # Detect fields
        if (input$auto_detect) {
          fields <- detect_fields(combined_raw)
          
          if (is.null(fields$customer_id) || is.null(fields$time) || is.null(fields$amount)) {
            values$status_text <- "錯誤: 無法偵測必要欄位"
            return()
          }
          
          # Standardize data
          standardized_data <- combined_raw %>%
            rename(
              customer_id = !!sym(fields$customer_id),
              payment_time = !!sym(fields$time),
              lineitem_price = !!sym(fields$amount)
            )
        } else {
          standardized_data <- combined_raw
        }
        
        # Clean and process data
        processed_data <- standardized_data %>%
          mutate(
            # 保留原始電子郵件以供參考
            original_customer_id = customer_id,
            # 創建電子郵件到數字ID的一對一映射
            customer_id = if(is.character(customer_id)) {
              if(any(grepl("@", customer_id, fixed = TRUE))) {
                # 為每個唯一的電子郵件創建數字ID
                as.integer(as.factor(customer_id))
              } else {
                as.integer(customer_id)
              }
            } else {
              as.integer(customer_id)
            },
            payment_time = as.POSIXct(payment_time),
            lineitem_price = as.numeric(lineitem_price),
            platform_id = "upload"
          ) %>%
          filter(
            !is.na(customer_id),
            !is.na(payment_time),
            !is.na(lineitem_price),
            lineitem_price > 0
          ) %>%
          arrange(customer_id, payment_time)
        
        # 創建電子郵件到數字ID的映射表以供後續使用
        if(any(grepl("@", standardized_data$customer_id, fixed = TRUE))) {
          email_to_id_mapping <- processed_data %>%
            select(original_customer_id, customer_id) %>%
            distinct() %>%
            arrange(customer_id)
          values$email_mapping <- email_to_id_mapping
          values$status_text <- paste("✅ 電子郵件映射完成:", nrow(email_to_id_mapping), "個唯一客戶")
        }
        
        values$combined_data <- processed_data
        values$status_text <- paste("✅ 資料處理完成，有效記錄:", nrow(processed_data), 
                                   "客戶數:", length(unique(processed_data$customer_id)))
        
        # 使用通用分析函數
        analyze_data(processed_data, input$min_transactions, input$delta_factor)
        
      }, error = function(e) {
        values$status_text <- paste("處理錯誤:", e$message)
      })
    })
    
    # Status output
    output$status <- renderText({
      values$status_text
    })
    
    # Metric button handlers
    observeEvent(input$show_m, { values$current_metric <- "M" })
    observeEvent(input$show_r, { values$current_metric <- "R" })
    observeEvent(input$show_f, { values$current_metric <- "F" })
    observeEvent(input$show_nes, { values$current_metric <- "NES" })
    
    # ECDF Plot - Based on microDNADistribution component
    output$plot_ecdf <- renderPlotly({
      tryCatch({
        req(values$dna_results, values$current_metric)
        
        data <- values$dna_results$data_by_customer
        metric <- values$current_metric
        
        metric_mapping <- list(
          "M" = "m_value",
          "R" = "r_value", 
          "F" = "f_value",
          "NES" = "nes_status"  # NES 使用狀態分類而非數值
        )
        
        col_name <- metric_mapping[[metric]]
        
        # Handle missing data gracefully
        if (is.null(data) || nrow(data) == 0 || is.null(col_name) || !col_name %in% names(data)) {
          return(plotly_empty(type = "scatter") %>%
            add_annotations(
              text = paste("無法找到", metric, "數據\n請檢查數據是否已正確載入"),
              x = 0.5, y = 0.5,
              xref = "paper", yref = "paper",
              showarrow = FALSE,
              font = list(size = 16)
            ))
        }
        
        # Get metric values and remove NA
        metric_values <- data[[col_name]]
        metric_values <- metric_values[!is.na(metric_values)]
        
        if (length(metric_values) == 0) {
          return(plotly_empty(type = "scatter") %>%
            add_annotations(
              text = paste(metric, "數據為空或全為 NA 值"),
              x = 0.5, y = 0.5,
              xref = "paper", yref = "paper",
              showarrow = FALSE,
              font = list(size = 16)
            ))
        }
        
        # Special handling for categorical data (NES) 
        if (metric == "NES") {
          # For NES, show informative message in ECDF position
          return(plotly_empty(type = "scatter") %>%
            add_annotations(
              text = "NES 狀態分佈\n請查看右側直方圖",
              x = 0.5, y = 0.5,
              xref = "paper", yref = "paper",
              showarrow = FALSE,
              font = list(size = 18, color = "#1F77B4")
            ) %>%
            layout(
              title = list(text = "ECDF - NES", font = list(size = 16)),
              xaxis = list(showgrid = FALSE, showticklabels = FALSE, zeroline = FALSE),
              yaxis = list(showgrid = FALSE, showticklabels = FALSE, zeroline = FALSE)
            ))
        } else {
          # Compute ECDF for continuous data
          sorted_values <- sort(unique(metric_values))
          ecdf_fn <- ecdf(metric_values)
          ecdf_values <- ecdf_fn(sorted_values)
          
          # Create plotly visualization with proper hover text
          plot_ly(
            x = ~sorted_values, 
            y = ~ecdf_values,
            type = "scatter", 
            mode = "lines",
            line = list(color = "#1F77B4", width = 2),
            hoverinfo = "text",
            text = ~paste0(
              metric, ": ", format(sorted_values, big.mark = ","),
              "<br>累積百分比: ", format(ecdf_values * 100, digits = 2), "%"
            )
          ) %>%
            layout(
              title = list(text = paste("ECDF -", metric), font = list(size = 16)),
              xaxis = list(title = metric),
              yaxis = list(title = "累積機率", tickformat = ".0%"),
              showlegend = FALSE
            )
        }
        
      }, error = function(e) {
        plotly_empty(type = "scatter") %>%
          add_annotations(
            text = paste("視覺化錯誤:", e$message),
            x = 0.5, y = 0.5,
            xref = "paper", yref = "paper",
            showarrow = FALSE,
            font = list(size = 14, color = "red")
          )
      })
    })
    
    # Histogram Plot - Based on microDNADistribution component  
    output$plot_hist <- renderPlotly({
      tryCatch({
        req(values$dna_results, values$current_metric)
        
        data <- values$dna_results$data_by_customer
        metric <- values$current_metric
        
        metric_mapping <- list(
          "M" = "m_value",
          "R" = "r_value",
          "F" = "f_value", 
          "NES" = "nes_status"  # NES 使用狀態分類而非數值
        )
        
        col_name <- metric_mapping[[metric]]
        
        # Handle missing data gracefully
        if (is.null(data) || nrow(data) == 0 || is.null(col_name) || !col_name %in% names(data)) {
          return(plotly_empty(type = "bar") %>%
            add_annotations(
              text = paste("無法找到", metric, "數據\n請檢查數據是否已正確載入"),
              x = 0.5, y = 0.5,
              xref = "paper", yref = "paper",
              showarrow = FALSE,
              font = list(size = 16)
            ))
        }
        
        # Get metric values and remove NA
        metric_values <- data[[col_name]]
        metric_values <- metric_values[!is.na(metric_values)]
        
        if (length(metric_values) == 0) {
          return(plotly_empty(type = "bar") %>%
            add_annotations(
              text = paste(metric, "數據為空或全為 NA 值"),
              x = 0.5, y = 0.5,
              xref = "paper", yref = "paper",
              showarrow = FALSE,
              font = list(size = 16)
            ))
        }
        
        # Choose visualization based on metric type
        if (metric == "F" || metric == "NES") {
          # For categorical/frequency data, use bar plot
          if (metric == "F") {
            # For frequency, ensure proper integer ordering
            max_f <- max(metric_values, na.rm = TRUE)
            freq_levels <- as.character(1:min(max_f, 50))
            cnt <- table(factor(metric_values, levels = freq_levels))
          } else {
            # For NES, use predefined levels
            cnt <- table(factor(metric_values, levels = c("N", "E0", "S1", "S2", "S3")))
          }
          
          # Convert to data frame for plotting
          df <- data.frame(x = names(cnt), y = as.numeric(cnt))
          total <- sum(df$y)
          
          plot_ly(
            df, 
            x = ~x, 
            y = ~y, 
            type = "bar", 
            marker = list(color = "#1F77B4"), 
            hoverinfo = "text",
            text = ~paste0(
              "值: ", x, 
              "<br>計數: ", format(y, big.mark = ","),
              "<br>百分比: ", round(y / total * 100, 1), "%"
            )
          ) %>%
            layout(
              title = list(text = if(metric == "NES") "NES 狀態分佈" else paste("分佈圖 -", metric), font = list(size = 16)),
              xaxis = list(title = if(metric == "NES") "NES 狀態" else "值", categoryorder = "array", categoryarray = df$x),
              yaxis = list(title = if(metric == "NES") "客戶數" else "計數")
            )
        } else {
          # For continuous data (M, R), use histogram
          plot_ly(
            x = ~metric_values, 
            type = "histogram", 
            marker = list(color = "#1F77B4"),
            hovertemplate = paste0(
              metric, ": %{x}<br>",
              "計數: %{y}<br>",
              "<extra></extra>"
            )
          ) %>%
            layout(
              title = list(text = paste("直方圖 -", metric), font = list(size = 16)),
              xaxis = list(title = metric),
              yaxis = list(title = "頻率"),
              showlegend = FALSE
            )
        }
        
      }, error = function(e) {
        plotly_empty(type = "bar") %>%
          add_annotations(
            text = paste("視覺化錯誤:", e$message),
            x = 0.5, y = 0.5,
            xref = "paper", yref = "paper",
            showarrow = FALSE,
            font = list(size = 14, color = "red")
          )
      })
    })
    
    # Email Mapping Table
    output$email_mapping_table <- renderDT({
      req(values$email_mapping)
      
      values$email_mapping %>%
        rename(
          "原始電子郵件" = original_customer_id,
          "數字客戶ID" = customer_id
        ) %>%
        arrange(`數字客戶ID`)
      
    }, options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
    
    # Check if email mapping exists
    output$has_email_mapping <- reactive({
      !is.null(values$email_mapping)
    })
    outputOptions(output, "has_email_mapping", suspendWhenHidden = FALSE)
    
    # DNA Results Table
    output$dna_table <- renderDT({
      tryCatch({
        req(values$dna_results)
        
        data <- values$dna_results$data_by_customer
        
        # Check which columns exist and select only available ones
        available_cols <- c("customer_id", "r_value", "f_value", "m_value", "ipt_mean", "cai_value", "pcv", "clv", "nes_status", "nes_value")
        existing_cols <- intersect(available_cols, names(data))
        
        if (length(existing_cols) == 0) {
          # Return empty table if no columns found
          return(DT::datatable(data.frame(Message = "No data columns available"), 
                               options = list(pageLength = 15, scrollX = TRUE), rownames = FALSE))
        }
        
        data <- data %>%
          select(all_of(existing_cols)) %>%
          mutate(across(where(is.numeric), ~ round(.x, 3)))
        
        DT::datatable(data, options = list(pageLength = 15, scrollX = TRUE), rownames = FALSE)
      }, error = function(e) {
        # Return error message in table format
        DT::datatable(data.frame(Error = paste("Table generation error:", e$message)), 
                      options = list(pageLength = 15, scrollX = TRUE), rownames = FALSE)
      })
    })
    
    # Summary Table
    output$summary_table <- renderDT({
      req(values$dna_results)
      
      data <- values$dna_results$data_by_customer
      
      summary_stats <- data.frame(
        指標 = c("客戶總數", "平均R值", "平均F值", "平均M值", "平均CLV"),
        數值 = c(
          nrow(data),
          round(mean(data$r_value, na.rm = TRUE), 2),
          round(mean(data$f_value, na.rm = TRUE), 2),
          round(mean(data$m_value, na.rm = TRUE), 2),
          round(mean(data$clv, na.rm = TRUE), 2)
        )
      )
      
      DT::datatable(summary_stats, options = list(dom = 't'), rownames = FALSE)
    })
    
    # DNA Explanation from MD file
    output$dna_explanation <- renderText({
      tryCatch({
        # Read the markdown file
        md_path <- "md/dna_results_explanation.md"
        if (file.exists(md_path)) {
          md_content <- readLines(md_path, encoding = "UTF-8")
          
          # Process line by line for better control
          html_lines <- c()
          in_list <- FALSE
          
          for (line in md_content) {
            # Handle headers
            if (grepl("^### ", line)) {
              if (in_list) { html_lines <- c(html_lines, "</ul>"); in_list <- FALSE }
              header_text <- gsub("^### ", "", line)
              html_lines <- c(html_lines, paste0("<h4 style='color: #2c3e50; margin-top: 20px;'>", header_text, "</h4>"))
            } else if (grepl("^## ", line)) {
              if (in_list) { html_lines <- c(html_lines, "</ul>"); in_list <- FALSE }
              header_text <- gsub("^## ", "", line)
              html_lines <- c(html_lines, paste0("<h3 style='color: #34495e; margin-top: 25px;'>", header_text, "</h3>"))
            } else if (grepl("^# ", line)) {
              if (in_list) { html_lines <- c(html_lines, "</ul>"); in_list <- FALSE }
              header_text <- gsub("^# ", "", line)
              html_lines <- c(html_lines, paste0("<h2 style='color: #2c3e50; margin-top: 30px;'>", header_text, "</h2>"))
            } else if (grepl("^- ", line)) {
              # Handle list items
              if (!in_list) {
                html_lines <- c(html_lines, "<ul style='margin: 10px 0; padding-left: 20px;'>")
                in_list <- TRUE
              }
              list_text <- gsub("^- ", "", line)
              # Process bold text within list items
              list_text <- gsub("\\*\\*(.*?)\\*\\*", "<strong>\\1</strong>", list_text)
              html_lines <- c(html_lines, paste0("<li style='margin: 5px 0;'>", list_text, "</li>"))
            } else if (grepl("^[0-9]+\\.", line)) {
              # Handle numbered lists
              if (in_list) { html_lines <- c(html_lines, "</ul>"); in_list <- FALSE }
              number_text <- gsub("^[0-9]+\\. ", "", line)
              number_text <- gsub("\\*\\*(.*?)\\*\\*", "<strong>\\1</strong>", number_text)
              html_lines <- c(html_lines, paste0("<p style='margin: 8px 0;'><strong>", 
                                               gsub("^([0-9]+)\\.", "\\1.", line), "</strong> ", 
                                               gsub("^[0-9]+\\. \\*\\*(.*?)\\*\\*:", "\\1:", number_text), "</p>"))
            } else if (line == "") {
              # Handle empty lines
              if (in_list) { html_lines <- c(html_lines, "</ul>"); in_list <- FALSE }
              html_lines <- c(html_lines, "<br>")
            } else {
              # Handle regular paragraphs
              if (in_list) { html_lines <- c(html_lines, "</ul>"); in_list <- FALSE }
              if (line != "") {
                # Process bold text
                processed_line <- gsub("\\*\\*(.*?)\\*\\*", "<strong>\\1</strong>", line)
                html_lines <- c(html_lines, paste0("<p style='margin: 10px 0; text-align: justify;'>", processed_line, "</p>"))
              }
            }
          }
          
          # Close any remaining lists
          if (in_list) {
            html_lines <- c(html_lines, "</ul>")
          }
          
          # Combine all lines
          html_content <- paste(html_lines, collapse = "\n")
          
          # Add overall styling
          styled_content <- paste0(
            "<div style='font-family: system-ui, -apple-system, sans-serif; line-height: 1.6; color: #2c3e50; max-width: 100%; padding: 20px; background: #f8f9fa; border-radius: 8px;'>",
            html_content,
            "</div>"
          )
          
          return(styled_content)
        } else {
          return("<div style='color: red; padding: 20px; background: #fff5f5; border: 1px solid #fed7d7; border-radius: 8px;'><strong>錯誤:</strong> 找不到說明文件: md/dna_results_explanation.md</div>")
        }
      }, error = function(e) {
        return(paste0("<div style='color: red; padding: 20px; background: #fff5f5; border: 1px solid #fed7d7; border-radius: 8px;'><strong>載入錯誤:</strong> ", e$message, "</div>"))
      })
    })
    
    # Return results
    return(reactive({
      list(
        dna_results = values$dna_results,
        combined_data = values$combined_data,
        status = values$status_text
      )
    }))
  })
} 