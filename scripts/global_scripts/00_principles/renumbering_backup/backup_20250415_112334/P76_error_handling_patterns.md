---
id: "P76"
title: "Error Handling Patterns"
type: "principle"
date_created: "2025-04-09"
author: "Claude"
derives_from:
  - "MP53": "Feedback Loop"
  - "MP54": "UI-Server Correspondence"
influences:
  - "R09": "UI-Server-Defaults Triple"
related_to:
  - "MP52": "Unidirectional Data Flow"
  - "P75": "Search Input Optimization"
---

# P76: Error Handling Patterns

## Core Principle

Applications must implement a systematic approach to error detection, handling, and recovery with consistent user feedback. Each error type requires an appropriate detection mechanism, clear communication pattern, and defined recovery path.

## Types of Errors

This principle categorizes errors into four distinct types, each requiring different handling approaches:

### 1. Input Validation Errors
- **Definition**: Errors occurring when user input fails validation criteria
- **Detection**: Client-side validation during input or before submission
- **Example**: Invalid email format, required field missing, numeric range violations

### 2. Data Access Errors
- **Definition**: Errors occurring when system cannot access required data sources
- **Detection**: Database connection failures, missing files, network problems
- **Example**: Database timeout, table not found, network interruption

### 3. Processing Errors
- **Definition**: Errors occurring during server-side data processing
- **Detection**: Exception handling in business logic, unexpected data formats
- **Example**: Calculation errors, incompatible data types, unexpected null values

### 4. System Errors
- **Definition**: Errors occurring due to broader system failures
- **Detection**: Application monitoring, environment failures
- **Example**: Out of memory, server crashes, dependency failure

## Implementation Guidelines

### 1. Error Detection Patterns

Each component should implement these detection patterns:

#### Input Validation
```r
# Progressive validation during input
observe({
  req(input$email)
  if (input$email != "" && !is_valid_email(input$email)) {
    updateTextInput(session, "email", 
      label = "Email (Invalid format)",
      class = "input-error"
    )
    validation_state$email <- FALSE
  } else {
    updateTextInput(session, "email", 
      label = "Email",
      class = "input-valid"
    )
    validation_state$email <- TRUE
  }
})

# Form-level validation before submission
observeEvent(input$submit, {
  validation_errors <- list()
  
  if (!validation_state$email) {
    validation_errors$email <- "Please enter a valid email address"
  }
  
  if (length(validation_errors) > 0) {
    # Handle validation errors
    handle_validation_errors(validation_errors)
    return()
  }
  
  # Proceed with form submission
  submit_form(input)
})
```

#### Data Access Error Detection
```r
# Data access with error detection
data <- reactive({
  tryCatch({
    # Attempt data access
    result <- dbGetQuery(connection, query)
    if (nrow(result) == 0) {
      # No data found (not technically an error, but requires handling)
      return(list(
        status = "empty",
        data = NULL,
        message = "No data found for the given criteria"
      ))
    }
    return(list(
      status = "success",
      data = result,
      message = NULL
    ))
  }, error = function(e) {
    # Database error
    return(list(
      status = "error",
      data = NULL,
      message = paste("Database error:", e$message)
    ))
  })
})
```

#### Processing Error Detection
```r
# Processing with error detection
processed_data <- reactive({
  req(data())
  
  if (data()$status != "success") {
    # Pass through the error state
    return(data())
  }
  
  tryCatch({
    # Attempt processing
    result <- process_data(data()$data)
    return(list(
      status = "success",
      data = result,
      message = NULL
    ))
  }, error = function(e) {
    # Processing error
    return(list(
      status = "error",
      data = NULL,
      message = paste("Processing error:", e$message)
    ))
  }, warning = function(w) {
    # Process completed with warnings
    result <- process_data(data()$data)
    return(list(
      status = "warning",
      data = result,
      message = paste("Warning:", w$message)
    ))
  })
})
```

### 2. Error Communication Patterns

User interface should implement these communication patterns:

#### Inline Validation Feedback
```r
# Inline validation with immediate feedback
textInput(inputId = "email", 
  label = "Email Address",
  placeholder = "example@domain.com"
)

# Validation message display
uiOutput("email_validation")

# Server-side rendering of validation message
output$email_validation <- renderUI({
  req(input$email, input$email != "")
  
  if (!is_valid_email(input$email)) {
    div(class = "validation-error",
      icon("exclamation-circle"),
      "Please enter a valid email address"
    )
  } else {
    div(class = "validation-success",
      icon("check-circle"),
      "Email format is valid"
    )
  }
})
```

#### Status-Based Data Display
```r
# UI component with status handling
output$data_display <- renderUI({
  req(processed_data())
  
  status <- processed_data()$status
  
  if (status == "error") {
    div(class = "error-message",
      icon("exclamation-triangle"),
      h4("Error Occurred"),
      p(processed_data()$message),
      actionButton(ns("retry"), "Retry")
    )
  } else if (status == "empty") {
    div(class = "empty-state",
      icon("info-circle"),
      h4("No Data Available"),
      p(processed_data()$message),
      p("Try changing your search criteria.")
    )
  } else if (status == "warning") {
    div(
      div(class = "warning-banner",
        icon("exclamation-circle"),
        "Warning: ", processed_data()$message
      ),
      # Still display data with warning
      render_data_table(processed_data()$data)
    )
  } else {
    # Success state
    render_data_table(processed_data()$data)
  }
})
```

#### Modal Error Messages
```r
# For critical errors that prevent continuation
display_critical_error <- function(title, message, details = NULL) {
  showModal(modalDialog(
    title = title,
    div(
      div(class = "critical-error-message", message),
      if (!is.null(details)) {
        div(class = "error-details",
          h5("Technical Details:"),
          pre(details)
        )
      } else NULL,
      div(class = "error-actions",
        actionButton("refresh", "Refresh Page", icon = icon("sync")),
        actionButton("contact_support", "Contact Support", icon = icon("envelope"))
      )
    ),
    footer = NULL,
    easyClose = FALSE
  ))
}
```

### 3. Recovery Patterns

Applications should provide clear recovery paths:

#### Automatic Retry
```r
# Automatic retry with exponential backoff
get_data_with_retry <- function(query, max_retries = 3) {
  reactive({
    attempt <- 1
    retry_delay <- 1000  # Start with 1 second delay
    
    while (attempt <= max_retries) {
      result <- tryCatch({
        # Attempt to get data
        data <- dbGetQuery(connection, query)
        list(
          success = TRUE,
          data = data,
          error = NULL
        )
      }, error = function(e) {
        list(
          success = FALSE,
          data = NULL,
          error = e$message
        )
      })
      
      if (result$success) {
        return(result)
      }
      
      # If this was the last attempt, return the error
      if (attempt == max_retries) {
        return(result)
      }
      
      # Wait before retrying
      Sys.sleep(retry_delay / 1000)
      
      # Increase delay for next attempt (exponential backoff)
      retry_delay <- min(retry_delay * 2, 30000)  # Cap at 30 seconds
      attempt <- attempt + 1
    }
  })
}
```

#### User-Initiated Recovery
```r
# Allow user to retry operations
observeEvent(input$retry, {
  # Reset error state
  error_state$current <- NULL
  
  # Re-trigger data loading
  data_trigger$refresh <- Sys.time()
})

# Data loading with refresh trigger
data <- reactive({
  # React to refresh trigger
  data_trigger$refresh
  
  tryCatch({
    # Data loading logic
    dbGetQuery(connection, query)
  }, error = function(e) {
    error_state$current <- e$message
    NULL
  })
})
```

#### Fallback Content
```r
# Provide fallback content when primary data is unavailable
output$dashboard_chart <- renderPlot({
  if (is.null(primary_data()) || primary_data()$status == "error") {
    # Use cached data as fallback
    cached_data <- get_cached_data()
    
    if (!is.null(cached_data)) {
      # Create plot with cached data but show cached indicator
      p <- create_plot(cached_data)
      p + theme(
        plot.background = element_rect(fill = "#FFF9F0"),
        plot.caption = element_text(
          color = "#B94700", 
          hjust = 1, 
          face = "italic", 
          size = 10
        )
      ) + 
      labs(caption = "* Using cached data from previous session")
    } else {
      # No data available - show placeholder
      create_empty_plot("No data available")
    }
  } else {
    # Normal case - use primary data
    create_plot(primary_data()$data)
  }
})
```

## Error Documentation Pattern

All error handling must be documented:

```r
#' Customer Profile Component Server
#'
#' @param id Module ID
#' @param app_data_connection Database connection
#'
#' @return Reactive values
#' @section Error Handling:
#' This component handles the following errors:
#' * Database connection errors: Shows connection failed message with retry option
#' * Empty customer data: Shows "No customer data" message with setup instructions
#' * Permission errors: Shows "Access denied" with request permission button
#' @export
customerProfileServer <- function(id, app_data_connection) {
  # Implementation
}
```

## Relationship to Other Principles

This principle:

1. **Extends MP53 (Feedback Loop)** by specifying error-specific feedback patterns
2. **Supports MP54 (UI-Server Correspondence)** by ensuring errors in server processes are reflected in the UI
3. **Complements MP52 (Unidirectional Data Flow)** by defining how errors flow from data sources to UI
4. **Works with R09 (UI-Server-Defaults Triple)** by ensuring default fallbacks for error states

## Common Anti-patterns

### 1. Silent Failures
**Problem**: Errors occur without user notification
**Solution**: Always communicate errors to users through appropriate UI patterns

### 2. Technical Error Messages
**Problem**: Displaying technical error details directly to end users
**Solution**: Translate technical errors into user-friendly messages while preserving technical details for developers

### 3. Dead-End Errors
**Problem**: Errors that offer no recovery path
**Solution**: Always provide clear next steps after an error occurs

### 4. Inconsistent Error Handling
**Problem**: Different components handle similar errors differently
**Solution**: Use consistent patterns across the application

## Testing Approach

Error handling should be systematically tested:

1. **Simulate each error type** to verify detection mechanisms
2. **Verify appropriate UI feedback** for each error condition
3. **Test recovery pathways** to ensure they work as expected
4. **Validate fallback content** when primary content is unavailable

## Conclusion

The Error Handling Patterns principle ensures a systematic approach to error management that balances technical accuracy with usability. By categorizing errors, defining detection patterns, implementing consistent communication, and providing recovery options, applications can maintain user trust even when things go wrong.