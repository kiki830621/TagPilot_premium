---
id: "R0051"
title: "Lowercase Variable Naming Convention"
type: "rule"
date_created: "2025-04-06"
author: "Claude"
implements:
  - "MP0017": "Separation of Concerns"
  - "MP0008": "Terminology Axiomatization"
related_to:
  - "R0047": "Aggregate Variable Naming Convention"
  - "R0019": "Object Naming Convention"
---

# Lowercase Variable Naming Convention

## Core Rule

All variable names must use lowercase letters exclusively for initial character and word separation, with underscores used to separate multiple words (snake_case).

## Rationale

Consistently using lowercase variable names:

1. **Ensures uniformity** across the codebase
2. **Eliminates ambiguity** about capitalization styles
3. **Simplifies code writing and reading** by removing the need to remember capitalization patterns
4. **Prevents errors** related to case-sensitivity in languages like R
5. **Follows modern R conventions** in major packages like data.table and tidyverse
6. **Eliminates backward compatibility concerns** by enforcing a single standard

## Implementation Guidelines

### Naming Pattern

All variable names must follow this pattern:
- Start with a lowercase letter
- Use only lowercase letters for all words
- Separate words with underscores (snake_case)
- Never use uppercase letters in variable names

### Examples

#### Correct (lowercase snake_case)

```r
customer_id
total_amount
purchase_date
min_time
count_transactions
ipt  # inter-purchase time
sum_spent_by_date
```

#### Incorrect (contains uppercase)

```r
CustomerID  # CamelCase
Total_Amount  # Initial capitals
purchaseDate  # camelCase
MIN_TIME  # ALL_CAPS
IPT  # acronym in caps
```

## Transition Process

When working with existing code:

1. **New variables**: Always use lowercase snake_case
2. **Modified variables**: Rename to lowercase snake_case
3. **Existing variables**: When significantly refactoring code, update variable names to lowercase
4. **No backward compatibility**: Do not maintain backward compatibility with old naming conventions

## Special Cases

### Acronyms and Abbreviations

Acronyms and abbreviations must also be lowercase:

```r
# Correct
ipt  # Inter-Purchase Time
cri  # Customer Regularity Index
clt  # Customer Lifetime Value

# Incorrect
IPT
CRI
CLT
```

### Function Names

This rule applies to variable names only. Function names should follow R's function_name() convention (also lowercase snake_case).

### Field and Column Names

This applies to all dataframe column names and database field names:

```r
# Correct
df <- data.frame(
  customer_id = c(1, 2, 3),
  purchase_date = as.Date(c("2023-01-01", "2023-01-15", "2023-02-01")),
  total_amount = c(100, 150, 200)
)

# Incorrect
df <- data.frame(
  Customer_ID = c(1, 2, 3),
  PurchaseDate = as.Date(c("2023-01-01", "2023-01-15", "2023-02-01")),
  Total_Amount = c(100, 150, 200)
)
```

## Documentation Standards

When documenting code:
- Always use the exact lowercase form of variable names
- Never introduce uppercase variants in documentation or comments
- Explain the meaning of abbreviations in documentation, not via capitalization

## Benefits

1. **Code consistency**: Uniform naming patterns across the entire codebase
2. **Reduced cognitive load**: No need to remember which variables use which capitalization pattern
3. **Error prevention**: Eliminates errors due to inconsistent capitalization
4. **Alignment with modern R practices**: Follows conventions in popular R packages
5. **Simplicity**: One rule to remember - "always lowercase with underscores"

## Integration with Other Principles

This rule builds upon and complements:

1. **R0047 (Aggregate Variable Naming Convention)**: Adds capitalization standards to the naming rules
2. **R0019 (Object Naming Convention)**: Extends naming conventions with specific capitalization rules
3. **MP0017 (Separation of Concerns)**: Helps separate different variables clearly with a consistent style
4. **MP0008 (Terminology Axiomatization)**: Supports formal definitions with consistent capitalization

## Implementation Note

This rule explicitly overrides any older practices that allowed mixed case or uppercase variable names. It does not require maintaining backward compatibility with previous capitalization patterns. When modifying existing code, variables should be updated to follow the lowercase convention without maintaining dual naming for compatibility.
