---
id: "R52"
title: "Cross-Platform Data Structure Rule"
type: "rule"
date_created: "2025-04-06"
author: "Claude"
implements:
  - "MP30": "Vectorization Principle"
  - "MP17": "Separation of Concerns"
  - "MP16": "Modularity"
related_to:
  - "R27": "Data Frame Creation Strategy"
  - "R51": "Lowercase Variable Naming Convention"
---

# Cross-Platform Data Structure Rule

## Core Rule

When working with multi-platform data, structure datasets according to analytical purpose:

1. **Single Combined Dataset** for cross-platform analytics and reporting
2. **Platform-Specific Datasets** for intensive platform-specific processing

## Implementation Requirements

### Combined Dataset Structure

When creating a unified cross-platform dataset:

```r
all_platforms_data <- rbind(
  transform(df_amazon, platform = "amazon"),
  transform(df_ebay, platform = "ebay"),
  transform(df_shopify, platform = "shopify")
)
```

- **MUST** include a `platform` identifier column
- **MUST** standardize all column names across platforms
- **MUST** ensure consistent data types for shared fields
- **MAY** include platform-specific fields with NULL values for other platforms

### Platform-Specific Dataset Structure

When maintaining separate platform datasets:

```r
df_amazon_sales_by_customer
df_ebay_sales_by_customer
df_shopify_sales_by_customer
```

- **MUST** use consistent naming convention with platform suffix
- **MUST** follow standard field naming within each dataset
- **SHOULD** maintain the same core field set across platforms
- **MAY** include platform-specific fields as needed

## Selection Criteria

Follow these guidelines to determine the appropriate structure:

1. Use **Combined Dataset** when:
   - Performing cross-platform comparisons
   - Generating aggregate reports
   - Analyzing customer behavior across platforms
   - Working with smaller data volumes

2. Use **Platform-Specific Datasets** when:
   - Executing resource-intensive calculations
   - Implementing platform-specific business logic
   - Processing large volumes of platform data
   - Optimizing for performance on a single platform

## Integration with Meta-Principles

This rule implements:
- **MP30**: Vectorization Principle (optimizing resource usage)
- **MP17**: Separation of Concerns (organizing by platform)
- **MP16**: Modularity (platform independence)

## Code Examples

### Cross-Platform Analysis Example

```r
# Create combined dataset for cross-platform analysis
all_platforms_data <- rbind(
  transform(df_amazon_sales_by_customer, platform = "amazon"),
  transform(df_ebay_sales_by_customer, platform = "ebay")
)

# Calculate metrics across platforms
platform_comparison <- all_platforms_data %>%
  group_by(platform) %>%
  summarize(
    avg_order_value = mean(total_spent, na.rm = TRUE),
    customer_count = n_distinct(customer_id),
    total_revenue = sum(total_spent, na.rm = TRUE)
  )
```

### Platform-Specific Processing Example

```r
# Process each platform independently for efficiency
amazon_dna <- analysis_dna(df_amazon_sales_by_customer, df_amazon_sales_by_customer_by_date)
ebay_dna <- analysis_dna(df_ebay_sales_by_customer, df_ebay_sales_by_customer_by_date)

# Combine results after processing for comparison if needed
all_dna_results <- rbind(
  transform(amazon_dna$data_by_customer, platform = "amazon"),
  transform(ebay_dna$data_by_customer, platform = "ebay")
)
```

By following this rule, code will achieve optimal performance while maintaining flexibility for cross-platform analysis.