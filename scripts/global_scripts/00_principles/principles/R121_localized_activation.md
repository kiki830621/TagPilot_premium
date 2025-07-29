# R121: Localized Activation

## Rule Statement
Components should implement conditional execution logic internally to perform expensive operations only when the component is contextually active or needed, improving overall application performance through selective computation.

## Rationale
In complex Shiny applications with multiple components, many expensive operations (database queries, AI API calls, complex calculations) may execute unnecessarily when users are not actively viewing the related content. Localized activation allows components to be "smart" about when to perform resource-intensive tasks.

## Implementation Pattern

### 1. Add Activation Parameter to Component Server
```r
componentServer <- function(id, data_connection = NULL, config = NULL,
                           session = getDefaultReactiveDomain(),
                           active_tab = NULL) {  # Add activation parameter
  moduleServer(id, function(input, output, session) {
    
    # Create activation checker
    is_component_active <- reactive({
      if (is.null(active_tab)) return(TRUE)  # Always active if no tab specified
      
      current_tab <- if (is.reactive(active_tab)) active_tab() else active_tab
      # Define when this component should be active
      identical(current_tab, "target_tab_name")
    })
    
    # Conditional expensive operations
    expensive_result <- reactive({
      # Only perform expensive operation when component is active
      if (!is_component_active()) {
        return(NULL)
      }
      
      # Expensive computation here
      perform_expensive_operation()
    })
  })
}
```

### 2. Pass Activation State from Parent
```r
# In union or parent component
component_res <- componentServer(
  id = "component_id",
  data_connection = app_connection,
  config = config,
  session = session,
  active_tab = reactive(input$sidebar_menu)  # Pass current tab state
)
```

### 3. Apply to Multiple Expensive Operations
```r
# Apply activation check to all expensive operations
observe({
  # Only perform background AI analysis when component is active
  if (!is_component_active()) {
    return()
  }
  
  # Expensive AI/API operations here
  perform_ai_analysis()
})

csa_analysis <- reactive({
  # Only perform MDS/clustering when component is active
  if (!is_component_active()) {
    return(NULL)
  }
  
  # Complex mathematical operations here
  perform_mds_clustering()
})
```

## Performance Benefits

### Memory Efficiency
- Prevents unnecessary data processing in background
- Reduces memory footprint of inactive components
- Allows garbage collection of unused intermediate results

### CPU Optimization
- Eliminates redundant calculations
- Reduces server load during navigation
- Improves application responsiveness

### Network Efficiency
- Prevents unnecessary API calls (GPT, external services)
- Reduces database query load
- Minimizes data transfer for inactive content

### User Experience
- Faster initial page loads
- Smoother tab navigation
- Better resource allocation for active content

## When to Apply

### High-Cost Operations
- Machine learning computations (MDS, clustering, PCA)
- External API calls (OpenAI GPT, web services)
- Large dataset processing
- Complex statistical analyses

### Background Processing
- Automatic AI naming/labeling
- Data aggregation and summarization
- Report generation
- Visualization preprocessing

### Resource-Intensive Components
- Market segmentation analysis
- Real-time data updates
- Large dataset visualizations
- Complex interactive plots

## Example Implementation

### positionMSPlotly Component
```r
# Before R121: Always executes expensive MDS analysis
csa_result <- reactive({
  perform_csa_analysis(data(), exclude_vars, na_threshold, use_modification)
})

# After R121: Only executes when tab is active
csa_result <- reactive({
  if (!is_component_active()) {
    return(NULL)
  }
  perform_csa_analysis(data(), exclude_vars, na_threshold, use_modification)
})
```

### AI Background Processing
```r
# Before R121: Always runs GPT analysis
observe({
  cluster_names <- generate_cluster_names(analysis(), gpt_key)
})

# After R121: Only runs when component is active
observe({
  if (!is_component_active()) {
    return()
  }
  cluster_names <- generate_cluster_names(analysis(), gpt_key)
})
```

## Design Considerations

### Backward Compatibility
- Components should work normally when `active_tab` is NULL
- Default behavior should be "always active" for safety
- No breaking changes to existing component interfaces

### State Preservation
- Once computed, results should be cached until data changes
- Activation state should not affect previously computed results
- Component should remember its state across activation cycles

### Granular Control
- Different operations within a component may have different activation conditions
- Some operations might be essential and always execute
- Others might be purely optional and heavily conditional

## Anti-Patterns

### Over-Optimization
```r
# Don't apply to lightweight operations
if (!is_component_active()) return(NULL)  # For simple data transformations
simple_filter <- data %>% filter(column == value)  # This is fine to always run
```

### Breaking Essential Functionality
```r
# Don't conditionally execute core reactive dependencies
essential_data <- reactive({
  if (!is_component_active()) return(NULL)  # BAD: Breaks dependent components
  get_core_data()
})
```

### Complex Activation Logic
```r
# Keep activation logic simple and clear
is_active <- reactive({
  # BAD: Complex multi-condition logic
  (input$tab == "target" && input$subtab == "detail" && 
   input$advanced_mode && weekdays(Sys.Date()) %in% c("Monday", "Tuesday"))
})
```

## Related Principles
- **MP47**: Functional Programming - Pure functions facilitate activation logic
- **MP55**: Computation Allocation - Determines where expensive operations should occur
- **P077**: Performance Optimization - General performance improvement strategies
- **R116**: Enhanced Data Access with tbl2 - Efficient data access patterns

## Keywords
localized activation, conditional execution, performance optimization, resource management, expensive operations, component activation, tab-based execution, smart components

## Version History
- **2025-01-15**: Initial creation (R121)
- **Application**: positionMSPlotly conditional MDS analysis and AI processing