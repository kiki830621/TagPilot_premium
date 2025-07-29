---
id: "R0112"
title: "Comment-Code Spacing Rule"
type: "rule"
date_created: "2025-04-15"
author: "Claude"
implements:
  - "MP0017": "Separation of Concerns"
  - "P0013": "Language Standard Adherence"
related_to:
  - "R0094": "Roxygen2 Function Examples Standard"
  - "R0057": "Commented Code Cleanup"
---

# Comment-Code Spacing Rule

## Core Concept

A blank line must be maintained between the end of documentation comments and the actual code implementation to ensure proper parsing, readability, and compatibility with documentation tools.

## Motivation

Proper spacing between documentation comments and code implementation is not merely a stylistic preference, but a critical element that affects:

1. **Documentation Tool Parsing**: Tools like roxygen2 and documentation generators may fail to properly parse documentation without proper spacing
2. **Code Readability**: Clear separation between documentation and implementation helps developers distinguish between what a function does and how it does it
3. **Maintenance Efficiency**: Consistent spacing patterns reduce cognitive load during code review and maintenance

## Specific Requirements

### 1. Required Spacing After Roxygen Blocks

Between roxygen-style documentation blocks (comments starting with `#'`) and the function declaration, there must be exactly one blank line:

```r
#' Function description
#' 
#' @param argument Description
#' @return Return value description
#'
# Note the blank line above this comment
function_name <- function(argument) {
  # Implementation
}
```

### 2. Required Spacing After Documentation Comments

For non-roxygen documentation that precedes function declarations, maintain one blank line between the last comment and the function:

```r
# This function performs important calculation
# with several steps
#
# Note the blank line above this comment
calculate_result <- function() {
  # Implementation
}
```

### 3. Function Parameters Spacing

When function parameters span multiple lines, maintain consistent indentation and spacing:

```r
#' Generate a complex query
#' @param various parameters
#'
generate_create_table_query <- function(con, source_table = NULL, target_table, 
                                        column_defs = NULL, primary_key = NULL,
                                        foreign_keys = NULL, indexes = NULL) {
  # Implementation
}
```

The space between the ending comment line and the function declaration is essential for proper parsing and documentation generation.

## Common Issues and Solutions

### 1. Roxygen Parsing Failures

**Issue**: Documentation not appearing in generated help files
**Solution**: Ensure a blank line exists between the last `#'` comment and the function declaration

### 2. Inconsistent Documentation Style

**Issue**: Some functions have spacing, others don't
**Solution**: Use automated linting to enforce consistent spacing patterns

### 3. Comment Continuation Confusion

**Issue**: Unclear where documentation ends and implementation begins
**Solution**: Always include a blank line separator, even for short documentation

## Implementation Examples

### Correct Implementation

```r
#' Calculate sum of squares
#' 
#' @param x Numeric vector of values
#' @return Sum of squared values
#'
sum_of_squares <- function(x) {
  sum(x^2)
}
```

### Incorrect Implementation

```r
#' Calculate sum of squares
#' 
#' @param x Numeric vector of values
#' @return Sum of squared values
sum_of_squares <- function(x) {  # Missing blank line
  sum(x^2)
}
```

## Relationship to Other Rules

This rule:

1. **Implements MP0017 (Separation of Concerns)**: Clearly separates documentation from implementation
2. **Implements P0013 (Language Standard Adherence)**: Follows R community best practices for documentation
3. **Relates to R0094 (Roxygen2 Function Examples Standard)**: Complements proper roxygen2 usage
4. **Relates to R0057 (Commented Code Cleanup)**: Ensures legitimate comments are formatted properly

## Conclusion

Maintaining proper spacing between documentation comments and code implementation is a critical practice that ensures documentation tools work correctly, improves code readability, and facilitates maintenance. This rule must be consistently applied across all code files in the project.