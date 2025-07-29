# R123: Unified Item ID Rule

## Statement
All platform-specific item identifiers must be standardized to `item_id` in the final data structures used by the application layer.

## Rationale
Different e-commerce platforms use different naming conventions for product identifiers:
- Amazon uses `asin` (Amazon Standard Identification Number)
- eBay uses `ebay_item_number`
- Other platforms may use `sku`, `product_id`, etc.

To ensure consistency across the application layer and simplify dashboard development, all platform-specific identifiers should be renamed to a unified `item_id` column.

## Implementation Guidelines

### 1. Data Processing Layer
During data processing (e.g., in D03 derivation flow), maintain platform-specific column names for clarity and traceability:
```r
# Processing layer - use platform-specific names
df_amz_competitor_items$asin
df_eby_competitor_items$ebay_item_number
```

### 2. Application Data Layer
When creating final tables for application use (e.g., position tables, app_data tables), rename to `item_id`:
```r
# Application layer - standardize to item_id
combined_data %>%
  dplyr::rename(item_id = !!sym(item_col))
```

### 3. Platform-Aware Functions
Functions that work across platforms should:
- Accept a `platform` parameter
- Internally map platform to the appropriate column name
- Output standardized `item_id` in final results

Example:
```r
item_col <- switch(platform,
  "amz" = "asin",
  "eby" = "ebay_item_number",
  stop(paste("Unknown platform:", platform))
)

# Process with platform-specific column
result <- data %>%
  group_by(!!sym(item_col)) %>%
  summarise(...) %>%
  # Standardize before returning
  rename(item_id = !!sym(item_col))
```

### 4. Database Schema
- Raw data tables: Keep original platform-specific column names
- Processed data tables: Keep platform-specific names for traceability
- App data tables: Use standardized `item_id`

### 5. Join Operations
When joining tables in the application layer, always use `item_id`:
```r
# Application layer joins
df_position %>%
  left_join(df_supplementary, by = c("item_id", "product_line_id"))
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
  dplyr::rename(item_id = !!sym(item_col))  # Standardize at the end
```

### Bad Practice
```r
# Don't use platform-specific names in app layer
if (platform == "amz") {
  df_position$asin
} else if (platform == "eby") {
  df_position$ebay_item_number
}
```

## Adoption Date
2024-01-06

## Notes
This rule applies to the final data structures used by the application. During intermediate processing steps, maintaining platform-specific names can improve code clarity and debugging.