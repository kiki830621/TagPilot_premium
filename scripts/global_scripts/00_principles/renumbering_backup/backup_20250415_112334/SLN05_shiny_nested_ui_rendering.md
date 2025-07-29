# SLN05: Avoiding Nested UI Rendering in Shiny

## Issue

Conditional UI elements in Shiny applications sometimes fail to appear when needed, particularly when using nested `renderUI` and `uiOutput` calls. This leads to missing filters, controls, or UI components that only appear after multiple refreshes.

## Root Cause

The root cause is a multi-level dependency chain in reactive UI rendering:
1. Nested `renderUI`/`uiOutput` pairs create sequential dependencies
2. Each level must wait for the previous level to complete rendering
3. This can lead to delayed initialization, race conditions, or complete failure to render
4. The Shiny reactive system may not properly resolve these dependencies during tab switching

## Common Scenarios

This issue frequently occurs in these scenarios:

1. **Conditional Sidebar Filters**: Filters that should appear when a specific tab is selected
   ```r
   # Problematic pattern
   output$filter_ui <- renderUI({ filter_component })
   output$sidebar_content <- renderUI({
     if(input$tab == "analysis") { uiOutput("filter_ui") }
   })
   ```

2. **Dynamic Tab Content**: UI elements that should update based on tab selection
   ```r
   # Problematic pattern
   output$tab_content <- renderUI({ specific_content })
   output$main_ui <- renderUI({
     tabsetPanel(
       tabPanel("Tab1", uiOutput("tab_content"))
     )
   })
   ```

3. **Component Architecture**: When using a component pattern that passes UI elements between components
   ```r
   # Problematic pattern
   component <- createComponent(...)
   output$component_ui <- renderUI({ component$ui })
   output$container <- renderUI({ uiOutput("component_ui") })
   ```

## Solution Patterns

### 1. Direct UI Element Inclusion

Replace nested `renderUI`/`uiOutput` with direct inclusion of UI objects:

```r
# Good pattern
component <- createComponent(...)
output$container <- renderUI({
  if(condition) {
    div(
      h3("Title"),
      component$ui  # Direct inclusion of UI object
    )
  }
})
```

### 2. Pre-render Static UI Elements

Separate static and dynamic parts of UI:

```r
# Good pattern
# Static UI defined outside reactive context
static_header <- div(h3("Analysis Results"), hr())

output$results <- renderUI({
  # Only dynamically render what changes
  tagList(
    static_header,
    plotOutput("dynamic_plot")
  )
})
```

### 3. Use Visibility Instead of Conditional Rendering

For UI that toggles visibility:

```r
# Good pattern
ui <- fluidPage(
  actionButton("show", "Show/Hide"),
  div(id = "content", style = "display: none",
    selectInput("choice", "Make a choice:", choices = c("A", "B"))
  )
)

server <- function(input, output, session) {
  observeEvent(input$show, {
    shinyjs::toggle("content")
  })
}
```

## Best Practices

1. **Single Rendering Layer**: Use at most one level of `renderUI` for any UI element
2. **Component Structure**: Component functions should return complete UI objects, not output IDs
3. **UI Stability**: Keep UI structure stable and use conditional visibility instead of rebuilding
4. **Minimal Dependencies**: Reduce reactive dependencies in UI rendering
5. **Isolation**: Use `isolate()` when accessing reactive values that shouldn't trigger UI rebuilds

## Anti-Patterns

1. ❌ **Deeply Nested renderUI Chains**:
   ```r
   # AVOID THIS
   output$level1 <- renderUI({ ... })
   output$level2 <- renderUI({ uiOutput("level1") })
   output$level3 <- renderUI({ uiOutput("level2") })
   ```

2. ❌ **Rendering Wrappers for Static UI**:
   ```r
   # AVOID THIS
   output$static_header <- renderUI({ div(h3("Fixed Title")) })
   ```

3. ❌ **Unnecessary Reactivity in UI Structure**:
   ```r
   # AVOID THIS
   output$ui <- renderUI({
     input$unrelated_value  # Creating dependency on unrelated input
     div(...)
   })
   ```

## Connection to Principles

- **R102 (Shiny Reactive Observation Rule)**: Minimize unnecessary reactive dependencies
- **MP52 (Unidirectional Data Flow)**: Maintain clear flow of data in UI rendering
- **P77 (Performance Optimization)**: Reduce rendering overhead
- **P104 (Consistent Component State)**: Ensure UI components maintain consistent state
- **R88 (Shiny Module ID Handling)**: Proper namespacing in modular UI components

## Example Application

### Before (Problematic):

```r
# Customer DNA Application with nested UI issue
customer_component <- microCustomerComponent(...)

# Create filter UI in one renderUI
output$customer_filter_ui <- renderUI({
  customer_component$ui$filter
})

# Create conditional container in another renderUI
output$conditionalCustomerFilter <- renderUI({
  if (!is.null(input$sidebar_menu) && input$sidebar_menu == "customer") {
    div(
      class = "sidebar-filter-container p-3 mt-4",
      h5("Customer Filter", class = "text-bold mb-3"),
      uiOutput("customer_filter_ui")  # Nested reference - filters don't appear
    )
  } else {
    NULL
  }
})
```

### After (Fixed):

```r
# Customer DNA Application with direct UI reference
customer_component <- microCustomerComponent(...)

# Single renderUI with direct inclusion of component UI
output$conditionalCustomerFilter <- renderUI({
  if (!is.null(input$sidebar_menu) && input$sidebar_menu == "customer") {
    div(
      class = "sidebar-filter-container p-3 mt-4",
      h5("Customer Filter", class = "text-bold mb-3"),
      customer_component$ui$filter  # Direct inclusion - filters appear correctly
    )
  } else {
    NULL
  }
})
```

This solution ensures the customer filter appears immediately when the customer tab is selected, without requiring additional refreshes or clicks.