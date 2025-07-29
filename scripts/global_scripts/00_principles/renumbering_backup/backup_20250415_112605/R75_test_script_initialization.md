# R75: Test Script Initialization Rule

## Purpose

This rule establishes standardized patterns for initializing test scripts, ensuring proper working directory setup, consistent dependency loading, correct source file inclusion, and flexible execution modes.

## Implementation

### 1. Demo Mode Flag

All test scripts MUST include a DEMO_MODE flag at the top of the file to allow easy switching between testing and interactive demonstration:

```r
# Set to TRUE to skip tests and just launch the app
DEMO_MODE <- TRUE  # Change to FALSE to run tests
```

The run_tests() function MUST check this flag and behave accordingly:

```r
run_tests <- function() {
  # Check if in demo mode
  if (DEMO_MODE) {
    message("Running in DEMO_MODE - launching app without tests")
    create_test_app(test_data)
    return()
  }
  
  # Run tests when not in demo mode
  # ...test code here...
}
```

### 2. Working Directory Management

All test scripts MUST include proper working directory management using the standard path detection patterns:

```r
# Initialize proper working directory (ROOT_DIR)
if (!exists("script_triggered_from_app_mode") || !script_triggered_from_app_mode) {
  # Get the project root path dynamically based on directory structure
  source_find_root <- function(start_path = getwd()) {
    current_path <- normalizePath(start_path, winslash = "/")
    while (!file.exists(file.path(current_path, "app.R"))) {
      parent_path <- dirname(current_path)
      if (parent_path == current_path) {
        stop("Cannot find project root directory containing app.R")
      }
      current_path <- parent_path
    }
    return(current_path)
  }
  
  # Set the correct working directory
  root_path <- source_find_root()
  setwd(root_path)
  
  # Source initialization script to set up proper environment
  source(file.path("update_scripts", "global_scripts", "00_principles", 
                   "sc_initialization_app_mode.R"))
}
```

### 3. Test Script Initialization Sequence

Test scripts MUST follow this initialization sequence:

1. **Demo Mode Flag**: Set DEMO_MODE flag at the top of the file
2. **Environment Setup**: Set working directory to ROOT_DIR
3. **Mode Initialization**: Source app mode initialization script
4. **Required Libraries**: Load testing libraries
5. **Module Under Test**: Source the module being tested
6. **Test Utilities**: Load test helpers and utilities
7. **Test Data**: Define or load test data
8. **Test Functions**: Define test and utility functions
9. **Test Execution**: Run the tests with DEMO_MODE check

```r
# Set to TRUE to skip tests and just launch the app
DEMO_MODE <- TRUE

# 1. Environment Setup
# (Root directory setup code from above)

# 2. Mode Initialization
source(file.path("update_scripts", "global_scripts", "00_principles", 
                 "sc_initialization_app_mode.R"))

# 3. Required Libraries
library(shiny)
library(testthat)
library(bs4Dash)  # If needed for module UI

# 4. Module Under Test
source(file.path("update_scripts", "global_scripts", "10_rshinyapp_components",
                 "micro", "microCustomer", "microCustomer.R"))

# 5. Test Utilities
source(file.path("update_scripts", "global_scripts", "04_utils",
                 "00_test_utils", "shiny_test_helpers.R"))

# 6. Test Data
test_data <- create_standardized_test_data()

# 7. Test Functions
create_test_app <- function(test_data) {
  # Create interactive test app
}

# 8. Test Execution with DEMO_MODE check
run_tests <- function() {
  # Check for demo mode
  if (DEMO_MODE) {
    message("Running in DEMO_MODE - launching app without tests")
    create_test_app(test_data)
    return()
  }
  
  # Run tests otherwise
  test_that("Module works correctly", {
    # Test code here
  })
}

# 9. Run tests
run_tests()
```

### 3. Test Module Sourcing

Modules being tested MUST be sourced using relative paths from the ROOT_DIR, not absolute paths:

```r
# CORRECT: Source using relative path from root
source(file.path("update_scripts", "global_scripts", "component_path", "component.R"))

# INCORRECT: Source using working directory relative path
source("component.R")  # Will fail if cwd isn't in the component directory

# INCORRECT: Source using hard-coded absolute path
source("/Users/developer/project/component.R")  # Will fail on other machines
```

### 4. Standard Testing Pattern Structure

Test scripts MUST implement a standardized structure:

```r
#' @title Component Test Script
#' @description Tests for the component following R74 and R75
#' @file component_test.R

# Initialization blocks (following the sequence above)

#' Test data creation function
#' @return Standardized test data following R74
create_test_data <- function() {
  # Implementation according to R74
}

#' Component validation tests
#' @param test_data The test data to use
run_validation_tests <- function(test_data) {
  test_that("Component handles complete data", {
    # Test with complete data
  })
  
  test_that("Component handles incomplete data", {
    # Test with incomplete data
  })
  
  test_that("Component handles empty data", {
    # Test with empty data
  })
}

#' Interactive test app for manual testing
#' @param test_data The test data to use
create_test_app <- function(test_data) {
  # Create interactive test app
  ui <- fluidPage(...)
  server <- function(input, output, session) {...}
  shinyApp(ui, server)
}

# Execute the tests
test_data <- create_test_data()
run_validation_tests(test_data)

# Only run interactive test app when requested
if (interactive() && !exists("skip_interactive") && !isTRUE(getOption("test.mode"))) {
  create_test_app(test_data)
}
```

## Test Script Naming Convention

Test scripts MUST follow this naming convention:

- **Component Tests**: `{component_name}_test.R`
- **Unit Tests**: `test_{function_name}.R`
- **Integration Tests**: `integration_test_{feature_name}.R`

## Standard Testing Blocks

### 1. Automatic Working Directory Detection Block

```r
# Standard working directory detection block
source_find_root <- function(start_path = getwd()) {
  current_path <- normalizePath(start_path, winslash = "/")
  while (!file.exists(file.path(current_path, "app.R"))) {
    parent_path <- dirname(current_path)
    if (parent_path == current_path) {
      stop("Cannot find project root directory containing app.R")
    }
    current_path <- parent_path
  }
  return(current_path)
}

# Do not initialize if already in app mode
if (!exists("script_triggered_from_app_mode") || !script_triggered_from_app_mode) {
  root_path <- source_find_root()
  setwd(root_path)
  source(file.path("update_scripts", "global_scripts", "00_principles", 
                   "sc_initialization_app_mode.R"))
}
```

### 2. Standard Test App Block

```r
# Standard test app creation function
create_standard_test_app <- function(module_ui_fn, module_server_fn, test_data, id = "test_module") {
  ui <- fluidPage(
    title = "Module Test",
    
    # Test controls
    fluidRow(
      column(12,
             h3("Test Controls"),
             selectInput("test_scenario", "Test Scenario:", 
                        choices = names(test_data$scenarios),
                        selected = names(test_data$scenarios)[1])
      )
    ),
    
    # Module under test
    fluidRow(
      column(12,
             h3("Module Test Results"),
             module_ui_fn(id)
      )
    ),
    
    # Debug information
    fluidRow(
      column(12,
             h3("Debug Information"),
             verbatimTextOutput("debug_info")
      )
    )
  )
  
  server <- function(input, output, session) {
    # Select current test data based on scenario
    current_data <- reactive({
      scenario <- input$test_scenario
      test_data$scenarios[[scenario]]
    })
    
    # Call the module server function
    module_result <- module_server_fn(id, current_data())
    
    # Display debug information
    output$debug_info <- renderPrint({
      list(
        test_scenario = input$test_scenario,
        data_summary = summarize_test_data(current_data()),
        module_result = if(is.reactive(module_result)) module_result() else module_result
      )
    })
  }
  
  # Launch the app with specific options for reliable browser opening
  shinyApp(ui, server, options = list(
    launch.browser = TRUE,  # Force browser launch
    port = 8765,            # Use a specific port
    host = "127.0.0.1"      # Listen on localhost only
  ))
}
```

## Relationship to Other Rules

### 1. Implements:
- **MP51 (Test Data Design)**: Ensures proper test data integration
- **R74 (Shiny Test Data)**: Complements test data rules with initialization rules

### 2. Depends on:
- **R37 (Dynamic Root Path Detection)**: Uses similar pattern for finding root path
- **R45 (Initialization Imports Only)**: Ensures initialization scripts are properly loaded

## Validation Checklist

To validate a test script against this rule, verify that:

1. The script properly initializes the ROOT_DIR working directory
2. Initialization sequence follows the standard pattern
3. All module sourcing uses relative paths from ROOT_DIR
4. The test script follows the standard structure
5. The naming convention is properly followed
6. The script distinguishes between automated and interactive tests

## Examples

### Example 1: Component Test Script

```r
# component_test.R
# Tests for Component following R74 and R75

# 1. Environment Setup
source_find_root <- function(start_path = getwd()) {
  current_path <- normalizePath(start_path, winslash = "/")
  while (!file.exists(file.path(current_path, "app.R"))) {
    parent_path <- dirname(current_path)
    if (parent_path == current_path) {
      stop("Cannot find project root directory containing app.R")
    }
    current_path <- parent_path
  }
  return(current_path)
}

if (!exists("script_triggered_from_app_mode") || !script_triggered_from_app_mode) {
  root_path <- source_find_root()
  setwd(root_path)
  
  # 2. Mode Initialization
  source(file.path("update_scripts", "global_scripts", "00_principles", 
                   "sc_initialization_app_mode.R"))
}

# 3. Required Libraries
library(shiny)
library(testthat)

# 4. Module Under Test
source(file.path("update_scripts", "global_scripts", "10_rshinyapp_components",
                 "component_path", "component.R"))

# 5-7: Test data, utilities, and execution
# ... Rest of the test script
```

### Example 2: Minimal Test Script

```r
# minimal_test.R

# Combined initialization (for simpler scripts)
if (!exists("script_triggered_from_app_mode") || !script_triggered_from_app_mode) {
  source_find_root <- function(start_path = getwd()) {
    current_path <- normalizePath(start_path, winslash = "/")
    while (!file.exists(file.path(current_path, "app.R"))) {
      parent_path <- dirname(current_path)
      if (parent_path == current_path) {
        stop("Cannot find project root directory containing app.R")
      }
      current_path <- parent_path
    }
    return(current_path)
  }
  
  root_path <- source_find_root()
  setwd(root_path)
  source(file.path("update_scripts", "global_scripts", "00_principles", 
                   "sc_initialization_app_mode.R"))
  
  # Load required libraries and source components
  library(shiny)
  library(testthat)
  source(file.path("update_scripts", "global_scripts", "component_path", "component.R"))
}

# Test execution
test_that("Function works correctly", {
  # Test implementation
})
```

## Launching Test Apps in Browser

When creating test applications that need to launch automatically in a browser, ensure they launch reliably in both interactive and non-interactive environments by following these guidelines:

### 1. Create a dedicated runner script

For test apps that should always launch in a browser, create a separate runner script:

```r
# run_demo.R - Dedicated script to launch the test app in browser
# Source the main test script to inherit its data and functions
source(paste0(dirname(sys.frame(1)$ofile), "/app_test.R"))

# Set browser launch option without custom browser function
# This avoids the infinite recursion problem
options(shiny.launch.browser = TRUE)

# Create and run the app (do NOT set both options and parameter)
message("Launching demo app...")
app <- create_test_app(test_data)
runApp(app, port = 8765) # Don't use launch.browser=TRUE here
```

### 2. Configure Shiny app options

When creating test apps, specify browser launch options directly:

```r
shinyApp(ui, server, options = list(
  launch.browser = TRUE,  # Force browser launch
  port = 8765,            # Use a specific port
  host = "127.0.0.1"      # Listen on localhost only
))
```

### 3. Set browser function

For environments that might not have a default browser set:

```r
# WARNING: Only use this if options(shiny.launch.browser = TRUE) is NOT set
# or you will create an infinite recursion!
options(browser = function(url) {
  message("Opening browser at: ", url)
  utils::browseURL(url)
})
```

## Implementation Timeline

This rule should be implemented immediately for all new test scripts and within 60 days for existing test scripts.