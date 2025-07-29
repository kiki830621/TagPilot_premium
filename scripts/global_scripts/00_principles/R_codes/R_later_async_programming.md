# R: Later vs Future - Async Programming in R

## Core Concept: later ≠ Parallel Computing

**Key Understanding**: `later` is NOT parallel computation.  
`later` simply "delays (or batches) an R code block for later execution", but all work still runs on **the same main thread**. If two code segments are CPU-heavy, they will still queue up—just queuing in the event loop instead.

---

## When to Use `later` (Split Tasks in Two Stages)

| Scenario | Benefits of Using `later` |
|----------|---------------------------|
| **High I/O Wait** - e.g., API calls, file downloads, disk I/O | Send request first → Use `later()` to schedule response handling; prevents UI (Shiny/RStudio) from freezing |
| **UI-First Rendering** | Render interface first → `later()` schedules heavy computation for next event loop; user interface won't freeze for seconds |
| **Periodic Polling** | `later(function() {...; later(this_fn, n) }, n)` creates simple scheduler without blocking thread with `Sys.sleep()` |

**Summary**: `later` is suitable for "non-blocking + single-threaded" scheduling.

---

## For True Parallel Heavy Computation → Use Parallel/Multi-process Methods

### 1. **future/future.apply Ecosystem**

```r
library(future.apply)
plan(multisession, workers = 2)   # macOS/Linux can use multicore, Windows uses multisession

results <- future_lapply(1:2, function(i){
  heavy_job(i)          # Your CPU-heavy function
})
```

One core per task, truly simultaneous execution; can still show progress with `progressr`.

### 2. **callr::r_bg() — Background R Session**

```r
library(callr)
p1 <- r_bg(function() heavy_job(1))
p2 <- r_bg(function() heavy_job(2))
p1$wait(); p2$wait()
```

### 3. **parallel Package Basics**

```r
library(parallel)
mclapply(1:2, heavy_job, mc.cores = 2)  # macOS/Linux
```

---

## How to Choose?

| Requirement/Constraint | Recommendation |
|------------------------|----------------|
| Shiny App, need single-thread but non-blocking UI | `later` with `promises` (for I/O operations) |
| Pure R script, CPU heavy, want shorter total time | `future` (multisession/multicore), `parallel`, or `callr` |
| Need both "non-blocking" AND "visible progress" | `future` + `progressr` (workers parallel internally; main thread receives progress signals) |

---

## Example: Parallelizing CPU-Heavy Work with future

```r
library(future)
library(progressr)
plan(multisession, workers = 2)

handlers(handler_progress())

with_progress({
  p <- progressor(steps = 2)

  res <- future_map(1:2, function(i){
    p(sprintf("Task %d started", i))
    heavy_job(i)          # Your time-consuming function
  })
})
```

---

## Practical Examples in Shiny Context

### Example 1: Non-blocking API Calls with later

```r
# In Shiny server
observeEvent(input$fetch_data, {
  # Show spinner immediately
  showNotification("Fetching data...", id = "fetch_progress", duration = NULL)
  
  # Schedule API call for next event loop
  later::later(function() {
    result <- tryCatch({
      api_call()  # Your API function
    }, error = function(e) {
      removeNotification("fetch_progress")
      showNotification("Error fetching data", type = "error")
      return(NULL)
    })
    
    if (!is.null(result)) {
      removeNotification("fetch_progress")
      # Update reactive values
      data_values$result <- result
    }
  }, delay = 0.1)  # Small delay to ensure UI updates first
})
```

### Example 2: True Parallel Processing with future in Shiny

```r
# For CPU-intensive parallel tasks
library(future)
library(promises)
plan(multisession, workers = 4)

observeEvent(input$process_data, {
  # Create future promise
  future_promise({
    # This runs in parallel worker
    heavy_computation(data)
  }) %...>% {
    # This runs back in main thread when done
    result <- .
    output$results <- renderTable(result)
  } %...!% {
    # Error handling
    showNotification("Processing failed", type = "error")
  }
})
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Using later for CPU-heavy tasks
```r
# WRONG: This still blocks eventually
later::later(function() {
  heavy_cpu_task()  # Still runs on main thread!
})

# RIGHT: Use future for true parallelism
future({
  heavy_cpu_task()  # Runs on separate process
})
```

### Pitfall 2: Scope issues with later
```r
# WRONG: Reactive context lost
observe({
  value <- reactive_value()
  later::later(function() {
    # Can't access reactive context here!
    another_reactive()  # ERROR
  })
})

# RIGHT: Isolate values first
observe({
  value <- isolate(reactive_value())
  later::later(function() {
    # Use isolated value
    process(value)
  })
})
```

---

## Conclusion

- **Just want to "split tasks" not "parallelize"** → `later` is most lightweight
- **Want true parallelism, multi-core usage** → `future` / `parallel` / `callr`; then use `later()` to return results to main thread for UI updates

## Best Practices

1. Use `later` for:
   - UI responsiveness in Shiny
   - Scheduling non-blocking I/O operations
   - Simple task queuing on single thread

2. Use `future` for:
   - CPU-intensive parallel computations
   - True concurrent execution
   - Multi-core utilization

3. Combine both when needed:
   - Use `future` for parallel computation
   - Use `later` to update UI with results

---

*Related Principles*:
- R121: Localized Activation Pattern
- MP47: Functional Programming
- R67: Functional Encapsulation