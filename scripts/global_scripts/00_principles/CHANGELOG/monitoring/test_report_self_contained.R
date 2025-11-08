#!/usr/bin/env Rscript
# =============================================================================
# Test Self-Contained Report Generation
# Created: 2025-09-28
# Purpose: Test the enhanced report generation with direct database access
# Principles:
#   - MP106: Console Output Transparency
#   - MP064: ETL-Derivation Separation
#   - R76: Module Data Connection
#   - MP052: Unidirectional Data Flow
# =============================================================================

cat("\n==== TEST SELF-CONTAINED REPORT GENERATION ====\n")
cat(sprintf("[%s] Starting test\n", Sys.time()))

# Navigate to project root
project_root <- "/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/MAMBA"
setwd(project_root)
cat(sprintf("[INFO] Working directory: %s\n", getwd()))

# Load required packages
cat("\n[STEP 1] Loading packages...\n")
suppressPackageStartupMessages({
  library(DBI)
  library(duckdb)
  library(shiny)
  library(markdown)
})
cat("[SUCCESS] Packages loaded\n")

# Source the report integration module
cat("\n[STEP 2] Loading report integration module...\n")
source("scripts/global_scripts/10_rshinyapp_components/report/reportIntegration/reportIntegration.R")
cat("[SUCCESS] Module loaded\n")

# Create test database connection
cat("\n[STEP 3] Connecting to database...\n")
con <- NULL
tryCatch({
  con <- dbConnect(duckdb(), "data/database/mamba.duckdb", read_only = TRUE)
  cat("[SUCCESS] Database connected\n")

  # Check tables
  tables <- dbListTables(con)
  cat(sprintf("[INFO] Found %d tables\n", length(tables)))

  # Test queries
  if ("cbz_L3_customers" %in% tables) {
    count <- dbGetQuery(con, "SELECT COUNT(*) as n FROM cbz_L3_customers WHERE platform_type_id = 2")$n
    cat(sprintf("[INFO] cbz_L3_customers has %d records for platform 2\n", count))
  }

  if ("cbz_L3_position" %in% tables) {
    count <- dbGetQuery(con, "SELECT COUNT(*) as n FROM cbz_L3_position WHERE platform_type_id = 2")$n
    cat(sprintf("[INFO] cbz_L3_position has %d records for platform 2\n", count))
  }

  if ("cbz_L3_poisson_metrics" %in% tables) {
    count <- dbGetQuery(con, "SELECT COUNT(*) as n FROM cbz_L3_poisson_metrics WHERE platform_type_id = 2")$n
    cat(sprintf("[INFO] cbz_L3_poisson_metrics has %d records for platform 2\n", count))
  }

}, error = function(e) {
  cat(sprintf("[ERROR] Database connection failed: %s\n", e$message))
})

# Test HTML generation
cat("\n[STEP 4] Testing HTML generation...\n")

# Create test markdown content
test_markdown <- "# Test Report

## Section 1: Overview
This is a test of the self-contained report generation.

### Key Metrics
- Customers analyzed: 100
- Market segments: 5
- Average market share: 15.5%

## Section 2: Analysis
The data shows interesting patterns in customer behavior.

## Section 3: Recommendations
1. Focus on high-value segments
2. Improve product positioning
3. Monitor competitive landscape

---
*Generated on: 2025-09-28*"

cat("[INFO] Test markdown content created\n")

# Convert to HTML
if (requireNamespace("markdown", quietly = TRUE)) {
  html_content <- markdown::markdownToHTML(text = test_markdown, fragment.only = FALSE)

  # Add styling
  styled_html <- paste0(
    "<html><head>",
    "<meta charset='utf-8'>",
    "<style>",
    "body { font-family: 'Microsoft YaHei', sans-serif; max-width: 900px; margin: 0 auto; padding: 20px; }",
    "h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }",
    "h2 { color: #34495e; margin-top: 30px; }",
    "</style>",
    "</head><body>",
    html_content,
    "</body></html>"
  )

  cat(sprintf("[SUCCESS] HTML generated (%d characters)\n", nchar(styled_html)))

  # Save test HTML
  test_html_file <- "scripts/global_scripts/00_principles/CHANGELOG/monitoring/test_report.html"
  writeLines(styled_html, test_html_file)
  cat(sprintf("[INFO] Test HTML saved to: %s\n", test_html_file))

  # Verify HTML structure
  if (grepl("<html", styled_html, ignore.case = TRUE)) {
    cat("[CHECK] HTML tag present\n")
  }
  if (grepl("<body", styled_html, ignore.case = TRUE)) {
    cat("[CHECK] Body tag present\n")
  }
  if (grepl("<h1>", styled_html)) {
    cat("[CHECK] H1 tags present\n")
  }
  if (grepl("<h2>", styled_html)) {
    cat("[CHECK] H2 tags present\n")
  }

} else {
  cat("[ERROR] markdown package not available\n")
}

# Test the report integration component initialization
cat("\n[STEP 5] Testing report component initialization...\n")

# Create a mock translate function
translate <- function(x) x

# Test component creation
tryCatch({
  # Create the component with database connection
  report_comp <- reportIntegrationComponent(
    id = "test_report",
    app_data_connection = con,
    config = NULL,
    translate = translate
  )

  if (!is.null(report_comp$ui)) {
    cat("[SUCCESS] Report component UI created\n")
  }

  if (!is.null(report_comp$server)) {
    cat("[SUCCESS] Report component server function created\n")
  }

}, error = function(e) {
  cat(sprintf("[ERROR] Component creation failed: %s\n", e$message))
})

# Clean up
cat("\n[STEP 6] Cleaning up...\n")
if (!is.null(con)) {
  dbDisconnect(con)
  cat("[INFO] Database disconnected\n")
}

cat("\n==== TEST COMPLETE ====\n")
cat(sprintf("[%s] Test ended\n", Sys.time()))

# Display summary
cat("\n[SUMMARY]\n")
cat("1. Database connection: TESTED\n")
cat("2. HTML generation: TESTED\n")
cat("3. Component creation: TESTED\n")
cat("4. Self-contained data fetching: IMPLEMENTED in module\n")
cat("5. Console logging: ENHANCED per MP106\n")

cat("\n[NEXT STEPS]\n")
cat("1. Run the actual app to test the full integration\n")
cat("2. Click 'Generate Report' button to trigger report generation\n")
cat("3. Monitor console output for detailed debugging info\n")
cat("4. Check if report displays properly in UI\n")

# 5-second delay for output capture
Sys.sleep(5)