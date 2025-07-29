---
id: "MP19"
title: "Package Consistency Principle"
type: "meta-principle"
date_created: "2025-04-03"
date_modified: "2025-04-03"
author: "Claude"
derives_from:
  - "MP01": "Hierarchy of Knowledge"
  - "MP02": "Structural Blueprint"
influences:
  - "P01": "Script Separation"
  - "R11": "UI-Server-Defaults Triple Rule"
  - "R12": "Package Consistency Naming Rule"
related_to:
  - "MP18": "Don't Repeat Yourself Principle"
---

# Package Consistency Principle

## Core Concept

When integrating with external packages or ecosystems, maintaining consistency with their established conventions takes precedence over our internal naming standards. This reduces cognitive load, improves readability, and facilitates easier integration with those ecosystems.

## Principle Hierarchy

The Package Consistency Principle sits at a high level in our principle hierarchy:

1. **MP20 - Package Consistency Principle**
2. Naming conventions (snake_case, camelCase)
3. File organization principles
4. Other style and organization principles

## Key Applications

### 1. Shiny Module Naming

Shiny modules conventionally use camelCase with UI/Server suffixes:

```r
# CORRECT: Following Shiny ecosystem conventions
moduleNameUI <- function(id) { ... }
moduleNameServer <- function(id, ...) { ... }

# Examples from our codebase:
microCustomerUI <- function(id) { ... }
microCustomerServer <- function(id, data_source = NULL) { ... }
```

The function names follow Shiny's convention, and with our folder-based organization, the file names also match the function names:

```
microCustomer/
├── microCustomerUI.R
├── microCustomerServer.R
└── microCustomerDefaults.R
```

### 2. Database Interface Functions

Functions that wrap DBI functionality maintain DBI's naming conventions:

```r
# CORRECT: Following DBI ecosystem conventions
dbConnect <- function(...) { ... }
dbGetQuery <- function(conn, query) { ... }

# Examples from our db_utils:
dbFetchAll <- function(query, conn = NULL) { ... }
```

### 3. Other Package Integrations

The same principle applies to other package integrations:

| Package | Naming Convention | Our Implementation |
|---------|-------------------|-------------------|
| ggplot2 | snake_case and dots (`geom_point()`) | Use `geom_*` naming |
| dplyr | snake_case verbs | Maintain verb-first style |
| data.table | camelCase with dots (`data[, .N, by=group]`) | Use data.table syntax in data.table contexts |

## Implementation Guidelines

### 1. Clear Package Context

When implementing functions that integrate with external packages:

- Clearly document which package's conventions you're following
- Use consistent prefixes or namespaces where appropriate
- Include the package in Imports or Depends

### 2. Interface Boundaries

- Maintain package consistency at the interface boundary
- Internal implementations can follow our standard conventions
- Consider wrapper functions if conventions conflict significantly

### 3. Documentation

- Document any deviations from our standard naming conventions
- Explain which package's conventions are being followed
- Provide examples of the correct usage pattern

### 4. File and Function Naming Alignment

- Files should be named after the primary function they contain
- This is especially important in folder-based organization
- Example: The function `microCustomerUI()` should be in a file named `microCustomerUI.R`

## Examples of Correct Implementation

### Shiny Module Implementation

```r
#' Micro Customer UI Component
#'
#' This follows Shiny module conventions with camelCase naming.
#' The file name matches the function name: microCustomerUI.R
#' 
#' @param id The module ID
#' @return A UI component
#' @export
microCustomerUI <- function(id) {
  ns <- NS(id)
  # Implementation
}
```

### Database Function Implementation

```r
#' Execute Query with Error Handling
#'
#' This follows DBI naming conventions with dbPrefix.
#' 
#' @param query SQL query string
#' @param conn Database connection
#' @return Query results
#' @export
dbSafeExecute <- function(query, conn = default_connection) {
  # Implementation
}
```

## Benefits

1. **Reduced Cognitive Load**: Developers don't have to context-switch between different naming conventions
2. **Improved Interoperability**: Code integrates more naturally with external packages
3. **Better Readability**: Function names align with related functions from the ecosystem
4. **Easier Learning Curve**: New developers familiar with the external packages can onboard more quickly
5. **Clearer API Design**: Interface boundaries are more intuitive

## Relation to Rule 11 (UI-Server-Defaults Triple)

The UI-Server-Defaults Triple Rule (R11) explicitly implements this principle through its folder-based organization pattern. By organizing component files in folders and naming files to match their exported functions, we create consistency between:

1. Function names in code (`microCustomerUI()`)
2. File names on disk (`microCustomerUI.R`)
3. Component folder names (`microCustomer/`)

This alignment creates a predictable structure that follows both R package conventions and Shiny conventions simultaneously.

## Conclusion

The Package Consistency Principle helps us balance internal consistency with the practical reality of working with external packages. By prioritizing consistency with established ecosystems at interface boundaries, we create code that is more intuitive and requires less context-switching for developers familiar with those ecosystems.

When in doubt, ask:
1. Is this function primarily interacting with an external package's API?
2. Does that package have strong naming conventions?
3. Would following our internal conventions create confusion?

If the answers are "yes," follow the external package's conventions.
