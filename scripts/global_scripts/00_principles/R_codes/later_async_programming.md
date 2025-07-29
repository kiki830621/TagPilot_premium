# Using `later` for Asynchronous Programming in Shiny

## Overview

The `later` package allows you to break Shiny's single-threaded blocking behavior by scheduling code to run asynchronously. This is crucial for creating responsive user interfaces that don't freeze while performing heavy computations.

## Key Concepts

### Single Thread Problem in Shiny
```r
# BAD: This blocks the entire UI
output$table <- renderDT({
  heavy_computation()    # UI freezes here
  create_table(result)   # User sees nothing until this completes
})
```

### Async Solution with `later`
```r
# GOOD: Immediate response with background processing
output$table <- renderDT({
  show_placeholder_table()  # Shows immediately
  
  later::later(function() {
    result <- heavy_computation()    # Runs in background
    update_table(result)            # Updates when ready
  }, delay = 0.1)
})
```

## Installation and Setup

```r
# Install the package
install.packages("later")

# Load in your app
library(later)

# Or use conditional loading
if (requireNamespace("later", quietly = TRUE)) {
  # Use later functionality
} else {
  # Fallback to synchronous behavior
}
```

## Basic Usage Patterns

### 1. Simple Delayed Execution
```r
# Execute function after delay
later::later(function() {
  message("This runs after 2 seconds")
}, delay = 2)
```

### 2. Background Data Processing
```r
# In server function
server <- function(input, output, session) {
  # Reactive values for storing results
  analysis_result <- reactiveVal(NULL)
  is_processing <- reactiveVal(FALSE)
  
  # Trigger background processing
  observeEvent(input$start_analysis, {
    is_processing(TRUE)
    
    # Show immediate feedback
    showNotification("Analysis started...", duration = NULL, id = "processing")
    
    # Background processing
    later::later(function() {
      # Heavy computation here
      result <- perform_heavy_analysis(input$data)
      
      # Update reactive values
      analysis_result(result)
      is_processing(FALSE)
      
      # Remove notification
      removeNotification("processing")
      showNotification("Analysis complete!", type = "message")
    }, delay = 0.1)  # Small delay to let UI update
  })
  
  # Render results when available
  output$results <- renderTable({
    req(analysis_result())
    analysis_result()
  })
}
```

### 3. Progressive UI Loading
```r
# Show skeleton UI first, then enhance
output$complex_plot <- renderPlotly({
  # Show basic plot immediately
  basic_plot <- create_basic_plot(data)
  
  # Add complex features in background
  later::later(function() {
    enhanced_plot <- add_complex_features(basic_plot, data)
    # Update plot (trigger reactive update)
    complex_plot_data(enhanced_plot)
  }, delay = 0.2)
  
  return(basic_plot)
})
```

## Advanced Patterns

### 1. Two-Stage Loading (Skeleton → Content)
```r
server <- function(input, output, session) {
  # Reactive values for different stages
  basic_data <- reactiveVal(NULL)
  enhanced_data <- reactiveVal(NULL)
  processing_stage <- reactiveVal("idle")  # idle, basic, enhanced
  
  # Stage 1: Quick basic data
  observe({
    if (processing_stage() == "idle") {
      processing_stage("basic")
      
      # Create basic version immediately
      basic_result <- create_basic_version(input$filters)
      basic_data(basic_result)
      
      # Stage 2: Enhanced version in background
      later::later(function() {
        processing_stage("enhanced")
        enhanced_result <- create_enhanced_version(basic_result, input$filters)
        enhanced_data(enhanced_result)
        processing_stage("complete")
      }, delay = 0.5)
    }
  })
  
  # Render table that updates progressively
  output$data_table <- renderDT({
    if (!is.null(enhanced_data())) {
      # Show enhanced version when ready
      return(enhanced_data())
    } else if (!is.null(basic_data())) {
      # Show basic version while waiting
      return(basic_data())
    } else {
      # Show loading message
      return(data.frame(Status = "Loading..."))
    }
  })
}
```

### 2. API Calls with Fallback
```r
# Background API call with immediate fallback
server <- function(input, output, session) {
  api_result <- reactiveVal(NULL)
  
  # Show default content immediately, enhance with API data
  output$content <- renderUI({
    default_content <- create_default_ui()
    
    # Try API call in background
    if (!is.null(input$api_key)) {
      later::later(function() {
        tryCatch({
          api_data <- call_external_api(input$api_key, input$parameters)
          api_result(api_data)
        }, error = function(e) {
          showNotification(paste("API error:", e$message), type = "warning")
        })
      }, delay = 0.1)
    }
    
    return(default_content)
  })
  
  # Update UI when API data arrives
  observe({
    if (!is.null(api_result())) {
      # Update existing UI with API data
      session$sendCustomMessage("updateWithAPIData", api_result())
    }
  })
}
```

### 3. Chained Background Operations
```r
# Sequential background tasks
server <- function(input, output, session) {
  task_status <- reactiveVal("pending")
  results <- reactiveValues(step1 = NULL, step2 = NULL, step3 = NULL)
  
  observeEvent(input$start_process, {
    task_status("running")
    
    # Step 1: Data preparation
    later::later(function() {
      results$step1 <- prepare_data(input$raw_data)
      task_status("step1_complete")
      
      # Step 2: Analysis (depends on step 1)
      later::later(function() {
        results$step2 <- analyze_data(results$step1)
        task_status("step2_complete")
        
        # Step 3: Visualization (depends on step 2)
        later::later(function() {
          results$step3 <- create_visualization(results$step2)
          task_status("complete")
        }, delay = 0.1)
      }, delay = 0.1)
    }, delay = 0.1)
  })
  
  # Show progress and results
  output$status <- renderText({
    switch(task_status(),
           "pending" = "Ready to start",
           "running" = "Preparing data...",
           "step1_complete" = "Analyzing data...",
           "step2_complete" = "Creating visualization...",
           "complete" = "Process complete!"
    )
  })
}
```

## Real-World Example: Cluster Analysis

```r
# Based on our positionMSPlotly implementation
server <- function(input, output, session) {
  # Reactive values for different stages
  basic_clusters <- reactiveVal(NULL)
  full_analysis <- reactiveVal(NULL)
  ai_names <- reactiveVal(NULL)
  
  # Stage 1: Basic cluster info (immediate)
  observe({
    csa_result <- csa_analysis()  # Assume this exists
    if (!is.null(csa_result)) {
      n_clusters <- length(unique(csa_result$clusters))
      basic_info <- data.frame(
        cluster = 1:n_clusters,
        name = paste0("Segment ", 1:n_clusters, " (分析中...)"),
        companies = sapply(1:n_clusters, function(i) sum(csa_result$clusters == i)),
        revenue = "計算中...",
        characteristics = "分析中..."
      )
      basic_clusters(basic_info)
    }
  })
  
  # Stage 2: Full statistical analysis (background)
  observe({
    csa_result <- csa_analysis()
    if (!is.null(csa_result) && is.null(full_analysis())) {
      later::later(function() {
        # Heavy statistical computation
        detailed_analysis <- perform_cluster_analysis(csa_result)
        full_analysis(detailed_analysis)
        
        # Stage 3: AI naming (even more background)
        if (!is.null(input$openai_key)) {
          later::later(function() {
            ai_generated_names <- call_openai_api(detailed_analysis, input$openai_key)
            ai_names(ai_generated_names)
          }, delay = 0.1)
        }
      }, delay = 0.5)  # Let basic table render first
    }
  })
  
  # Progressive table rendering
  output$cluster_table <- renderDT({
    # Priority: AI names > Full analysis > Basic clusters
    if (!is.null(ai_names()) && !is.null(full_analysis())) {
      # Final version with AI names
      analysis <- full_analysis()
      analysis$name <- ai_names()
      return(analysis)
    } else if (!is.null(full_analysis())) {
      # Detailed analysis without AI names
      analysis <- full_analysis()
      analysis$name <- paste0("Segment ", analysis$cluster, " (AI 分析中)")
      return(analysis)
    } else if (!is.null(basic_clusters())) {
      # Basic version while computing
      return(basic_clusters())
    } else {
      # Loading state
      return(data.frame(Status = "載入中..."))
    }
  })
}
```

## Best Practices

### 1. Always Provide Immediate Feedback
```r
# DON'T: Leave users hanging
output$result <- renderText({
  later::later(function() {
    heavy_computation()
  }, delay = 1)
})

# DO: Show something immediately
output$result <- renderText({
  result <- "Processing..."
  
  later::later(function() {
    final_result <- heavy_computation()
    # Update result through reactive value
    result_data(final_result)
  }, delay = 0.1)
  
  return(result)
})
```

### 2. Use Reasonable Delays
```r
# Common delay patterns:
delay = 0.1    # Let current UI render (100ms)
delay = 0.5    # User can see intermediate state (500ms)
delay = 1.0    # For heavy operations (1 second)
delay = 2.0    # For very heavy operations (2 seconds)
```

### 3. Handle Errors Gracefully
```r
later::later(function() {
  tryCatch({
    result <- risky_operation()
    success_result(result)
  }, error = function(e) {
    showNotification(paste("Error:", e$message), type = "error")
    error_result(NULL)
  })
}, delay = 0.1)
```

### 4. Avoid Infinite Loops
```r
# BAD: Can create infinite recursion
observe({
  later::later(function() {
    # This triggers the observe again!
    trigger_reactive_update()
  }, delay = 1)
})

# GOOD: Use flags to control execution
observe({
  if (should_process() && !is_processing()) {
    is_processing(TRUE)
    later::later(function() {
      process_data()
      is_processing(FALSE)
    }, delay = 1)
  }
})
```

## Performance Considerations

1. **Memory Usage**: `later` doesn't create true threads, so memory is still shared
2. **CPU Intensive Tasks**: Still block the main thread during execution
3. **UI Responsiveness**: Best for I/O operations and progressive enhancement
4. **Scheduling**: Multiple `later` calls are queued and executed in order

## Integration with Other Packages

### With `promises` (for true async)
```r
# For CPU-intensive tasks, consider promises + future
library(promises)
library(future)

plan(multisession)  # Enable parallel processing

server <- function(input, output, session) {
  output$result <- renderText({
    # Show immediate placeholder
    placeholder <- "Computing..."
    
    # True async computation
    future({
      heavy_cpu_task()
    }) %...>% {
      # This runs when future completes
      final_result(.)
    }
    
    return(placeholder)
  })
}
```

### With `httr2` for API calls
```r
# Combine later with httr2 for non-blocking API calls
later::later(function() {
  response <- httr2::request("https://api.example.com") |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  
  api_data(response)
}, delay = 0.1)
```

This guide provides a comprehensive foundation for using `later` to create responsive, user-friendly Shiny applications that don't freeze during heavy computations.