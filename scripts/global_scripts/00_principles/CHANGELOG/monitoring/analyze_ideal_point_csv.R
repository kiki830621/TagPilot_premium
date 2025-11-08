#!/usr/bin/env Rscript
# Debug script for ISSUE_105: Ideal point count error using CSV data
# Expected: 8 key factors with 4:6 weighting
# Actual: 26 factors being identified

library(dplyr)

# Read position data from CSV
cat("📊 Reading position data from CSV...\n")
position_data <- read.csv("data/database_to_csv/app_data/df_position.csv", 
                          stringsAsFactors = FALSE, 
                          fileEncoding = "UTF-8")

# Filter for Turbo product line
turbo_data <- position_data %>%
  filter(product_line_id == "tur")

cat("  - Total Turbo rows:", nrow(turbo_data), "\n")
cat("  - Total columns:", ncol(turbo_data), "\n\n")

# Get Ideal row
ideal_row <- turbo_data %>% filter(product_id == "Ideal")

# Exclude metadata columns
metadata_cols <- c("product_line_id", "product_id", "brand", "rating", "sales")
attribute_cols <- setdiff(names(turbo_data), metadata_cols)

cat("🔢 Column Analysis:\n")
cat("  - Metadata columns:", length(metadata_cols), "\n")
cat("  - Attribute columns:", length(attribute_cols), "\n\n")

# Count non-NA values in Ideal row for each attribute
ideal_values <- ideal_row[, attribute_cols]
non_na_count <- sum(!is.na(ideal_values))

cat("🎯 Ideal Row Analysis:\n")
cat("  - Non-NA values in Ideal row:", non_na_count, "\n")
cat("  - NA values in Ideal row:", sum(is.na(ideal_values)), "\n\n")

# List attributes with non-NA ideal values
cat("📋 Attributes with Ideal Values:\n")
attrs_with_ideal <- attribute_cols[!is.na(ideal_values)]
for (i in seq_along(attrs_with_ideal)) {
  attr_name <- attrs_with_ideal[i]
  ideal_val <- ideal_values[[attr_name]]
  cat(sprintf("  %2d. %-20s (Ideal: %.2f)\n", i, attr_name, ideal_val))
}

cat("\n🔍 Key Factor Analysis:\n")
# Simulate the ideal rate analysis logic
df_no_ideal <- turbo_data %>% filter(product_id != "Ideal")
n_products <- nrow(df_no_ideal)
cat("  - Number of products (excluding Ideal):", n_products, "\n")

# Create indicators matrix (1 if value >= ideal, 0 otherwise)
indicators <- matrix(0, nrow = n_products, ncol = length(attrs_with_ideal))
colnames(indicators) <- attrs_with_ideal

for (col in attrs_with_ideal) {
  ideal_val <- ideal_row[[col]][1]
  if (!is.na(ideal_val)) {
    col_values <- df_no_ideal[[col]]
    indicators[, col] <- ifelse(is.na(col_values), 0, ifelse(col_values >= ideal_val, 1, 0))
  }
}

# Calculate gate (threshold)
gate_values <- rowSums(indicators) / ncol(indicators)
mean_gate <- mean(gate_values)
cat("  - Mean gate value:", round(mean_gate, 4), "\n")

# Calculate column sums
col_sums <- colSums(indicators)

# Current logic: select columns where sum > mean(gate)
current_threshold <- mean_gate * n_products
key_factors_current <- names(col_sums[col_sums > current_threshold])
cat("  - Current threshold (mean gate):", round(current_threshold, 2), "\n")
cat("  - Factors passing current threshold:", length(key_factors_current), "\n\n")

# Proposed fix: Select top 8 factors
top_8_factors <- names(sort(col_sums, decreasing = TRUE)[1:8])

cat("💡 SOLUTION: Select Top 8 Factors by Score\n")
cat("  Top 8 factors (sorted by importance):\n")
for (i in 1:8) {
  factor_name <- top_8_factors[i]
  factor_score <- col_sums[factor_name]
  pct_products <- round(factor_score / n_products * 100, 1)
  cat(sprintf("  %d. %-20s (Score: %3d, %.1f%% of products)\n", 
              i, factor_name, factor_score, pct_products))
}

cat("\n📊 Comparison:\n")
cat("  - Current implementation: ", length(key_factors_current), " factors\n")
cat("  - Fixed implementation: 8 factors (as expected)\n")

# Show which factors would be excluded
excluded_factors <- setdiff(key_factors_current, top_8_factors)
if (length(excluded_factors) > 0) {
  cat("\n❌ Factors that would be excluded with fix:\n")
  for (factor in excluded_factors) {
    score <- col_sums[factor]
    cat(sprintf("  - %-20s (Score: %d)\n", factor, score))
  }
}

cat("\n✅ Analysis complete\n")