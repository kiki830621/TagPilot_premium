# MP0039: One-Time Operations During Initialization

## Definition
Operations that need to be performed exactly once should be executed during the initialization phase, never conditionally or reactively. One-time operations belong in static code executed as part of initialization (before user interaction begins).

## Multi-Dimensional Terminology
In application lifecycle management:

- **Phase**: A major time period in the application lifecycle with a distinct purpose and resource allocation
- **Stage**: A process that spends time and resources to accomplish a specific task
- **A phase is a sequence of stages**: Each phase consists of an ordered sequence of stages that consume time and resources in succession

Phases and stages serve multiple roles:
1. **Time Units**: Measuring when operations occur
2. **Resource Units**: Measuring and controlling CPU, memory, GPU, and other computational resources
3. **State Transformers**: Converting one state (data) to another through defined processes

This multi-dimensional view allows for comprehensive reasoning about application behavior and optimization.

## Initialization Phase Breakdown
The initialization phase encompasses several distinct stages that execute in sequence:

1. **System Initialization Stage**: Loading libraries, configuring environment, setting up globals
2. **UI Construction Stage**: Creating all UI elements and components (all possible components)
3. **Data Preparation Stage**: Loading and preparing static data needed at startup
4. **Session Setup Stage**: Establishing initial session state before user interaction

All one-time operations should be performed in the appropriate initialization stage, not deferred to runtime conditional execution.

## Explanation
When code is known to execute exactly once, placing it in conditional logic adds unnecessary complexity and potential for errors. One-time operations should be performed deterministically during the application start phase, creating a stable foundation for the reactive parts of the application.

## Implementation Guidelines

### 1. UI Structure Creation

All UI structure should be created once during the start phase:

```r
# CORRECT: One-time UI creation at start
ui <- fluidPage(
  div(id = "always_visible", ...),
  div(id = "sometimes_visible", style = "display: none;", ...),
  div(id = "conditionally_visible", style = "display: none;", ...)
)

# INCORRECT: Conditional UI creation
ui <- fluidPage(
  div(id = "always_visible", ...),
  conditionalPanel(
    condition = "input.show_panel == true",
    div(id = "sometimes_visible", ...)
  )
)
```

### 2. Configuration Loading

All configuration should be loaded once at start:

```r
# CORRECT: One-time configuration loading at start
app_config <- load_config("config.yaml")

# INCORRECT: Conditional configuration loading
observe({
  if (input$reload_config) {
    app_config(load_config("config.yaml"))
  }
})
```

### 3. Static Component Initialization

Components that don't change should be fully initialized at start:

```r
# CORRECT: One-time component initialization
oneTimeUnionUI(
  main = div(...),
  panel1 = div(...),
  panel2 = div(...)
)

# INCORRECT: Reactive component generation
output$ui_components <- renderUI({
  if (input$show_panel1) {
    tagList(div(...))
  } else {
    tagList(div(...))
  }
})
```

## Benefits

1. **Performance**: One-time operations at start eliminate redundant execution
2. **Predictability**: Deterministic startup sequence is easier to reason about
3. **Reliability**: Reduces potential for runtime errors from conditional logic
4. **State Preservation**: Components exist throughout app lifecycle, preserving state
5. **Simplicity**: Clear separation between static and dynamic aspects of the app

## Runtime Visibility Control

For elements created at start that need conditional visibility:

```r
# Create all UI elements at start (one-time)
ui <- fluidPage(
  div(id = "panel1", ...),
  div(id = "panel2", style = "display: none;", ...)
)

# Control visibility at runtime (many-time)
server <- function(input, output, session) {
  observe({
    if (input$show_panel2) {
      shinyjs::show("panel2")
    } else {
      shinyjs::hide("panel2")
    }
  })
}
```

## Anti-Patterns

### 1. Conditional Component Creation

Avoid:
```r
# Bad: Creating components conditionally
observe({
  if (input$create_component) {
    output$component <- renderUI({
      div(...)
    })
  }
})
```

### 2. Runtime Dynamic Loading

Avoid:
```r
# Bad: Loading resources conditionally at runtime
observeEvent(input$load_module, {
  source("module.R")
  callModule(...)
})
```

### 3. Recreating One-Time Elements

Avoid:
```r
# Bad: Recreating elements that should be created once
output$static_text <- renderUI({
  div("This never changes but is recreated every time")
})
```

## Application to Component Naming

Use the "oneTime" prefix for components that follow this pattern:

```r
# Clearly communicates execution pattern
oneTimeUnionUI <- function(...) {
  # Create UI structure once at start
}

oneTimeInitializer <- function() {
  # Perform initialization once at start
}
```

## Related Principles

- P22: CSS Controls Over Shiny Conditionals
- MP0038: Incremental Single-Feature Release
- MP0037: Comment Only for Temporary or Uncertain Code
