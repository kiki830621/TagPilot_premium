#!/usr/bin/env Rscript
# =============================================================================
# Debug Report Generation Issue
# Created: 2025-09-28
# Purpose: Debug why report shows empty content after generation
# Principles:
#   - MP106: Console Output Transparency
#   - MP099: Real-time progress reporting
#   - R113: Four-part script structure (INITIALIZE/MAIN/TEST/DEINITIALIZE)
#   - MP064: ETL-Derivation Separation
#   - R76: Module Data Connection
# =============================================================================

# ---- INITIALIZE -------------------------------------------------------------
cat("\n==== DEBUG REPORT GENERATION START ====\n")
cat(sprintf("[%s] Initializing debugging session\n", Sys.time()))

# Navigate to project root
tryCatch({
  if (file.exists(".Rproj")) {
    cat("[INFO] Already in project root\n")
  } else {
    # Find the project root by looking for .Rproj file
    project_root <- "/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/MAMBA"
    setwd(project_root)
    cat(sprintf("[INFO] Changed to project root: %s\n", getwd()))
  }
}, error = function(e) {
  cat(sprintf("[ERROR] Failed to set working directory: %s\n", e$message))
})

# Load autoinit - use correct path
tryCatch({
  # Check for autoinit.R in correct locations
  autoinit_paths <- c(
    "scripts/global_scripts/00_principles/autoinit.R",
    "scripts/global_scripts/autoinit.R",
    "autoinit.R"
  )

  autoinit_loaded <- FALSE
  for (path in autoinit_paths) {
    if (file.exists(path)) {
      cat(sprintf("[INFO] Loading autoinit from: %s\n", path))
      source(path)
      autoinit_loaded <- TRUE
      break
    }
  }

  if (!autoinit_loaded) {
    cat("[WARNING] autoinit.R not found, loading packages manually\n")
    # Manual package loading if autoinit not found
    library(DBI)
    library(duckdb)
    library(dplyr)
  } else if (exists("autoinit")) {
    autoinit()
    cat("[INFO] autoinit() completed successfully\n")
  }
}, error = function(e) {
  cat(sprintf("[ERROR] autoinit failed: %s\n", e$message))
  # Fallback to manual loading
  library(DBI)
  library(duckdb)
  library(dplyr)
})

# ---- MAIN -------------------------------------------------------------------
cat("\n[MAIN] Starting report generation debugging\n")

# 1. Check database connection
cat("\n[STEP 1] Checking database connection...\n")
tryCatch({
  con <- dbConnect(duckdb::duckdb(), "data/database/mamba.duckdb", read_only = TRUE)
  cat("[SUCCESS] Database connected\n")

  # List available tables
  tables <- dbListTables(con)
  cat(sprintf("[INFO] Available tables: %s\n", paste(tables, collapse = ", ")))

  # Check for key tables used in report
  key_tables <- c("cbz_L3_customers", "cbz_L3_position", "cbz_L3_poisson_metrics")
  for (table in key_tables) {
    if (table %in% tables) {
      count <- dbGetQuery(con, sprintf("SELECT COUNT(*) as n FROM %s", table))$n
      cat(sprintf("[INFO] Table %s has %d rows\n", table, count))
    } else {
      cat(sprintf("[WARNING] Table %s not found\n", table))
    }
  }

  dbDisconnect(con)
}, error = function(e) {
  cat(sprintf("[ERROR] Database check failed: %s\n", e$message))
})

# 2. Load report integration module
cat("\n[STEP 2] Loading report integration module...\n")
tryCatch({
  source("scripts/global_scripts/10_rshinyapp_components/report/reportIntegration/reportIntegration.R")
  cat("[SUCCESS] Report integration module loaded\n")

  # Check if required functions exist
  if (exists("reportIntegrationServer")) {
    cat("[INFO] reportIntegrationServer function exists\n")
  }
  if (exists("reportIntegrationComponent")) {
    cat("[INFO] reportIntegrationComponent function exists\n")
  }
}, error = function(e) {
  cat(sprintf("[ERROR] Failed to load report module: %s\n", e$message))
})

# 3. Check OpenAI API configuration
cat("\n[STEP 3] Checking OpenAI API configuration...\n")
api_key <- Sys.getenv("OPENAI_API_KEY")
if (nzchar(api_key)) {
  cat(sprintf("[SUCCESS] OpenAI API key configured (length: %d)\n", nchar(api_key)))
} else {
  cat("[WARNING] OpenAI API key not configured\n")
}

# 4. Check fn_chat_api availability
cat("\n[STEP 4] Checking AI functions...\n")
tryCatch({
  chat_api_path <- "scripts/global_scripts/08_ai/fn_chat_api.R"
  if (file.exists(chat_api_path)) {
    source(chat_api_path)
    cat("[SUCCESS] fn_chat_api.R loaded\n")

    if (exists("fn_chat_api")) {
      cat("[INFO] fn_chat_api function is available\n")
    }
  } else {
    cat("[WARNING] fn_chat_api.R not found\n")
  }
}, error = function(e) {
  cat(sprintf("[ERROR] Failed to load AI functions: %s\n", e$message))
})

# ---- TEST -------------------------------------------------------------------
cat("\n[TEST] Testing self-contained data fetching...\n")

# Test direct database data fetching (simulating what report should do)
tryCatch({
  con <- dbConnect(duckdb::duckdb(), "data/database/mamba.duckdb", read_only = TRUE)

  # Test 1: Fetch customer DNA data directly
  cat("\n[TEST 1] Fetching customer DNA data...\n")
  customer_query <- "
    SELECT product_name, market_segment, dna, dna_type
    FROM cbz_L3_customers
    WHERE platform_type_id = 2
    LIMIT 5
  "
  customer_data <- dbGetQuery(con, customer_query)
  if (nrow(customer_data) > 0) {
    cat(sprintf("[SUCCESS] Retrieved %d customer records\n", nrow(customer_data)))
  } else {
    cat("[WARNING] No customer data retrieved\n")
  }

  # Test 2: Fetch position data directly
  cat("\n[TEST 2] Fetching position data...\n")
  position_query <- "
    SELECT brand, ideal_point, market_share, unit_price
    FROM cbz_L3_position
    WHERE platform_type_id = 2
    LIMIT 5
  "
  position_data <- dbGetQuery(con, position_query)
  if (nrow(position_data) > 0) {
    cat(sprintf("[SUCCESS] Retrieved %d position records\n", nrow(position_data)))
  } else {
    cat("[WARNING] No position data retrieved\n")
  }

  # Test 3: Fetch poisson metrics directly
  cat("\n[TEST 3] Fetching poisson metrics...\n")
  poisson_query <- "
    SELECT product_name, lambda_star, lambda_review, lambda_feature
    FROM cbz_L3_poisson_metrics
    WHERE platform_type_id = 2
    LIMIT 5
  "
  poisson_data <- dbGetQuery(con, poisson_query)
  if (nrow(poisson_data) > 0) {
    cat(sprintf("[SUCCESS] Retrieved %d poisson records\n", nrow(poisson_data)))
  } else {
    cat("[WARNING] No poisson data retrieved\n")
  }

  dbDisconnect(con)
  cat("\n[SUCCESS] All test queries completed\n")

}, error = function(e) {
  cat(sprintf("[ERROR] Test queries failed: %s\n", e$message))
})

# Test report HTML generation
cat("\n[TEST 4] Testing report HTML generation...\n")
tryCatch({
  # Create simple test report content
  test_report <- "# Test Report\n\nThis is a test report.\n\n## Section 1\nTest content here."

  if (requireNamespace("markdown", quietly = TRUE)) {
    html_content <- markdown::markdownToHTML(text = test_report, fragment.only = FALSE)

    if (nchar(html_content) > 0) {
      cat(sprintf("[SUCCESS] HTML generated (length: %d characters)\n", nchar(html_content)))

      # Check if HTML contains expected tags
      if (grepl("<h1>", html_content)) {
        cat("[INFO] HTML contains H1 tags\n")
      }
      if (grepl("<h2>", html_content)) {
        cat("[INFO] HTML contains H2 tags\n")
      }
    } else {
      cat("[WARNING] Generated HTML is empty\n")
    }
  } else {
    cat("[WARNING] markdown package not available\n")
  }
}, error = function(e) {
  cat(sprintf("[ERROR] HTML generation test failed: %s\n", e$message))
})

# ---- DEINITIALIZE -----------------------------------------------------------
cat("\n[DEINIT] Cleaning up...\n")

# Clean up any remaining connections
if (exists("con")) {
  tryCatch({
    dbDisconnect(con)
    cat("[INFO] Database connection closed\n")
  }, error = function(e) {
    # Silent fail - connection might already be closed
  })
}

autodeinit()

cat("\n==== DEBUG REPORT GENERATION COMPLETE ====\n")
cat(sprintf("[%s] Debug session ended\n", Sys.time()))

# Add 5-second delay per debugging requirements
cat("[INFO] Waiting 5 seconds for output capture...\n")
Sys.sleep(5)