#!/usr/bin/env Rscript
# Debug script for ISSUE_105: Ideal point count error
# Expected: 8 key factors with 4:6 weighting
# Actual: 26 factors being identified

# Load required libraries
library(dplyr)
library(DBI)
library(duckdb)

# Set working directory to project root
setwd("/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/MAMBA")

# Source required functions
source("scripts/global_scripts/02_db_utils/tbl2/fn_tbl2.R")
source("scripts/global_scripts/10_rshinyapp_components/position/positionIdealRate/positionIdealRate.R")

# Connect to database
con <- dbConnect(duckdb::duckdb(), "data/data.duckdb")

# Get Turbo position data
turbo_data <- tbl2(con, "df_position") %>%
  filter(product_line_id == "tur") %>%
  collect()

cat("📊 Turbo Position Data:\n")
cat("  - Total rows:", nrow(turbo_data), "\n")
cat("  - Total columns:", ncol(turbo_data), "\n")

# Check for Ideal row
ideal_row <- turbo_data %>% filter(product_id == "Ideal")
cat("  - Ideal row exists:", nrow(ideal_row) > 0, "\n\n")

# Get numeric columns (excluding metadata)
metadata_cols <- c("product_line_id", "product_id", "brand", "rating", "sales")
numeric_cols <- turbo_data %>%
  select(-any_of(metadata_cols)) %>%
  select_if(is.numeric) %>%
  names()

cat("🔢 Numeric Columns Analysis:\n")
cat("  - Total numeric columns:", length(numeric_cols), "\n")

# Count non-NA values in Ideal row
ideal_values <- ideal_row %>%
  select(all_of(numeric_cols))
non_na_count <- sum(!is.na(ideal_values))
cat("  - Non-NA values in Ideal row:", non_na_count, "\n\n")

# Perform ideal rate analysis (current implementation)
cat("🔬 Running Current Ideal Rate Analysis:\n")
result <- perform_ideal_rate_analysis(
  data = turbo_data,
  exclude_vars = c("product_line_id", "platform_id", "rating", "sales", "revenue"),
  threshold_multiplier = 1.0
)

cat("  - Key factors identified:", length(result$key_factors), "\n")
cat("  - Gate threshold:", round(result$gate_threshold, 4), "\n\n")

# Display key factors
if (length(result$key_factors) > 0) {
  cat("📋 Key Factors Identified:\n")
  for (i in seq_along(result$key_factors)) {
    cat("  ", i, ". ", result$key_factors[i], "\n", sep = "")
  }
  cat("\n")
}

# Analyze threshold calculation
cat("🎯 Threshold Analysis:\n")
df_no_ideal <- turbo_data %>% filter(product_id != "Ideal")
n_products <- nrow(df_no_ideal)
cat("  - Number of products (excluding Ideal):", n_products, "\n")

# Calculate column sums from indicators
indicators <- result$indicators
col_sums <- colSums(indicators, na.rm = TRUE)
gate_values <- rowSums(indicators, na.rm = TRUE) / ncol(indicators)
mean_gate <- mean(gate_values, na.rm = TRUE)

cat("  - Mean gate value:", round(mean_gate, 4), "\n")
cat("  - Columns passing threshold (>", round(mean_gate, 4), "):", 
    sum(col_sums > mean_gate), "\n\n")

# Proposed fix: Select top 8 factors by column sum
cat("💡 Proposed Fix: Select Top 8 Factors\n")
top_8_factors <- names(sort(col_sums, decreasing = TRUE)[1:8])
cat("  Top 8 factors by importance:\n")
for (i in seq_along(top_8_factors)) {
  factor_name <- top_8_factors[i]
  factor_score <- col_sums[factor_name]
  cat("  ", i, ". ", factor_name, " (score: ", round(factor_score, 2), ")\n", sep = "")
}

# Alternative: Use 4:6 weighting (rating:sales)
cat("\n🔄 Alternative: 4:6 Weighting Implementation\n")
cat("  Note: Issue mentions 4:6 weighting (rating:sales)\n")
cat("  This suggests combining rating-based and sales-based metrics\n")
cat("  Current implementation doesn't incorporate this weighting\n")

# Clean up
dbDisconnect(con)

cat("\n✅ Debug analysis complete\n")