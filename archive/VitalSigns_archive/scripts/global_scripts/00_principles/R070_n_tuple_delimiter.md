# R0070: N-Tuple Delimiter Rule

## Purpose
This rule establishes a clear, consistent pattern for visually separating components in n-tuples (particularly UI-server-defaults triples) using the `####component.name####` delimiter pattern. This enhances code readability and maintainability by clearly delineating boundaries between related components.

## Implementation

### 1. Delimiter Pattern

When implementing n-tuples (such as UI-server-defaults triples), use the following delimiter pattern to separate components:

```
####component.name####
```

Where:
- The delimiter consists of four hash symbols (`####`) on each side
- `component.name` follows the object naming convention from R19
- No spaces should be used within the delimiter

### 2. UI-Server-Defaults Implementation

For UI-server-defaults triples, implement the delimiter pattern as follows:

```r
####ui.component_name####
# UI component implementation
ui.component_name <- function(id) {
  # UI implementation
}

####server.component_name####
# Server component implementation
server.component_name <- function(id, data) {
  # Server implementation
}

####defaults.component_name####
# Default values for the component
defaults.component_name <- list(
  # Default values
)
```

### 3. File Organization Options

The delimiter pattern can be used in two ways:

#### Single File Implementation
```r
# File: component_name.R

####ui.component_name####
ui.component_name <- function(id) {
  # UI implementation
}

####server.component_name####
server.component_name <- function(id, data) {
  # Server implementation
}

####defaults.component_name####
defaults.component_name <- list(
  # Default values
)
```

#### Multiple File Implementation
When following R0021 (One Function One File), use consistent delimiter comments at the beginning of each file:

```r
# File: fn_ui_component_name.R
####ui.component_name####
ui.component_name <- function(id) {
  # UI implementation
}
```

```r
# File: fn_server_component_name.R
####server.component_name####
server.component_name <- function(id, data) {
  # Server implementation
}
```

```r
# File: defaults_component_name.R
####defaults.component_name####
defaults.component_name <- list(
  # Default values
)
```

### 4. Extended N-Tuples

For components with more than three parts, maintain the same delimiter pattern:

```r
####ui.component_name####
# UI implementation

####server.component_name####
# Server implementation

####defaults.component_name####
# Defaults implementation

####tests.component_name####
# Tests implementation

####docs.component_name####
# Documentation implementation
```

## Examples

### Example 1: Customer Profile Component Triple

```r
####ui.customer_profile####
ui.customer_profile <- function(id) {
  ns <- NS(id)
  
  div(
    class = "profile-container",
    h3("Customer Profile"),
    textOutput(ns("customer_name")),
    textOutput(ns("customer_email")),
    valueBoxOutput(ns("total_purchases"))
  )
}

####server.customer_profile####
server.customer_profile <- function(id, customer_data) {
  moduleServer(id, function(input, output, session) {
    output$customer_name <- renderText({
      customer_data()$name
    })
    
    output$customer_email <- renderText({
      customer_data()$email
    })
    
    output$total_purchases <- renderValueBox({
      valueBox(
        customer_data()$purchase_count,
        "Total Purchases",
        icon = icon("shopping-cart")
      )
    })
  })
}

####defaults.customer_profile####
defaults.customer_profile <- list(
  empty_customer = list(
    name = "No customer selected",
    email = "N/A",
    purchase_count = 0
  ),
  refresh_interval = 30,
  max_history_items = 10
)
```

### Example 2: Data Filter Component with Documentation

```r
####ui.data_filter####
ui.data_filter <- function(id) {
  # UI implementation
}

####server.data_filter####
server.data_filter <- function(id, data_source) {
  # Server implementation
}

####defaults.data_filter####
defaults.data_filter <- list(
  # Defaults implementation
)

####docs.data_filter####
# Data Filter Component
# 
# This component provides filtering capabilities for tabular data.
# It supports:
# - Text search
# - Date range filtering
# - Category selection
# - Numeric range filters
#
# Usage: 
# ```r
# ui.data_filter("my_filter")
# server.data_filter("my_filter", reactive(my_data))
# ```
```

## Benefits

1. **Visual Clarity**: Creates clear visual separation between component parts
2. **Consistent Structure**: Establishes a predictable pattern for code organization
3. **Searchability**: Makes it easy to search for specific components using the delimiter pattern
4. **Organization**: Helps maintain organization even in larger files with multiple components
5. **Readability**: Improves code readability and navigation
6. **Documentation**: Serves as self-documenting code structure

## Relationship to Other Rules

### Implements and Extends

1. **R0009 (UI Server Defaults Triple)**: Extends by providing specific delimiter pattern
2. **MP0017 (Separation of Concerns)**: Enhances visual separation of different concerns
3. **R0019 (Object Naming Convention)**: Complements naming conventions with visual separators

### Related Rules

1. **R0021 (One Function One File)**: Can be used alongside this rule or as an alternative approach
2. **P0072 (UI Package Consistency)**: Supports consistent UI component structure
3. **P0073 (Server-to-UI Data Flow)**: Helps clarify relationships between UI and server components

## Implementation Guidance

1. Apply this pattern to all new component development
2. Add delimiters when modifying existing components
3. Use find-and-replace to add delimiters to existing codebases in bulk
4. Consider adding syntax highlighting in IDE for these delimiters to enhance visibility

#LOCK FILE
