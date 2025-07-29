---
id: "R10"
title: "Package Consistency Naming Rule"
type: "rule"
date_created: "2025-04-03"
date_modified: "2025-04-03"
author: "Claude"
implements:
  - "MP19": "Package Consistency Principle"
related_to:
  - "R11": "UI-Server-Defaults Triple Rule"
  - "P07": "App Bottom-Up Construction"
---

# Package Consistency Naming Rule

## Core Requirement

When working with external packages, function names and file names must follow the naming conventions of those packages rather than our internal standards. Files must be named after the primary function they contain to maintain consistency between code and file organization.

## Implementation Requirements

### 1. Function Naming Requirements

#### Shiny Module Functions

All Shiny module functions must follow Shiny's camelCase convention with appropriate suffixes:

```r
# UI components must use camelCase with UI suffix
moduleNameUI <- function(id) { ... }

# Server components must use camelCase with Server suffix
moduleNameServer <- function(id, ...) { ... }

# Default components must use camelCase with Defaults suffix
moduleNameDefaults <- function() { ... }
```

Examples:
- `microCustomerUI`
- `dataExplorerServer`
- `rfmAnalysisDefaults`

#### Database Interface Functions

Database functions must follow DBI conventions with the `db` prefix:

```r
# Primary functions use dbVerb format
dbConnect <- function(drv, ...) { ... }
dbGetQuery <- function(conn, statement, ...) { ... }

# Custom functions maintain the db prefix
dbFetchAllCustomers <- function(conn = NULL) { ... }
dbSaveTransaction <- function(conn, transaction_data) { ... }
```

#### ggplot2 Extensions

Functions that extend ggplot2 should follow its naming pattern:

```r
# Geoms use snake_case with geom_ prefix
geom_custom_point <- function(mapping = NULL, ...) { ... }

# Stats use snake_case with stat_ prefix
stat_custom_summary <- function(mapping = NULL, ...) { ... }

# Scales use snake_case with scale_ prefix
scale_color_custom <- function(...) { ... }
```

#### dplyr Extensions

Functions that extend dplyr should follow its verb-first snake_case pattern:

```r
# Data manipulation verbs
filter_by_segment <- function(data, segment) { ... }
summarize_by_group <- function(data, ...) { ... }
```

### 2. File Naming Requirements

File names must match the primary function they contain:

```
# Function: microCustomerUI()
microCustomerUI.R

# Function: dbFetchAllCustomers()
dbFetchAllCustomers.R

# Function: geom_custom_point()
geom_custom_point.R
```

### 3. Directory Organization

#### For Shiny Components:

Follow the folder-based organization defined in R11, with component function names determining folder structure:

```
10_rshinyapp_components/
├── micro/
│   ├── microCustomer/
│   │   ├── microCustomerUI.R
│   │   ├── microCustomerServer.R
│   │   └── microCustomerDefaults.R
│   └── microTransactions/
│       ├── microTransactionsUI.R
│       ├── microTransactionsServer.R
│       └── microTransactionsDefaults.R
└── macro/
    └── macroOverview/
        ├── macroOverviewUI.R
        ├── macroOverviewServer.R
        └── macroOverviewDefaults.R
```

#### For Database Functions:

Group related database functions in meaningful directories:

```
03_database/
├── core/
│   ├── dbConnect.R
│   ├── dbDisconnect.R
│   └── dbGetQuery.R
├── customers/
│   ├── dbFetchAllCustomers.R
│   └── dbSaveCustomer.R
└── transactions/
    ├── dbGetTransactions.R
    └── dbSaveTransaction.R
```

## Implementation Examples

### Example 1: Shiny Module Triple

```r
# File: microCustomerUI.R
#' Micro Customer UI Component
#'
#' @param id The module ID
#' @export
microCustomerUI <- function(id) {
  ns <- NS(id)
  
  card(
    card_header("Customer Profile"),
    card_body(
      selectInput(ns("customer_id"), "Select Customer", choices = NULL),
      valueBox(
        title = "Customer Value",
        value = textOutput(ns("customer_value"))
      )
    )
  )
}

# File: microCustomerServer.R
#' Micro Customer Server Component
#'
#' @param id The module ID
#' @param data_source The data source
#' @export
microCustomerServer <- function(id, data_source = NULL) {
  moduleServer(id, function(input, output, session) {
    # Server logic...
  })
}

# File: microCustomerDefaults.R
#' Default Values for Micro Customer Component
#'
#' @return Named list of default values
#' @export
microCustomerDefaults <- function() {
  list(
    customer_value = "$0.00"
  )
}
```

### Example 2: Database Functions

```r
# File: dbFetchAllCustomers.R
#' Fetch All Customers from Database
#'
#' @param conn Database connection
#' @return Dataframe with customers
#' @export
dbFetchAllCustomers <- function(conn = NULL) {
  # Use local connection if none provided
  if (is.null(conn)) {
    conn <- getDefaultConnection()
  }
  
  # Execute query with proper error handling
  query <- "SELECT * FROM customers WHERE active = 1 ORDER BY created_at DESC"
  result <- dbGetQuery(conn, query)
  
  return(result)
}
```

### Example 3: ggplot2 Extension

```r
# File: geom_customer_segments.R
#' Custom Geom for Customer Segment Visualization
#'
#' @inheritParams ggplot2::geom_point
#' @export
geom_customer_segments <- function(mapping = NULL, data = NULL, stat = "identity",
                                   position = "identity", ...) {
  ggplot2::layer(
    geom = GeomCustomerSegments,
    mapping = mapping,
    data = data,
    stat = stat,
    position = position,
    params = list(...)
  )
}

# ggproto object definition
GeomCustomerSegments <- ggplot2::ggproto("GeomCustomerSegments", ggplot2::GeomPoint,
  # Custom drawing function...
)
```

## Common Errors and Solutions

### Error 1: Inconsistent Naming Between Function and File

**Problem**: Function name doesn't match file name, making it difficult to locate function definitions.

```r
# File: customer_ui.R
microCustomerUI <- function(id) { ... }
```

**Solution**: Rename the file to match the function name:

```r
# File: microCustomerUI.R
microCustomerUI <- function(id) { ... }
```

### Error 2: Mixing Naming Conventions

**Problem**: Inconsistent naming conventions across related functions.

```r
# Inconsistent naming
micro_customer_ui <- function(id) { ... }  # snake_case
microCustomerServer <- function(id) { ... }  # camelCase
```

**Solution**: Consistently follow package conventions:

```r
# Consistent Shiny convention
microCustomerUI <- function(id) { ... }  # camelCase with UI suffix
microCustomerServer <- function(id) { ... }  # camelCase with Server suffix
```

### Error 3: Inconsistent Directory Structure

**Problem**: Different organization patterns for similar components.

**Solution**: Follow consistent directory patterns for each type of function:

```
# Consistent structure for all Shiny components
component_name/
├── componentNameUI.R
├── componentNameServer.R
└── componentNameDefaults.R
```

## Benefits

1. **Predictable Code Navigation**: Developers can easily locate function definitions by file name
2. **Reduced Cognitive Load**: Consistent naming reduces context switching between different conventions
3. **Improved Interoperability**: Code follows the conventions of the ecosystems it integrates with
4. **Simplified Development**: IDE autocomplete and function lookup work more effectively
5. **Cleaner API Boundaries**: Clear distinction between functions from different ecosystems
6. **Better Maintainability**: Standardized naming patterns make code more accessible to new developers
7. **Easier Package Development**: Follows R package standards for potential future extraction

## Relation to Other Rules and Principles

### Relation to R11 (UI-Server-Defaults Triple Rule)

R11 defines how Shiny components should be organized as triples of UI, server, and defaults files. This rule (R12) complements R11 by specifying the naming patterns for functions and files within that organizational structure.

### Relation to MP19 (Package Consistency Principle)

This rule directly implements MP19 by providing specific requirements and examples for following package conventions in function and file naming.

### Relation to P07 (App Bottom-Up Construction)

Consistent naming patterns support bottom-up construction by making components more self-contained and reusable.

## Conclusion

The Package Consistency Naming Rule ensures that our codebase maintains consistent naming patterns that align with the external packages and ecosystems we integrate with. By following package-specific conventions for function naming and ensuring files are named after their primary functions, we create a more navigable, maintainable, and interoperable codebase.
