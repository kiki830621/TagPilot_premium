---
id: "R47"
title: "Aggregate Variable Naming Convention"
type: "rule"
date_created: "2025-04-06"
author: "Claude"
implements:
  - "MP17": "Separation of Concerns"
  - "MP08": "Terminology Axiomatization"
related_to:
  - "R19": "Object Naming Convention"
  - "R24": "Type Token Naming"
---

# Aggregate Variable Naming Convention

## Core Rule

When naming variables that represent aggregated data, prefix the variable name with the aggregation function name rather than using generic terms like "total" or "all".

## Rationale

Clear and consistent naming of aggregated variables:

1. **Provides explicit information** about how the data was processed
2. **Avoids ambiguity** about the operation applied to the data
3. **Enhances code readability** and self-documentation
4. **Facilitates debugging** by making data transformations more transparent
5. **Ensures consistency** in naming conventions across the codebase

## Implementation Guidelines

### Preferred Prefixes

Use these function-based prefixes for aggregated variables:

| Prefix    | Meaning                                 | Example                |
|-----------|----------------------------------------|------------------------|
| `sum_`    | Sum of values                          | `sum_spent_by_date`    |
| `mean_`   | Arithmetic mean                        | `mean_price_by_item`   |
| `median_` | Median value                           | `median_amount_by_cat` |
| `min_`    | Minimum value                          | `min_time_by_date`     |
| `max_`    | Maximum value                          | `max_price_by_vendor`  |
| `count_`  | Count of observations                  | `count_orders_by_day`  |
| `std_`    | Standard deviation                     | `std_price_by_category`|
| `var_`    | Variance                               | `var_sales_by_region`  |

### Suffix Usage

Include a descriptive suffix that indicates the grouping or categorization:

| Suffix      | Meaning                                      | Example                |
|-------------|--------------------------------------------|------------------------|
| `_by_date`  | Aggregated by date                         | `sum_spent_by_date`    |
| `_by_customer` | Aggregated by customer                  | `sum_orders_by_customer` |
| `_by_region`| Aggregated by geographical region          | `mean_sales_by_region` |
| `_by_product`| Aggregated by product                     | `count_units_by_product`|

### Suffix Elimination Rule

When further aggregating an already aggregated variable, eliminate redundant suffixes:

1. If `min_time_by_date` represents the minimum time within each date, then:
2. The minimum of all `min_time_by_date` values should be named `min_time` (not `min_min_time_by_date` or `min_time_by_date_by_customer`)

**Example:**
```r
# First-level aggregation by date
result[, min_time_by_date := min(payment_time), by = .(customer_id, date)]

# Further aggregation across dates for each customer
result[, min_time := min(min_time_by_date), by = customer_id]
```

### Incorrect vs. Correct Examples

**Incorrect naming (too generic):**
```r
total_spent <- sum(transaction_amount)
average_price <- mean(item_price)
all_transactions <- count(transactions)
```

**Correct naming (specific and clear):**
```r
sum_spent <- sum(transaction_amount)
mean_price <- mean(item_price)
count_transactions <- count(transactions)
```

**Incorrect naming (grouped data):**
```r
total_spent_date <- aggregate(amount ~ date, data = df, sum)
customer_transactions <- aggregate(count ~ customer_id, data = df, sum)
```

**Correct naming (grouped data):**
```r
sum_spent_by_date <- aggregate(amount ~ date, data = df, sum)
sum_transactions_by_customer <- aggregate(count ~ customer_id, data = df, sum)
```

## Specific Transformations

For data.table operations, maintain consistent naming:

```r
# Group by date, sum transactions
dt[, sum_spent_by_date := sum(amount), by = date]

# Multiple aggregations in one step
result <- dt[, .(
  sum_spent_by_date = sum(amount),
  count_orders_by_date = .N,
  min_time_by_date = min(order_time)
), by = .(customer_id, date)]
```

## Benefits

1. **Self-documenting code**: The variable name itself explains how the data was processed
2. **Consistency**: Established patterns make code more predictable and maintainable
3. **Clarity**: Reduces confusion about what operations were performed
4. **Traceability**: Makes it easier to track data transformations

## Integration with Other Principles

This rule builds upon and complements:

1. **R19 (Object Naming Convention)**: Extends naming conventions to aggregated variables
2. **R24 (Type Token Naming)**: Provides specific guidance for a common type of derived data
3. **MP17 (Separation of Concerns)**: Helps separate different types of aggregated data clearly

## Exceptions

While descriptive prefixes are strongly recommended, there are a few acceptable exceptions:

1. **Established domain-specific terms**: Variables like `lifetime_value` that are standard in the field
2. **Final presentation variables**: When preparing data for final reporting, more reader-friendly names may be used
3. **Very limited scope**: In small, self-contained functions where context is extremely clear

However, even in these cases, consider adding comments to clarify how the aggregation was performed.