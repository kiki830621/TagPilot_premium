# ExtendedTask Implementation in positionMSPlotly

## Overview

This document describes how we use Shiny's `ExtendedTask` for handling long-running AI operations without blocking the UI.

## Why ExtendedTask?

### ExtendedTask vs future_promise

While both allow asynchronous operations, they serve different purposes:

**future_promise**:
- Good for one-off async operations
- Requires manual state management
- Can lead to overlapping operations

**ExtendedTask**:
- Designed specifically for Shiny apps
- Built-in state management (initial/running/success/error)
- Automatic queueing of operations
- Prevents overlapping invocations
- Integrated with Shiny's reactive system

## Implementation in positionMSPlotly

### 1. Task Creation

```r
# Create ExtendedTask for AI naming
ai_naming_task <- if (!is.null(gpt_key)) {
  ExtendedTask$new(function(analysis_data, api_key) {
    # This function runs in a separate process via future
    future::future({
      generate_cluster_names(analysis_data, api_key)
    }, seed = TRUE)
  })
} else {
  NULL  # No task if no API key
}
```

### 2. Task Invocation

```r
# Trigger AI naming when cluster analysis changes
observe({
  if (!is_component_active()) return()
  if (is.null(ai_naming_task)) return()
  
  analysis <- cluster_analysis()
  if (is.null(analysis) || nrow(analysis) == 0) return()
  
  # Create unique ID for this analysis
  new_id <- create_analysis_id(analysis)
  
  # Check if this is a new analysis
  if (!identical(current_analysis_id(), new_id)) {
    current_analysis_id(new_id)
    
    # Invoke the task with current analysis data
    # ExtendedTask automatically queues if already running
    ai_naming_task$invoke(analysis, gpt_key)
  }
})
```

### 3. Using Task Results

```r
output$cluster_table <- renderDT({
  analysis <- cluster_analysis()
  
  # Try to get AI-generated names from ExtendedTask
  if (!is.null(ai_naming_task)) {
    task_status <- ai_naming_task$status()
    
    if (task_status == "success") {
      # Get the result from the completed task
      ai_names <- ai_naming_task$result()
      analysis$cluster_name <- ai_names
    } else if (task_status == "running") {
      # Task is still running, show placeholder
      analysis$cluster_name <- paste0("Segment ", analysis$cluster, " (AI naming...)")
    } else if (task_status == "error") {
      # Task failed, use default names
      analysis$cluster_name <- paste0("Segment ", analysis$cluster)
    } else {
      # Initial state - task hasn't been invoked yet
      analysis$cluster_name <- paste0("Segment ", analysis$cluster)
    }
  }
  
  # Render the table...
})
```

## Key Benefits

### 1. **Automatic State Management**

ExtendedTask tracks its own state:
- `"initial"`: Not yet invoked
- `"running"`: Currently processing
- `"success"`: Completed successfully
- `"error"`: Failed with error

### 2. **Built-in Queueing**

If you call `invoke()` while a task is running, it automatically queues the new invocation:

```r
# First invocation starts immediately
ai_naming_task$invoke(analysis1, api_key)

# Second invocation queues automatically
ai_naming_task$invoke(analysis2, api_key)
```

### 3. **Reactive Integration**

Both `status()` and `result()` are reactive reads that automatically invalidate when the task state changes:

```r
# This output automatically updates when task completes
output$status_text <- renderText({
  paste("Task status:", ai_naming_task$status())
})
```

### 4. **Error Handling**

Errors are captured and can be handled gracefully:

```r
task_status <- ai_naming_task$status()

if (task_status == "error") {
  # Calling result() would re-throw the error
  # Instead, handle gracefully with fallback
  use_default_names()
}
```

## Comparison with Previous Implementation

### Before (with future_promise):

```r
# Complex state management
cluster_names_final <- reactiveVal(NULL)
ai_processing_id <- reactiveVal(NULL)
previous_analysis_id <- reactiveVal(NULL)

# Manual promise handling
promises::future_promise({
  generate_cluster_names(analysis, gpt_key)
}) %>%
promises::then(
  onFulfilled = function(names) {
    later::later(function() {
      if (identical(isolate(ai_processing_id()), current_id)) {
        cluster_names_final(names)
        ai_processing_id(paste0("completed_", current_id))
      }
    })
  },
  onRejected = function(error) {
    # Error handling
  }
)
```

### After (with ExtendedTask):

```r
# Simple task creation
ai_naming_task <- ExtendedTask$new(function(analysis_data, api_key) {
  future::future({
    generate_cluster_names(analysis_data, api_key)
  })
})

# Simple invocation
ai_naming_task$invoke(analysis, gpt_key)

# Simple result retrieval
if (ai_naming_task$status() == "success") {
  names <- ai_naming_task$result()
}
```

## Best Practices

### 1. **Create Tasks at Module/App Level**

```r
# Good: Create once at server startup
server <- function(input, output, session) {
  ai_task <- ExtendedTask$new(...)
  
  # Use throughout server
}

# Avoid: Creating in reactive contexts
observe({
  # Don't create ExtendedTask here
})
```

### 2. **Pass Parameters, Don't Read Reactives**

```r
# Good: Pass reactive values as parameters
ai_task$invoke(
  analysis = cluster_analysis(),
  api_key = api_key()
)

# Avoid: Reading reactives inside task function
ExtendedTask$new(function() {
  # Don't do this:
  data <- cluster_analysis()  # Won't work!
})
```

### 3. **Handle All Status Cases**

```r
switch(ai_task$status(),
  initial = show_start_button(),
  running = show_progress_indicator(),
  success = show_results(ai_task$result()),
  error = show_error_message()
)
```

### 4. **Use with input_task_button**

For better UX, bind the task to a button:

```r
# In UI
input_task_button("analyze", "Start Analysis")

# In server
bind_task_button(ai_task, "analyze")
```

## Migration Guide

To migrate from promises to ExtendedTask:

1. **Replace reactive values** with ExtendedTask instance
2. **Replace promise chains** with task invocation
3. **Replace manual state checking** with `status()` method
4. **Replace result storage** with `result()` method
5. **Remove cleanup observers** - ExtendedTask handles its own cleanup

## Conclusion

ExtendedTask provides a cleaner, more robust way to handle long-running operations in Shiny. It's particularly well-suited for:

- API calls that may take several seconds
- Heavy computations that shouldn't block the UI
- Operations that users might trigger multiple times
- Tasks that need clear status indicators

The implementation in positionMSPlotly demonstrates how ExtendedTask simplifies async operations while providing better user experience through automatic state management and reactive integration.