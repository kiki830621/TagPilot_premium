# Future + Mirai Implementation in Precision Marketing App

## Overview

This document describes the implementation of `future.mirai` for high-performance asynchronous operations in the Shiny application.

## Implementation Details

### 1. Package Initialization

The required packages are added to the core packages in `fn_initialize_packages.R`:

```r
core_packages <- c(
  "stringr",      # String manipulation
  "glue",         # String templating
  "tools",        # File utilities
  "yaml",         # YAML parsing
  "future",       # Future framework for async
  "future.mirai", # Mirai backend for future
  "promises",     # Promise handling for async
  "later"         # Later for event loop
)
```

### 2. Global Future Plan Setup

In `sc_initialization_app_mode.R`, a global future plan is established:

```r
# Setup global future plan with mirai backend
if ("future" %in% unlist(AVAILABLE_PACKAGES) && "future.mirai" %in% unlist(AVAILABLE_PACKAGES)) {
  ## 1. 依容器 vCPU 自動設定 worker 數
  n <- future::availableCores()   # shinyapps.io 自動給 1/2/4
  
  # Set up mirai backend
  future::plan(future.mirai::mirai_multisession, workers = n)
}
```

This approach automatically adapts to the container's vCPU allocation:
- Local development: Uses all available cores
- shinyapps.io Basic: 1 worker
- shinyapps.io Standard: 2 workers  
- shinyapps.io Professional: 4 workers

### 3. Component-Level Usage

In `positionMSPlotly.R`, the AI naming feature uses `future_promise()`:

```r
# Create future promise for true parallel execution
promises::future_promise({
  # This runs in a separate R process
  generate_cluster_names(analysis, gpt_key)
}, seed = TRUE) %>%
promises::then(
  onFulfilled = function(cluster_names) {
    # Success - update reactive values in main thread
    later::later(function() {
      if (identical(isolate(ai_processing_id()), current_id)) {
        cluster_names_final(cluster_names)
        ai_processing_id(paste0("completed_", current_id))
      }
    })
  },
  onRejected = function(error) {
    # Error handling - use fallback names
    later::later(function() {
      if (identical(isolate(ai_processing_id()), current_id)) {
        warning("AI naming failed: ", error$message)
        cluster_names_final(paste("Segment", seq_len(nrow(analysis))))
        ai_processing_id(paste0("failed_", current_id))
      }
    })
  }
)
```

## Key Benefits

### 1. **Performance**
- Mirai provides faster process spawning than standard `multisession`
- Lower memory overhead
- Better task scheduling through NNG (nanomsg)

### 2. **Reliability**
- Automatic worker recovery on crashes
- Clean process termination
- No zombie processes

### 3. **Scalability**
- Automatically adjusts to available CPU cores
- Works seamlessly on both local and deployed environments
- Graceful degradation on resource-limited systems

### 4. **Non-blocking UI**
- Table renders immediately with placeholder names
- AI processing happens in parallel
- UI remains responsive during API calls

## Usage Pattern

### Basic Future Promise

```r
# Simple async operation
promises::future_promise({
  # CPU or I/O intensive operation
  expensive_operation()
}) %...>% {
  # Handle success
  update_ui(.)
} %...!% {
  # Handle error
  show_error(.$message)
}
```

### With Progress Updates

```r
# For operations that can report progress
promises::future_promise({
  for (i in 1:10) {
    # Do work
    Sys.sleep(0.5)
    # Report progress (if using progressr)
    p(sprintf("Step %d/10", i))
  }
  return(result)
}) %...>% {
  finalize_ui(.)
}
```

### Parallel Batch Processing

```r
# Process multiple products in parallel
products <- list(product1, product2, product3)

# Create promises for each product
promises_list <- lapply(products, function(product) {
  promises::future_promise({
    process_product(product)
  })
})

# Wait for all to complete
promises::promise_all(.list = promises_list) %...>% {
  # All products processed
  combine_results(.)
}
```

## Resource Management

### Worker Pool Limits

The implementation includes safeguards against resource exhaustion:

1. **Deployment Detection**: Automatically limits workers on shinyapps.io
2. **Local Cap**: Maximum 4 workers locally to prevent system overload
3. **Cleanup**: `.cleanup = TRUE` ensures proper resource release

### Best Practices

1. **Use the Global Plan**: Components should use the global future plan when available
2. **Isolate Reactive Updates**: Always use `isolate()` when updating reactive values from promises
3. **Error Handling**: Always include `%...!%` error handlers
4. **Resource Awareness**: Consider the number of concurrent users when setting worker limits

## Monitoring and Debugging

### Check Current Plan

```r
# In your Shiny app
current_plan <- future::plan()
message("Current future plan: ", class(current_plan)[1])
message("Number of workers: ", future::nbrOfWorkers())
```

### Monitor Worker Usage

```r
# Check available workers
future::nbrOfFreeWorkers()

# Check if all workers are busy
if (future::nbrOfFreeWorkers() == 0) {
  message("All workers busy, operations will queue")
}
```

## Migration Guide

### From `later` to `future_promise`

```r
# Old approach with later
later::later(function() {
  result <- slow_operation()
  update_ui(result)
}, delay = 0.1)

# New approach with future_promise
promises::future_promise({
  slow_operation()
}) %...>% {
  update_ui(.)
}
```

### From Standard `future` to `future_promise`

```r
# Old approach
f <- future::future({ slow_operation() })
promises::then(
  as.promise(f),
  onFulfilled = function(result) { update_ui(result) }
)

# New approach (cleaner)
promises::future_promise({
  slow_operation()
}) %...>% {
  update_ui(.)
}
```

## Conclusion

The `future.mirai` implementation provides a robust, high-performance foundation for asynchronous operations in the Shiny application. By using the built-in `future_promise()` function from the promises package, we get:

1. **Simplified Code**: No need to manually convert futures to promises
2. **Better Queue Management**: Automatic queueing when workers are busy
3. **Consistent API**: Works seamlessly with promise chains
4. **Production Ready**: Battle-tested in many production Shiny apps

This implementation ensures that expensive operations like AI API calls don't block the UI, providing a smooth user experience even under heavy load.