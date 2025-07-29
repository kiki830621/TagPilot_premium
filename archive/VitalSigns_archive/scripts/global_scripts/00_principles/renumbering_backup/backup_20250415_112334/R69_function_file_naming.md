# R69: Function File Naming Rule

## Purpose
This rule establishes a consistent naming convention for function files, clarifying when and how to use the "fn_" prefix in filenames, while ensuring clear distinction between function file names and function object names.

## Implementation

### 1. Function File Naming Pattern

All files containing function definitions must follow this naming pattern:
```
fn_[function_name].R
```

Where:
- `fn_` is a required prefix for the file name
- `[function_name]` follows the object naming convention from R19, with dots replaced by underscores per R23
- `.R` is the file extension for R scripts

### 2. Function Object Naming Pattern

Within function files, the function object itself must be named according to R19 Object Naming Convention without the "fn_" prefix:
```r
# File: fn_calculate_revenue.R
calculate_revenue <- function(sales_data, date_range) {
  # Function implementation
}
```

### 3. One Function One File

Following R21 (One Function One File), each function file should contain exactly one primary function, with the file named after that function:

```r
# File: fn_process_customer_data.R
process_customer_data <- function(customer_id) {
  # Primary function implementation
  
  # Helper functions may be included if they are only used within this function
  validate_id <- function(id) {
    # Helper function implementation
  }
  
  # Function implementation using the helper
  validate_id(customer_id)
  # Rest of implementation
}
```

### 4. Function File Organization

Function files should be organized according to their purpose and domain:

1. **Utilities**: General-purpose functions should be placed in the `04_utils` directory
2. **Module-specific**: Functions specific to a module should be placed in the module's directory
3. **Domain-specific**: Functions specific to a domain should be placed in the domain's directory

## Valid Examples

### Example 1: Standard Utility Function

```
File path: update_scripts/global_scripts/04_utils/fn_clean_data.R

# Function implementation
clean_data <- function(data) {
  # Implementation
}
```

### Example 2: Module Function

```
File path: update_scripts/global_scripts/10_rshinyapp_components/micro/customer_profile/fn_format_customer_data.R

# Function implementation
format_customer_data <- function(customer_data) {
  # Implementation
}
```

### Example 3: Function with Type Prefix

```
File path: update_scripts/global_scripts/04_utils/fn_dt_transform_dates.R

# Function implementation
dt.transform_dates <- function(data, format = "%Y-%m-%d") {
  # Implementation
}
```

## Invalid Patterns

### Invalid Example 1: Missing File Prefix

```
# INCORRECT: Missing fn_ prefix in filename
File path: update_scripts/global_scripts/04_utils/clean_data.R

clean_data <- function(data) {
  # Implementation
}
```

### Invalid Example 2: Prefix in Function Name

```
# INCORRECT: fn_ prefix included in function name
File path: update_scripts/global_scripts/04_utils/fn_clean_data.R

fn_clean_data <- function(data) {  # Wrong - should be just "clean_data"
  # Implementation
}
```

### Invalid Example 3: Inconsistent Naming

```
# INCORRECT: Function name doesn't match filename
File path: update_scripts/global_scripts/04_utils/fn_clean_data.R

format_data <- function(data) {  # Wrong - should be "clean_data"
  # Implementation
}
```

## Relationship to Other Rules

### Implements and Extends

1. **R19 (Object Naming Convention)**: Extends naming conventions specifically for function files
2. **R21 (One Function One File)**: Complements by specifying naming for the individual function files
3. **R23 (Object File Name Translation)**: Provides specific rules for function file naming

### Related Rules

1. **R01 (File Naming Convention)**: Provides broader file naming guidance
2. **MP47 (Functional Programming)**: Supports functional programming by organizing functions consistently
3. **R67 (Functional Encapsulation)**: Enhances function encapsulation through clear file organization

## Verification Process

1. **File Naming Check**: Ensure all function files follow the `fn_*` naming pattern
2. **Function Name Check**: Verify function object names do not include the `fn_` prefix
3. **Consistency Check**: Confirm function object names match their file names (minus the prefix and with dots replaced by underscores)

## Benefits

1. **Clarity**: Clear distinction between function files and function objects
2. **Consistency**: Uniform naming across the codebase
3. **Navigability**: Makes code easier to navigate and discover
4. **Maintainability**: Simplifies maintenance and refactoring
5. **IDE Support**: Better supports IDE features like autocomplete and search

#LOCK FILE