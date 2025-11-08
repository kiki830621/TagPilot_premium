#!/usr/bin/env Rscript
# Test script to verify position table fixes
# Following principles:
# - MP031: Defensive Programming
# - R113: Proper error handling
# - MP099: Progress reporting

cat("=== TESTING POSITION TABLE FIX ===\n")
cat("Testing that item_id is properly renamed to product_id\n\n")

# Change to project root
setwd("/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/WISER")

# Initialize environment
tryCatch({
  cat("📦 Initializing environment...\n")
  Sys.setenv(OPERATION_MODE = "APP_MODE")
  source("scripts/global_scripts/22_initializations/sc_initialization_app_mode.R")
  cat("✅ Environment initialized\n\n")
}, error = function(e) {
  cat("❌ Error initializing environment: ", e$message, "\n")
  stop("Cannot proceed without initialization")
})

# Load position functions
cat("📚 Loading position functions...\n")
source("scripts/global_scripts/11_rshinyapp_utils/fn_get_position_complete_case.R")
source("scripts/global_scripts/11_rshinyapp_utils/fn_get_position_demonstrate_case.R")
cat("✅ Functions loaded\n\n")

# Test 1: Test fn_get_position_complete_case
cat("TEST 1: Testing fn_get_position_complete_case\n")
cat("="*50, "\n")

tryCatch({
  cat("🔄 Fetching position data with complete case...\n")

  # Get app connection
  app_conn <- app_data

  # Call the function
  position_data <- fn_get_position_complete_case(
    app_data_connection = app_conn,
    product_line_id = "jew",  # Use a specific product line
    include_special_rows = TRUE,
    apply_type_filter = FALSE  # Disable type filter for simple test
  )

  # Check results
  cat("📊 Data retrieved successfully!\n")
  cat("  - Rows: ", nrow(position_data), "\n")
  cat("  - Columns: ", ncol(position_data), "\n")

  # Check for product_id column
  if ("product_id" %in% names(position_data)) {
    cat("✅ product_id column exists!\n")
    cat("  - Sample product_ids: ", paste(head(unique(position_data$product_id), 5), collapse=", "), "\n")
  } else {
    cat("❌ product_id column missing!\n")
    cat("  - Available columns: ", paste(names(position_data)[1:10], collapse=", "), "...\n")
  }

  # Check if item_id still exists (it shouldn't)
  if ("item_id" %in% names(position_data)) {
    cat("⚠️ item_id column still exists (should have been renamed)\n")
  } else {
    cat("✅ item_id column properly renamed\n")
  }

}, error = function(e) {
  cat("❌ Error in TEST 1: ", e$message, "\n")
})

cat("\n")

# Test 2: Test fn_get_position_demonstrate_case
cat("TEST 2: Testing fn_get_position_demonstrate_case\n")
cat("="*50, "\n")

tryCatch({
  cat("🔄 Fetching position data with demonstrate case...\n")

  # Call the function
  demo_data <- fn_get_position_demonstrate_case(
    app_data_connection = app_conn,
    product_line_id = "jew",
    apply_iterative_filter = FALSE,
    apply_type_filter = FALSE
  )

  # Check results
  cat("📊 Data retrieved successfully!\n")
  cat("  - Rows: ", nrow(demo_data), "\n")
  cat("  - Columns: ", ncol(demo_data), "\n")

  # Check for product_id column
  if ("product_id" %in% names(demo_data)) {
    cat("✅ product_id column exists!\n")

    # Check that special rows are excluded
    special_rows <- c("Ideal", "Rating", "Revenue")
    special_found <- intersect(demo_data$product_id, special_rows)
    if (length(special_found) == 0) {
      cat("✅ Special rows properly excluded\n")
    } else {
      cat("❌ Special rows found: ", paste(special_found, collapse=", "), "\n")
    }
  } else {
    cat("❌ product_id column missing!\n")
  }

}, error = function(e) {
  cat("❌ Error in TEST 2: ", e$message, "\n")
})

cat("\n")

# Test 3: Test positionStrategy component
cat("TEST 3: Testing positionStrategy component\n")
cat("="*50, "\n")

tryCatch({
  cat("🔄 Loading positionStrategy component...\n")
  source("scripts/global_scripts/10_rshinyapp_components/position/positionStrategy/positionStrategy.R")

  # Create a minimal test for strategy analysis
  cat("🔄 Running strategy analysis...\n")

  # Get test data
  test_data <- fn_get_position_complete_case(
    app_data_connection = app_conn,
    product_line_id = "jew",
    include_special_rows = TRUE,
    apply_type_filter = FALSE
  )

  # Run strategy analysis
  result <- perform_strategy_analysis(
    data = test_data,
    selected_product_id = test_data$product_id[2],  # Select second product (first might be Ideal)
    key_factors = c("rating", "sales"),
    exclude_vars = c("product_line_id", "platform_id")
  )

  if (!is.null(result$selected_product)) {
    cat("✅ Strategy analysis completed successfully!\n")
    cat("  - Selected product: ", result$selected_product$product_id[1], "\n")
    cat("  - Argument factors: ", result$argument_text, "\n")
  } else {
    cat("❌ Strategy analysis failed - no product selected\n")
  }

}, error = function(e) {
  cat("❌ Error in TEST 3: ", e$message, "\n")
  cat("  Stack trace:\n")
  traceback()
})

cat("\n")
cat("=== TEST COMPLETE ===\n")

# Print summary
cat("\n📋 SUMMARY:\n")
cat("- Position data functions have been updated to handle item_id -> product_id renaming\n")
cat("- Defensive programming added per MP031 principle\n")
cat("- Components should now work with the actual df_position table structure\n")

# Sleep to ensure output is captured
Sys.sleep(5)