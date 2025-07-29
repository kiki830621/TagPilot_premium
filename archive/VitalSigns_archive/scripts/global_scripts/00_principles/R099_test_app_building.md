---
id: "R0099"
title: "Test App Building Principles"
type: "rule"
date_created: "2025-04-13"
date_modified: "2025-04-13"
author: "Claude"
derives_from:
  - "MP0051": "Test Data Design"
  - "MP0016": "Modularity"
  - "MP0017": "Separation of Concerns"
  - "R0074": "Shiny Test Data"
  - "R0075": "Test Script Initialization"
  - "R0076": "Module Data Connection Rule"
  - "R0091": "Universal Data Access Pattern"
  - "P0076": "Error Handling Patterns"
  - "P0077": "Performance Optimization"
influences:
  - "P0004": "App Construction Principles"
  - "P0016": "Component Testing"
---

# Test App Building Principles

## Core Rule

Test applications for Shiny components must be designed with a consistent, comprehensive approach that tests both unit functionality and integration capabilities. Each test script should verify all component functions, support multiple data access patterns, and provide both automated validation and interactive testing modes.

## Implementation Guidelines

1. **Comprehensive Function Testing**: 
   - Each test script must validate all exported functions from the component being tested
   - Components must be tested as-is without reimplementation or manual rebuilding of functionality
   - All interface variants (UI, server, component factory) must be individually verified

2. **Universal Data Access Compatibility**:
   - Test scripts must validate the component against all supported connection types:
     - List-based connections (direct data access)
     - Function-based connections (get_* function patterns)
     - Mixed connections (combination of direct and functional access)
     - DBI database connections (real database when available)
     - Reactive expressions (Shiny-specific wrappers)

3. **Test Data Structure**:
   - Include multiple data scenarios to verify error handling and edge cases:
     - Complete data (ideal case with all fields)
     - Partial data (subset of records but complete fields)
     - Incomplete fields (missing some expected fields)
     - Alternative field names (testing field name mapping logic)
     - Empty datasets (zero rows but proper structure)
     - NULL data (complete absence of data)

4. **Dual-Mode Testing Approach**:
   - Automated Testing Mode: Run non-interactive unit tests with testthat
   - Interactive Demo Mode: Launch a Shiny app for visual verification and manual testing
   - Support conditional execution based on environment (DEMO_MODE, interactive(), etc.)

5. **Self-Contained Execution**:
   - Test scripts must work correctly regardless of working directory
   - Include project root detection logic that works across environments
   - Automatically source required dependencies with informative error handling
   - Check for and handle missing package dependencies gracefully

6. **Interactive Test App Structure**:
   - Provide controls for switching between connection types at runtime
   - Enable toggling between different test data scenarios
   - Include detailed debug information that can be shown/hidden
   - Implement real-time response to configuration changes

## Example Structure

A compliant test script should follow this general structure:

```r
# 1. Configuration & Environment Setup
DEMO_MODE <- TRUE/FALSE
find_project_root <- function() { ... }
project_root <- find_project_root()

# 2. Load Dependencies
suppressPackageStartupMessages({
  library(shiny)
  library(testthat)
  # Additional required packages
})

# 3. Source Component Files
source(file.path(project_root, "path/to/component.R"))

# 4. Test Data Generation
generate_test_data <- function() {
  # Create all test scenarios
  return(list(
    scenarios = list(
      complete = list(...),
      partial = list(...),
      incomplete_fields = list(...),
      alt_field_names = list(...),
      empty = list(...),
      null_data = list(...)
    )
  ))
}
test_data <- generate_test_data()

# 5. Connection Factory Functions
create_test_connection <- function(scenario_data, connection_type = "list") {
  # Create connections of different types using the same data
}

# 6. Unit Test Functions
test_component_functions <- function() {
  # Test each individual function in the component
}

# 7. Interactive Test App
create_test_app <- function() {
  # Create a Shiny app with type/scenario switchers
  ui <- fluidPage(...)
  server <- function(input, output, session) {...}
  shinyApp(ui, server)
}

# 8. Test Execution Logic
if (!DEMO_MODE) {
  # Run automated tests
} else {
  # Launch interactive test app
}
```

## Test App Requirements

The interactive test application must include:

1. **UI Controls**:
   - Connection type selector
   - Test scenario selector
   - Debug information toggle
   - Refresh/reset capability

2. **Visualization Areas**:
   - Component UI rendering space
   - Connection information display
   - Data state visualization
   - Error message display area

3. **Consistent Styling**:
   - Clear visual hierarchy with proper headings
   - Separation between control and display areas
   - Consistent color scheme and typography
   - Responsive layout for different screen sizes

## Practical Implementation

This test file structure should be used for all Shiny components, especially those that:

1. Implement the Universal Data Access Pattern (R0091)
2. Are designed for reuse across multiple applications
3. Handle complex user interactions or data operations
4. Need verification across multiple data scenarios

The test app should be stored alongside the component file, using the naming convention `[component_name]_test.R`.

## User Validation as Ultimate Success Criterion

While automated tests and technical metrics are valuable, the ultimate criterion for test app success is human validation:

1. **User-Centered Validation**: The final determination of whether a component functions properly must be made by a human user through interactive testing, not solely by automated checks.

2. **Visual Inspection**: Components must be visually inspected for proper rendering, layout, and responsiveness.

3. **Interactive Validation**: All user interactions (clicks, inputs, selections) must be manually tested to ensure expected behavior.

4. **Cross-Connection Testing**: Users should verify component functionality across all connection types, with particular attention to the most common use cases in production.

5. **Error State Validation**: Users must evaluate how gracefully the component handles error states, missing data, and edge cases.

6. **Acceptance Criteria**: A component is considered successfully tested only when a human user has verified its behavior in the target environment with typical usage patterns.

This human validation step is non-negotiable regardless of automated test coverage and serves as the final sign-off prior to component integration.

## Related Rules

- **R0074** (Shiny Test Data): Defines standards for creating test data for Shiny components
- **R0075** (Test Script Initialization): Specifies how test scripts should initialize their environment
- **R0076** (Module Data Connection Rule): Defines how modules should connect to data sources
- **R0091** (Universal Data Access Pattern): Defines the pattern for accessing data from multiple source types
- **MP0051** (Test Data Design): Meta-principle for designing effective test data
