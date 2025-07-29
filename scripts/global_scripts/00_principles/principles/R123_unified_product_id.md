# R123: Unified product ID Rule

## Statement
All platform-specific product identifiers must be standardized to `product_id` in the final data structures used by the application layer.

## Rationale
Different e-commerce platforms use different naming conventions for product identifiers:
- Amazon uses `asin` (Amazon Standard Identification Number)
- eBay uses `ebay_product_number`
- Other platforms may use `sku`, `product_id`, etc.

To ensure consistency across the application layer and simplify dashboard development, all platform-specific identifiers should be renamed to a unified `product_id` column.

## Implementation Guidelines

### 1. Data Processing Layer
During data processing (e.g., in D03 derivation flow), maintain platform-specific column names for clarity and traceability:
```r
# Processing layer - use platform-specific names
df_amz_competitor_products$asin
df_eby_competitor_products$ebay_product_number
```

### 2. Application Data Layer
When creating final tables for application use (e.g., position tables, app_data tables), rename to `product_id`:
```r
# Application layer - standardize to product_id
combined_data %>%
  dplyr::rename(product_id = !!sym(product_col))
```

### 3. Platform-Aware Functions
Functions that work across platforms should:
- Accept a `platform` parameter
- Internally map platform to the appropriate column name
- Output standardized `product_id` in final results

Example:
```r
product_col <- switch(platform,
  "amz" = "asin",
  "eby" = "ebay_product_number",
  stop(paste("Unknown platform:", platform))
)

# Process with platform-specific column
result <- data %>%
  group_by(!!sym(product_col)) %>%
  summarise(...) %>%
  # Standardize before returning
  rename(product_id = !!sym(product_col))
```

### 4. Database Schema
- Raw data tables: Keep original platform-specific column names
- Processed data tables: Keep platform-specific names for traceability
- App data tables: Use standardized `product_id`

### 5. Join Operations
When joining tables in the application layer, always use `product_id`:
```r
# Application layer joins
df_position %>%
  left_join(df_supplementary, by = c("product_id", "product_line_id"))
```

## Benefits
1. **Consistency**: Single column name across all dashboards and visualizations
2. **Maintainability**: No need for platform-specific logic in UI components
3. **Extensibility**: Easy to add new platforms without changing application code
4. **Simplicity**: Developers only need to remember one column name

## Related Principles
- MP47: Functional Programming
- R76: Module Data Connection
- R91: Universal Data Access Pattern

## Examples

### Good Practice
```r
# In process_position_table function
combined_position___with_ideal <- combined_position %>%
  # ... processing ...
  dplyr::rename(product_id = !!sym(product_col))  # Standardize at the end
```

### Bad Practice
```r
# Don't use platform-specific names in app layer
if (platform == "amz") {
  df_position$asin
} else if (platform == "eby") {
  df_position$ebay_product_number
}
```

## Adoption Date
2024-01-06

## Notes
This rule applies to the final data structures used by the application. During intermediate processing steps, maintaining platform-specific names can improve code clarity and debugging.