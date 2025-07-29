# Refactoring positionMSPlotly from Later to Future

## Current Implementation Analysis

The current implementation in `positionMSPlotly.R` uses `later::later()` to defer AI naming generation:

```r
# Current approach (lines 823-863)
later::later(function() {
  # API call happens on main thread, just delayed
  cluster_names <- generate_cluster_names(analysis_snapshot, gpt_key)
  # Update reactive values
}, delay = 1.0)
```

**Problems with this approach:**
1. **Still blocks the main thread** - The API call runs on the same thread, just delayed
2. **Complex scope management** - Need to use `isolate()` to access reactive values
3. **No real parallelism** - DT rendering and API call don't truly run simultaneously

## Improved Future Implementation

Here's how to refactor using `future` + `promises` for true parallel execution:

```r
# In positionMSPlotlyServer function

# Setup future plan at the top of server
future::plan(future::multisession, workers = 2)

# ------------ AI Names (True Parallel Processing) ------------------------
# Reactive values for AI names
cluster_names_final <- reactiveVal(NULL)
ai_processing_id <- reactiveVal(NULL)

# Generate AI names with true parallelism
observe({
  # Only perform AI analysis when component is active
  if (!is_component_active()) {
    return()
  }
  
  analysis <- cluster_analysis()
  if (is.null(analysis) || nrow(analysis) == 0) return()
  
  # Create unique ID for this analysis
  current_id <- paste0(nrow(analysis), "_", Sys.time())
  
  # Only generate names if not already processing this exact analysis
  if (is.null(ai_processing_id()) && !is.null(gpt_key)) {
    ai_processing_id(current_id)
    message("Starting AI naming for analysis ID: ", current_id)
    
    # Create future promise for AI naming
    naming_promise <- future::future({
      # This runs in a separate R process
      generate_cluster_names(analysis, gpt_key)
    }, seed = TRUE) %>%
    promises::then(
      onFulfilled = function(cluster_names) {
        # Success - update reactive values in main thread
        message("AI naming completed successfully")
        
        # Check if we're still processing the same analysis
        if (identical(isolate(ai_processing_id()), current_id)) {
          cluster_names_final(cluster_names)
          ai_processing_id(paste0("completed_", current_id))
          
          # Show success notification
          showNotification(
            paste("✅ AI naming completed:", paste(cluster_names, collapse = ", ")),
            duration = 5,
            type = "success",
            session = session
          )
        }
      },
      onRejected = function(error) {
        # Error handling
        warning("Error in AI naming: ", error$message)
        
        # Fallback to default names
        if (identical(isolate(ai_processing_id()), current_id)) {
          cluster_names_final(paste("Segment", seq_len(nrow(analysis))))
          ai_processing_id(paste0("failed_", current_id))
          
          # Show error notification
          showNotification(
            "❌ AI naming failed, using default names",
            duration = 5,
            type = "error",
            session = session
          )
        }
      }
    )
    
    # No need for explicit catch - promises handle errors
    NULL
  }
})
```

## Key Improvements

### 1. True Parallel Execution
```r
# Thread 1: Main Shiny thread
# - Renders DT immediately with placeholder names
# - UI remains fully responsive

# Thread 2: Worker process
# - Makes GPT API call
# - Processes response
# - Returns results to main thread
```

### 2. Cleaner Error Handling
```r
promises::then(
  onFulfilled = function(result) {
    # Success path
  },
  onRejected = function(error) {
    # Error path with graceful fallback
  }
)
```

### 3. Better Resource Management
- Worker processes managed automatically by `future`
- No manual thread management needed
- Automatic cleanup when app stops

## Implementation with Progress Tracking

For even better UX, add progress tracking:

```r
# Enhanced version with progress spinner
observe({
  # ... (same setup as before)
  
  if (is.null(ai_processing_id()) && !is.null(gpt_key)) {
    ai_processing_id(current_id)
    
    # Use withSpinner for the entire cluster_table output
    # This is already implemented in the UI
    
    # Create future with progress
    naming_promise <- future::future({
      # Simulate progress updates (optional)
      for (i in 1:10) {
        Sys.sleep(0.1)  # Simulate work
        # In real implementation, this would be actual API progress
      }
      generate_cluster_names(analysis, gpt_key)
    }, seed = TRUE)
    
    # Handle promise resolution
    promises::then(naming_promise,
      onFulfilled = function(names) {
        # Update UI from main thread
        later::later(function() {
          cluster_names_final(names)
          ai_processing_id(paste0("completed_", current_id))
        })
      }
    )
  }
})
```

## Complete Refactored Section

Here's the complete refactored AI naming section:

```r
# ------------ AI Names (True Parallel Processing) ------------------------
# Setup future plan
if (!exists(".future_plan_set")) {
  if (Sys.getenv("SHINY_PORT") != "") {
    future::plan(future::sequential)  # shinyapps.io limitation
  } else {
    future::plan(future::multisession, workers = 2)
  }
  .future_plan_set <<- TRUE
}

# Reactive values for AI names
cluster_names_final <- reactiveVal(NULL)
ai_processing_id <- reactiveVal(NULL)
previous_analysis_id <- reactiveVal(NULL)

# Generate AI names with true parallelism
observe({
  # Only perform AI analysis when component is active
  if (!is_component_active()) return()
  
  analysis <- cluster_analysis()
  if (is.null(analysis) || nrow(analysis) == 0) return()
  
  # Create unique ID for this analysis
  content_string <- paste(analysis$significant_vars, collapse = "|")
  simple_checksum <- sum(utf8ToInt(content_string)) %% 10000
  current_id <- paste0(nrow(analysis), "_", simple_checksum)
  
  # Check if this is a new analysis
  if (!identical(previous_analysis_id(), current_id)) {
    previous_analysis_id(current_id)
    
    # Reset AI processing state
    ai_processing_id(NULL)
    cluster_names_final(NULL)
    
    # Generate names if API key available
    if (!is.null(gpt_key)) {
      ai_processing_id(current_id)
      
      # Create future promise
      future::future({
        generate_cluster_names(analysis, gpt_key)
      }, seed = TRUE) %>%
      promises::then(
        onFulfilled = function(names) {
          # Success - update in main thread
          later::later(function() {
            if (identical(isolate(ai_processing_id()), current_id)) {
              cluster_names_final(names)
              ai_processing_id(paste0("completed_", current_id))
              message("AI naming completed: ", paste(names, collapse = ", "))
            }
          })
        },
        onRejected = function(err) {
          # Error - use fallback names
          later::later(function() {
            if (identical(isolate(ai_processing_id()), current_id)) {
              warning("AI naming failed: ", err$message)
              cluster_names_final(paste("Segment", seq_len(nrow(analysis))))
              ai_processing_id(paste0("failed_", current_id))
            }
          })
        }
      )
    }
  }
})
```

## Benefits Summary

1. **True Parallelism**: DT renders immediately while AI naming happens in parallel
2. **Non-blocking**: Main thread stays responsive for user interactions
3. **Better Performance**: Utilizes multiple CPU cores effectively
4. **Cleaner Code**: No complex `isolate()` patterns needed
5. **Robust Error Handling**: Graceful fallbacks with promises
6. **Scalable**: Easy to adjust worker count based on resources

## Migration Checklist

- [ ] Add `promises` to package dependencies
- [ ] Set up future plan appropriately for deployment environment
- [ ] Replace `later::later()` with `future::future()` + `promises::then()`
- [ ] Test error scenarios with network failures
- [ ] Verify performance improvements with timing logs
- [ ] Ensure proper cleanup in session end handlers