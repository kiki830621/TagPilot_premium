# CLAUDE AI Guidelines

This document contains specific guidelines and reminders for Claude when working with this codebase. These are lessons learned from previous issues and are critical to maintain code quality.

## Critical Code Patterns

### 1. Function Parameter Specification (MP081) 

#### ⚠️ radioButtons Parameter Specification

**Problem**: A recurring issue has been found with `radioButtons()` parameters not being explicitly named, leading to bugs when positional parameters are misinterpreted.

**Solution**: ALWAYS use named parameters with radioButtons:

```r
# CORRECT - Named parameters (MP081)
radioButtons(
  inputId = "platform",
  label = NULL,
  choices = c("Amazon" = 2, "All Platforms" = 0),
  selected = 2
)

# INCORRECT - Positional parameters (AVOID)
radioButtons("platform", NULL, c("Amazon" = 2, "All Platforms" = 0), 2)
```

**Impacted files**:
- `/update_scripts/global_scripts/10_rshinyapp_components/micro/microDNADistribution/microDNADistribution_production_test.R`
- Other files with radioButtons UI components

#### Variable Name Consistency in Observers

**Problem**: When renaming variables in observers, not updating all instances has led to errors.

**Solution**: Ensure variable names are consistently updated throughout the observer - including both notification and logging sections:

```r
# Example of consistent variable naming
observeEvent(input$platform, {
  # Define mapping once
  platform_map <- c("0" = "All Platforms", "2" = "Amazon")
  
  # Get platform name
  platform_id <- as.character(input$platform)
  platform_name <- platform_map[platform_id]
  
  # Use the SAME variable in notification
  showNotification(paste("Switched to", platform_name))
  
  # Use the SAME variable in logging
  log_data <- data.frame(
    timestamp = Sys.time(),
    event = "platform_switch",
    details = platform_name,  # SAME variable as notification
    user_id = session$user
  )
})
```

### 2. Data Filtering with Missing Values (R116)

**Problem**: Errors with `if (!is.null(x) && !is.na(x) && x > 0)` when x contains NA values.

**Solution**: Always add NA checking before comparisons:

```r
# CORRECT - Complete validation
if (!is.null(x) && !is.na(x) && as.numeric(x) > 0) {
  # Safe to use x
}

# CORRECT - Use tryCatch for robust error handling
tryCatch({
  if (!is.null(x) && !is.na(x) && as.numeric(x) > 0) {
    # Safe code
  }
}, error = function(e) {
  warning("Error handling value: ", e$message)
  # Fallback behavior
})
```

### 3. Reactive Configuration Handling (R116)

**Problem**: Errors when accessing reactive configurations outside of reactive contexts.

**Solution**: Safely handle reactive configurations:

```r
# CORRECT - Safe reactive handling
platform_id <- reactive({
  tryCatch({
    # Safely handle reactive config
    if (is.null(config)) {
      return(NULL)
    } else if (is.function(config)) {
      if (shiny::is.reactivevalues(config) || 
          shiny::is.reactive(config) || 
          "reactive" %in% class(config)) {
        # Get reactive config safely
        local_config <- config()
      } else {
        # Handle non-reactive function
        local_config <- config()
      }
    } else {
      # Handle static config
      local_config <- config
    }
    
    # Extract value from config
    # ...
  }, error = function(e) {
    warning("Error extracting config: ", e$message)
    NULL
  })
})
```

## Principles to Remember

1. **MP081 - Explicit Parameter Specification**
   - Always specify function parameters by name
   - Particularly critical for UI components and functions with multiple parameters

2. **MP068 - Language as Index**
   - Use consistent variable naming throughout components
   - Update all instances when renaming variables

3. **R116 - Enhanced Data Access**
   - Add proper error handling for data access
   - Handle NULL and NA values explicitly
   - Use tryCatch for robust error handling

4. **MP035 - Null Special Treatment**
   - Always check for NULL before other operations
   - Handle NA values explicitly in comparisons

## File Reference

This guidance applies specifically to:

1. Component files:
   - `/update_scripts/global_scripts/10_rshinyapp_components/micro/microDNADistribution/microDNADistribution.R`
   - `/update_scripts/global_scripts/10_rshinyapp_components/micro/microDNADistribution/microDNADistribution_production_test.R`
   - `/update_scripts/global_scripts/10_rshinyapp_components/micro/microCustomer/microCustomer2.R`

2. Principles files:
   - `/update_scripts/global_scripts/00_principles/MP081_explicit_parameter_specification.md`
   - `/update_scripts/global_scripts/00_principles/R116_tbl2_enhanced_data_access.md`
   - `/update_scripts/global_scripts/00_principles/MP035_null_special_treatment.md`