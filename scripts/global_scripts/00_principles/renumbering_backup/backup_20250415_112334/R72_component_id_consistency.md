# R72: Component ID Consistency Rule

## Purpose
This rule establishes that all parts of an n-tuple component (UI, server, defaults) must use identical base identifiers to ensure proper communication between components, prevent namespace collisions, and maintain debugging simplicity.

## Implementation

### 1. Component Base Identifier

All parts of a component n-tuple must use the same base identifier:

```r
####ui.user_profile####
ui.user_profile <- function(id) {
  # id must match the base component name (user_profile)
  ns <- NS(id)
  # UI implementation
}

####server.user_profile####
server.user_profile <- function(id, data) {
  # id must match the base component name (user_profile)
  moduleServer(id, function(input, output, session) {
    # Server implementation
  })
}

####defaults.user_profile####
defaults.user_profile <- list(
  # Component defaults
)
```

### 2. ID Derivation Rules

Component IDs should be derived using these rules:

1. The base ID for a component should match its filename (minus any prefixes)
2. For files containing multiple components, the ID should match the component's suffix
3. The ID should be passed unchanged between UI, server, and defaults components
4. The same ID parameter name must be used in all component functions

### 3. Namespace Usage

Namespaces must be derived immediately from the provided ID:

```r
####ui.customer_list####
ui.customer_list <- function(id) {
  # CORRECT: Using the id parameter directly
  ns <- NS(id)
  
  div(
    h3("Customers"),
    tableOutput(ns("customer_table"))  # Using namespace derived from id
  )
}

####server.customer_list####
server.customer_list <- function(id, data) {
  # CORRECT: Using the same id parameter directly
  moduleServer(id, function(input, output, session) {
    output$customer_table <- renderTable({
      # Implementation
    })
  })
}
```

### 4. Common Violations to Avoid

#### ID Mismatch Between UI and Server
```r
# INCORRECT: Mismatched IDs
ui.component <- function(ui_id) {  # Wrong parameter name
  ns <- NS(ui_id)
  # UI implementation
}

server.component <- function(server_id, data) {  # Different parameter name
  moduleServer(server_id, function(input, output, session) {
    # Server implementation
  })
}
```

#### Modified IDs
```r
# INCORRECT: Modifying ID
ui.component <- function(id) {
  ns <- NS(paste0("prefix_", id))  # Modifying ID - WRONG
  # UI implementation
}
```

#### Inconsistent Usage in Module Registration
```r
# INCORRECT: Inconsistent ID usage
moduleServer("customer_module", function(input, output, session) {
  # Using different IDs for sub-components
  ui.customer_profile("profile")    # Using "profile" for UI
  server.customer_profile("customer_profile") # Using "customer_profile" for server
})
```

### 5. ID Generation Patterns

For dynamically generated components, follow these patterns:

#### Sequential IDs
```r
# CORRECT: Sequential IDs with consistent prefixing
lapply(1:n, function(i) {
  component_id <- paste0(id, "_item_", i)
  ui.list_item(component_id)
  server.list_item(component_id, data[[i]])
})
```

#### Named IDs
```r
# CORRECT: Named IDs with consistent application
lapply(names(items), function(item_name) {
  component_id <- paste0(id, "_", item_name)
  ui.item(component_id)
  server.item(component_id, items[[item_name]])
})
```

## Valid Examples

### Example 1: Basic Module with Consistent IDs

```r
####ui.customer_profile####
ui.customer_profile <- function(id) {
  ns <- NS(id)
  
  div(
    h3("Customer Profile"),
    textOutput(ns("name")),
    textOutput(ns("email"))
  )
}

####server.customer_profile####
server.customer_profile <- function(id, customer_data) {
  moduleServer(id, function(input, output, session) {
    output$name <- renderText({
      customer_data()$name
    })
    
    output$email <- renderText({
      customer_data()$email
    })
  })
}

####defaults.customer_profile####
defaults.customer_profile <- list(
  empty_customer = list(
    name = "No customer selected",
    email = "N/A"
  )
)

# Usage in parent module
ui.parent <- function(id) {
  ns <- NS(id)
  div(
    ui.customer_profile(ns("profile"))
  )
}

server.parent <- function(id) {
  moduleServer(id, function(input, output, session) {
    customer_data <- reactive({
      # Get customer data
    })
    
    server.customer_profile("profile", customer_data)
  })
}
```

### Example 2: Dynamic Components

```r
####ui.tab_panel####
ui.tab_panel <- function(id, tab_items) {
  ns <- NS(id)
  
  tabs <- lapply(names(tab_items), function(tab_name) {
    tab_id <- paste0(id, "_", tab_name)
    tabPanel(
      title = tab_items[[tab_name]]$title,
      ui.tab_content(tab_id)
    )
  })
  
  do.call(tabsetPanel, tabs)
}

####server.tab_panel####
server.tab_panel <- function(id, tab_items, data) {
  moduleServer(id, function(input, output, session) {
    # Initialize each tab's server component
    lapply(names(tab_items), function(tab_name) {
      tab_id <- paste0(id, "_", tab_name)
      server.tab_content(tab_id, data[[tab_name]])
    })
  })
}
```

## Invalid Patterns

### Invalid Example 1: Inconsistent Parameter Names

```r
# INCORRECT: Using different parameter names
ui.component <- function(ui_id) {  # Should be just "id"
  ns <- NS(ui_id)
  # UI implementation
}

server.component <- function(module_id, data) {  # Should be just "id"
  moduleServer(module_id, function(input, output, session) {
    # Server implementation
  })
}
```

### Invalid Example 2: ID Transformation

```r
# INCORRECT: Transforming IDs
ui.component <- function(id) {
  # Wrong - modifying id before namespace creation
  ns <- NS(tolower(id))
  # UI implementation
}

server.component <- function(id, data) {
  # Wrong - different transformation makes IDs inconsistent
  moduleServer(gsub(" ", "_", id), function(input, output, session) {
    # Server implementation
  })
}
```

## Benefits

1. **Debugging Simplicity**: Makes it easier to trace errors across component parts
2. **Maintenance**: Simplifies code maintenance by using consistent identifiers
3. **Reactivity**: Ensures reactivity works correctly between UI and server components
4. **Collision Prevention**: Prevents namespace collisions in complex applications
5. **Clarity**: Improves code clarity and developer understanding

## Relationship to Other Rules

### Implements and Extends

1. **R09 (UI Server Defaults Triple)**: Enhances the triple pattern with ID consistency
2. **R70 (N-Tuple Delimiter)**: Complements the delimiter pattern with ID consistency
3. **MP17 (Separation of Concerns)**: Supports proper separation while maintaining connections

### Related Rules

1. **R19 (Object Naming Convention)**: Extends naming conventions to component IDs
2. **P16 (Component Testing)**: Makes testing easier with predictable component IDs
3. **R21 (One Function One File)**: Works alongside file organization principles

## Verification Checklist

1. **Consistent Parameter Names**: Ensure all component functions use `id` as the parameter name
2. **Direct NS Usage**: Check that `NS(id)` is called without modifying the ID
3. **Module Registration**: Verify moduleServer uses the same ID as the UI component
4. **Dynamic ID Generation**: Confirm consistent ID generation for dynamic components
5. **Parent-Child Consistency**: Check that parent modules correctly namespace child module IDs

## Implementation Strategy

1. **New Components**: Apply this rule strictly to all new components
2. **Existing Components**: Refactor existing components to use consistent IDs
3. **Automated Checks**: Develop linting rules to verify ID consistency
4. **Documentation**: Include ID requirements in component documentation

#LOCK FILE