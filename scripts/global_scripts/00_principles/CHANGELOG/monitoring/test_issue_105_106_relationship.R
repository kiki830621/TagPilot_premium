#!/usr/bin/env Rscript

# Test script to explore relationship between ISSUE_105 and ISSUE_106
# Created: 2025-09-22
# Purpose: Verify dependency and independence of key factor determination

# Load required libraries
library(dplyr)

# Source the components
cat("Loading positionIdealRate component...\n")
source("/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/MAMBA/scripts/global_scripts/10_rshinyapp_components/position/positionIdealRate/positionIdealRate.R")

cat("Loading positionStrategy component...\n")
source("/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/MAMBA/scripts/global_scripts/10_rshinyapp_components/position/positionStrategy/positionStrategy.R")

# Create test data following MK03 example
create_test_data <- function() {
  data.frame(
    product_id = c("A1", "A2", "A3", "Ideal"),
    brand = c("Brand1", "Brand2", "Brand3", NA),
    product_line_id = c("PL1", "PL2", "PL3", NA),
    platform_id = c("eby", "eby", "eby", NA),
    quality = c(4, 3, 2, 3.51),
    price = c(5, 4, 3, 4.51),
    design = c(3, 4, 5, 3.49),
    functionality = c(4, 3, 2, 3.51),
    durability = c(2, 3, 4, 2.49),
    service = c(3, 4, 2, 3.20),
    innovation = c(4, 2, 3, 3.00),
    reliability = c(5, 3, 4, 4.10)
  )
}

# Test expanded dataset with more attributes
create_expanded_test_data <- function() {
  n_products <- 30
  n_attributes <- 26

  # Generate random product data
  product_data <- matrix(runif(n_products * n_attributes, 1, 5),
                         nrow = n_products, ncol = n_attributes)

  # Create column names
  attr_names <- paste0("attr_", sprintf("%02d", 1:n_attributes))

  # Calculate ideal row (weighted average)
  ratings <- runif(n_products, 3, 5)
  sales <- runif(n_products, 100, 1000)

  # Normalize and weight
  r_norm <- (ratings - min(ratings)) / (max(ratings) - min(ratings))
  s_norm <- (sales - min(sales)) / (max(sales) - min(sales))
  composite <- 0.4 * r_norm + 0.6 * s_norm
  w_i <- composite / sum(composite)

  # Calculate ideal point
  ideal_values <- colSums(w_i * product_data)

  # Create data frame
  df <- as.data.frame(product_data)
  colnames(df) <- attr_names

  # Add metadata columns
  df$product_id <- paste0("P", sprintf("%02d", 1:n_products))
  df$brand <- paste0("Brand", sample(1:5, n_products, replace = TRUE))
  df$product_line_id <- "TestLine"
  df$platform_id <- "eby"

  # Add ideal row
  ideal_row <- as.data.frame(t(ideal_values))
  colnames(ideal_row) <- attr_names
  ideal_row$product_id <- "Ideal"
  ideal_row$brand <- NA
  ideal_row$product_line_id <- NA
  ideal_row$platform_id <- NA

  # Combine
  result <- rbind(df, ideal_row)

  # Reorder columns
  result <- result[, c("product_id", "brand", "product_line_id", "platform_id", attr_names)]

  return(result)
}

# Test positionIdealRate key factor identification
test_ideal_rate_analysis <- function(data, method = "cross_average") {
  cat("\n========================================\n")
  cat("Testing positionIdealRate Analysis\n")
  cat("Method:", method, "\n")
  cat("========================================\n")

  result <- perform_ideal_rate_analysis(
    data = data,
    exclude_vars = c("brand", "product_line_id", "platform_id"),
    selection_method = method,
    n_key_factors = 8
  )

  cat("\nIdeal Point Vector:\n")
  ideal_row <- data[data$product_id == "Ideal", ]
  numeric_cols <- names(data)[sapply(data, is.numeric)]
  ideal_vector <- as.numeric(ideal_row[numeric_cols])
  names(ideal_vector) <- numeric_cols
  print(round(ideal_vector, 2))

  cat("\nCross-attribute average:", round(mean(ideal_vector, na.rm = TRUE), 2), "\n")

  cat("\nKey factors identified (", length(result$key_factors), "):\n")
  print(result$key_factors)

  return(result)
}

# Simulate positionStrategy key factor identification
test_strategy_key_factors <- function(data) {
  cat("\n========================================\n")
  cat("Testing positionStrategy Key Factor Logic\n")
  cat("========================================\n")

  # Extract ideal row
  ideal_row <- data[data$product_id == "Ideal", ]

  # Get numeric columns
  key_cols <- c("product_id", "brand", "product_line_id", "platform_id")
  numeric_cols <- setdiff(names(data), key_cols)
  numeric_cols <- numeric_cols[sapply(data[numeric_cols], is.numeric)]

  cat("\nIdeal values check (positive filtering logic):\n")

  # Current positionStrategy logic: all positive ideal values
  key_factors_strategy <- character(0)
  for (col in numeric_cols) {
    ideal_val <- ideal_row[[col]][1]
    if (!is.na(ideal_val) && is.numeric(ideal_val) && is.finite(ideal_val) && ideal_val > 0) {
      key_factors_strategy <- c(key_factors_strategy, col)
      cat(sprintf("  %s: %.2f > 0 ✓ SELECTED\n", col, ideal_val))
    } else {
      cat(sprintf("  %s: %.2f ✗ NOT SELECTED\n", col,
                  ifelse(is.na(ideal_val), NA, ideal_val)))
    }
  }

  cat("\nStrategy key factors (", length(key_factors_strategy), "):\n")
  print(key_factors_strategy)

  return(key_factors_strategy)
}

# Compare results
compare_results <- function(ideal_rate_factors, strategy_factors) {
  cat("\n========================================\n")
  cat("COMPARISON OF KEY FACTOR METHODS\n")
  cat("========================================\n")

  cat("\nIdealRate (MK03 cross-average):", length(ideal_rate_factors), "factors\n")
  cat("Strategy (positive filtering):", length(strategy_factors), "factors\n")

  cat("\nFactors only in IdealRate:\n")
  print(setdiff(ideal_rate_factors, strategy_factors))

  cat("\nFactors only in Strategy:\n")
  print(setdiff(strategy_factors, ideal_rate_factors))

  cat("\nCommon factors:\n")
  print(intersect(ideal_rate_factors, strategy_factors))

  cat("\nDependency Analysis:\n")
  if (identical(ideal_rate_factors, strategy_factors)) {
    cat("✓ DEPENDENT: Both components identify EXACTLY the same key factors\n")
  } else {
    cat("✗ INDEPENDENT: Components use different logic and produce different results\n")
    cat("  - IdealRate uses MK03 principle (cross-attribute average)\n")
    cat("  - Strategy uses positive value filtering (all values > 0)\n")
  }
}

# Main test execution
main <- function() {
  cat("===============================================\n")
  cat("ISSUE_105 & ISSUE_106 Relationship Analysis\n")
  cat("===============================================\n")

  # Test with simple data
  cat("\n--- TEST 1: Simple 8-attribute dataset ---\n")
  simple_data <- create_test_data()

  # Test IdealRate with cross-average method (MK03)
  ideal_result_cross <- test_ideal_rate_analysis(simple_data, "cross_average")

  # Test IdealRate with top_n method
  ideal_result_topn <- test_ideal_rate_analysis(simple_data, "top_n")

  # Test Strategy logic
  strategy_result <- test_strategy_key_factors(simple_data)

  # Compare results
  cat("\n--- Comparing cross_average vs Strategy ---\n")
  compare_results(ideal_result_cross$key_factors, strategy_result)

  cat("\n--- Comparing top_n vs Strategy ---\n")
  compare_results(ideal_result_topn$key_factors, strategy_result)

  # Test with expanded data
  cat("\n\n--- TEST 2: Expanded 26-attribute dataset ---\n")
  expanded_data <- create_expanded_test_data()

  # Test IdealRate with cross-average method (MK03)
  ideal_expanded_cross <- test_ideal_rate_analysis(expanded_data, "cross_average")

  # Test IdealRate with top_n method
  ideal_expanded_topn <- test_ideal_rate_analysis(expanded_data, "top_n")

  # Test Strategy logic
  strategy_expanded <- test_strategy_key_factors(expanded_data)

  # Compare expanded results
  cat("\n--- Comparing cross_average vs Strategy (26 attributes) ---\n")
  compare_results(ideal_expanded_cross$key_factors, strategy_expanded)

  cat("\n--- Comparing top_n vs Strategy (26 attributes) ---\n")
  compare_results(ideal_expanded_topn$key_factors, strategy_expanded)

  # Final conclusion
  cat("\n\n===============================================\n")
  cat("CONCLUSION\n")
  cat("===============================================\n")
  cat("\nThe two components (positionIdealRate and positionStrategy) are:\n")
  cat("INDEPENDENT - They calculate key factors using different logic\n\n")

  cat("ISSUE_105 (positionIdealRate) has been fixed to use MK03 principle\n")
  cat("ISSUE_106 (positionStrategy) still uses 'positive value' logic\n\n")

  cat("RECOMMENDATION:\n")
  cat("1. positionStrategy should be updated to use the same MK03 logic\n")
  cat("2. OR it should retrieve key_factors from positionIdealRate component\n")
  cat("3. This ensures consistency across the entire positioning analysis\n")
}

# Run tests
tryCatch({
  main()
}, error = function(e) {
  cat("\nERROR during testing:\n")
  print(e)
})