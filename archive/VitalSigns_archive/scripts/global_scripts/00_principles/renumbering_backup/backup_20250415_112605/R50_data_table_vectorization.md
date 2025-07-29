---
id: "R50"
title: "data.table Vectorized Operations"
type: "rule"
date_created: "2025-04-06"
author: "Claude"
implements:
  - "MP30": "Vectorization Principle"
related_to:
  - "R49": "Apply Functions Over For Loops"
  - "R47": "Aggregate Variable Naming Convention"
---

# data.table Vectorized Operations

## Core Rule

When using the data.table package in R, leverage its specialized vectorized syntax for data transformations, aggregations, and manipulations rather than using explicit loops or general R constructs.

## Rationale

data.table provides highly optimized, concise syntax for data operations that:

1. **Significantly improves performance** through C-optimized implementations
2. **Reduces memory overhead** through reference semantics and specialized algorithms
3. **Enhances code readability** with a consistent, expressive syntax
4. **Enables complex operations** in a single expression
5. **Minimizes temporary object creation** through by-reference operations

## Implementation Guidelines

### Basic data.table Operations

Structure data.table operations using the comprehensive syntax:

```r
DT[i, j, by]
```

Where:
- `i`: Filter/subset rows (WHERE)
- `j`: Select/compute/update columns (SELECT/UPDATE)
- `by`: Group by specified columns (GROUP BY)

### Vectorized Aggregations

Use data.table's built-in functions and list syntax for aggregations:

```r
# Multiple aggregations in a single operation (vectorized)
result <- dt[, .(
  sum_spent_by_customer = sum(amount, na.rm = TRUE),
  count_transactions = .N,
  mean_amount = mean(amount, na.rm = TRUE),
  min_time = min(transaction_time)
), by = customer_id]
```

### Efficient Column Creation/Modification

Use `:=` for by-reference column addition or modification:

```r
# Vectorized column creation
dt[, `:=`(
  new_col1 = value1 * 2,
  new_col2 = log(value2),
  new_col3 = ifelse(condition, valueA, valueB)
)]
```

### Grouped Operations

Use the `by` parameter for grouped operations:

```r
# Vectorized grouped operations
dt[, .(
  group_sum = sum(value, na.rm = TRUE),
  group_count = .N,
  group_mean = mean(value, na.rm = TRUE)
), by = .(group1, group2)]
```

### Special Symbols

Leverage data.table's special symbols for enhanced operations:

- `.N`: Number of rows in current group
- `.I`: Row numbers in original data
- `.GRP`: Group counter
- `.SD`: Subset of data for current group
- `.SDcols`: Columns to include in .SD

### .SD with lapply for Multiple Column Operations

Use `.SD` with `lapply()` for applying operations to multiple columns:

```r
# Apply the same function to multiple columns within groups
dt[, lapply(.SD, sum), by = group, .SDcols = patterns("^value")]

# Multiple operations on .SD
dt[, c(
  .(group_total = sum(value)),
  lapply(.SD, function(x) mean(x, na.rm = TRUE))
), by = group, .SDcols = patterns("^metric_")]
```

## Explicit Examples

### Incorrect (Non-vectorized)

```r
# Non-vectorized approach with loops (avoid)
result <- data.table(customer_id = unique(dt$customer_id))
for (id in result$customer_id) {
  subset <- dt[customer_id == id]
  result[customer_id == id, sum_spent := sum(subset$amount)]
  result[customer_id == id, count_transactions := nrow(subset)]
}
```

### Correct (Vectorized data.table)

```r
# Vectorized data.table approach (preferred)
result <- dt[, .(
  sum_spent = sum(amount, na.rm = TRUE),
  count_transactions = .N
), by = customer_id]
```

## Advanced Patterns

### Chained Operations with Intermediate Results

```r
# Process in steps using chaining
result <- dt[
  amount > 0,                              # Filter step
][
  , .(total = sum(amount)), by = customer  # Aggregate step
][
  order(-total)                            # Sort step
][
  1:10                                     # Limit step
]
```

### Conditional Aggregations

```r
# Aggregate with conditional logic
dt[, .(
  sum_amount = sum(amount, na.rm = TRUE),
  sum_positive = sum(amount[amount > 0], na.rm = TRUE),
  sum_negative = sum(amount[amount < 0], na.rm = TRUE),
  count_positive = sum(amount > 0),
  count_negative = sum(amount < 0)
), by = category]
```

### Dynamic Column Creation with Patterns

```r
# Create multiple columns with patterns
metrics <- c("sum", "mean", "min", "max")
cols <- c("value1", "value2")

# Create all combinations dynamically
dt[, c(
  .(group_id = group_id),
  unlist(lapply(metrics, function(m) {
    lapply(cols, function(c) {
      if (m == "sum") return(sum(get(c), na.rm = TRUE))
      if (m == "mean") return(mean(get(c), na.rm = TRUE))
      if (m == "min") return(min(get(c), na.rm = TRUE))
      if (m == "max") return(max(get(c), na.rm = TRUE))
    })
  }), recursive = FALSE)
), by = group_id]

# Uses R49 (apply functions) within data.table context
```

## Integration with Aggregate Variable Naming (R47)

When using data.table for aggregations, follow R47 (Aggregate Variable Naming):

```r
# Following both R47 and R50
result <- dt[, .(
  sum_spent_by_customer = sum(amount, na.rm = TRUE),
  count_transactions_by_customer = .N,
  min_time_by_customer = min(transaction_time)
), by = customer_id]
```

## Performance Considerations

1. **Use key/index for large datasets**: `setkey(dt, column)` or `dt[column == value, on = "column"]`
2. **Minimize j expressions**: Combine operations in a single j expression when possible
3. **Use set() for multiple single-column updates**: `set(dt, i, j, value)` is faster than `:=`
4. **Think in terms of columns, not rows**: Operations should transform entire columns

## Integration with Other Principles

This rule implements:

1. **MP30 (Vectorization Principle)**: Directly applies vectorization to data.table operations

And relates to:

1. **R49 (Apply Functions Over For Loops)**: Extends functional programming to data.table's specialized context
2. **R47 (Aggregate Variable Naming Convention)**: Provides naming conventions for aggregated columns

## Exceptions

There are a few cases where alternative approaches may be needed:

1. **Very complex cumulative calculations** that rely on previous results
2. **Recursive operations** that cannot be vectorized
3. **Operations on very large data** where chunking is required for memory reasons

## Conclusion

Leveraging data.table's vectorized operations dramatically improves performance, code clarity, and consistency. By following this rule, you align with both R's functional programming paradigm and data.table's optimized design for large data operations.