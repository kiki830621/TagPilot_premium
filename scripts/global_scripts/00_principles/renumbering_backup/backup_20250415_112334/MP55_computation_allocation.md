---
id: "MP55"
title: "Computation Allocation Principle"
type: "meta-principle"
date_created: "2025-04-10"
date_modified: "2025-04-10"
author: "Development Team"
extends:
  - "MP17": "Separation of Concerns"
  - "MP30": "Vectorization Principle"
  - "MP47": "Functional Programming"
requires:
  - "P77": "Performance Optimization"
key_terms:
  - computation allocation
  - performance optimization
  - resource management
  - lazy computation
  - pre-computation
---

# MP55: Computation Allocation Principle

## Core Statement

Application computation must be strategically allocated across different phases of execution (initialization, idle time, user-triggered, and real-time) based on computational intensity, frequency of use, and criticality to user experience.

## Rationale

Reactive applications must balance computational resources to ensure optimal user experience while managing system resources effectively. Strategic allocation of computation ensures:

1. **Application Responsiveness**: Critical user interactions remain fast and fluid
2. **Resource Efficiency**: Computational resources are used when they are most available
3. **Scalability**: Applications can handle increasing data volumes without proportional performance degradation
4. **User Experience**: Perceptual latency is minimized for key interactions

## Implementation Framework

### 1. Computation Classification

All computations in the application should be classified by:

#### A. Computational Intensity
- **Light**: Completes in < 100ms on reference hardware
- **Medium**: Completes in 100ms-1s on reference hardware
- **Heavy**: Completes in > 1s on reference hardware

#### B. Usage Frequency
- **Once**: Computed once during application lifecycle
- **Occasional**: Computed infrequently (e.g., daily or per session)
- **Frequent**: Computed regularly during normal application use

#### C. Result Stability
- **Static**: Results don't change during application session
- **Semi-static**: Results change infrequently
- **Dynamic**: Results change frequently based on user actions or data updates

#### D. Criticality
- **Core**: Essential for basic application functionality
- **Feature**: Important for specific features
- **Enhancement**: Provides added value but not essential

### 2. Allocation Strategies

Based on the classification, allocate computation to one of these strategies:

#### A. Pre-computation
For calculations that are **heavy** + **static**/**semi-static** + **frequent**:
- Calculate during initialization or data loading
- Store results for immediate access
- Update on data refresh cycles, not during user interaction

#### B. Lazy Computation
For calculations that are **medium**/**heavy** + **semi-static** + **occasional**:
- Calculate only when first needed
- Store results for subsequent access
- Invalidate cache when inputs change significantly

#### C. Cached Computation
For calculations that are **medium** + **dynamic** + **frequent**:
- Calculate when inputs change
- Cache results until inputs change again
- Implement efficient cache invalidation

#### D. Throttled Computation
For calculations that are **light**/**medium** + **dynamic** + **frequent**:
- Calculate on-demand but limit frequency (debouncing)
- Prioritize responsiveness over real-time updates
- Consider visual feedback for in-progress calculations

#### E. Background Computation
For calculations that are **heavy** + **dynamic** + **occasional**:
- Offload to background processes
- Update UI progressively as results arrive
- Provide interim feedback during processing

#### F. On-demand Computation
For calculations that are **light** + **dynamic** + **frequent**:
- Calculate in real-time when needed
- Optimize for maximum performance
- Use vectorized operations where possible

### 3. System Architecture Implications

#### A. Computation Location
- **Client-side**: For personalized, UI-dependent calculations
- **Server-side**: For shared, data-intensive, or secure calculations
- **Database**: For data-oriented aggregations and filtering

#### B. Data Transfer Optimization
- Transfer only processed results, not raw data
- Use progressive data loading for large datasets
- Compress data appropriately for transfer

#### C. Hardware Resource Management
- Manage memory consumption for large datasets
- Utilize parallel processing for independent calculations
- Consider CPU/GPU optimization for intensive operations

## Implementation Patterns

### 1. Pre-computed Distributions Pattern

```r
# During initialization phase
initialize_distributions <- function(data_source) {
  # Calculate distributions of key metrics
  distributions <- list(
    metric_a = calculate_distribution(data_source$metric_a),
    metric_b = calculate_distribution(data_source$metric_b)
  )
  
  # Return as a reactive value for app use
  reactiveVal(distributions)
}

# In component server function
server <- function(input, output, session) {
  output$distribution_plot <- renderPlot({
    # Use pre-computed distribution
    dist_data <- distributions()[[input$selected_metric]]
    
    # Create visualization using pre-computed data
    ggplot(dist_data, aes(x = value, y = cumulative)) +
      geom_line()
  })
}
```

### 2. Cached Reactive Pattern

```r
# In component server function
server <- function(input, output, session) {
  # Define cached calculation with reactive dependencies
  filtered_data <- reactive({
    # Only recalculate when inputs change
    req(input$filter_a, input$filter_b)
    
    # Check if cache is valid
    cache_key <- paste(input$filter_a, input$filter_b, sep = "|")
    if (cache_key %in% names(results_cache)) {
      return(results_cache[[cache_key]])
    }
    
    # Perform calculation if not cached
    result <- heavy_calculation(data, input$filter_a, input$filter_b)
    
    # Update cache
    results_cache[[cache_key]] <<- result
    return(result)
  })
}
```

### 3. Background Processing Pattern

```r
# In component server function
server <- function(input, output, session) {
  # Track calculation status
  calculation_status <- reactiveVal("idle")
  
  # Trigger heavy calculation in background
  observeEvent(input$run_analysis, {
    calculation_status("running")
    
    # Launch background job
    future_promise({
      # Run intensive calculation
      result <- run_complex_analysis(data, input$parameters)
      return(result)
    }) %...>% 
      (function(result) {
        # Update UI when calculation completes
        calculation_results(result)
        calculation_status("complete")
      }) %...!% 
      (function(error) {
        # Handle errors
        calculation_status("error")
        log_error(error)
      })
  })
  
  # Show appropriate UI based on status
  output$results <- renderUI({
    status <- calculation_status()
    if (status == "idle") {
      return(div("Click 'Run Analysis' to begin"))
    } else if (status == "running") {
      return(div("Analysis in progress...", spinner()))
    } else if (status == "complete") {
      return(plot_results(calculation_results()))
    } else {
      return(div("Error running analysis", class = "error"))
    }
  })
}
```

### 4. Progressive Loading Pattern

```r
# In component server function
server <- function(input, output, session) {
  # Initial state uses sample
  current_data <- reactiveVal(sample_data(full_data, n = 1000))
  
  # Start with fast approximate analysis
  output$visualization <- renderPlot({
    # Always shows something immediately
    create_visualization(current_data())
  })
  
  # Then process full dataset in background
  observe({
    # Only run when component is initialized
    invalidateLater(100)
    
    # Don't block UI thread
    future_promise({
      process_full_dataset(full_data)
    }) %...>% 
      (function(result) {
        # Update with full results when available
        current_data(result)
      })
  })
}
```

## Application Across Environment Types

### 1. Development Environment
- Focus on flexibility and debuggability
- Accept some performance trade-offs for development speed
- Implement computation allocation as simulated behaviors

### 2. Testing Environment
- Match production computation allocation
- Add instrumentation to verify performance characteristics
- Test with realistic data volumes

### 3. Production Environment
- Apply all optimization strategies
- Monitor computation times and resource usage
- Scale allocation strategies based on actual usage patterns

## Relationship to Other Principles

This meta-principle builds upon:

- **MP17 (Separation of Concerns)**: By separating computation timing from logic implementation
- **MP30 (Vectorization Principle)**: By optimizing internal calculations for performance
- **MP47 (Functional Programming)**: By encouraging pure functions for better caching and memoization

And requires implementation of:

- **P77 (Performance Optimization)**: For creating efficient computations regardless of allocation

## Benefits

1. **Smoother User Experience**: Applications feel more responsive even with complex computations
2. **Better Resource Utilization**: Computations happen when resources are available
3. **Improved Scalability**: Applications can handle larger datasets without proportional slowdown
4. **Explicit Performance Management**: Makes performance considerations an architectural concern
5. **Predictable Behavior**: System performance characteristics become more predictable

## Implementation Checklist

To apply this meta-principle to your application:

1. [ ] Inventory and classify all computations by intensity, frequency, stability, and criticality
2. [ ] Identify appropriate allocation strategy for each computation
3. [ ] Implement caching mechanisms for semi-static calculations
4. [ ] Add pre-computation for heavy, frequent calculations
5. [ ] Create background processing infrastructure for long-running operations
6. [ ] Establish monitoring for computation times and resource usage
7. [ ] Document computation allocation decisions for maintainability

## Examples

### Customer DNA Distributions Example

1. **Classification**:
   - Computational Intensity: Medium (large customer dataset)
   - Usage Frequency: Frequent (core visualization)
   - Result Stability: Semi-static (changes with data updates)
   - Criticality: Core (primary analysis tool)

2. **Allocation Strategy**: Pre-computation + Cached Computation

3. **Implementation**:
   ```r
   # During data initialization
   precomputed_distributions <- reactiveVal(NULL)
   
   # Initialize with data loading
   observe({
     req(customer_data())
     
     # Calculate common distributions
     distributions <- list(
       m_distribution = compute_distribution(customer_data()$m_value),
       r_distribution = compute_distribution(customer_data()$r_value),
       f_distribution = compute_distribution(customer_data()$f_value),
       ipt_distribution = compute_distribution(customer_data()$ipt_mean),
       nes_counts = table(customer_data()$nes_status)
     )
     
     # Store for component use
     precomputed_distributions(distributions)
   })
   
   # Use in visualization component
   output$distribution_plot <- renderPlotly({
     req(precomputed_distributions())
     metric <- input$selected_metric
     
     # Use pre-computed data
     plot_distribution(precomputed_distributions()[[paste0(metric, "_distribution")]])
   })
   ```