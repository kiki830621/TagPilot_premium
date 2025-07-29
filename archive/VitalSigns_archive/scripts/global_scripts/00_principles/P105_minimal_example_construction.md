# P105: Minimal Example Construction Principle

## Core Principle

Development should begin with the construction of a minimal working example that demonstrates core functionality before expanding to full feature implementation. This approach enables faster validation of concepts, easier debugging, and clearer communication of design patterns.

## Implementation Requirements

1. **Start With Core Functionality**:
   - Begin by implementing the simplest version that demonstrates the primary purpose
   - Include only essential components, props, and state management
   - Focus on the critical path that demonstrates the main functionality
   - Omit error handling, edge cases, and optional features initially

2. **Incremental Expansion**:
   - Gradually add features only after the minimal example works correctly
   - Test each addition before moving to the next feature
   - Document each step of expansion to preserve the development path
   - Maintain working versions at each significant milestone

3. **Isolating Components**:
   - Create self-contained examples for each major component
   - Minimize dependencies between components during initial development
   - Use placeholder data/functions before implementing complex integrations
   - Keep external dependencies to a minimum in early versions

4. **Documentation Through Example**:
   - Include minimal examples in component documentation
   - Use the simplest possible syntax to illustrate usage patterns
   - Demonstrate both basic and advanced use cases with minimal examples
   - Show the evolution from simple to complex implementations

## Benefits

1. **Development Efficiency**:
   - Quicker iteration cycles during early development
   - Easier to identify and fix issues in simpler implementations
   - Provides clear milestones for incremental testing
   - Reduces wasted effort by validating concepts early

2. **Knowledge Transfer**:
   - Minimal examples are easier to explain to team members
   - New developers can understand core functionality faster
   - Usage patterns become self-evident through simple demonstrations
   - Creates usable reference implementations for future development

3. **Maintainability**:
   - Simpler initial implementations create cleaner foundation code
   - Easier to refactor when core functionality is well-defined
   - Better separation of concerns from the beginning
   - More modular architecture emerges naturally

4. **Debugging Advantages**:
   - Simplified test cases make issues more visible
   - Easier to isolate causes in minimal implementations
   - Provides clear regression tests for complex features
   - Supports rapid problem reproduction

## Implementation Examples

### Minimal UI Component Example

```r
# Minimal tabbed interface example
if (interactive()) {
  library(shiny)
  library(bs4Dash)
  
  ui <- fluidPage(
    # Only essential UI elements
    actionButton("tab1_btn", "Tab 1", class = "btn-primary"),
    actionButton("tab2_btn", "Tab 2"),
    
    # Single content area with conditional display
    div(
      id = "content_area",
      div(id = "tab1_content", "Tab 1 Content"),
      div(id = "tab2_content", style = "display: none;", "Tab 2 Content")
    )
  )
  
  server <- function(input, output, session) {
    # Minimal state management
    observeEvent(input$tab1_btn, {
      # Simple DOM manipulation
      shinyjs::addClass(id = "tab1_btn", class = "btn-primary")
      shinyjs::removeClass(id = "tab2_btn", class = "btn-primary")
      shinyjs::show("tab1_content")
      shinyjs::hide("tab2_content")
    })
    
    observeEvent(input$tab2_btn, {
      # Simple DOM manipulation
      shinyjs::removeClass(id = "tab1_btn", class = "btn-primary")
      shinyjs::addClass(id = "tab2_btn", class = "btn-primary")
      shinyjs::hide("tab1_content")
      shinyjs::show("tab2_content")
    })
  }
  
  shinyApp(ui, server)
}
```

### Incremental Component Expansion

```r
# Step 1: Minimal implementation with core functionality
create_minimal_component <- function(id) {
  # Only essential reactive values
  value <- reactiveVal(0)
  
  # Minimal UI with just the basics
  ui <- function() {
    div(
      actionButton(NS(id, "increment"), "Increment"),
      textOutput(NS(id, "value"))
    )
  }
  
  # Minimal server logic
  server <- function(input, output, session) {
    observeEvent(input$increment, {
      value(value() + 1)
    })
    
    output$value <- renderText({
      paste("Current value:", value())
    })
  }
  
  return(list(ui = ui, server = server))
}

# Step 2: Add additional features once minimal version works
create_expanded_component <- function(id) {
  # Start with the minimal component
  minimal <- create_minimal_component(id)
  
  # Keep the original UI but extend it
  ui <- function() {
    tagList(
      minimal$ui(),
      # Add new UI elements
      actionButton(NS(id, "decrement"), "Decrement"),
      actionButton(NS(id, "reset"), "Reset")
    )
  }
  
  # Extend the server logic
  server <- function(input, output, session) {
    # Call the minimal server first
    minimal$server(input, output, session)
    
    # Add new event handlers
    observeEvent(input$decrement, {
      value(value() - 1)
    })
    
    observeEvent(input$reset, {
      value(0)
    })
  }
  
  return(list(ui = ui, server = server))
}
```

### Isolating Components With Minimal Dependencies

```r
# Minimal data input component
create_data_entry <- function(id) {
  ui <- function() {
    div(
      textInput(NS(id, "name"), "Name"),
      numericInput(NS(id, "age"), "Age", value = 30),
      actionButton(NS(id, "submit"), "Submit")
    )
  }
  
  server <- function(input, output, session) {
    # Return reactive values rather than modifying global state
    return(list(
      data = reactive({
        list(
          name = input$name,
          age = input$age,
          submitted = input$submit > 0
        )
      })
    ))
  }
  
  return(list(ui = ui, server = server))
}

# Minimal data display component with dummy data option
create_data_display <- function(id) {
  ui <- function() {
    div(
      h4("User Information"),
      tableOutput(NS(id, "user_table"))
    )
  }
  
  server <- function(input, output, session, data_source = NULL) {
    # Use dummy data if no source provided (for isolated testing)
    actual_data <- reactive({
      if (is.null(data_source)) {
        # Dummy data for isolated testing
        return(data.frame(
          Name = "Test User",
          Age = 30,
          stringsAsFactors = FALSE
        ))
      } else {
        # Convert actual data source when available
        data <- data_source()
        return(data.frame(
          Name = data$name,
          Age = data$age,
          stringsAsFactors = FALSE
        ))
      }
    })
    
    output$user_table <- renderTable({
      actual_data()
    })
  }
  
  return(list(ui = ui, server = server))
}
```

## Relationship to Other Principles

- **Implements**: MP17: Modularity Principle, MP31: Initialization First
- **Builds Upon**: P77: Performance Optimization Principle, P101: Minimal CSS Usage Principle
- **Related To**: P102: Defensive Error Handling Principle, P104: Consistent Component State Principle, R09: UI-Server-Defaults Triple Rule

## Conclusion

The Minimal Example Construction Principle promotes a disciplined approach to software development that begins with the simplest possible implementation before expanding to more complex features. By starting with minimal examples, developers can validate core concepts quickly, establish clear patterns, and build a solid foundation for expansion. This approach leads to more maintainable code, better documentation, and more efficient development processes, while making it easier to test, debug, and communicate design patterns throughout the project lifecycle.