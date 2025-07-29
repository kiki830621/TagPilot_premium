---
id: "R0009"
title: "Integrated Component Pattern Rule"
type: "rule"
date_created: "2025-04-02"
date_modified: "2025-04-16"
author: "Claude"
implements:
  - "P0004": "App Construction Principles"
  - "MP0017": "Separation of Concerns Principle"
derives_from:
  - "MP0016": "Modularity Principle"
  - "MP0018": "Don't Repeat Yourself Principle"
related_to:
  - "P0007": "App Bottom-Up Construction"
  - "R0004": "App YAML Configuration"
  - "R0012": "Package Consistency Naming Rule"
  - "P0113": "Dual Testing Approach Principle"
folderorg_implements:
  - "MP0016": "Modularity Principle"
  - "MP0017": "Separation of Concerns Principle" 
  - "MP0018": "Don't Repeat Yourself Principle"
  - "P0007": "App Bottom-Up Construction"
  - "MP0019": "Package Consistency Principle"
---

# Integrated Component Pattern Rule

## Core Requirement

Every Shiny component in the system must follow a structured implementation pattern with:

1. A main component file that integrates UI, server, and defaults in a single source file
2. Functional test files to verify component behavior with synthetic data
3. Production test files to validate component behavior with real data connections

This structure creates resilient, well-tested components with clean separation of concerns while maintaining practical file organization for development and maintenance.

## Implementation Requirements

### 1. File Structure and Organization

Components should be organized into dedicated folders with a specific file structure:

```
10_rshinyapp_components/[section]/[componentName]/
├── [componentName].R               # Main component file (UI, server, defaults)
├── [componentName]_test.R          # Functional test with synthetic data
├── [componentName]_production_test.R # Production test with real data connections
├── README.md                       # Component documentation
└── TEST.md                         # Test documentation
```

Where:
- **[section]**: Major app section (e.g., "micro", "macro", "target")
- **[componentName]**: Specific component name (e.g., "microCustomer", "microDNADistribution")

Example for a DNA distribution component in the micro section:
```
10_rshinyapp_components/micro/microDNADistribution/
├── microDNADistribution.R
├── microDNADistribution_test.R
├── microDNADistribution_production_test.R
├── README.md
└── TEST.md
```

This folder-based organization:
- Improves component encapsulation
- Makes relationships between component files explicit
- Reduces directory clutter
- Simplifies management of related files
- Enables comprehensive testing with both synthetic and real data
- Follows P0113: Dual Testing Approach Principle

### 2. Main Component File Requirements

The main component file (e.g., `microDNADistribution.R`) must include:

1. **Component Function**: A primary function that returns both UI and server functions
2. **UI Function**: A nested UI function that defines all visual elements
3. **Server Function**: A nested server function that provides all business logic
4. **Defaults**: Default values integrated within the server function

Example structure for the main component file:

```r
#' Component Name
#'
#' Component description and purpose
#'
#' @param id The module ID
#' @return A list containing UI and server functions
#' @export
componentName <- function(id) {
  ns <- NS(id)
  
  # Return the component parts
  list(
    # UI function (input edge node)
    ui = componentNameUI(ns),
    
    # Server function (internal component logic)
    server = componentNameServer
  )
}

#' Component UI Function
#'
#' @param ns The namespace function
#' @return The UI elements
componentNameUI <- function(ns) {
  # UI definition
  tagList(
    # UI elements...
  )
}

#' Component Server Function
#'
#' @param id The module ID
#' @param app_data_connection The data connection
#' @param config Configuration parameters (optional)
#' @param session The Shiny session object
#' @return A list of reactive values for testing/composition
componentNameServer <- function(id,
                               app_data_connection = NULL,
                               config = NULL,
                               session = getDefaultReactiveDomain()) {
  moduleServer(id, function(input, output, session) {
    # Component state reactive values
    
    # Default values (integrated within the server)
    default_values <- list(
      output1 = "Default value 1",
      output2 = "Default value 2"
    )
    
    # Process data with fallbacks to defaults
    
    # Return a list of reactive values for testing/composition
    list(
      # Return reactive values that can be used by parent components or tests
      reactive_value1 = reactive_value1,
      reactive_value2 = reactive_value2
    )
  })
}
```

### 3. Functional Test File Requirements

The functional test file (e.g., `microDNADistribution_test.R`) must:

1. **Be self-contained**: Include all necessary dependencies
2. **Use synthetic data**: Test with controlled mock data
3. **Test all features**: Verify all component functionality
4. **Validate outputs**: Assert output correctness
5. **Include UI testing**: Test UI elements behavior

Example structure for functional test:

```r
#' Functional Test for Component
#'
#' This file provides a self-contained test environment with synthetic data
#' to verify component functionality.

# Required libraries
library(shiny)
library(plotly)
library(dplyr)

# Source the component file
source("componentName.R")

# Create synthetic test data
test_data <- list(
  data_frame1 = data.frame(...),
  data_frame2 = data.frame(...)
)

# Create a test UI
ui <- fluidPage(
  h1("Component Test Environment"),
  
  # Add test controls and input options
  selectInput("test_option", "Test Option", choices = c("Option 1", "Option 2")),
  
  # Include the component UI
  componentName("test_component")$ui()
)

# Create a test server
server <- function(input, output, session) {
  # Initialize the component with synthetic data
  component_instance <- componentName("test_component")$server(
    id = "test_component",
    app_data_connection = test_data,
    config = list(
      parameter1 = "value1",
      parameter2 = "value2"
    )
  )
  
  # Add test observers to validate component behavior
  observe({
    # Validate component outputs
    output_value <- component_instance$reactive_value1()
    print(paste("Output value:", output_value))
  })
}

# Run the test app
shinyApp(ui, server)
```

### 4. Production Test File Requirements

The production test file (e.g., `microDNADistribution_production_test.R`) must:

1. **Connect to real data**: Use actual database connections
2. **Test in realistic context**: Simulate real-world usage
3. **Include error handling**: Test behavior with missing or bad data
4. **Monitor performance**: Measure data loading and processing time
5. **Provide diagnostic tools**: Include debugging tools for production issues

Example structure for production test:

```r
#' Production Test for Component
#'
#' This file provides a realistic test environment with actual data connections
#' to verify component behavior in production-like conditions.

# Required libraries
library(shiny)
library(bs4Dash)
library(DBI)
library(dplyr)

# Source the component file
source("componentName.R")

# Source database connection utilities
source("path/to/db_utils.R")

# Create a production-like UI with bs4Dash
ui <- bs4DashPage(
  header = bs4DashNavbar(
    title = "Production Test Environment"
  ),
  sidebar = bs4DashSidebar(
    bs4SidebarMenu(
      bs4SidebarMenuItem(
        text = "Component Test",
        tabName = "component_test",
        icon = icon("vial")
      ),
      bs4SidebarMenuItem(
        text = "Performance",
        tabName = "performance",
        icon = icon("gauge-high")
      )
    )
  ),
  body = bs4DashBody(
    bs4TabItems(
      bs4TabItem(
        tabName = "component_test",
        fluidRow(
          column(
            width = 12,
            bs4Card(
              title = "Component Under Test",
              width = 12,
              status = "primary",
              solidHeader = TRUE,
              # Insert component UI
              componentName("prod_component")$ui()
            )
          )
        )
      ),
      bs4TabItem(
        tabName = "performance",
        fluidRow(
          column(
            width = 12,
            bs4Card(
              title = "Performance Metrics",
              width = 12,
              status = "info",
              # Add performance metrics UI
              # ...
            )
          )
        )
      )
    )
  )
)

# Create a server with real data connections
server <- function(input, output, session) {
  # Connect to actual database
  db_connection <- tryCatch({
    connect_to_database()
  }, error = function(e) {
    showNotification(paste("Database connection error:", e$message), type = "error")
    return(NULL)
  })
  
  # Initialize the component with real data connection
  component_instance <- componentName("prod_component")$server(
    id = "prod_component",
    app_data_connection = db_connection,
    config = reactive({
      list(
        parameter1 = input$parameter1,
        parameter2 = input$parameter2
      )
    })
  )
  
  # Add monitoring and diagnostic tools
  # ...
  
  # Clean up when session ends
  session$onSessionEnded(function() {
    if (!is.null(db_connection)) {
      try(dbDisconnect(db_connection))
    }
  })
}

# Run the production test app
shinyApp(ui, server)
```

### 5. Documentation Requirements

#### README.md

Each component folder should include a README.md that provides:

1. **Component Purpose**: Clear explanation of what the component does
2. **Usage Instructions**: How to integrate and use the component
3. **Parameter Reference**: Detailed explanation of all parameters
4. **Data Requirements**: Expected data structure and formats
5. **Dependencies**: Required libraries and other components
6. **Example Code**: Basic usage examples

#### TEST.md

Each component folder should include a TEST.md that provides:

1. **Test Overview**: Description of test approach
2. **Functional Tests**: Details of synthetic data tests
3. **Production Tests**: Details of real-data tests
4. **Test Coverage**: What aspects are tested and how
5. **Test Data**: Description of test data structure

## Usage Patterns

### 1. Basic Usage Pattern

The standard pattern for using a component in an application:

```r
# In app.R or other component files:

# Include the component
source("path/to/componentName.R")

# In the UI
ui <- fluidPage(
  componentName("my_component")$ui()
)

# In the server
server <- function(input, output, session) {
  componentName("my_component")$server(
    id = "my_component",
    app_data_connection = my_data_connection,
    config = list(
      parameter1 = "value1",
      parameter2 = "value2"
    )
  )
}
```

### 2. Reactive Configuration Pattern

Using reactive configuration for dynamic component behavior:

```r
# In app.R or other component files:

# Create reactive configuration
component_config <- reactive({
  list(
    parameter1 = input$parameter1,
    parameter2 = input$parameter2
  )
})

# Initialize the component with reactive config
component_instance <- componentName("my_component")$server(
  id = "my_component",
  app_data_connection = my_data_connection,
  config = component_config  # Pass the reactive function directly
)
```

### 3. Component Composition Pattern

Composing multiple components together:

```r
# In app.R or other component files:

# Initialize parent component
parent_component <- parentComponent("parent")$server(
  id = "parent",
  app_data_connection = my_data_connection
)

# Initialize child component using parent's reactive output
child_component <- childComponent("child")$server(
  id = "child",
  app_data_connection = parent_component$processed_data,  # Use parent's reactive output
  config = list(...)
)
```

### 4. Namespacing Pattern

Following R110: Explicit Namespace in Shiny for improved maintainability:

```r
# In component UI function
ui <- shiny::tagList(
  bs4Dash::bs4Card(
    title = "Component Title",
    status = "primary",
    solidHeader = TRUE,
    width = 12,
    shiny::plotlyOutput(ns("plot"))
  )
)

# In server function
output$plot <- plotly::renderPlotly({
  plotly::plot_ly(data, x = ~x, y = ~y, type = "scatter", mode = "lines+markers")
})
```

## Template Examples

### Example 1: Complete Component with Main File, Tests, and Documentation

The microDNADistribution component demonstrates a complete implementation:

```
microDNADistribution/
├── microDNADistribution.R
├── microDNADistribution_test.R
├── microDNADistribution_production_test.R
├── README.md
└── TEST.md
```

#### Main Component File (microDNADistribution.R)

```r
#' Customer DNA Distribution Visualization Component
#'
#' Implements a visualization component for customer DNA distributions (M, R, F, IPT, NES)
#' following the Connected Component principle and using plotly for visualizations.
#' @param id The module ID
#' @return A list containing UI and server functions
#' @export
microDNADistribution <- function(id) {
  ns <- NS(id)
  
  # Return the component parts
  list(
    # UI function (input edge node)
    ui = microDNADistributionUI(ns),
    
    # Server function (internal component logic)
    server = microDNADistributionServer
  )
}

#' DNA Distribution UI function
#'
#' @param ns The namespace function
#' @return The UI elements
microDNADistributionUI <- function(ns) {
  tagList(
    fluidRow(
      column(
        width = 12,
        # UI elements...
      )
    )
  )
}

#' DNA Distribution Server function
#'
#' @param id The module ID
#' @param app_data_connection The data connection
#' @param config Configuration parameters (optional)
#' @param session The Shiny session object
#' @return A list of reactive values for testing/composition
microDNADistributionServer <- function(id,
                                     app_data_connection = NULL,
                                     config = NULL,
                                     session = getDefaultReactiveDomain()) {
  moduleServer(id, function(input, output, session) {
    # Component state management
    # ...
    
    # Data processing
    # ...
    
    # UI rendering
    # ...
    
    # Return reactive values
    list(
      df_dna_by_customer = df_dna_by_customer,
      component_status = component_status,
      # ...
    )
  })
}
```

#### Functional Test File (microDNADistribution_test.R)

```r
#' Functional Test for DNA Distribution Component
#'
#' This file provides a self-contained test environment with synthetic data
#' to verify the DNA distribution component functionality.

# Required libraries
library(shiny)
library(plotly)
library(dplyr)

# Source the component
source("microDNADistribution.R")

# Create synthetic test data
test_data <- list(
  df_dna_by_customer = data.frame(
    customer_id = 1:100,
    M = sample(100:10000, 100, replace = TRUE),
    R = sample(1:365, 100, replace = TRUE),
    F = sample(1:50, 100, replace = TRUE),
    IPT_mean = round(runif(100, 1, 100), 2),
    NES = sample(c("新客戶", "主力型", "重度型", "流失型"), 100, replace = TRUE),
    platform_id = sample(c(6, 7), 100, replace = TRUE)
  )
)

# Create a test UI
ui <- fluidPage(
  titlePanel("DNA Distribution Component Test"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("platform", "Platform", 
                  choices = c("All" = "", "Platform 6" = "6", "Platform 7" = "7"),
                  selected = ""),
      checkboxInput("use_precomputed", "Use Pre-computation", TRUE)
    ),
    
    mainPanel(
      microDNADistribution("test_component")$ui()
    )
  )
)

# Create a test server
server <- function(input, output, session) {
  # Create reactive configuration
  component_config <- reactive({
    list(
      platform_id = input$platform,
      use_precomputed = input$use_precomputed
    )
  })
  
  # Initialize the component
  component_data <- microDNADistribution("test_component")$server(
    id = "test_component",
    app_data_connection = test_data,
    config = component_config
  )
  
  # Add test observers to monitor component behavior
  observe({
    status <- component_data$component_status()
    cat("Component status:", status, "\n")
  })
}

# Run the test app
shinyApp(ui, server)
```

#### Production Test File (microDNADistribution_production_test.R)

```r
#' Production Test for DNA Distribution Component
#'
#' This file provides a realistic test environment with actual data connections
#' to verify component behavior in production-like conditions.

# Initialize the app environment with standard initialization
init_script_path <- file.path("update_scripts", "global_scripts", "00_principles", 
                           "sc_initialization_app_mode.R")
source(init_script_path)

# Required libraries
library(shiny)
library(bs4Dash)
library(plotly)
library(dplyr)

# Source the component file
component_path <- file.path("update_scripts", "global_scripts", "10_rshinyapp_components", 
                         "micro", "microDNADistribution", "microDNADistribution.R")
source(component_path)

# Source db utilities
db_utils_path <- file.path("update_scripts", "global_scripts", "02_db_utils", 
                        "fn_universal_data_accessor.R")
source(db_utils_path)

# Test configuration
test_config <- list(
  platforms = c("All" = "", "Platform 1" = "1", "Platform 2" = "2"),
  default_platform = "1",
  db_name = "app_data",
  title = "DNA Distribution Analysis - Production Test"
)

# Define the UI with bs4Dash
ui <- bs4Dash::bs4DashPage(
  title = test_config$title,
  header = bs4Dash::bs4DashNavbar(
    title = test_config$title,
    status = "primary",
    # Status indicators
    # ...
  ),
  sidebar = bs4Dash::bs4DashSidebar(
    bs4Dash::bs4SidebarMenu(
      id = "sidebar_menu",
      bs4Dash::bs4SidebarMenuItem(
        text = "DNA Distribution",
        tabName = "dna_distribution",
        icon = shiny::icon("dna")
      ),
      bs4Dash::bs4SidebarMenuItem(
        text = "Performance Metrics",
        tabName = "performance",
        icon = shiny::icon("chart-line")
      )
    ),
    # Filter controls
    # ...
  ),
  body = bs4Dash::bs4DashBody(
    shinyjs::useShinyjs(),
    bs4Dash::bs4TabItems(
      bs4Dash::bs4TabItem(
        tabName = "dna_distribution",
        shiny::fluidRow(
          shiny::column(
            width = 12,
            bs4Dash::bs4Card(
              title = "Customer DNA Distribution Analysis", 
              width = 12,
              status = "primary",
              solidHeader = TRUE,
              microDNADistribution("dna_distribution")$ui()
            )
          )
        )
      ),
      bs4Dash::bs4TabItem(
        tabName = "performance",
        # Performance metrics
        # ...
      )
    )
  ),
  controlbar = bs4Dash::bs4DashControlbar(
    # Control options
    # ...
  )
)

# Server logic
server <- function(input, output, session) {
  # Initialize timers and reactive values
  # ...
  
  # Get database connection
  db_connection <- connect_to_app_database()
  
  # Reactive configuration for the component
  component_config <- reactive({
    list(
      platform_id = if(input$platform == "") NULL else input$platform
    )
  })
  
  # Initialize the microDNADistribution component
  component <- microDNADistribution("dna_distribution")
  component_data <- component$server(
    "dna_distribution",
    app_data_connection = db_connection,
    config = component_config
  )
  
  # Monitor component status
  # ...
  
  # Performance metrics
  # ...
  
  # Clean up when session ends
  session$onSessionEnded(function() {
    if (!is.null(db_connection)) {
      try(dbDisconnect(db_connection))
    }
  })
}

# Run the production test app
shinyApp(ui, server)
```

## Benefits of the Integrated Component Pattern

### 1. Integrated Components with Clear Testing

This approach offers several benefits:

1. **Unified Component File**: Single source file for each component keeps related code together
2. **Comprehensive Testing**: Both functional and production tests ensure robust components
3. **Clear Documentation**: README.md and TEST.md provide complete documentation
4. **Real World Validation**: Production tests validate behavior with actual data
5. **Performance Assessment**: Production tests allow performance measurement
6. **Simplified Maintenance**: Clear structure makes updating components easier
7. **Better Developer Experience**: Integrated approach reduces context switching
8. **Enhanced Discoverability**: Standardized structure makes finding components and tests easier

### 2. Compliance with Dual Testing Approach (P0113)

This pattern implements the Dual Testing Approach Principle (P0113) by providing:

1. **Functional Tests**: Using synthetic data to verify component behavior in isolation
2. **Production Tests**: Using real data connections to validate real-world behavior

This dual approach ensures components work correctly both in controlled environments and under real-world conditions.

### 3. Practical Development Benefits

From a practical development perspective, this pattern provides:

1. **Faster Development**: Integrated approach reduces file switching
2. **Easier Debugging**: Direct relationship between component and test files
3. **Better Collaboration**: Clear structure helps team members understand components
4. **Simplified Deployment**: Well-tested components reduce production issues
5. **Improved Documentation**: Standardized documentation approach

## Relationship to Other Principles

This rule:

1. **Implements P0004 (App Construction Principles)**: Provides a specific implementation pattern for constructing app components
2. **Derives from MP0016 (Modularity Principle)**: Creates modular components with clear boundaries and independence
3. **Implements MP0017 (Separation of Concerns)**: Separates UI definition, logic, and default value management
4. **Applies MP0018 (Don't Repeat Yourself)**: Centralizes component implementation and ensures consistent behavior
5. **Supports P0007 (App Bottom-Up Construction)**: Enables testing components in isolation before integration
6. **Implements P0113 (Dual Testing Approach)**: Provides both functional and production tests
7. **Relates to R110 (Explicit Namespace in Shiny)**: Encourages proper namespacing in component implementation

## Conclusion

The Integrated Component Pattern Rule provides a comprehensive approach to developing, testing, and documenting Shiny components. By combining UI, server, and defaults in a single well-structured file, while adding comprehensive testing through both functional and production test files, this pattern ensures components are robust, thoroughly tested, and properly documented.

By following the template structure demonstrated in the microCustomer and microDNADistribution components, developers can create consistent, high-quality components that work reliably in both development and production environments.