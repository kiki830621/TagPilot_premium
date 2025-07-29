# Rule 57: Filtering Logic Patterns

## Core Rule
Filtering logic for special categories, especially "ALL", must follow standard patterns that optimize for both performance and code clarity, with explicit handling of special ID values.

## Implementation Patterns

### Filter Bypassing Pattern
When "ALL" is selected, bypass filtering entirely rather than applying a filter that matches everything:

```r
# Essential Pattern: ALL Bypasses Filter
filter_data <- function(data, category_id) {
  if (category_id == "000") {  # ALL category
    return(data)  # Return full dataset without filtering
  } else {
    return(data[data$category == category_id, ])
  }
}
```

### SQL Query Pattern
In SQL queries, use a conditional clause that evaluates to TRUE for special categories:

```sql
-- Pattern 1: OR condition for ALL
SELECT * FROM products 
WHERE (:category_id = '000' OR category_id = :category_id)

-- Pattern 2: CASE expression for multiple special categories
SELECT * FROM products 
WHERE CASE 
  WHEN :category_id = '000' THEN TRUE  -- ALL category
  WHEN :category_id = '999' THEN category_id IS NULL  -- OTHER category
  ELSE category_id = :category_id  -- Standard category
END
```

### Multi-Level Filtering Pattern
For hierarchical filtering, handle "ALL" at each level independently:

```r
# Multi-level filtering with ALL handling
filter_products <- function(data, category_id, subcategory_id) {
  # Start with all data
  filtered_data <- data
  
  # Apply category filter if not ALL
  if (category_id != "000") {
    filtered_data <- filtered_data[filtered_data$category_id == category_id, ]
  }
  
  # Apply subcategory filter if not ALL
  if (subcategory_id != "000") {
    filtered_data <- filtered_data[filtered_data$subcategory_id == subcategory_id, ]
  }
  
  return(filtered_data)
}
```

### Reactive Dependency Pattern
In Shiny, optimize reactive expressions to avoid unnecessary recalculation:

```r
# In server.R

# Define base data only once
all_data <- reactive({
  load_all_products()
})

# First-level filtered data
category_filtered <- reactive({
  req(input$category_id)
  
  # If ALL is selected, return base data without filtering
  if (input$category_id == "000") {
    return(all_data())
  }
  
  # Otherwise filter by category
  all_data()[all_data()$category_id == input$category_id, ]
})

# Second-level filtered data
fully_filtered <- reactive({
  req(input$subcategory_id)
  
  # Get the appropriate base data based on category selection
  base_data <- category_filtered()
  
  # If ALL subcategory is selected, return category-filtered data without further filtering
  if (input$subcategory_id == "000") {
    return(base_data)
  }
  
  # Otherwise apply subcategory filter
  base_data[base_data$subcategory_id == input$subcategory_id, ]
})
```

### Multiple Value Filtering Pattern
For multi-select inputs, handle special cases:

```r
# Multi-select filtering with ALL handling
filter_by_multiple_categories <- function(data, selected_categories) {
  # If ALL is among selected categories, return all data
  if ("000" %in% selected_categories) {
    return(data)
  }
  
  # If no categories selected, return empty dataset
  if (length(selected_categories) == 0) {
    return(data[0, ])
  }
  
  # Standard filtering for multiple selection
  data[data$category_id %in% selected_categories, ]
}
```

## Performance Considerations

### Caching Strategy
Cache results for common filters, especially the full dataset for "ALL":

```r
# Cache implementation
category_cache <- new.env(parent = emptyenv())

get_filtered_data <- function(category_id) {
  cache_key <- paste("category", category_id, sep = "_")
  
  # Check if result is in cache
  if (exists(cache_key, envir = category_cache)) {
    return(get(cache_key, envir = category_cache))
  }
  
  # Not in cache, compute result
  if (category_id == "000") {
    result <- get_all_data()
  } else {
    result <- filter_data_by_category(category_id)
  }
  
  # Store in cache
  assign(cache_key, result, envir = category_cache)
  return(result)
}
```

### Large Dataset Optimization
For large datasets, consider pre-aggregation or data subsetting:

```r
# Pre-aggregate data for common groupings
precompute_aggregations <- function() {
  # Aggregation for ALL category (total summary)
  all_summary <- aggregate_all_data()
  
  # Aggregations per category
  category_summaries <- lapply(unique(data$category_id), function(cat_id) {
    aggregate_by_category(cat_id)
  })
  
  # Store for later use
  assign("precomputed_aggregations", list(
    all = all_summary,
    by_category = setNames(category_summaries, unique(data$category_id))
  ), envir = .GlobalEnv)
}
```

## Related Rules and Principles
- MP0034 (Special Treatment of "ALL" Category)
- R0056 (Special ID Conventions)
- R0055 (Default Selection Conventions)
- P0002 (Data Integrity)
