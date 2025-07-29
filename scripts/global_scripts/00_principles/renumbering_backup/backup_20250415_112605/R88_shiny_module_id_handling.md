# R88: Shiny Module ID Handling Rule

## Statement
Module component IDs must be consistently handled within Shiny's namespacing system without creating double namespacing.

## Description
This rule establishes a consistent pattern for working with Shiny module IDs and namespaces to prevent common issues like double namespacing when updating inputs via updateXXX functions.

## Rationale
1. **Consistent Interface**: Creates a predictable pattern for working with module IDs
2. **Error Prevention**: Prevents namespacing issues when modules are nested or reused
3. **Clarity**: Makes the relationship between UI and server components explicit
4. **Debugging**: Reduces difficult-to-trace errors related to ID resolution

## Implementation Guide

### Namespacing in UI Components
When defining UI components within a module, always use the `ns()` function to namespace input and output IDs:

```r
moduleNameUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    selectInput(ns("selector"), "Select an option:", choices = c("A", "B", "C")),
    textOutput(ns("result"))
  )
}
```

### Accessing Inputs in Server Functions
When accessing inputs within a module server function, use `input$name` directly without re-namespacing:

```r
moduleNameServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    # CORRECT: Direct access of input value
    output$result <- renderText({
      paste("Selected:", input$selector)
    })
  })
}
```

### Updating Inputs within Module
When updating inputs within a module server function, use the input ID without namespacing, since `session` already has the namespace context:

```r
moduleNameServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    # CORRECT: Directly use the input ID without re-namespacing
    updateSelectInput(
      session = session,
      inputId = "selector", # Do not use ns("selector") here!
      choices = c("X", "Y", "Z")
    )
  })
}
```

### Anti-patterns

```r
# INCORRECT: Double namespacing
moduleNameServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- NS(id) # Creating another namespace function inside moduleServer
    
    updateSelectInput(
      session = session,
      inputId = ns("selector"), # This causes double namespacing!
      choices = c("X", "Y", "Z")
    )
  })
}
```

### Handling Multiple Module Inputs
When a server function handles multiple module IDs (like filter and display components), use separate session objects and proper namespacing:

```r
# CORRECT: Proper handling for multiple components
moduleNameServer <- function(id, filter_id = NULL, display_id = NULL) {
  filter_id <- if (is.null(filter_id)) id else filter_id
  display_id <- if (is.null(display_id)) id else display_id
  
  # The main module
  moduleServer(id, function(input, output, session) {
    # Within this scope, use unnamespaced IDs
    updateSelectInput(
      session = session,
      inputId = "selector",
      choices = c("X", "Y", "Z")
    )
  })
}
```

## Examples

### Correct Implementation
```r
# Module with filter and display components
customerModuleServer <- function(id, filter_id = NULL, display_id = NULL) {
  # Default to main id if specific ids aren't provided
  filter_id <- if (is.null(filter_id)) id else filter_id
  display_id <- if (is.null(display_id)) id else display_id
  
  moduleServer(id, function(input, output, session) {
    # Access inputs directly using input$name
    observeEvent(input$customer_select, {
      # Process selection
    })
    
    # Update inputs directly using the input ID without re-namespacing
    observe({
      updateSelectizeInput(
        session = session,
        inputId = "customer_select", # Correct - no namespacing
        choices = customer_choices
      )
    })
  })
}
```

## Related Rules and Principles
- R09: UI-Server-Defaults Triple
- R76: Module Data Connection Rule
- R89: Integer ID Type Conversion
- MP17: Separation of Concerns
- MP54: UI-Server Correspondence
- P80: Integer ID Consistency