---
id: "R0115"
title: "dplyr Usage Rules"
type: "rule"
date_created: "2025-04-19"
author: "Claude"
implements:
  - "MP0030": "Vectorization Principle"
  - "MP0047": "Functional Programming"
  - "MP0060": "Parsimony"
related_to:
  - "R0049": "Apply Over Loops"
  - "R0048": "Switch Over If-Else"
  - "P0077": "Performance Optimization"
---

# dplyr Usage Rules

## Core Requirement

All data manipulation in precision marketing applications must follow consistent dplyr usage patterns that prioritize clarity, maintainability, and performance while avoiding common pitfalls and warning messages.

## Pattern Description

The dplyr Usage Rules standardize how data manipulation is performed throughout the application, ensuring consistency, readability, and optimal performance. These rules establish best practices for using dplyr's grammar of data manipulation and address common issues that can lead to warnings, errors, or inefficient code.

### 1. Group Management

When using grouped operations, always explicitly manage group status:

```r
# CORRECT: Explicitly handle grouping
df %>%
  group_by(customer_id) %>%
  summarize(
    purchase_count = n(),
    total_spent = sum(amount),
    .groups = "drop"  # Explicitly drop grouping
  )

# CORRECT: Maintain grouping when needed for further operations
df %>%
  group_by(customer_id, product_category) %>%
  summarize(
    purchase_count = n(),
    .groups = "keep"  # Explicitly keep grouping (maintains customer_id grouping)
  ) %>%
  # Continue with grouped operations
  mutate(category_percentage = purchase_count / sum(purchase_count))
```

### 2. Function Namespacing

Always namespace dplyr functions in package code and complex scripts:

```r
# CORRECT: Explicitly namespace functions
df %>%
  dplyr::filter(amount > 100) %>%
  dplyr::mutate(tax = amount * 0.05) %>%
  dplyr::select(customer_id, product_id, amount, tax)

# INCORRECT: Implicit function usage (don't do this)
df %>%
  filter(amount > 100) %>%
  mutate(tax = amount * 0.05) %>%
  select(customer_id, product_id, amount, tax)
```

### 3. Handling dplyr-Generated Warnings

When using grouped operations that might trigger warnings, use the appropriate strategies:

```r
# CORRECT: Using .groups parameter
result <- df %>%
  dplyr::group_by(customer_id, date) %>%
  dplyr::summarize(
    total = sum(amount),
    count = dplyr::n(),
    .groups = "drop"  # Explicitly drops all grouping
  )

# CORRECT: Using ungroup() when needed
result <- df %>%
  dplyr::group_by(customer_id, date) %>%
  dplyr::summarize(
    total = sum(amount),
    count = dplyr::n()
  ) %>%
  dplyr::ungroup()  # Explicitly removes all grouping
```

### 4. Variable Selection

Use consistent patterns for selecting or referring to variables:

```r
# CORRECT: Using all_of() for external vectors of column names
selected_cols <- c("customer_id", "product_id", "amount")
df %>% dplyr::select(dplyr::all_of(selected_cols))

# CORRECT: Using any_of() when some columns might be missing
optional_cols <- c("discount", "coupon_code", "referrer")
df %>% dplyr::select(dplyr::any_of(optional_cols))

# CORRECT: Using across() for applying functions to multiple columns
df %>%
  dplyr::mutate(dplyr::across(
    .cols = dplyr::where(is.numeric),
    .fns = ~ replace(., is.na(.), 0)
  ))
```

### 5. Join Operations

Use explicit join variants and always specify by:

```r
# CORRECT: Explicit join type with by parameter
customers %>%
  dplyr::left_join(
    orders,
    by = "customer_id"
  )

# CORRECT: Handling differently named join columns
customers %>%
  dplyr::left_join(
    orders,
    by = c("customer_id" = "buyer_id")
  )
```

## Implementation

### 1. Handling Missing Values

Always be explicit about handling missing values:

```r
# CORRECT: Explicit NA handling in aggregations
df %>%
  dplyr::group_by(customer_id) %>%
  dplyr::summarize(
    total_purchases = sum(amount, na.rm = TRUE),
    avg_value = mean(amount, na.rm = TRUE),
    .groups = "drop"
  )
```

### 2. Function Composition

Prefer the pipe operator for composing operations:

```r
# CORRECT: Using pipe for clarity
df %>%
  dplyr::filter(!is.na(customer_id)) %>%
  dplyr::group_by(customer_id) %>%
  dplyr::summarize(
    purchase_count = dplyr::n(),
    total_spent = sum(amount, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  dplyr::arrange(dplyr::desc(total_spent))
```

### 3. Ensuring Reproducibility

Always set random seeds before random operations:

```r
# CORRECT: Setting seed before sample_n/sample_frac
set.seed(123)
df %>% dplyr::sample_n(10)
```

### 4. Handling Large Data

Use appropriate strategies for large data:

```r
# CORRECT: Using slice operations for large data
df %>% 
  dplyr::arrange(date) %>%
  dplyr::slice_tail(n = 1000)  # More efficient than tail()
```

### 5. Model Formula Construction with Factors

When preparing data for modeling, use explicit factor conversion and proper formula construction:

```r
# PROBLEM: Incorrect factor handling for machine learning models
train_data <- train_data %>% 
  mutate(product_id=as.factor(product_id), prev_product_id=as.factor(prev_product_id))

formula_str <- paste("(product_id) ~", 
                     paste(c("(prev_product_id)", covariate_cols), collapse = " + "))
# This will fail because product_id and prev_product_id are missing the as.factor() wrapper
# Additionally, trying to add as.factor() in the formula is redundant if already converted

# CORRECT: Proper factor conversion with namespacing
train_data <- train_data %>% 
  dplyr::mutate(
    product_id = as.factor(product_id),
    prev_product_id = as.factor(prev_product_id)
  )

# CORRECT: Formula references the column names directly (already factors)
formula_str <- paste("product_id ~", 
                     paste(c("prev_product_id", covariate_cols), collapse = " + "))

model <- randomForest::randomForest(
  formula = as.formula(formula_str),
  data = train_data,
  ntree = 100
)
```

## Common Warnings and Solutions

### 1. "Adding missing grouping variables"

This warning occurs when a summarize operation drops some grouping variables:

```r
# Problem: Creates warning about missing grouping variables
df %>%
  dplyr::group_by(customer_id, product_id) %>%
  dplyr::summarize(total = sum(amount))  # Warning occurs here

# Solution 1: Use .groups parameter
df %>%
  dplyr::group_by(customer_id, product_id) %>%
  dplyr::summarize(
    total = sum(amount),
    .groups = "drop"  # Explicitly drop all grouping
  )

# Solution 2: Use .groups parameter to keep specific grouping
df %>%
  dplyr::group_by(customer_id, product_id) %>%
  dplyr::summarize(
    total = sum(amount),
    .groups = "keep"  # Keep both grouping variables
  )

# Solution 3: Use ungroup() after operations
df %>%
  dplyr::group_by(customer_id, product_id) %>%
  dplyr::summarize(total = sum(amount)) %>%
  dplyr::ungroup()  # Remove all grouping
```

### 2. "Unknown or uninitialised column"

This error occurs when referring to columns that don't exist or haven't been created yet:

```r
# Problem:
df %>%
  dplyr::mutate(
    tax = amount * 0.05,
    total = amount + tax  # Works fine
  ) %>%
  dplyr::select(sales_id, total)  # Error if sales_id doesn't exist

# Solution 1: Verify column existence before using
if ("sales_id" %in% colnames(df)) {
  df %>%
    dplyr::mutate(
      tax = amount * 0.05,
      total = amount + tax
    ) %>%
    dplyr::select(sales_id, total)
}

# Solution 2: Use any_of() to safely select columns that might not exist
df %>%
  dplyr::mutate(
    tax = amount * 0.05,
    total = amount + tax
  ) %>%
  dplyr::select(dplyr::any_of(c("sales_id", "total")))
```

### 3. "Joining with `by = NULL`"

This warning occurs when performing a join without specifying the join columns:

```r
# Problem:
df1 %>% dplyr::left_join(df2)  # Warning: Joining with `by = NULL`

# Solution: Always specify join columns explicitly
df1 %>% dplyr::left_join(df2, by = "customer_id")
```

## Benefits

1. **Consistency**: Uniform data manipulation patterns across the application
2. **Readability**: Clear, predictable code that is easier to maintain
3. **Performance**: Optimized data operations that avoid common inefficiencies
4. **Reproducibility**: Deterministic results through consistent approaches
5. **Maintainability**: Easier debugging and fewer warning messages
6. **Explicit Intent**: Code that clearly communicates the developer's intentions

## Relationship to Other Rules and Principles

This rule implements:
- **MP0030 (Vectorization Principle)**: By promoting vectorized operations over loops
- **MP0047 (Functional Programming)**: By using functional data transformation approaches
- **MP0060 (Parsimony)**: By creating concise, readable data manipulation code

It relates to:
- **R0049 (Apply Over Loops)**: By providing dplyr alternatives to imperative loops
- **R0048 (Switch Over If-Else)**: By promoting declarative patterns over imperative ones
- **P0077 (Performance Optimization)**: By establishing efficient data manipulation patterns

## Code Example

Example implementing all dplyr best practices:

```r
library(dplyr)

# Function that follows all dplyr rules
analyze_customer_purchases <- function(purchase_data, min_purchase_date = NULL) {
  # Input validation
  if (!is.data.frame(purchase_data)) {
    stop("purchase_data must be a data frame")
  }
  
  if (!all(c("customer_id", "purchase_date", "amount") %in% colnames(purchase_data))) {
    stop("purchase_data must contain customer_id, purchase_date, and amount columns")
  }
  
  # Filter by date if provided (safely handling NULL)
  filtered_data <- if (!is.null(min_purchase_date)) {
    purchase_data %>%
      dplyr::filter(purchase_date >= min_purchase_date)
  } else {
    purchase_data
  }
  
  # Customer-level summary
  customer_summary <- filtered_data %>%
    # Group by customer
    dplyr::group_by(customer_id) %>%
    # Summarize with explicit NA handling
    dplyr::summarize(
      total_purchases = dplyr::n(),
      total_spent = sum(amount, na.rm = TRUE),
      avg_purchase = mean(amount, na.rm = TRUE),
      first_purchase = min(purchase_date, na.rm = TRUE),
      last_purchase = max(purchase_date, na.rm = TRUE),
      .groups = "drop"  # Explicitly drop grouping
    ) %>%
    # Add derived measures
    dplyr::mutate(
      days_as_customer = as.numeric(difftime(last_purchase, first_purchase, units = "days")),
      purchase_frequency = dplyr::if_else(
        days_as_customer > 0,
        total_purchases / days_as_customer * 30,  # Monthly frequency
        0
      )
    ) %>%
    # Sort by total spent
    dplyr::arrange(dplyr::desc(total_spent))
  
  return(customer_summary)
}
```

## Testing dplyr Code

When testing dplyr operations, validate both the structure and content:

```r
test_that("analyze_customer_purchases works correctly", {
  # Create test data
  test_data <- data.frame(
    customer_id = c(1, 1, 2, 3, 3, 3),
    purchase_date = as.Date(c("2025-01-01", "2025-02-01", "2025-01-15", 
                             "2025-03-01", "2025-03-15", "2025-04-01")),
    amount = c(100, 150, 200, 50, 75, 100)
  )
  
  # Run function
  result <- analyze_customer_purchases(test_data)
  
  # Test structure
  expect_s3_class(result, "data.frame")
  expect_named(result, c("customer_id", "total_purchases", "total_spent", 
                        "avg_purchase", "first_purchase", "last_purchase",
                        "days_as_customer", "purchase_frequency"))
  
  # Test content
  expect_equal(nrow(result), 3)  # Three unique customers
  expect_equal(result$total_purchases, c(3, 2, 1))  # Ordered by total_spent
  expect_equal(result$total_spent, c(225, 250, 200))
})
```

## Conclusion

The dplyr Usage Rules standardize data manipulation throughout the application, ensuring consistent, readable, and performant code. By following these rules, developers can avoid common pitfalls, minimize warnings, and create code that is easier to maintain and extend. These rules build on the functional programming paradigm and vectorization principles to establish a declarative, pipeline-oriented approach to data transformation.