# Principle 15: Initialization Assumption

## Core Principle
Every behavior, function, and operation within the system can and should assume that proper initialization has occurred before execution.

## Rationale
In a robustly designed system, initialization establishes the foundation for all operations. This principle creates a clean separation between initialization concerns and operational logic:

1. **Separation of Concerns**: Initialization logic remains isolated from operational logic
2. **Simplified Code**: Functions don't need to repeatedly verify initialization state
3. **Clearer Error Boundaries**: When errors occur, they are either initialization failures or operational failures
4. **Reduced Redundancy**: Removes the need for repeated environment checks
5. **Consistent State Guarantees**: All code operates with consistent guarantees about the environment

## Implementation Guidelines

### What Code Should Assume
- Appropriate mode (APP_MODE, UPDATE_MODE, GLOBAL_MODE) has been set
- All required libraries are loaded
- Path variables are properly configured
- Required utility functions are available
- Configuration parameters have been loaded

### What Code Should Not Assume
- Specific values of parameters (these should be explicitly passed or retrieved)
- The existence of specific data files (these should be checked)
- Network connectivity (should be verified when needed)
- Previous operational steps have been completed (should be validated)

## Practical Examples

### Correct Implementation
```r
# Function assumes initialization has occurred
calculate_customer_metrics <- function(customer_data) {
  # Just use functions made available during initialization
  result <- process_with_standard_metrics(customer_data)
  return(result)
}
```

### Incorrect Implementation
```r
# Function unnecessarily checks initialization state
calculate_customer_metrics <- function(customer_data) {
  # Don't do this - initialization should be assumed
  if (!exists("APP_MODE") && !exists("UPDATE_MODE")) {
    stop("System not properly initialized")
  }
  
  # Don't do this - library loading is part of initialization
  if (!require(dplyr)) {
    install.packages("dplyr")
    library(dplyr)
  }
  
  result <- process_with_standard_metrics(customer_data)
  return(result)
}
```

## Exception Handling
If a function genuinely requires verification that specific initialization has occurred:

1. Document this requirement clearly
2. Create a dedicated validation function
3. Call the validation function at the beginning of execution
4. Provide clear error messages that point to initialization requirements

## Related Principles
- MP31_initialization_first.md
- MP03_operating_modes.md
- MP04_mode_hierarchy.md
- R13_initialization_sourcing.md