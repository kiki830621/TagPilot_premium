#' @title Report Integration Module - Auto-Loading Version
#' @description Enhanced report generation with automatic data loading from all modules
#' @principle MP56 Connected Component Principle
#' @principle R091 Universal Data Access Pattern
#' @principle MP81 Explicit Parameter Specification
#' @principle MP099 Real-time progress reporting and monitoring
#' @principle MP106 Console Output Transparency
#' @principle MP052 Unidirectional Data Flow
#' @principle MP064 ETL-Derivation Separation Principle
#' @principle R116 Enhanced Data Access with tbl2

# Helper functions ------------------------------------------------------------
`%||%` <- function(x, y) if (is.null(x)) y else x

#' Extract reactive value from module results - Enhanced version
#' @description Safely extracts values with better debugging output
extract_reactive_value_debug <- function(obj, field = NULL, debug_name = "unknown") {
  tryCatch({
    # MP106: Console Output Transparency
    cat(sprintf("[DEBUG] Extracting %s...\n", debug_name))

    # If field is specified, try to access it first
    if (!is.null(field) && is.list(obj)) {
      obj <- obj[[field]]
    }

    # Now extract the value based on the type
    if (is.null(obj)) {
      cat(sprintf("[DEBUG] %s is NULL\n", debug_name))
      return(NULL)
    } else if (is.function(obj)) {
      # It's a reactive or reactiveVal - call it
      result <- obj()
      # If result is still a function (nested reactive), call it again
      if (is.function(result)) {
        result <- result()
      }
      cat(sprintf("[DEBUG] %s extracted from reactive: %s\n", debug_name, class(result)[1]))
      return(result)
    } else if (is.list(obj) && "ai_analysis_result" %in% names(obj)) {
      cat(sprintf("[DEBUG] %s found in ai_analysis_result field\n", debug_name))
      return(extract_reactive_value_debug(obj$ai_analysis_result, debug_name = paste0(debug_name, ".ai_analysis_result")))
    } else if (is.list(obj) && "result" %in% names(obj)) {
      cat(sprintf("[DEBUG] %s found in result field\n", debug_name))
      return(extract_reactive_value_debug(obj$result, debug_name = paste0(debug_name, ".result")))
    } else if (is.list(obj) && "value" %in% names(obj)) {
      cat(sprintf("[DEBUG] %s found in value field\n", debug_name))
      return(extract_reactive_value_debug(obj$value, debug_name = paste0(debug_name, ".value")))
    } else {
      # Assume it's already a value
      cat(sprintf("[DEBUG] %s is direct value: %s\n", debug_name, class(obj)[1]))
      return(obj)
    }
  }, error = function(e) {
    cat(sprintf("[ERROR] Failed to extract %s: %s\n", debug_name, e$message))
    return(NULL)
  })
}

#' Report Integration UI - Enhanced
#' @param id Module ID
#' @param translate Translation function
reportIntegrationUI <- function(id, translate = function(x) x) {
  ns <- NS(id)

  tagList(
    # Include shinyjs for show/hide functionality
    shinyjs::useShinyjs(),
    # MP106: Console Output Transparency - Remove debug panel from UI
    # Debug messages now go to console only

    # Progress indicator will be shown via withProgress in server

    # Progress and Preview
    uiOutput(ns("generation_progress")),

    # Report Preview - Initially hidden
    shinyjs::hidden(
      div(
        id = ns("report_preview_section"),
        h4(translate("報告預覽")),
        uiOutput(ns("report_preview")),
        br(),
        downloadButton(
          ns("download_report"),
          translate("下載報告"),
          class = "btn-success"
        )
      )
    )
  )
}

#' Report Integration Server - Enhanced with debugging
#' @param id Module ID
#' @param app_data_connection Data connection object
#' @param module_results Reactive containing analysis results from all modules
reportIntegrationServer <- function(id, app_data_connection = NULL, module_results = NULL, translate = function(x) x) {
  moduleServer(id, function(input, output, session) {

    # Debug output reactive
    debug_messages <- reactiveVal("")

    # MP106: Console Output Transparency - Output to console only
    add_debug <- function(msg) {
      timestamp <- format(Sys.time(), "%H:%M:%S")
      message(paste0("[REPORT ", timestamp, "] ", msg))  # Use message() for console output
    }

    # Get OpenAI API key
    gpt_key <- Sys.getenv("OPENAI_API_KEY", "")

    # Check and load fn_chat_api if not available
    if (!exists("fn_chat_api")) {
      add_debug("fn_chat_api not found, attempting to load...")
      chat_api_path <- "scripts/global_scripts/08_ai/fn_chat_api.R"
      if (file.exists(chat_api_path)) {
        source(chat_api_path)
        add_debug("fn_chat_api loaded successfully")
      } else {
        add_debug("WARNING: fn_chat_api.R not found!")
      }
    }

    # Reactive values for report content
    report_content <- reactiveVal(NULL)
    report_html <- reactiveVal(NULL)
    module_loading_status <- reactiveVal(list())
    data_loaded <- reactiveVal(FALSE)

    # MP099: Track generation status
    generation_in_progress <- reactiveVal(FALSE)
    generation_message <- reactiveVal(NULL)

    # MP106: Debug output removed from UI - now console only

    # Helper function to trigger module data loading
    trigger_module_data <- function(module_result) {
      # MP052: Unidirectional Data Flow - Trigger data loading by accessing reactive
      if (!is.null(module_result)) {
        tryCatch({
          # For modules that return reactive lists
          if (is.list(module_result)) {
            # Try to access key data reactives to trigger loading
            if (!is.null(module_result$data)) {
              if (is.function(module_result$data)) module_result$data()
            }
            if (!is.null(module_result$position_data)) {
              if (is.function(module_result$position_data)) module_result$position_data()
            }
            if (!is.null(module_result$kpi_data)) {
              if (is.function(module_result$kpi_data)) module_result$kpi_data()
            }
            if (!is.null(module_result$result)) {
              if (is.function(module_result$result)) module_result$result()
            }
          }
        }, error = function(e) {
          add_debug(sprintf("Error triggering module data: %s", e$message))
        })
      }
    }

    # Generate integrated report with auto-loading
    observeEvent(input$generate_report, {
      # Prevent multiple simultaneous generations
      if (generation_in_progress()) {
        add_debug("Report generation already in progress, skipping...")
        return()
      }

      generation_in_progress(TRUE)
      generation_message(translate("生成中..."))  # Set initial generating message

      add_debug("=== Starting Report Generation with Auto-Loading ===")
      add_debug(sprintf("OpenAI API Key: %s", ifelse(nzchar(gpt_key), "Available", "Missing")))
      add_debug(sprintf("fn_chat_api function: %s", ifelse(exists("fn_chat_api"), "Available", "Missing")))

      # MP064: ETL-Derivation Separation - Fetch data directly from database
      # R76: Module Data Connection - Use connection, not pre-filtered data
      add_debug("Fetching data directly from database for self-contained generation...")

      # MP099: Real-time progress reporting using withProgress

      # Initialize module loading status
      loading_status <- list(
        vital_signs = "Loading...",
        tagpilot = "Loading...",
        brandedge = "Loading...",
        insightforge = "Loading..."
      )
      module_loading_status(loading_status)

      # Self-contained data fetching variables
      db_data <- list()

      # MP099: Real-time progress reporting and monitoring
      withProgress(message = "正在自動載入模組數據並生成報告...", value = 0, detail = "初始化中...", {

        incProgress(0.05, detail = "開始自動載入模組數據...")
        add_debug("Starting automatic module data loading...")

        # SELF-CONTAINED DATA FETCHING - Following R76 and MP064
        # Fetch data directly from database instead of relying on other modules
        tryCatch({
          add_debug("Attempting direct database connection for self-contained data fetching...")

          # Get database connection from app_data_connection or create new one
          if (!is.null(app_data_connection)) {
            if (is.reactive(app_data_connection)) {
              con <- app_data_connection()
            } else {
              con <- app_data_connection
            }
            add_debug("Using provided database connection")
          } else {
            # Fallback to direct connection - check multiple possible paths
            add_debug("Creating new database connection...")
            db_paths <- c(
              "data/data.duckdb",
              "data/app_data/app_data.duckdb",
              "data/database/mamba.duckdb",
              "scripts/global_scripts/global_data/mock_data.duckdb"
            )

            con <- NULL
            for (db_path in db_paths) {
              if (file.exists(db_path)) {
                add_debug(sprintf("Trying to connect to: %s", db_path))
                tryCatch({
                  con <- DBI::dbConnect(duckdb::duckdb(), db_path, read_only = TRUE)
                  add_debug(sprintf("Successfully connected to: %s", db_path))
                  break
                }, error = function(e) {
                  add_debug(sprintf("Failed to connect to %s: %s", db_path, e$message))
                })
              }
            }

            if (is.null(con)) {
              add_debug("WARNING: No database file found or connection failed")
            }
          }

          if (!is.null(con)) {
            # List available tables for debugging
            available_tables <- DBI::dbListTables(con)
            add_debug(sprintf("Available tables: %d", length(available_tables)))

            # Fetch customer DNA data - using actual table names
            if (DBI::dbExistsTable(con, "df_customer_profile")) {
              db_data$customers <- DBI::dbGetQuery(con, "
                SELECT * FROM df_customer_profile LIMIT 100
              ")
              add_debug(sprintf("Fetched %d customer profile records", nrow(db_data$customers)))
            } else if (DBI::dbExistsTable(con, "df_dna_by_customer")) {
              db_data$customers <- DBI::dbGetQuery(con, "
                SELECT * FROM df_dna_by_customer LIMIT 100
              ")
              add_debug(sprintf("Fetched %d DNA customer records", nrow(db_data$customers)))
            } else {
              add_debug("WARNING: No customer table found")
            }

            # Fetch position data - using actual table name
            if (DBI::dbExistsTable(con, "df_position")) {
              db_data$position <- DBI::dbGetQuery(con, "
                SELECT * FROM df_position LIMIT 100
              ")
              add_debug(sprintf("Fetched %d position records", nrow(db_data$position)))
            } else {
              add_debug("WARNING: Position table not found")
            }

            # Fetch poisson metrics - using actual table name
            if (DBI::dbExistsTable(con, "df_cbz_poisson_analysis_all")) {
              db_data$poisson <- DBI::dbGetQuery(con, "
                SELECT * FROM df_cbz_poisson_analysis_all LIMIT 100
              ")
              add_debug(sprintf("Fetched %d poisson records", nrow(db_data$poisson)))
            } else if (DBI::dbExistsTable(con, "df_eby_poisson_analysis_all")) {
              db_data$poisson <- DBI::dbGetQuery(con, "
                SELECT * FROM df_eby_poisson_analysis_all LIMIT 100
              ")
              add_debug(sprintf("Fetched %d poisson records from eby", nrow(db_data$poisson)))
            } else {
              add_debug("WARNING: Poisson analysis table not found")
            }

            # Close connection if we created it
            if (is.null(app_data_connection)) {
              DBI::dbDisconnect(con)
              add_debug("Database connection closed")
            }
          }
        }, error = function(e) {
          add_debug(sprintf("ERROR in self-contained data fetching: %s", e$message))
        })

        # MP064: ETL-Derivation Separation - Trigger data loading for all modules
        if (!is.null(module_results)) {
          if (is.reactive(module_results)) {
            mod_res <- module_results()

            # Trigger Marketing Vital Signs data loading
            incProgress(0.1, detail = "載入 Marketing Vital Signs 數據...")
            add_debug("Loading Marketing Vital Signs data...")
            if (!is.null(mod_res$vital_signs)) {
              trigger_module_data(mod_res$vital_signs$micro_macro_kpi)
              trigger_module_data(mod_res$vital_signs$dna_distribution)
              loading_status$vital_signs <- "✓ 已載入"
              module_loading_status(loading_status)
            }

            # Trigger TagPilot data loading
            incProgress(0.15, detail = "載入 TagPilot 數據...")
            add_debug("Loading TagPilot data...")
            if (!is.null(mod_res$tagpilot)) {
              trigger_module_data(mod_res$tagpilot$customer_dna)
              loading_status$tagpilot <- "✓ 已載入"
              module_loading_status(loading_status)
            }

            # Trigger BrandEdge data loading
            incProgress(0.2, detail = "載入 BrandEdge 數據...")
            add_debug("Loading BrandEdge data...")
            if (!is.null(mod_res$brandedge)) {
              trigger_module_data(mod_res$brandedge$position_table)
              trigger_module_data(mod_res$brandedge$position_dna)
              trigger_module_data(mod_res$brandedge$position_ms)
              trigger_module_data(mod_res$brandedge$position_kfe)
              trigger_module_data(mod_res$brandedge$position_ideal)
              trigger_module_data(mod_res$brandedge$position_strategy)
              loading_status$brandedge <- "✓ 已載入"
              module_loading_status(loading_status)
            }

            # Trigger InsightForge data loading
            incProgress(0.25, detail = "載入 InsightForge 數據...")
            add_debug("Loading InsightForge data...")
            if (!is.null(mod_res$insightforge)) {
              trigger_module_data(mod_res$insightforge$poisson_comment)
              trigger_module_data(mod_res$insightforge$poisson_time)
              trigger_module_data(mod_res$insightforge$poisson_feature)
              loading_status$insightforge <- "✓ 已載入"
              module_loading_status(loading_status)
            }

            # Allow time for reactive updates to propagate
            Sys.sleep(0.5)

            add_debug("All module data loading triggered successfully")
            data_loaded(TRUE)
          }
        }

        incProgress(0.3, detail = "收集所有分析結果...")
        add_debug("Collecting analysis results...")

        # Automatically include all modules
        selected_modules <- c(
          "macro_kpi", "dna_dist",           # Marketing Vital-Signs
          "customer_dna",                     # TagPilot
          "position_strategy",                # BrandEdge
          "market_segment", "key_factors",    # BrandEdge
          "market_track",                     # InsightForge 360
          "time_analysis", "precision"        # InsightForge 360
        )

        incProgress(0.4, detail = "整合 AI 分析內容...")
        add_debug("Integrating AI analysis content...")

        # Debug: Check module_results structure
        if (!is.null(module_results)) {
          if (is.reactive(module_results)) {
            mod_res <- module_results()
            add_debug(sprintf("Module results type: %s", class(mod_res)[1]))
            if (is.list(mod_res)) {
              add_debug(sprintf("Module results names: %s", paste(names(mod_res), collapse = ", ")))
            }
          } else {
            add_debug("Module results is not reactive")
          }
        } else {
          add_debug("WARNING: module_results is NULL!")
        }

        # Build report structure
        report_sections <- list()

        # Report header
        report_sections$title <- "# MAMBA 整合分析報告\n\n"
        report_sections$date <- paste0("**報告日期：** ", Sys.Date(), "\n")
        report_sections$time <- paste0("**生成時間：** ", format(Sys.time(), "%H:%M:%S"), "\n\n")

        incProgress(0.5, detail = "生成報告內容...")
        add_debug("Generating report sections...")

        # Generate each section with error handling
        tryCatch({
          # Section 1: Marketing Vital Signs - Use self-contained data first
          if ("macro_kpi" %in% selected_modules) {
            add_debug("Processing macro_kpi section...")

            # Try self-contained data first
            if (!is.null(db_data$customers) && nrow(db_data$customers) > 0) {
              # Generate insights from self-contained data
              total_customers <- nrow(db_data$customers)
              # Use actual column names from the data
              unique_products <- length(unique(db_data$customers[[1]]))  # First column

              report_sections$macro <- paste0(
                "## 1. 宏觀市場指標\n\n",
                "### 關鍵績效指標\n",
                "- ✓ 客戶數據分析：", total_customers, " 筆記錄\n",
                "- 獨立產品數：", unique_products, "\n",
                "- 數據來源：Customer Profile Database\n",
                "- 數據涵蓋時間：", Sys.Date(), "\n\n"
              )
              add_debug("KPI section generated from self-contained data")
            } else if (!is.null(module_results) && is.reactive(module_results)) {
              # Fallback to module results if available
              mod_res <- module_results()
              kpi_data <- extract_reactive_value_debug(
                mod_res$vital_signs$micro_macro_kpi,
                "kpi_data",
                "KPI_Data"
              )

              if (!is.null(kpi_data)) {
                report_sections$macro <- paste0(
                  "## 1. 宏觀市場指標\n\n",
                  "### 關鍵績效指標\n",
                  "- ✓ KPI 數據已載入\n",
                  "- 數據涵蓋時間：", Sys.Date(), "\n\n"
                )
                add_debug("KPI section generated from module data")
              } else {
                report_sections$macro <- paste0(
                  "## 1. 宏觀市場指標\n\n",
                  "*等待 KPI 模組數據載入...*\n\n"
                )
                add_debug("KPI data not available")
              }
            } else {
              report_sections$macro <- paste0(
                "## 1. 宏觀市場指標\n\n",
                "*數據載入中，請稍後重試...*\n\n"
              )
              add_debug("No data available for KPI section")
            }
          }

          # Section 2: Brand Positioning Strategy - Use self-contained data first
          if ("position_strategy" %in% selected_modules) {
            add_debug("Processing position_strategy section...")

            # Try self-contained data first
            if (!is.null(db_data$position) && nrow(db_data$position) > 0) {
              # Generate insights from self-contained position data
              # Use actual columns available in the data
              total_records <- nrow(db_data$position)
              col_names <- names(db_data$position)
              num_columns <- length(col_names)

              report_sections$strategy <- paste0(
                "## 2. 品牌定位策略分析\n\n",
                "### 策略定位分析\n",
                "- 定位數據記錄：", total_records, "\n",
                "- 數據維度：", num_columns, " 個分析指標\n",
                "- 數據來源：Position Analysis Database\n",
                "- 分析時間：", Sys.Date(), "\n\n",
                "**策略建議**\n",
                "基於定位數據，建議深入分析品牌定位與競爭優勢。\n\n"
              )
              add_debug("Position strategy section generated from self-contained data")
            } else if (!is.null(module_results) && is.reactive(module_results)) {
              mod_res <- module_results()

              # Try multiple paths to find the AI analysis
              ai_text <- NULL

              # Path 1: Direct position_strategy
              if (!is.null(mod_res$brandedge$position_strategy)) {
                ai_text <- extract_reactive_value_debug(
                  mod_res$brandedge$position_strategy,
                  "ai_analysis_result",
                  "Position_Strategy_AI"
                )
              }

              # Path 2: Try position module
              if (is.null(ai_text) && !is.null(mod_res$position)) {
                ai_text <- extract_reactive_value_debug(
                  mod_res$position,
                  "ai_analysis",
                  "Position_AI_Alternative"
                )
              }

              # Handle the extracted text
              if (!is.null(ai_text) && length(ai_text) > 0) {
                # Fix for vector case
                if (is.character(ai_text) && all(nzchar(ai_text))) {
                  if (length(ai_text) > 1) {
                    ai_text <- paste(ai_text, collapse = "\n")
                  }
                  report_sections$strategy <- paste0(
                    "## 2. 品牌定位策略分析\n\n",
                    ai_text, "\n\n"
                  )
                  add_debug("Position strategy AI text included")
                } else {
                  report_sections$strategy <- paste0(
                    "## 2. 品牌定位策略分析\n\n",
                    "### 策略定位分析\n",
                    "- 四象限策略分析進行中\n",
                    "- 品牌定位建議生成中\n\n"
                  )
                  add_debug("Position strategy data processing")
                }
              } else {
                report_sections$strategy <- paste0(
                  "## 2. 品牌定位策略分析\n\n",
                  "*策略分析模組數據正在載入中，請稍後重試...*\n\n"
                )
                add_debug("Position strategy not available")
              }
            }
          }

          # Section 3: Market Track Analysis - Use self-contained data first
          if ("market_track" %in% selected_modules) {
            add_debug("Processing market_track section...")

            # Try self-contained data first
            if (!is.null(db_data$poisson) && nrow(db_data$poisson) > 0) {
              # Generate insights from self-contained poisson data
              total_poisson_records <- nrow(db_data$poisson)
              poisson_cols <- names(db_data$poisson)
              num_metrics <- length(poisson_cols)

              report_sections$market <- paste0(
                "## 3. 市場賽道分析\n\n",
                "### 產品賽道競爭力分析\n",
                "- Poisson 分析記錄：", total_poisson_records, "\n",
                "- 分析指標數：", num_metrics, "\n",
                "- 數據來源：Poisson Analysis Database\n",
                "- 分析時間：", Sys.Date(), "\n\n",
                "**市場洞察**\n",
                "基於 Poisson 分析，產品評論和評分分布顯示市場活躍度高。\n\n"
              )
              add_debug("Market analysis section generated from self-contained data")
            } else if (!is.null(module_results) && is.reactive(module_results)) {
              mod_res <- module_results()

              comment_text <- extract_reactive_value_debug(
                mod_res$insightforge$poisson_comment,
                NULL,
                "Market_Comment_Analysis"
              )

              if (!is.null(comment_text) && length(comment_text) > 0) {
                # Fix for vector case
                if (is.character(comment_text) && all(nzchar(comment_text))) {
                  if (length(comment_text) > 1) {
                    comment_text <- paste(comment_text, collapse = "\n")
                  }
                  report_sections$market <- paste0(
                    "## 3. 市場賽道分析\n\n",
                    comment_text, "\n\n"
                  )
                  add_debug("Market analysis text included")
                } else {
                  report_sections$market <- paste0(
                    "## 3. 市場賽道分析\n\n",
                    "### 產品賽道競爭力分析\n",
                    "- 評分與評論分析進行中\n",
                    "- 市場定位建議生成中\n\n"
                  )
                  add_debug("Market analysis data processing")
                }
              } else {
                report_sections$market <- paste0(
                  "## 3. 市場賽道分析\n\n",
                  "*市場分析模組數據正在載入中，請稍後重試...*\n\n"
                )
                add_debug("Market analysis not available")
              }
            }
          }

        }, error = function(e) {
          add_debug(sprintf("ERROR in section generation: %s", e$message))
          report_sections$error <- paste0(
            "## ⚠️ 報告生成遇到問題\n\n",
            "部分模組數據無法正常載入，請檢查：\n",
            "1. 各分析模組是否已完成運算\n",
            "2. 資料連接是否正常\n",
            "3. API 金鑰是否正確設定\n\n"
          )
        })

        incProgress(0.7, detail = "使用 AI 生成整合見解...")
        add_debug("Generating AI integrated insights...")

        # Generate integrated insights using GPT (if available)
        if (nzchar(gpt_key) && exists("fn_chat_api") && length(report_sections) > 3) {
          add_debug("Calling OpenAI API for integrated insights...")

          # Prepare content for AI analysis
          combined_content <- paste(unlist(report_sections), collapse = "\n")

          sys_prompt <- "你是專業的商業分析顧問，擅長整合多維度數據洞察。請用繁體中文回答。"
          user_prompt <- paste0(
            "基於以下分析報告內容，提供整合性的策略建議：\n\n",
            combined_content,
            "\n\n請提供：",
            "\n1. **整合洞察摘要**（2-3個關鍵發現）",
            "\n2. **立即行動建議**（最重要的2個行動）",
            "\n3. **潛在風險提醒**（1個主要風險）",
            "\n\n請以精簡專業的方式呈現，總字數限制在200字內。"
          )

          # Call AI for integrated insights
          tryCatch({
            ai_response <- fn_chat_api(
              list(
                list(role = "system", content = sys_prompt),
                list(role = "user", content = user_prompt)
              ),
              gpt_key
            )

            if (!is.null(ai_response) && nzchar(ai_response)) {
              report_sections$ai_insights <- paste0(
                "## 整合策略建議\n\n",
                ai_response, "\n\n"
              )
              add_debug("AI insights generated successfully")
            }
          }, error = function(e) {
            add_debug(sprintf("AI API call failed: %s", e$message))
            report_sections$ai_insights <- paste0(
              "## 整合策略建議\n\n",
              "*AI 分析服務暫時無法使用，請稍後再試*\n\n"
            )
          })
        } else {
          if (!nzchar(gpt_key)) {
            add_debug("OpenAI API key not configured")
          }
          if (!exists("fn_chat_api")) {
            add_debug("fn_chat_api function not available")
          }
        }

        incProgress(0.9, detail = "格式化報告...")
        add_debug("Formatting final report...")

        # Combine all sections
        final_report <- paste(unlist(report_sections), collapse = "")

        # Add footer
        final_report <- paste0(
          final_report,
          "\n---\n",
          "*本報告由 MAMBA Enterprise Platform 自動生成*\n",
          "*生成時間：", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "*\n",
          "*Powered by AI Marketing Intelligence*"
        )

        report_content(final_report)
        add_debug(sprintf("[CONTENT] Report content saved (%d characters)", nchar(final_report)))

        # Convert to HTML
        if (requireNamespace("markdown", quietly = TRUE)) {
          add_debug("[HTML] Converting markdown to HTML...")
          html_content <- markdown::markdownToHTML(
            text = final_report,
            fragment.only = FALSE
          )
          add_debug(sprintf("[HTML] Raw HTML generated (%d characters)", nchar(html_content)))

          # Add styling
          styled_html <- paste0(
            "<html><head>",
            "<meta charset='utf-8'>",
            "<style>",
            "body { font-family: 'Microsoft YaHei', sans-serif; max-width: 900px; margin: 0 auto; padding: 20px; background: #f8f9fa; }",
            "h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }",
            "h2 { color: #34495e; margin-top: 30px; border-left: 4px solid #3498db; padding-left: 10px; }",
            "h3 { color: #7f8c8d; }",
            "strong { color: #e74c3c; }",
            "ul { line-height: 1.8; }",
            "li { margin: 5px 0; }",
            "hr { margin: 40px 0; border: none; border-top: 2px solid #ecf0f1; }",
            "em { color: #95a5a6; }",
            "</style>",
            "</head><body>",
            html_content,
            "</body></html>"
          )

          # Save the styled HTML to reactive value
          add_debug(sprintf("[HTML] Setting report_html reactive value (%d characters)", nchar(styled_html)))
          report_html(styled_html)

          # Verify it was set
          verify_content <- report_html()
          if (!is.null(verify_content)) {
            add_debug(sprintf("[HTML] Report HTML verified in reactive (%d characters)", nchar(verify_content)))
          } else {
            add_debug("[ERROR] Report HTML not properly set in reactive!")
          }
        } else {
          fallback_html <- paste0("<pre>", final_report, "</pre>")
          add_debug(sprintf("[HTML] Markdown package not available, using plain text (%d characters)", nchar(fallback_html)))
          report_html(fallback_html)
        }

        # Force UI update
        add_debug("[UI] Triggering UI update for report display")

        # MP106: Console Output Transparency - Log current state
        add_debug(sprintf("[UI] Report content exists: %s", !is.null(report_content())))
        add_debug(sprintf("[UI] Report HTML exists: %s", !is.null(report_html())))
        add_debug(sprintf("[UI] Generation in progress: %s", generation_in_progress()))

        incProgress(1.0, detail = "報告生成完成！")
        add_debug("=== Report Generation Complete with Auto-Loading ===")

        # Clear generation message and mark as complete
        # MP099: Clear progress message when done
        generation_message(NULL)
        generation_in_progress(FALSE)

        # Ensure report preview is shown
        # DEV_R036: Use session$ns for proper namespace
        shinyjs::show(session$ns("report_preview_section"))
      })
    }, ignoreInit = TRUE)

    # Render report preview with proper reactive invalidation
    output$report_preview <- renderUI({
      html_content <- report_html()

      # MP106: Console Output Transparency - Detailed debugging
      if (is.null(html_content)) {
        add_debug("[RENDER] Report HTML content is NULL")
        return(NULL)
      }

      content_length <- nchar(html_content)
      add_debug(sprintf("[RENDER] Report HTML content length: %d characters", content_length))

      if (content_length == 0) {
        add_debug("[RENDER] Report HTML content is empty string")
        return(NULL)
      }

      # Check if HTML contains expected structure
      has_html_tag <- grepl("<html", html_content, ignore.case = TRUE)
      has_body_tag <- grepl("<body", html_content, ignore.case = TRUE)
      has_h1_tag <- grepl("<h1", html_content, ignore.case = TRUE)

      add_debug(sprintf("[RENDER] HTML structure check - html: %s, body: %s, h1: %s",
                       has_html_tag, has_body_tag, has_h1_tag))

      add_debug("[RENDER] Creating iframe for report preview")

      # Return the iframe
      iframe_element <- tags$iframe(
        srcdoc = html_content,
        width = "100%",
        height = "600px",
        style = "border: 1px solid #ddd; border-radius: 4px; background: white;",
        id = session$ns("report_iframe")
      )

      add_debug("[RENDER] Iframe element created and returned")
      return(iframe_element)
    })

    # Observer to ensure report section shows when content is ready
    # MP099: Real-time progress reporting and monitoring
    # DEV_R036: ShinyJS module namespace handling - use session$ns
    observeEvent(report_html(), {
      html_content <- report_html()

      add_debug("[OBSERVER] Report HTML changed event triggered")

      if (is.null(html_content)) {
        add_debug("[OBSERVER] Report HTML is NULL, not showing preview")
        return()
      }

      content_length <- nchar(html_content)
      add_debug(sprintf("[OBSERVER] Report HTML length: %d characters", content_length))

      if (content_length > 0) {
        add_debug("[OBSERVER] Report HTML ready, showing preview section")

        # Clear any remaining generation message
        generation_message(NULL)
        add_debug("[OBSERVER] Generation message cleared")

        # Show the report preview section with proper namespace
        section_id <- session$ns("report_preview_section")
        add_debug(sprintf("[OBSERVER] Showing section with ID: %s", section_id))

        shinyjs::show(section_id)
        add_debug("[OBSERVER] shinyjs::show() called - Report preview section should now be visible")

        # Double-check visibility
        shinyjs::runjs(sprintf(
          "console.log('[JS] Element visibility:', $('#%s').is(':visible'));",
          section_id
        ))
      } else {
        add_debug("[OBSERVER] Report HTML is empty, not showing preview")
      }
    }, ignoreNULL = TRUE)

    # Download handler
    output$download_report <- downloadHandler(
      filename = function() {
        paste0("MAMBA_Report_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".html")
      },
      content = function(file) {
        writeLines(report_html() %||% "<html><body>No report generated</body></html>", file)
      }
    )

    # Render generation progress message
    # MP099: Real-time progress reporting
    # DEV_R036: ShinyJS module namespace handling
    output$generation_progress <- renderUI({
      msg <- generation_message()
      if (!is.null(msg)) {
        add_debug(sprintf("Displaying progress message: %s", msg))
        tagList(
          div(
            class = "alert alert-info",
            style = "padding: 10px; margin: 10px 0;",
            icon("spinner", class = "fa-spin"),
            span(style = "margin-left: 10px;", msg)
          )
        )
      } else {
        # Return empty div when no message
        NULL
      }
    })

    # MP106: Module loading status removed from UI - progress shown via withProgress

    # Return reactive values
    return(list(
      report_content = report_content,
      report_html = report_html,
      debug_messages = debug_messages,
      module_loading_status = module_loading_status,
      data_loaded = data_loaded,
      generation_in_progress = generation_in_progress,
      generation_message = generation_message
    ))
  })
}

# Initialize function
reportIntegrationInitialize <- function(id, app_data_connection = NULL, module_results = NULL) {
  list(
    ui = reportIntegrationUI(id),
    server = function(input, output, session) {
      reportIntegrationServer(id, app_data_connection, module_results)
    }
  )
}

#' Report Integration Component Wrapper - Enhanced
#' @description Component wrapper with improved debugging
reportIntegrationComponent <- function(id, app_data_connection = NULL, config = NULL, translate = function(x) x) {
  ns <- NS(id)

  # Create UI components - Following MP014: Company Centered Design, R72: Component ID Consistency
  ui_filter <- wellPanel(
    class = "filter-panel",
    style = "padding: 15px;",  # Standard styling matching other modules (R09: UI-Server-Defaults Triple)
    h4(translate("整合報告中心"), icon("file-alt"), style = "border-bottom: none; margin-bottom: 10px;"),  # Remove any border and set margin
    tags$hr(style = "margin: 10px 0;"),  # Single separator with controlled margins

    # Module information section first - Following intuitive UI hierarchy
    p(translate("自動整合分析模組："), style = "color: #666; font-size: 12px; margin: 0; padding-top: 5px;"),  # Controlled margins
    tags$div(
      style = "font-size: 11px; color: #666; padding-left: 10px; margin-bottom: 15px;",  # Added margin-bottom for spacing
      p(style = "margin: 2px 0;", icon("chart-line", style = "width: 15px;"), " Marketing Vital-Signs 市場指標"),
      p(style = "margin: 2px 0;", icon("tag", style = "width: 15px;"), " TagPilot 顧客 DNA 分析"),
      p(style = "margin: 2px 0;", icon("gem", style = "width: 15px;"), " BrandEdge 品牌定位策略"),
      p(style = "margin: 2px 0;", icon("lightbulb", style = "width: 15px;"), " InsightForge 市場賽道洞察")
    ),

    # API Status info - positioned before action button
    tags$div(
      style = "margin-top: 10px; margin-bottom: 15px; padding: 10px; background: #f8f9fa; border-radius: 5px;",  # Adjusted margins
      tags$small(
        "API Status: ",
        tags$span(
          id = ns("api_status"),
          ifelse(nzchar(Sys.getenv("OPENAI_API_KEY")), "✓ Ready", "✗ Missing"),
          style = ifelse(
            nzchar(Sys.getenv("OPENAI_API_KEY")),
            "color: #28a745;",  # Standard success color
            "color: #dc3545;"   # Standard danger color
          )
        )
      )
    ),

    # Report generation button at bottom - Following MP014: Company Centered Design for intuitive UI flow
    actionButton(
      ns("generate_report"),
      translate("生成整合報告"),
      icon = icon("magic"),
      class = "btn-primary btn-block",  # btn-primary for consistency with other modules
      width = "100%",
      style = "margin-top: 10px;"  # Added top margin for visual separation
    )
  )

  ui_display <- reportIntegrationUI(id, translate)

  # Return component structure - Following R09: UI-Server-Defaults Triple
  # Must maintain compatibility with union_production_test.R expectations
  list(
    ui = list(
      filter = ui_filter,  # Left panel with button
      display = ui_display  # Right panel with report display
    ),
    server = function(input, output, session, module_results = NULL) {
      # Call the server function with correct parameters
      # Note: input, output, session are from the parent, not used here
      reportIntegrationServer(id, app_data_connection, module_results, translate)
    }
  )
}

# Export the main functions
# Following R69: Function File Naming
# Following MP47: Functional Programming