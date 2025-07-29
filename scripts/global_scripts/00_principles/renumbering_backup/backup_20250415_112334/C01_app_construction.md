# C01: App Construction Framework

## Overview
This concept document provides a comprehensive framework for constructing applications within the precision marketing ecosystem. It bridges multiple principles and rules to guide developers through the process of creating consistent, maintainable, and modular applications.

## Core Principle
Applications should be constructed following a consistent bottom-up approach where components are organized into a clear hierarchy, each with well-defined responsibilities and clean interfaces. Implementation should leverage modular design, principle-driven development, functional programming paradigms, unidirectional data flow, and complete feedback loops that ensure every UI element has a server-side purpose.

## Decision Tree/Process

### Phase 1: Architecture Planning
1. **Define application scope**
   - Identify core user needs and business requirements
   - Determine data sources and connections needed
   - Outline key functionality and features

2. **Design component hierarchy**
   - Break functionality into logical components following MP16 (Modularity)
   - Separate concerns following MP17 (Separation of Concerns)
   - Define UI-Server-Defaults triples per R09

3. **Establish data flow**
   - Map data sources to components
   - Define reactive data dependencies
   - Plan unidirectional data flow following MP52
   - Ensure output IDs follow the [section]_[datasource]_[field] pattern
   
4. **Design interaction patterns**
   - Map user actions to server-side processes (MP53 Feedback Loop)
   - Ensure every UI element has a corresponding server purpose (MP54 UI-Server Correspondence)
   - Define feedback mechanisms for all user actions
   - Document the full interaction cycle for each feature

### Phase 2: Component Implementation
1. **Create basic components**
   - Implement from bottom-up following P07
   - Define folder structure for each component
   - Create UI, server, and defaults files for each component

2. **Implement data connections**
   - Set up database connections following R76
   - Implement reactive data management
   - Ensure proper module data connections

3. **Develop component interfaces**
   - Design clear input/output interfaces
   - Implement consistent naming following R72
   - Ensure components use enhanced inputs per R71
   - Create responsive feedback indicators for all user interactions
   - Implement input validation with clear user feedback

### Phase 3: Application Assembly
1. **Create main application structure**
   - Set up initialization flow following MP48
   - Implement app mode management per MP03
   - Configure app structure per R14 (UI Hierarchy)

2. **Connect components**
   - Integrate components into main app
   - Set up navigation and routing
   - Implement sidebar following R11

3. **Finalize configuration**
   - Set up YAML configuration following R04
   - Configure default values per R15
   - Test with standardized data per MP51

## Implementation Pattern

### Component Structure Pattern
Each component should follow this folder/file structure:
```
componentName/
├── componentNameUI.R         # UI definition
├── componentNameServer.R     # Server logic
└── componentNameDefaults.R   # Default values
```

### Component Implementation Pattern
Each component should follow the UI-Server-Defaults triple pattern:

**UI Component (componentNameUI.R)**:
```r
#' Component Name UI
#'
#' UI definition for the component
#'
#' @param id Module ID
#' @return UI element
componentNameUI <- function(id) {
  ns <- NS(id)
  
  # UI definition with properly namespaced inputs/outputs
  # Following P73, use IDs that match server-side naming pattern
  card(
    card_header("Customer Profile"),
    card_body(
      # Enhanced inputs (R71)
      selectizeInput(ns("customer_id"), "Select Customer:", choices = NULL),
      
      # Output IDs following section_datasource_field pattern (P73)
      h4("Customer Information"),
      div(
        strong("Name: "), 
        textOutput(ns("customer_profile_name"), inline = TRUE)
      ),
      div(
        strong("Status: "), 
        textOutput(ns("customer_profile_status"), inline = TRUE)
      )
    )
  )
}
```

**Server Component (componentNameServer.R)**:
```r
#' Component Name Server
#'
#' Server logic for the component
#'
#' @param id Module ID
#' @param app_data_connection Database connection
#' @return Reactive values
componentNameServer <- function(id, app_data_connection) {
  moduleServer(id, function(input, output, session) {
    # Load defaults
    defaults <- componentNameDefaults()
    
    # Get data from connection - follow data source hierarchy per MP06
    df_customer_profile <- reactive({
      req(app_data_connection)
      # Query data using connection
      tryCatch({
        dbGetQuery(app_data_connection, "SELECT * FROM customer_profile")
      }, error = function(e) {
        NULL
      })
    })
    
    # Output with fallback to defaults - follow P73 server-to-UI data flow
    # Use section_datasource_field naming pattern
    output$customer_profile_name <- renderText({
      # Validate data before rendering
      req(df_customer_profile())
      
      # Check if data exists
      if (is.null(df_customer_profile()) || 
          nrow(df_customer_profile()) == 0 || 
          !"name" %in% colnames(df_customer_profile())) {
        return(defaults$customer_profile_name)
      }
      
      # Process and return data
      df_customer_profile()$name[1]
    })
    
    # Return reactive values for parent components
    return(reactive({
      # Return processed data
      if (is.null(df_customer_profile())) {
        return(NULL)
      }
      
      df_customer_profile()
    }))
  })
}
```

**Defaults Component (componentNameDefaults.R)**:
```r
#' Component Name Defaults
#'
#' Default values for the component
#'
#' @return Named list of default values
componentNameDefaults <- function() {
  # Default values that match the same naming pattern as output IDs
  # Follows R15 (Defaults from Triple) and P73 naming conventions
  list(
    customer_profile_name = "No Data Available",
    customer_profile_status = "Unknown Status",
    customer_profile_email = "No Email Available"
    # Additional defaults for all outputs
  )
}
```

### Main App Pattern
The main app should follow this structure:

```r
# Load initialization scripts (MP48)
source(file.path("update_scripts", "global_scripts", "00_principles", "sc_initialization_app_mode.R"))

# Load configuration (R04)
config <- load_yaml_config("app_config.yaml")

# Define UI hierarchy (R14)
ui <- fluidPage(
  # App layout
  sidebarLayout(
    # Sidebar with navigation (R11)
    sidebarPanel(
      # Navigation controls
    ),
    # Main panel with component layout
    mainPanel(
      # Dynamic UI based on selected navigation
      uiOutput("dynamic_content")
    )
  )
)

# Server logic
server <- function(input, output, session) {
  # Initialize data connections
  app_data_conn <- initialize_data_connection()
  
  # Instantiate components using module pattern
  output$dynamic_content <- renderUI({
    # Render appropriate component based on navigation
  })
  
  # Initialize components with data connections
  component_data <- componentNameServer("component_id", app_data_conn)
}

# Run the application
shinyApp(ui = ui, server = server)
```

## Anti-patterns

### 1. Monolithic Approach
**Avoid**: Creating a single large file containing all application code
**Instead**: Break down into modular components following MP16 and R09

### 2. Premature Merging of Data
**Avoid**: Pre-filtering or joining data before passing to components
**Instead**: Pass data connections to components (R76) and let them handle filtering

### 3. Global Variable Dependency
**Avoid**: Relying on global variables for component communication
**Instead**: Use reactive values and explicit inputs/outputs

### 4. Implicit UI State
**Avoid**: Managing UI state through direct manipulation
**Instead**: Use reactive programming for state management

### 5. Missing Default Values
**Avoid**: Components that break when data is unavailable
**Instead**: Always provide defaults for all outputs (R09)

### 6. Bidirectional Data Flow
**Avoid**: Creating circular data dependencies or UI components that directly modify server data
**Instead**: Maintain unidirectional data flow (MP52)

### 7. Inconsistent Output ID Naming
**Avoid**: Random or inconsistent naming for output IDs
**Instead**: Follow the `[section]_[datasource]_[field]` pattern from MP52

### 8. Decorative UI Elements
**Avoid**: UI elements that exist purely for visual appeal with no server interaction
**Instead**: Ensure every UI element has a purpose in server functionality (MP54)

### 9. Silent Processing
**Avoid**: Server-side processes that occur without UI feedback
**Instead**: Implement complete feedback loops for all processes (MP53)

### 10. Delayed Feedback
**Avoid**: User actions that don't receive immediate acknowledgment
**Instead**: Provide immediate feedback followed by process status updates

### 11. Inconsistent Naming
**Avoid**: Different naming patterns across components
**Instead**: Follow consistent naming conventions (R72)

### 12. Top-Down Construction
**Avoid**: Building the main app first and components later
**Instead**: Follow bottom-up construction (P07)

### 13. Function-File Mismatch
**Avoid**: Files containing multiple functions or misnamed files
**Instead**: Follow one-function-one-file rule (R21) with proper prefixes (R69)

## Related Principles

### Meta-Principles
- MP03: Operating Modes
- MP16: Modularity Principle
- MP17: Separation of Concerns
- MP47: Functional Programming
- MP48: Universal Initialization
- MP51: Test Data Design
- MP52: Unidirectional Data Flow
- MP53: Feedback Loop
- MP54: UI-Server Correspondence

### Principles
- P04: App Construction Principles
- P07: App Bottom-Up Construction
- P12: App.R Is Global
- P74: Reactive Data Filtering
- P75: Search Input Optimization

### Rules
- R04: App YAML Configuration
- R09: UI-Server-Defaults Triple
- R11: Hybrid Sidebar Pattern
- R14: UI Hierarchy
- R15: Defaults from Triple
- R21: One Function One File
- R68: Object Initialization
- R69: Function File Naming
- R71: Enhanced Input Components
- R72: Component ID Consistency
- R76: Module Data Connection