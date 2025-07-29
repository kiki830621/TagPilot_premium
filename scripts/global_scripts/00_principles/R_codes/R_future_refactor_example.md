# Refactoring AI Naming from Later to Future/Promises in R Shiny

## Overview
This guide demonstrates how to refactor the AI naming functionality in the positioning app from using `later` package to the more robust `future/promises` approach.

## 1. Current Implementation (Synchronous with Conditional Parallelism)

The current implementation uses `furrr::future_map_chr` for local parallel processing and falls back to sequential processing on shinyapps.io:

```r
# Current implementation in full_app_v17.R (lines 390-401)
if (Sys.getenv("SHINY_PORT") != "") {
  # Sequential processing on shinyapps.io
  res_vec <- purrr::map_chr(prompts, function(msgs) {
    out <- try(chat_api(msgs), silent = TRUE)
    if (inherits(out, "try-error")) NA_character_ else out
  })
} else {
  # Parallel processing locally
  res_vec <- future_map_chr(prompts, function(msgs) {
    out <- try(chat_api(msgs), silent = TRUE)
    if (inherits(out, "try-error")) NA_character_ else out
  }, .options = furrr_options(seed = TRUE))
}
```

## 2. Improved Future/Promises Implementation

Here's the refactored version using `future` and `promises` for truly asynchronous processing:

```r
# Load required packages
library(future)
library(promises)
library(later)  # Still needed for promise handling in Shiny

# Setup future plan (in global.R or app initialization)
if (Sys.getenv("SHINY_PORT") != "") {
  plan(sequential)  # shinyapps.io limitation
} else {
  plan(multisession, workers = min(4, parallel::detectCores() - 1))
}

# Async version of chat_api
chat_api_async <- function(messages,
                          model = "gpt-4o-mini",
                          api_key = Sys.getenv("OPENAI_API_KEY"),
                          api_url = "https://api.openai.com/v1/chat/completions",
                          timeout_sec = 60) {
  
  future({
    if (!nzchar(api_key)) stop("🔑 OPENAI_API_KEY is missing")
    
    body <- list(
      model = model,
      messages = messages,
      temperature = 0.3,
      max_tokens = 1024
    )
    
    req <- request(api_url) |>
      req_auth_bearer_token(api_key) |>
      req_headers(`Content-Type` = "application/json") |>
      req_body_json(body) |>
      req_timeout(timeout_sec)
    
    resp <- req_perform(req)
    
    if (resp_status(resp) >= 400) {
      err <- resp_body_string(resp)
      stop(sprintf("Chat API error %s:\n%s", resp_status(resp), err))
    }
    
    content <- resp_body_json(resp)
    trimws(content$choices[[1]]$message$content)
  }) %...>% (function(result) {
    # Success handler
    result
  }) %...!% (function(error) {
    # Error handler
    warning(paste("API call failed:", error$message))
    NA_character_
  })
}

# Refactored scoring function with promises
observeEvent(input$score, {
  req(facets_rv(), working_data())
  
  shinyjs::disable("score")
  shinyjs::disable("to_step3")
  
  df <- working_data()
  attrs <- facets_rv()
  nr <- min(nrow(df), input$nrows)
  total <- nr
  
  # Create reactive values for progress tracking
  progress_rv <- reactiveVal(0)
  results_rv <- reactiveVal(list())
  
  # Show progress modal
  showModal(modalDialog(
    title = "AI 評分中...",
    tagList(
      tags$div(
        class = "progress",
        tags$div(
          class = "progress-bar progress-bar-striped progress-bar-animated",
          role = "progressbar",
          style = "width: 0%",
          id = "scoring-progress"
        )
      ),
      textOutput("scoring-eta")
    ),
    footer = NULL,
    easyClose = FALSE
  ))
  
  start_time <- Sys.time()
  
  # Process all rows asynchronously
  all_promises <- lapply(1:nr, function(i) {
    row <- df[i, ]
    
    # Create prompts for all attributes
    prompts <- lapply(attrs, function(a) {
      list(
        list(role = "system", content = "你是一位行銷專業的數據分析師，請用繁體中文回答。"),
        list(role = "user", content = sprintf(
          "以下 JSON：%s請只回%s:<1-5或無>",
          toJSON(row[c("Variation","Title","Body")], dataframe = "rows", auto_unbox = TRUE), a
        ))
      )
    })
    
    # Create promises for all API calls for this row
    row_promises <- lapply(prompts, chat_api_async)
    
    # Combine all promises for this row
    promise_all(.list = row_promises) %...>% (function(responses) {
      # Process responses
      vals <- purrr::map_dbl(responses, safe_value)
      tmp_list <- setNames(as.list(vals), attrs)
      scores_df <- as.data.frame(tmp_list, check.names = FALSE, stringsAsFactors = FALSE)
      scores_df <- cbind(Variation = row$Variation, scores_df)
      
      # Update progress
      current_progress <- progress_rv() + 1
      progress_rv(current_progress)
      
      # Update results
      current_results <- results_rv()
      current_results[[i]] <- scores_df
      results_rv(current_results)
      
      # Update UI progress bar
      shinyjs::runjs(sprintf(
        "$('#scoring-progress').css('width', '%d%%').attr('aria-valuenow', %d);",
        round(current_progress / total * 100),
        round(current_progress / total * 100)
      ))
      
      # Update ETA
      elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
      eta <- (elapsed / current_progress) * (total - current_progress)
      output$`scoring-eta` <- renderText({
        sprintf("預估剩餘 %02d:%02d", eta %/% 60, round(eta %% 60))
      })
      
      scores_df
    })
  })
  
  # Wait for all promises to complete
  promise_all(.list = all_promises) %...>% (function(all_results) {
    # Combine results
    result_df <- bind_rows(all_results)
    other_col <- df %>% select(-c("Variation","Title","Body"))
    result_df <- bind_cols(other_col, result_df)
    
    # Update reactive values
    working_data(result_df)
    
    # Update UI
    output$score_tbl <- renderDT(result_df, selection = "none")
    shinyjs::enable("to_step3")
    
    # Store to DB
    tryCatch({
      dbExecute(con_global,
                "INSERT INTO processed_data (user_id, processed_at, json) VALUES ($1,$2,$3)",
                params = list(
                  current_user$id,
                  format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
                  toJSON(result_df, dataframe = "rows")
                ))
    }, error = function(e) {
      warning("Failed to save to database:", e$message)
    })
    
    # Close modal
    removeModal()
    
    # Show completion message
    showNotification("評分完成！", type = "success", duration = 5)
    
  }) %...!% (function(error) {
    # Error handling
    removeModal()
    shinyjs::enable("score")
    showModal(modalDialog(
      title = "錯誤",
      paste("評分過程中發生錯誤:", error$message),
      easyClose = TRUE,
      footer = modalButton("關閉")
    ))
  })
})
```

## 3. Benefits of Future/Promises Approach

### 3.1 Non-blocking UI
- The UI remains responsive during long-running API calls
- Users can interact with other parts of the app while processing

### 3.2 Better Error Handling
- Individual API failures don't crash the entire process
- Graceful degradation with NA values for failed calls
- Comprehensive error reporting

### 3.3 Real-time Progress Updates
- Smooth progress bar updates as each promise resolves
- Accurate ETA calculations based on completed tasks
- No need for arbitrary delays or polling

### 3.4 Resource Efficiency
- Automatic management of worker processes
- No manual thread management required
- Better memory usage through promise chaining

### 3.5 Scalability
- Easy to adjust number of concurrent workers
- Handles varying workloads automatically
- Degrades gracefully on resource-limited environments

## 4. Error Handling Best Practices

```r
# Comprehensive error handling with retry logic
chat_api_async_with_retry <- function(messages, max_retries = 3, ...) {
  attempt <- 0
  
  retry_promise <- function() {
    attempt <<- attempt + 1
    
    chat_api_async(messages, ...) %...!% (function(error) {
      if (attempt < max_retries) {
        # Exponential backoff
        Sys.sleep(2^attempt)
        retry_promise()
      } else {
        # Max retries reached
        stop(paste("API call failed after", max_retries, "attempts:", error$message))
      }
    })
  }
  
  retry_promise()
}

# Usage with retry
row_promises <- lapply(prompts, function(prompt) {
  chat_api_async_with_retry(prompt, max_retries = 3)
})
```

## 5. Updating Reactive Values from Futures

When working with futures and reactive values in Shiny, it's important to update them safely:

```r
# Safe reactive value update from promise
update_reactive_from_promise <- function(promise, reactive_val, update_fn) {
  promise %...>% (function(result) {
    # Use isolate to prevent reactive loops
    isolate({
      current_value <- reactive_val()
      new_value <- update_fn(current_value, result)
      reactive_val(new_value)
    })
    result
  })
}

# Example usage
results_promise <- chat_api_async(prompt)
update_reactive_from_promise(results_promise, results_rv, function(current, new_result) {
  c(current, list(new_result))
})
```

## 6. Migration Checklist

When migrating from `later` to `future/promises`:

1. **Dependencies**
   - Add `promises` to your package dependencies
   - Keep `future` and update to latest version
   - `later` is still needed for Shiny's internal promise handling

2. **Global Setup**
   - Configure future plan early in app initialization
   - Set appropriate worker limits based on deployment environment
   - Handle shinyapps.io limitations gracefully

3. **API Functions**
   - Convert synchronous functions to return futures
   - Add proper error handling with `%...!%`
   - Implement retry logic for resilience

4. **UI Updates**
   - Use `shinyjs::runjs()` for real-time progress updates
   - Implement proper modal dialogs for long operations
   - Add cancel functionality where appropriate

5. **Testing**
   - Test with both sequential and parallel plans
   - Verify error handling with simulated failures
   - Check memory usage under load
   - Ensure proper cleanup of workers

## 7. Performance Monitoring

```r
# Add performance monitoring
monitor_promise_performance <- function(promise, operation_name) {
  start_time <- Sys.time()
  
  promise %...>% (function(result) {
    duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
    loginfo(sprintf("%s completed in %.2f seconds", operation_name, duration))
    result
  }) %...!% (function(error) {
    duration <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
    logerror(sprintf("%s failed after %.2f seconds: %s", 
                     operation_name, duration, error$message))
    stop(error)
  })
}

# Usage
monitored_promise <- monitor_promise_performance(
  chat_api_async(prompt),
  "AI attribute generation"
)
```

## Conclusion

The migration from `later` to `future/promises` provides significant benefits in terms of performance, user experience, and code maintainability. The asynchronous approach ensures that your Shiny app remains responsive during long-running AI operations while providing better error handling and progress feedback to users.