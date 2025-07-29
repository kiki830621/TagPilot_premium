# P0022: CSS Controls Over Shiny Conditionals

## Definition
Use CSS-based visibility control for UI elements when it offers better performance than Shiny's conditional constructs (such as `conditionalPanel` or `renderUI`), especially for frequently toggled elements, complex widgets, or elements that need to preserve state when hidden. This principle implements MP0039 (One-Time Operations At Start) by creating all UI elements once at start time and controlling visibility through CSS rather than conditional rendering.

## Explanation
While Shiny provides built-in conditional rendering functions, these constructs often rebuild DOM elements from scratch when conditions change. For many UI interactions, particularly those involving visibility toggling without state changes, direct CSS manipulation offers significant performance advantages.

## Implementation Guidelines

### 1. When to Use CSS Controls

Use CSS-based visibility (with `shinyjs` or direct styles) when:

```r
# PREFERRED: CSS visibility for state-preserving toggles
div(
  id = ns("filter_panel"),
  class = "sidebar-filters",
  style = "padding: 10px 15px; display: none;",  # Initially hidden with CSS
  
  # Content that should maintain state when hidden
  selectInput(ns("region"), "Region", choices = regions)
)

# In server:
observeEvent(input$tab, {
  if(input$tab == "analysis") {
    shinyjs::show("filter_panel")  # Simple CSS toggle
  } else {
    shinyjs::hide("filter_panel")  # No state is lost
  }
})
```

### 2. When to Use Shiny Conditionals

Use Shiny's conditional constructs when:

```r
# PREFERRED: Conditional panels for content that depends on complex logic
conditionalPanel(
  condition = "input.data_source == 'api' && input.load_status == 'complete'",
  ns = ns,
  
  # Content that should only exist in DOM when conditions are met
  downloadButton(ns("export"), "Export API Data")
)
```

## Choosing Between Approaches

| Factor | CSS Controls | Shiny Conditionals |
|--------|-------------|-------------------|
| Performance | ✅ Faster for frequent toggles | ❌ Slower due to DOM rebuilding |
| State Preservation | ✅ Maintains input values | ❌ Resets values when rebuilt |
| Memory Usage | ✅ Lower (elements always exist) | ❌ Higher (rebuilds elements) |
| Reactivity | ❌ Manual implementation needed | ✅ Automatic dependency tracking |
| Complex Conditions | ❌ Requires custom JS/server logic | ✅ Simple declarative conditions |
| User Experience | ✅ Smoother transitions | ❌ Potential flicker during rebuilds |

## Best Practices

1. **Measure Impact**: Test performance before committing to either approach for complex UIs

2. **Mixed Approach**: Use CSS for high-frequency toggles and Shiny conditionals for infrequent complex logic:

```r
# Good: Mixed approach
# Outer container uses conditionalPanel for infrequent existence change
conditionalPanel(
  condition = "input.module == 'analysis'",
  ns = ns,
  
  # Inner tabs use CSS for frequent visibility toggling
  div(
    id = ns("subtab1"),
    style = "display: block;",
    # Tab 1 content
  ),
  div(
    id = ns("subtab2"),
    style = "display: none;", 
    # Tab 2 content - hidden but state preserved
  )
)
```

3. **Documentation**: Comment your choice to clarify intent:

```r
# Using CSS visibility for performance reasons
# This preserves filter states when switching tabs
div(id = ns("filters"), style = "display: none;", ...)
```

## Anti-Patterns

### 1. CSS for Everything

Avoid:
```r
# Bad: Using CSS for genuinely conditional content
div(
  id = "api_panel",
  style = "display: none;",  # Initially hidden
  # API-specific controls that make no sense for other data sources
)

# Requires complex server-side management
observe({
  if (input$data_source == "api" && 
      input$authenticated == TRUE && 
      !is.null(credentials$permissions$api_access)) {
    shinyjs::show("api_panel")
  } else {
    shinyjs::hide("api_panel")
  }
})
```

### 2. Conditionals for Everything

Avoid:
```r
# Bad: Using conditionalPanel for simple tab toggles
conditionalPanel(
  condition = "input.currentTab == 'tab1'",
  ns = ns,
  # Tab 1 content with inputs that lose state when tab changes
)
```

## Related Principles

- MP0016: Modularity 
- MP0017: Separation of Concerns
- P0020: Sidebar Filtering Only
- R0011: Hybrid Sidebar Pattern
