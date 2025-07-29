---
id: "R120"
title: "Filter Variable Naming Convention"
type: "rule"
date_created: "2025-05-18"
date_modified: "2025-05-18"
author: "Claude"
related_to:
  - "MP068": "Language as Index"
  - "R051": "Lowercase Variable Naming"
  - "R053": "Multiple Selection Delimiter"
  - "R117": "Dynamic Combined ID Pattern"
---

# R120: Filter Variable Naming Convention

## Problem Statement

Multi-dimensional data analysis requires consistent variable naming conventions across platforms, particularly for identifiers used to filter data. Without standardized naming, the distinction between entity identifiers and filtering parameters becomes ambiguous, leading to confusion and bugs.

## Rule Definition

All variables used to filter data must be suffixed with `_filter` to clearly indicate their purpose as filtering parameters rather than entity identifiers.

### Key Points

1. **Consistent Suffix**: All variables used to filter datasets must end with the suffix `_filter`.

2. **Filter Variable Examples**:
   - `product_line_id_filter`: Filter for product line category
   - `platform_id_filter`: Filter for platform
   - `date_range_filter`: Filter for date range
   - `customer_segment_filter`: Filter for customer segment

3. **Entity ID vs. Filter ID**:
   - `product_line_id`: Identifies a specific product line
   - `product_line_id_filter`: Parameter used to filter data by product line

4. **Column Names in Results**:
   - When filter variables are stored in resulting datasets, they must maintain the `_filter` suffix
   - Example: `platform_id_filter` column in DNA analysis results represents the filter parameter, not the entity ID

## Justification

1. **Clarity of Purpose**: The `_filter` suffix makes it immediately clear that a variable is used for filtering rather than identification.

2. **Bug Prevention**: Distinguishes between ID columns (inherent properties) and filter parameters (analysis constraints).

3. **Multi-dimensional Consistent Analysis**: Enables clear definitions for DNA profiles that depend on filtered subsets of data.

4. **Schema Consistency**: Enforces consistent column naming in database tables and data frames.

## Implementation Examples

### SQL Queries
```sql
SELECT *
FROM customer_dna
WHERE platform_id_filter = 'amz'
  AND product_line_id_filter = 'jewelry';
```

### R Code
```r
df_filtered <- df_sales %>%
  filter(
    platform_id_filter == "amz",
    product_line_id_filter == "jewelry"
  )
```

### Function Parameters
```r
analyze_dna <- function(data, platform_id_filter = "all", product_line_id_filter = "all") {
  filtered_data <- data %>%
    filter(
      if (platform_id_filter != "all") platform_id == platform_id_filter else TRUE,
      if (product_line_id_filter != "all") product_line_id == product_line_id_filter else TRUE
    )
  # Analysis code...
}
```

## Related Principles and Rules

- **MP068: Language as Index** - Variable names serve as an index to their purpose
- **R051: Lowercase Variable Naming** - Filter variables follow lowercase naming conventions
- **R053: Multiple Selection Delimiter** - When a filter variable accepts multiple values, use proper delimiters
- **R117: Dynamic Combined ID Pattern** - Filter variables can be combined with entity IDs for unique identification