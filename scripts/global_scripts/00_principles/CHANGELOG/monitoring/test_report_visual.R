#!/usr/bin/env Rscript

#' @title Visual Test for Report Display Fix
#' @description Interactive test to visually verify the report display fix
#' @principle MP099 Real-time progress reporting
#' @principle MP106 Console Output Transparency
#' @principle DEV_R036 ShinyJS module namespace handling

cat("=== VISUAL TEST FOR REPORT DISPLAY FIX ===\n")
cat("This test creates a minimal app to verify the fix visually\n\n")

# Load libraries
suppressPackageStartupMessages({
  library(shiny)
  library(bs4Dash)
  library(shinyjs)
})

# Set working directory
setwd("/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/MAMBA")

# Source the fixed report module
source("scripts/global_scripts/10_rshinyapp_components/report/reportIntegration/reportIntegration.R")

# Create test UI
ui <- bs4DashPage(
  header = bs4DashNavbar(
    title = "Report Display Fix - Visual Test",
    status = "primary"
  ),
  sidebar = bs4DashSidebar(disable = TRUE),
  body = bs4DashBody(
    useShinyjs(),

    fluidRow(
      column(
        width = 12,

        # Instructions box
        bs4Card(
          title = "Test Instructions",
          status = "info",
          solidHeader = TRUE,
          width = 12,
          collapsible = TRUE,
          p("Follow these steps to test the fix:"),
          tags$ol(
            tags$li("Click the blue 'Generate Report' button below"),
            tags$li("Watch for '生成中...' message to appear"),
            tags$li("Wait ~5 seconds for simulated generation"),
            tags$li("Verify '生成中...' disappears when report appears"),
            tags$li("Check console output (R console) for debug messages")
          )
        ),

        # Status monitor
        bs4Card(
          title = "Live Status Monitor",
          status = "warning",
          solidHeader = TRUE,
          width = 12,
          verbatimTextOutput("status_monitor")
        )
      )
    ),

    fluidRow(
      column(
        width = 4,

        # Control panel
        bs4Card(
          title = "Test Controls",
          status = "primary",
          solidHeader = TRUE,
          width = 12,

          # The actual generate button from the module
          reportIntegrationComponent("report_test")$ui$filter
        )
      ),

      column(
        width = 8,

        # Report display area
        bs4Card(
          title = "Report Display Area",
          status = "success",
          solidHeader = TRUE,
          width = 12,
          height = "600px",

          # The actual report display from the module
          reportIntegrationComponent("report_test")$ui$display
        )
      )
    )
  )
)

# Create test server
server <- function(input, output, session) {

  # Status tracking
  status_log <- reactiveVal(character())

  add_status <- function(msg) {
    timestamp <- format(Sys.time(), "%H:%M:%S.%OS3")
    current <- status_log()
    new_msg <- paste0("[", timestamp, "] ", msg)
    status_log(c(current, new_msg))

    # Also log to console for debugging
    cat(paste0("[VISUAL TEST] ", new_msg, "\n"))

    # Keep only last 10 messages
    if (length(status_log()) > 10) {
      status_log(tail(status_log(), 10))
    }
  }

  # Initialize status
  add_status("Test app started - Ready for testing")

  # Create mock module results
  module_results <- reactive({
    add_status("Module results requested")

    list(
      vital_signs = list(
        micro_macro_kpi = list(
          kpi_data = reactive({
            add_status("KPI data accessed")
            data.frame(
              metric = c("Revenue", "Growth", "Margin"),
              value = c(1000000, 15.5, 22.3)
            )
          })
        )
      ),

      brandedge = list(
        position_strategy = list(
          ai_analysis_result = reactive({
            add_status("Position strategy accessed")
            paste0(
              "## 品牌定位策略分析\n\n",
              "### 市場定位\n",
              "品牌目前處於**領導者**象限，具有高市場份額和強勢定位。\n\n",
              "### 建議策略\n",
              "1. 持續創新以維持領導地位\n",
              "2. 擴展產品線覆蓋更多細分市場\n",
              "3. 加強品牌差異化優勢\n"
            )
          })
        )
      ),

      insightforge = list(
        poisson_comment = reactive({
          add_status("Market analysis accessed")
          paste0(
            "## 市場賽道分析\n\n",
            "### 競爭態勢\n",
            "市場呈現**高度競爭**格局，主要競爭者包括品牌A、B、C。\n\n",
            "### 機會點\n",
            "- 數位化轉型帶來新機遇\n",
            "- 年輕消費群體快速成長\n",
            "- 永續發展成為差異化關鍵\n"
          )
        })
      )
    )
  })

  # Initialize report module with monitoring
  report_component <- reportIntegrationComponent("report_test")

  # Call the server function
  report_result <- report_component$server(
    input, output, session,
    module_results = module_results
  )

  # Monitor generation state
  observe({
    if (!is.null(report_result)) {
      # Check generation in progress
      if (!is.null(report_result$generation_in_progress)) {
        in_progress <- isolate(report_result$generation_in_progress())
        if (!is.null(in_progress)) {
          if (in_progress) {
            add_status("⏳ Report generation IN PROGRESS")
          }
        }
      }

      # Check generation message
      if (!is.null(report_result$generation_message)) {
        msg <- isolate(report_result$generation_message())
        if (!is.null(msg)) {
          add_status(paste0("📝 Generation message: ", msg))
        }
      }

      # Check if report HTML is ready
      if (!is.null(report_result$report_html)) {
        html <- isolate(report_result$report_html())
        if (!is.null(html) && nzchar(html)) {
          add_status(paste0("✅ Report HTML ready (", nchar(html), " chars)"))
        }
      }
    }
  })

  # Monitor button clicks
  observeEvent(input$`report_test-generate_report`, {
    add_status("🔵 Generate button CLICKED")
  })

  # Display status monitor
  output$status_monitor <- renderText({
    paste(status_log(), collapse = "\n")
  })

  # Add periodic heartbeat to show app is responsive
  observe({
    invalidateLater(10000)  # Every 10 seconds
    add_status("💓 App heartbeat - System responsive")
  })

  # Initial instructions
  showNotification(
    "Click 'Generate Report' button to test the fix",
    type = "info",
    duration = 5
  )
}

# Run the test app
cat("\n=== LAUNCHING VISUAL TEST APP ===\n")
cat("The app will open in your browser.\n")
cat("Follow the on-screen instructions to test.\n")
cat("Watch both the browser AND this console for messages.\n\n")

shinyApp(ui = ui, server = server, options = list(
  port = 8889,
  launch.browser = TRUE
))