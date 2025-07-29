# Shiny Reactive Observation Rule

## Core Rule

In Shiny applications, only explicitly observed reactive expressions will trigger execution of dependent code, and only rendered outputs will update the UI. All critical reactive logic must have explicit observers to ensure proper execution, especially in modular applications.

## Rationale

Shiny's reactive programming model depends on establishing clear dependency chains. When these chains are broken or incomplete, components can appear to work but fail to respond to user input or data changes.

## Implementation Guidelines

1. **Explicit Observation Required**: All critical reactive expressions that don't directly connect to an output must be explicitly observed using `observe()` or `observeEvent()`.

2. **Module Server Execution**: When using Shiny modules, ensure module server functions are explicitly triggered rather than merely defined.

3. **UI-Independent Logic**: Any server-side logic that should execute regardless of UI visibility must be explicitly observed.

4. **Debugging Pattern**: If a component works when debugging outputs are displayed but fails when they are hidden, this indicates a broken reactive chain.

5. **Complete Reactive Chains**: Verify that all reactive expressions are part of complete chains that ultimately connect to UI outputs or explicit observers.

## Examples

### Problematic Pattern (Broken Chain)

```r
# Definition of reactive expression
filtered_data <- reactive({
  # Code to filter data based on input
  # ...
})

# UI output that shows debug information
output$debug_output <- renderPrint({
  # This output happens to depend on filtered_data()
  # and is the only thing triggering it to execute
  str(filtered_data())
})

# Filter UI shows up but doesn't work when debug output is hidden
```

### Corrected Pattern (Complete Chain)

```r
# Definition of reactive expression
filtered_data <- reactive({
  # Code to filter data based on input
  # ...
})

# Explicit observer ensures filtered_data runs regardless of UI visibility
observe({
  # Force filtered_data to execute
  filtered_data()
})

# Debug output doesn't affect whether filtered_data runs
output$debug_output <- renderPrint({
  str(filtered_data())
})

# Filter will now work regardless of debug output visibility
```

## Module Pattern Best Practice

When creating Shiny modules, ensure server logic is always executed:

```r
# Module creation
myModule <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Module logic
  })
}

# In main app - WRONG: This creates the server function but doesn't execute it!
server <- function(input, output, session) {
  my_module_server <- myModule("module1")  # Nothing observes this
}

# In main app - CORRECT: This ensures the module server runs
server <- function(input, output, session) {
  # Call the module directly
  myModule("module1")
  
  # Or if you need to capture its return value
  my_module_data <- myModule("module1")
  
  # Ensure any reactive expressions are observed
  observe({
    my_module_data()
  })
}
```

## Edge Case: Conditional UI

When using conditional UI, be especially careful to ensure server logic is executed regardless of UI visibility:

```r
# Conditional UI with server logic that must always run
conditionalPanel(
  condition = "input.show_panel == true",
  div(id = "conditional_content", ...)
)

# Server logic must be observed regardless of panel visibility
observe({
  # Logic that operates on the conditional panel's inputs
  # This runs even when panel is hidden
})
```

## Related Principles

- MP52 Unidirectional Data Flow
- MP53 Feedback Loop
- MP54 UI-Server Correspondence
- R88 Shiny Module ID Handling