# SLN07: Shiny Selectize Input Naming Solution

## Statement

When updating selectize inputs with dynamic choices, always use non-empty string labels as named values to avoid "attempt to use zero-length variable name" errors in Shiny applications.

## Description

This solution pattern addresses a common Shiny error: "attempt to use zero-length variable name" that occurs when updating selectizeInput with choices that include an empty string as a named parameter. This often happens when attempting to add a blank/empty default option to a dropdown menu.

## Problem Context

Developers often include a blank default option in dropdown menus using code like `c("" = "", ...)` to provide an empty first choice, which can lead to a parsing error in Shiny's reactive context:

```r
# INCORRECT: Using empty string as name causes "attempt to use zero-length variable name" error
updateSelectizeInput(session, "customer_filter", 
                    choices = c("" = "", choice_list), 
                    server = TRUE)
```

## Solution

Always use a descriptive text label for the default/empty option rather than an empty string:

```r
# CORRECT: Use descriptive text for the empty/placeholder option
updateSelectizeInput(session, "customer_filter", 
                    choices = c("Select a customer..." = "", choice_list), 
                    server = TRUE)
```

## Implementation Pattern

### Pattern 1: Default Option with Descriptive Label

```r
# For dropdown with optional selection:
updateSelectizeInput(session, "filter_field", 
                     choices = c("All options" = "", actual_choices),
                     selected = "")

# For required selection with clear instruction:
updateSelectizeInput(session, "customer_id", 
                     choices = c("Please select..." = "", customer_choices),
                     selected = "")
```

### Pattern 2: Use Placeholder Instead of Default Option

When the selectize input has `options = list(placeholder = "text")`, you can often avoid adding an empty default option entirely:

```r
# BETTER: Use selectize placeholder feature instead of empty default option
updateSelectizeInput(session, "customer_filter", 
                     choices = choice_list,
                     options = list(placeholder = "Select a customer..."))
```

### Pattern 3: Create Options with Informative Messages

For cases where no valid choices exist:

```r
# When no data is available:
if (length(customer_data) == 0) {
  updateSelectizeInput(session, "customer_filter",
                      choices = c("No customers available" = ""),
                      selected = "")
  return()
}
```

## Examples

### Complete Implementation Example

```r
# UI definition
selectizeInput("region_filter", "Select Region:",
               choices = NULL,  # will be populated server-side
               options = list(
                 placeholder = "Type to search regions...",
                 maxOptions = 50
               ))

# Server-side update
observeEvent(input$country, {
  # Get regions based on country selection
  regions <- get_regions(input$country)
  
  if (length(regions) == 0) {
    # No regions available
    updateSelectizeInput(session, "region_filter",
                         choices = c("No regions available for this country" = ""))
  } else {
    # Create named vector for choices
    region_choices <- setNames(regions$code, regions$name)
    
    # Update with descriptive placeholder option
    updateSelectizeInput(session, "region_filter",
                         choices = c("Select a region..." = "", region_choices))
  }
})
```

### Enhanced Customer Filter Example

```r
# In microCustomerServer function:
observeEvent(df_prof(), {
  prof <- df_prof()
  ids  <- valid_ids()
  
  # Handle case with no valid customer choices
  if (length(ids) == 0 || nrow(prof) == 0) {
    updateSelectizeInput(session, "customer_filter", 
                         choices = c("No customers available" = ""),
                         selected = "")
    return()
  }
  
  # Create customer choices
  choices <- prof %>%
    dplyr::filter(customer_id %in% ids) %>%
    dplyr::slice_head(n = 100) %>%
    dplyr::mutate(label = paste0(buyer_name, " (", email, ")")) %>%
    dplyr::select(customer_id, label)
  
  choice_list <- setNames(as.character(choices[["customer_id"]]), choices[["label"]])
  
  # CORRECT: Use descriptive text for placeholder option
  updateSelectizeInput(session, "customer_filter", 
                       choices = c("Select a customer..." = "", choice_list), 
                       server = TRUE)
})
```

## Related Principles and Rules

- P076: Error Handling Patterns
- P081: Tidyverse-Shiny Terminology Alignment
- R088: Shiny Module ID Handling
- SLN04: Shiny Namespace Collision
- SLN05: Shiny Nested UI Rendering