# Initialization Files Should Only Import and Configure

## Overview

This principle establishes that initialization files should be limited to importing existing functionality and configuring environments, rather than defining new functions or business logic.

## Rule

**Initialization files must only import, configure, and set up the environment. All substantive functionality must be defined in dedicated module or utility files.**

## Rationale

Defining functions directly in initialization files creates several problems:

1. **Duplicate Functionality**: May override properly defined functions from utility files
2. **Versioning Conflicts**: Different initialization files might define conflicting versions
3. **Hidden Dependencies**: Makes it difficult to track where functionality is defined
4. **Testing Challenges**: Functions in initialization files are harder to unit test
5. **Confusion**: Creates ambiguity about which implementation is authoritative
6. **Maintenance Issues**: Requires maintaining the same logic in multiple places

## Implementation Guidelines

### Correct Initialization File Structure

Initialization files should only:

1. **Import Libraries**: Load required packages and dependencies
2. **Source Utility Files**: Import functions from dedicated utility files
3. **Set Environment Variables**: Configure runtime environment
4. **Initialize Resources**: Set up connections and resources
5. **Create Directories**: Ensure required directories exist

```r
# CORRECT: Initialization file that only imports and configures
# 000g_initialization_update_mode.R

# Load required packages
required_packages <- c("DBI", "dplyr", "tidyr", "readr")
for(pkg in required_packages) {
  if(!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
  library(pkg, character.only = TRUE)
}

# Get the db_utils directory
db_utils_dir <- file.path("update_scripts", "global_scripts", "02_db_utils")

# Source individual function files directly
fn_files <- c(
  "fn_dbConnect_from_list.R",
  "fn_dbDisconnect_all.R", 
  "fn_get_default_db_paths.R",
  "fn_set_db_paths.R"
)

# Source each function file
for(fn_file in fn_files) {
  fn_path <- file.path(db_utils_dir, fn_file)
  if(file.exists(fn_path)) {
    source(fn_path)
  }
}

# Source other utility modules
source(file.path("update_scripts", "global_scripts", "03_file_utils", "file_utils.R"))

# Set environment variables
OPERATION_MODE <- "UPDATE_MODE"

# Initialize resources
initialize_logging()

# Print initialization message
message("=== Update script initialized at ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " ===")
```

### Incorrect Initialization Practices

```r
# INCORRECT: Initialization file that defines functions
# 000g_initialization_update_mode.R

# Load required packages
required_packages <- c("DBI", "dplyr", "tidyr", "readr")
for(pkg in required_packages) {
  if(!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
  library(pkg, character.only = TRUE)
}

# WRONG: Defining functions in initialization file
dbConnect_from_list <- function(db_name) {
  # Function implementation...
}

# WRONG: Defining business logic in initialization file
process_data <- function(data) {
  # Function implementation...
}

# Print initialization message
message("=== Update script initialized at ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " ===")
```

## Function Definition Location

Functions should be defined in dedicated files:

1. **Utility Functions**: In appropriately named utility files
   - Example: dbConnect_from_list in db_utils.R
   
2. **Business Logic**: In module or sequence scripts
   - Example: calculate_customer_metrics in customer_metrics.R

3. **Helper Functions**: In related helper modules
   - Example: format_currency in formatting_helpers.R

## Import Approach

When needing functionality:

1. **Source First**: Always source the appropriate utility file
2. **Verify Function Exists**: Check that required functions are available
3. **Use Common Utilities**: Leverage centralized utility modules
4. **Document Dependencies**: Note which utilities are required

## Exception Process

Any exception to this principle requires:

1. **Documented Justification**: Clear explanation of why an exception is needed
2. **Fallback Mechanism**: Ensure the function checks for existing implementations first
3. **Warning Comment**: Prominent note that the implementation violates this principle
4. **Migration Plan**: Timeline for moving the function to an appropriate utility file

## Benefits

Following this principle ensures:

1. **Clear Dependency Hierarchy**: Utilities depend on libraries, not initialization
2. **Single Source of Truth**: Functions defined in only one authoritative location
3. **Testability**: Utility functions can be tested independently
4. **Maintainability**: Changes to functions need to be made in only one place
5. **Consistency**: Same implementation used regardless of initialization context

## Integration with Other Principles

This principle reinforces:

- **R21 One Function One File**: Functions should be defined in dedicated files
- **R43 Check Existing Functions**: Always check if a function exists before definition
- **MP02 Default Deny**: Don't create functionality unless explicitly needed
- **R07 Module Structure**: Follow established structure for organizing code