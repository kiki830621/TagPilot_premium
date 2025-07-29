# Principle 17: Config-Driven Customization

## Core Principle
In application mode, all company-specific content, options, and behavior must be derived from `app_config` or initialization parameters, never hardcoded in the application code. Any element that varies by company must be configurable without code modification.

## Rationale
This principle ensures:

1. **Reusability**: Application code can be used across different companies without modification
2. **Maintainability**: Changes to company-specific elements are made in configuration, not code
3. **Separation of Concerns**: Code handles logic while configuration provides context-specific parameters
4. **Scalability**: New companies can be onboarded without code changes
5. **Testability**: Easier to test with different configuration scenarios

## Implementation Guidelines

### Configuration Sources Hierarchy
Company-specific content should be sourced from (in order of precedence):
1. `app_config` loaded during initialization
2. Database tables with company-specific parameters
3. User preferences stored in the application state
4. Environment variables (only for API keys, credentials, etc.)

### What Must Be Configurable
1. **UI Elements**:
   - Company name, logo, colors
   - Available options in dropdowns, radio buttons, etc.
   - Menu items and navigation structure
   - Labels and text content

2. **Business Logic**:
   - Company-specific calculation rules
   - Validation rules and thresholds
   - Default values and presets
   - Feature availability flags

### Implementation Pattern
Always follow this pattern for company-specific content:

```r
# INCORRECT - Hardcoded company-specific options
choices <- list(
  "Amazon" = "amazon",
  "Official Website" = "officialwebsite"
)

# CORRECT - Derived from app_config
choices <- config$company$marketing_channels
if (is.null(choices) || length(choices) == 0) {
  # Fallback to defaults if not configured
  choices <- list("Default Channel" = "default")
}
```

## Practical Examples

### UI Components Example
```r
# Create marketing channel options from app_config
sidebar_items[[1]] <- div(
  class = "marketing-channel-section",
  style = "margin-bottom: 15px;",
  h2(
    class = "sidebar-section-title",
    translate("Marketing Channel")
  ),
  shinyWidgets::prettyRadioButtons(
    inputId = ns("distribution_channel"),
    label = NULL,
    # Use config-driven choices instead of hardcoded values
    choices = if (!is.null(config$company$marketing_channels)) {
      config$company$marketing_channels
    } else {
      # Fallback only if configuration is missing
      list("Default Channel" = "default")
    },
    selected = if (!is.null(config$company$default_channel)) {
      config$company$default_channel
    } else {
      names(config$company$marketing_channels)[1]
    },
    status = "primary",
    animation = "smooth"
  )
)
```

### Business Logic Example
```r
# Use company-specific calculation rules from config
calculate_discount <- function(order_value) {
  # Use company-specific discount thresholds and rates
  thresholds <- config$company$discount_thresholds
  rates <- config$company$discount_rates
  
  # Find applicable discount rate
  applicable_rate <- 0
  for (i in seq_along(thresholds)) {
    if (order_value >= thresholds[i]) {
      applicable_rate <- rates[i]
    }
  }
  
  return(order_value * applicable_rate)
}
```

## Exception Handling
If a required configuration element is missing:
1. Log a warning about the missing configuration
2. Fall back to sensible defaults that are clearly marked as such
3. Continue application operation if possible
4. Provide clear documentation about the required configuration structure

## Related Principles
- P02 (Data Integrity)
- P12 (app_r_is_global)
- MP17 (Separation of Concerns)
- R04 (App YAML Configuration)