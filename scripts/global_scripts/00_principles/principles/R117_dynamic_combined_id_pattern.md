---
id: "R0117"
title: "Dynamic Combined ID Pattern"
type: "rule"
date_created: "2025-04-19"
author: "Claude"
derives_from:
  - "P0015": "Dual ID Format Principle"
  - "MP0017": "Separation of Concerns"
related_to:
  - "P0080": "Integer ID Consistency"
  - "R0089": "Integer ID Type Conversion"
---

# Dynamic Combined ID Pattern

## Core Rule

When working with multiple ID components (like platform_id and customer_id), generate combined identifiers dynamically at query time rather than storing them as separate fields in the database.

## Rationale

This rule optimizes database storage, query performance, and flexibility:

- Avoids data duplication in the database
- Preserves the integrity of individual ID components
- Maintains flexibility for different display formats
- Supports efficient filtering on component IDs
- Eliminates synchronization issues between stored combined IDs and component IDs

## Implementation Guidelines

### Dynamic Generation Approaches

When combining IDs for querying or display, use these approaches based on your needs:

#### 1. Separator-Based Approach (Recommended)

```r
# Use a clear separator between components
combined_id <- paste(platform_id, customer_id, sep = "_")
# Example: "1_12345"

# Easy to split back into components
parts <- strsplit(combined_id, "_")[[1]]
platform_id <- as.integer(parts[1])
customer_id <- as.integer(parts[2])
```

#### 2. Fixed-Width Format

```r
# Use fixed width for each component
combined_id <- sprintf("%02d%07d", platform_id, customer_id)
# Example: "0112345"

# Requires knowledge of format for decomposition
platform_id <- as.integer(substr(combined_id, 1, 2))
customer_id <- as.integer(substr(combined_id, 3, 9))
```

### Database Implementation

For database operations:

```r
# In R with dplyr
results <- df %>%
  # Generate combined ID on-the-fly
  mutate(combined_id = paste(platform_id, customer_id, sep = "_")) %>%
  # Filter using the generated ID
  filter(combined_id == "1_12345")

# Using direct component filtering is more efficient
results <- df %>%
  filter(platform_id == 1, customer_id == 12345)

# In SQL directly
sql_query <- "
SELECT *, 
       platform_id || '_' || customer_id AS combined_id 
FROM customers 
WHERE platform_id = 1 AND customer_id = 12345;
"
```

### Creating Reusable Functions

Package combined ID logic in functions:

```r
make_combined_id <- function(platform_id, customer_id, 
                            format = c("separator", "fixed")) {
  format <- match.arg(format)
  
  if (format == "separator") {
    return(paste(platform_id, customer_id, sep = "_"))
  } else {
    return(sprintf("%02d%07d", platform_id, customer_id))
  }
}

parse_combined_id <- function(combined_id, 
                             format = c("separator", "fixed")) {
  format <- match.arg(format)
  
  if (format == "separator") {
    parts <- strsplit(combined_id, "_")[[1]]
    return(list(
      platform_id = as.integer(parts[1]), 
      customer_id = as.integer(parts[2])
    ))
  } else {
    return(list(
      platform_id = as.integer(substr(combined_id, 1, 2)),
      customer_id = as.integer(substr(combined_id, 3, 9))
    ))
  }
}
```

### Best Practices for Display

For user interface display:

```r
# For data table display
display_data <- df %>%
  mutate(combined_id = paste(platform_id, customer_id, sep = "_"))

# Add type prefixes for more clarity
display_data <- df %>%
  mutate(combined_id = paste0("PC", platform_id, "_", customer_id))

# For formatted display with fixed width
display_data <- df %>%
  mutate(combined_id = sprintf("PC%02d-%07d", platform_id, customer_id))
```

## Creating Database Views

When frequently using combined IDs, consider creating a view:

```sql
CREATE VIEW customers_with_combined_id AS
SELECT *, 
       platform_id || '_' || customer_id AS combined_id 
FROM customers;
```

## Benefits

1. **Storage Efficiency**: No redundant data stored
2. **Maintainability**: No risk of combined_id becoming out of sync with component IDs
3. **Flexibility**: Can adjust formatting without database changes
4. **Performance**: Component IDs can use efficient numeric indexes
5. **Adaptability**: Handles variable-length IDs without padding issues

## Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Storing combined IDs in database | Generate dynamically when needed |
| Using string operations for numeric filtering | Filter on component IDs directly |
| Inconsistent separator usage | Standardize on one approach |
| Performance issues with large datasets | Create indexed views or computed columns |
| Parsing errors with complex formats | Use simple separators when possible |

## Integration with Other Principles

This rule implements:

- **P0015 (Dual ID Format Principle)**: Maintains separation between storage and display formats
- **P0080 (Integer ID Consistency)**: Preserves integer type for component IDs
- **MP0017 (Separation of Concerns)**: Separates storage from presentation concerns

## Examples

### Database Schema with Component IDs

```sql
CREATE TABLE customer_sales (
  platform_id INTEGER NOT NULL,
  customer_id INTEGER NOT NULL,
  sale_date DATE NOT NULL,
  amount NUMERIC(10,2) NOT NULL,
  PRIMARY KEY (platform_id, customer_id, sale_date)
);
```

### Creating a Search Function

```r
search_customer_by_combined_id <- function(conn, combined_id, format = "separator") {
  # Parse the combined ID
  components <- parse_combined_id(combined_id, format)
  
  # Query using component IDs
  result <- tbl(conn, "customers") %>%
    filter(
      platform_id == components$platform_id,
      customer_id == components$customer_id
    ) %>%
    collect()
    
  return(result)
}
```

### UI Implementation

```r
output$customer_table <- renderDataTable({
  # Get data with dynamically generated combined IDs
  display_data <- customer_data %>%
    mutate(combined_id = make_combined_id(platform_id, customer_id))
    
  # Display in a datatable with the combined ID
  datatable(
    display_data[, c("combined_id", "name", "email", "last_purchase")],
    options = list(pageLength = 25)
  )
})
```

By following this pattern, you maintain the computational advantages of integer component IDs while providing the flexibility of combined identifiers when needed for display or cross-reference purposes.