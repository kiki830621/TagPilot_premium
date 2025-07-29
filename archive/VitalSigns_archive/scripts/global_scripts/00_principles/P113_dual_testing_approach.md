---
id: "P0113"
title: "Dual Testing Approach"
type: "principle"
date_created: "2025-04-16"
date_modified: "2025-04-16"
author: "Claude"
derives_from:
  - "P0016": "Component-wise Testing"
  - "P0009": "Authentic Context Testing"
influences:
  - "P0077": "Performance Optimization"
  - "R0099": "Test App Building"
---

# Dual Testing Approach Principle

## Core Principle

**Shiny components and modules shall be tested using a dual approach: (1) a functional test with controlled synthetic data to verify individual features and edge cases, and (2) a production-like test with actual data connections to validate real-world behavior and performance.**

## Rationale

Single-approach testing often fails to provide complete validation:

1. **Functional tests alone** validate isolated features but may miss integration and performance issues
2. **Production-like tests alone** validate real behavior but make edge case testing and debugging difficult

The dual approach ensures:

1. Comprehensive validation of both individual features and integration aspects
2. Clear identification of feature failures vs. integration/data issues
3. Better coverage of edge cases while still confirming real-world behavior
4. Performance validation under realistic data conditions
5. More efficient debugging through separation of concerns

## Implementation Guidelines

### 1. Functional Test Implementation

Functional tests focus on feature validation with controlled data:

1. **Isolated Environment**:
   - Standalone file in component's directory (e.g., `componentName_test.R`)
   - Mock data generator for all required test scenarios
   - Direct component instantiation without data connections
   - Tests specific UI and server features in isolation

2. **Test Matrix Coverage**:
   - Normal operation with standard data
   - Edge cases (empty data, invalid formats, extreme values)
   - Error handling scenarios
   - UI responsiveness verification
   - Feature-specific boundary conditions

3. **Implementation Structure**:
   ```r
   # componentName_test.R
   
   # Required libraries
   library(shiny)
   library(plotly) # Component-specific dependencies
   
   # Source component
   source("path/to/componentName.R")
   
   # Mock data generator with scenario control
   create_mock_data <- function(scenario = "normal") {
     switch(scenario,
       "normal" = data.frame(...),
       "empty" = data.frame(),
       "extreme" = data.frame(...),
       # Additional scenarios
     )
   }
   
   # Test UI
   ui <- fluidPage(
     sidebarLayout(
       sidebarPanel(
         selectInput("scenario", "Test Scenario",
           choices = c("Normal", "Empty", "Extreme")
         )
       ),
       mainPanel(
         componentNameUI("test")
       )
     )
   )
   
   # Test server
   server <- function(input, output, session) {
     # Generate data based on selected scenario
     test_data <- reactive({
       create_mock_data(input$scenario)
     })
     
     # Initialize component with controlled data
     componentNameServer("test", data = test_data)
   }
   
   # Run test app
   shinyApp(ui, server)
   ```

### 2. Production-like Test Implementation

Production-like tests validate real-world behavior:

1. **Authentic Environment**:
   - Uses actual initialization scripts and database connections
   - Proper error handling and recovery with real data
   - Interfaces with related components (limited scope)
   - Tests integration behaviors with core dependencies

2. **Implementation Structure**:
   ```r
   # componentName_production_test.R
   
   # Initialize in actual app mode
   source("update_scripts/global_scripts/00_principles/sc_initialization_app_mode.R")
   
   # Required libraries - use actual initialization sequence
   library(shiny)
   library(bs4Dash)
   
   # Source the component file
   source("update_scripts/global_scripts/path/to/componentName.R")
   
   # Create minimal app with actual data connections
   ui <- bs4DashPage(
     header = bs4DashNavbar(title = "Production Test"),
     sidebar = bs4DashSidebar(
       bs4SidebarMenu(
         bs4SidebarMenuItem("Component Test", tabName = "test")
       )
     ),
     body = bs4DashBody(
       bs4TabItems(
         bs4TabItem(
           tabName = "test",
           fluidRow(
             column(width = 12, 
               box(width = NULL, title = "Test Environment",
                 componentNameUI("test")
               )
             )
           )
         )
       )
     )
   )
   
   server <- function(input, output, session) {
     # Use actual database connections
     db_conn <- dbConnect_from_list("main_db", path_list = db_path_list)
     
     # Initialize component with real data connection
     componentNameServer(
       id = "test",
       app_data_connection = db_conn,
       config = list(platform_id = 1)
     )
     
     # Close connection when session ends
     session$onSessionEnded(function() {
       dbDisconnect(db_conn)
     })
   }
   
   shinyApp(ui, server)
   ```

### 3. Testing Sequence

Follow this testing sequence to optimize development:

1. **Develop with Functional Test**:
   - Build core features with synthetic data
   - Validate edge cases and error handling
   - Ensure clean UI behavior in controlled environment
   - Fix isolated component issues

2. **Validate with Production Test**:
   - Test with real data and connections
   - Validate performance with actual data volume
   - Identify integration issues
   - Ensure compatibility with authentication/permissions

3. **Regression Testing**:
   - Run both test types after significant changes
   - Ensure changes pass both isolated and integrated testing
   - Document specific test scenarios for future validation

### 4. Documentation Requirements

Document test approach for each component:

1. **Test Configuration Documentation**:
   - List of test scenarios covered in functional test
   - Data requirements for production-like test
   - Known edge cases and their expected handling
   - Performance expectations under normal load

2. **Test Execution Instructions**:
   - Clear steps to run each test type
   - Required permissions/credentials for production test
   - Expected behavior patterns and failure indicators

3. **Test Result Integration**:
   - How test results affect component development
   - Criteria for passing both test types
   - Resolution approach for conflicts between test results

## Relationship to Existing Principles

This principle:

1. **Enhances P0016 (Component-wise Testing)** by adding real-world validation
2. **Complements P0009 (Authentic Context Testing)** by adding isolated feature validation
3. **Supports P0077 (Performance Optimization)** by enabling realistic performance testing
4. **Extends R0099 (Test App Building)** with specific dual-approach methodology

## Implementation Examples

### Example 1: microDNADistribution Component

```r
# Functional Test (microDNADistribution_test.R)
# - Tests all visualizations with mock data
# - Validates UI reactions to different data scenarios
# - Ensures correct statistics calculation
# - Tests empty/extreme data handling

# Production Test (microDNADistribution_production_test.R)
# - Connects to real df_dna_by_customer data
# - Tests platform filtering with actual IDs
# - Validates performance with large datasets
# - Ensures proper integration with filter components
```

### Example 2: Data Upload Component

```r
# Functional Test (dataUpload_test.R)
# - Tests file upload UI with synthetic files
# - Validates all format validation checks
# - Tests error messages for invalid files
# - Validates progress indicators

# Production Test (dataUpload_production_test.R)
# - Tests with actual permission system
# - Validates storage to real database
# - Tests file size handling with real files
# - Verifies notification system integration
```

## Benefits

The dual testing approach provides:

1. **Faster Development Cycles** - isolated testing speeds initial development
2. **More Thorough Validation** - tests both features and integration aspects
3. **Better Problem Isolation** - clearly identifies feature vs. integration issues
4. **Performance Assurance** - validates behavior with realistic data volumes
5. **Higher Quality Components** - ensures components work in both idealized and real conditions

## Conclusion

By implementing the Dual Testing Approach Principle, we create more robust components that function correctly both in isolation and within the full application context. This approach reduces integration issues, ensures feature completeness, and provides better performance validation than either approach alone.