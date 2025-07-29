# SLN06: Named Vector Creation in R

## Problem Description

When creating named vectors in R, especially in UI components like selectInput or updateSelectizeInput, developers often encounter errors when trying to dynamically generate the names using functions like paste0().

The error typically appears as:
```
Warning: Error in if: argument is of length zero
```

This happens because R's syntax for named vector creation using `c()` doesn't allow the name part to be a function call or dynamic expression.

## Incorrect Approach

The following pattern will cause errors:

```r
# This doesn't work - trying to use paste0 to create a dynamic name
choices = c(paste0("-- No customers for platform ", platform_id, " --") = "")
```

This fails because R's named vector syntax requires literal strings before the `=` sign, not function calls or expressions.

## Correct Approach

There are several correct approaches to create named vectors in R:

### 1. Using setNames()

```r
# Correct - using setNames to create a named vector
choices = setNames("", paste0("-- No customers for platform ", platform_id, " --"))
```

### 2. Using a named list constructor

```r
# Alternative correct approach - creating a named list
choices = list()
choices[paste0("-- No customers for platform ", platform_id, " --")] = ""
```

### 3. Pre-computing the name

```r
# Pre-compute the name string
name_string <- paste0("-- No customers for platform ", platform_id, " --")
choices = c()
choices[name_string] <- ""
```

### 4. For selectInput/updateSelectizeInput specifically

```r
# Create name-value pairs for select inputs
name <- paste0("-- No customers for platform ", platform_id, " --")
value <- ""
choices <- structure(list(value), names = name)
```

## Prevention

To prevent this issue, follow these guidelines:

1. Always use `setNames()` when creating named vectors with dynamic names
2. Alternatively, create empty lists/vectors first and assign named elements
3. For Shiny select inputs, test your choices construction independently
4. Remember that R's `c(name = value)` syntax requires literal names, not expressions

## Related Principles

- P76: Error Handling Patterns
- R71: Enhanced Input Components
- R106: Selectize Input Usage

## Examples

Here's a complete example handling multiple cases:

```r
createPlatformChoices <- function(platform_id = NULL, empty_result = FALSE) {
  if (is.null(platform_id)) {
    # Default case - all platforms
    return(c("All Platforms" = 0, 
             "Amazon" = 1, 
             "Shopify" = 2, 
             "Official Website" = 3))
  } else if (empty_result) {
    # No results found case
    return(setNames("", paste0("-- No customers for platform ", platform_id, " --")))
  } else {
    # Single platform selected - highlight it at the top
    platforms <- c("All Platforms" = 0, 
                  "Amazon" = 1, 
                  "Shopify" = 2, 
                  "Official Website" = 3)
    
    # Move selected platform to top for visibility
    platform_name <- names(platforms)[platforms == platform_id]
    result <- c()
    result[platform_name] <- platform_id
    result["All Platforms"] <- 0
    
    return(result)
  }
}
```

Using this function in a Shiny app:

```r
# In server function
observe({
  platform_id <- as.integer(input$platform)
  
  if (no_results_found) {
    updateSelectizeInput(
      session = session,
      inputId = "customer_filter",
      choices = createPlatformChoices(platform_id, empty_result = TRUE)
    )
  } else {
    # Normal update with regular choices
  }
})
```