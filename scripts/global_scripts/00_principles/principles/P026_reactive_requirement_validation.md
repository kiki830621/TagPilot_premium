# P0026: Reactive Requirement Validation

## Context
In reactive programming, especially in Shiny applications, computations often depend on values that may not be immediately available or that may become invalid during the application lifecycle. Without proper validation, reactive chains can execute with incomplete or invalid inputs, leading to errors, unexpected UI behaviors, or invalid computations.

## Principle
**All reactive computations must explicitly validate their required inputs using appropriate validation mechanisms (like req() in Shiny) before proceeding, with clear error handling strategies for missing or invalid values.**

## Rationale
1. **Execution Control**: Properly halts reactive execution when prerequisites aren't satisfied.

2. **Error Prevention**: Stops errors from propagating through the reactive graph.

3. **Stability**: Prevents UI components from entering invalid states.

4. **Predictability**: Makes reactive behavior more deterministic and predictable.

5. **User Experience**: Allows for graceful handling of temporary undefined states.

## Implementation
Reactive requirement validation should be implemented through:

1. **Input Validation**:
   ```r
   observe({
     # Validate that required inputs exist
     req(input$selection, input$data)
     
     # Continue with computation using validated inputs
     ...
   })
   ```

2. **Conditional Output**:
   ```r
   output$plot <- renderPlot({
     # Only proceed if we have data and settings
     req(data(), !is.null(input$plot_type))
     
     # Create plot with validated inputs
     ...
   })
   ```

3. **State Preservation**:
   ```r
   # Keep previous valid output when inputs are temporarily invalid
   output$summary <- renderText({
     req(dataset(), cancelOutput = TRUE)
     paste("Dataset has", nrow(dataset()), "rows")
   })
   ```

4. **Progressive Requirements**:
   ```r
   # Chain requirements to provide contextual validation
   output$details <- renderUI({
     req(input$category)
     options <- getOptionsForCategory(input$category)
     req(length(options) > 0)
     selectInput("option", "Select option", options)
   })
   ```

5. **Custom Validation Functions**:
   ```r
   is_valid_input <- function(x) {
     # Return TRUE if input is valid, FALSE otherwise
     !is.null(x) && length(x) > 0 && x != ""
   }
   
   observe({
     req(is_valid_input(input$value))
     # Proceed with valid input
   })
   ```

## Examples

### Example 1: Basic Input Validation
```r
# Wait for both x and y inputs to be available
output$scatterplot <- renderPlot({
  req(input$x_var, input$y_var)
  plot(data()[, input$x_var], data()[, input$y_var],
       xlab = input$x_var, ylab = input$y_var)
})
```

### Example 2: Conditional Validation with Custom Logic
```r
# More complex validation logic
output$analysis <- renderPrint({
  req(input$analysis_type)
  
  if (input$analysis_type == "correlation") {
    req(input$cor_vars, length(input$cor_vars) >= 2)
    # Correlation analysis needs at least 2 variables
    cor(data()[, input$cor_vars])
  } else if (input$analysis_type == "regression") {
    req(input$dep_var, input$indep_vars, length(input$indep_vars) >= 1)
    # Regression needs dependent and independent variables
    formula_str <- paste(input$dep_var, "~", paste(input$indep_vars, collapse = " + "))
    lm(formula_str, data = data())
  }
})
```

### Example 3: Preserving Previous Output
```r
# Keep showing data table even when filter is temporarily invalid
output$filtered_table <- renderTable({
  # cancelOutput=TRUE keeps previous table visible during invalid filter state
  req(input$filter_value, cancelOutput = TRUE)
  
  filtered_data <- data()[data()$value > input$filter_value, ]
  req(nrow(filtered_data) > 0, cancelOutput = TRUE)
  
  filtered_data
})
```

## Related Principles
- SLN01: Handling Non-Logical Data Types in Logical Contexts
- MP0041: Type-Dependent Operations
- P0024: Reactive Value Access Safety

## Application
This principle should be applied:
- At the beginning of all reactive expressions and observers
- Before attempting to access potentially undefined reactive values
- When rendering UI components that depend on dynamic data
- In any situation where computations depend on user input or other dynamic data sources

By implementing thorough reactive requirement validation, applications become more robust, with fewer unexpected errors and a better user experience through predictable behavior and appropriate handling of missing or invalid inputs.
