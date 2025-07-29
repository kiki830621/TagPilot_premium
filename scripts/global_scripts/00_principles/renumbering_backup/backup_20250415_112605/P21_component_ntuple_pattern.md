# Principle 21: Component N-tuple Pattern

## Core Principle
Component architecture should follow an n-tuple pattern where each logical component is split into separate, specialized files based on responsibility, with each file focused on a single aspect of component functionality.

## Rationale
This principle extends the traditional UI-Server-Defaults triple pattern to accommodate additional component aspects as needed:

1. **Enhanced Separation of Concerns**: Each component aspect has a dedicated file with a single responsibility
2. **Flexible Componentization**: New component aspects can be added without restructuring existing code
3. **Improved Maintainability**: Changes to one aspect don't require modifying files for other aspects
4. **Clearer Organization**: File naming clearly indicates each file's responsibility
5. **Better Testability**: Each component aspect can be tested independently

## Component Aspect Types

### Core Component Aspects (Basic Triple)
1. **UI**: Visual presentation and structure
   - File suffix: `UI.R` or `_ui.R`
   - Responsibility: Define component appearance, layout, and inputs/outputs

2. **Server**: Business logic and data processing
   - File suffix: `Server.R` or `_server.R`
   - Responsibility: Handle data transformation, reactivity, and event responses

3. **Defaults**: Configuration and parameterization
   - File suffix: `Defaults.R` or `_defaults.R`
   - Responsibility: Define default values, parameter ranges, and configuration

### Extended Component Aspects
4. **Filters**: Component-specific filtering controls
   - File suffix: `Filters.R` or `_filters.R`
   - Responsibility: Define filtering options specific to the component

5. **Utilities**: Helper functions
   - File suffix: `Utils.R` or `_utils.R`
   - Responsibility: Provide component-specific utility functions

6. **Validators**: Input validation
   - File suffix: `Validators.R` or `_validators.R`
   - Responsibility: Validate component inputs and parameters

7. **Tests**: Component tests
   - File suffix: `Tests.R` or `_tests.R`
   - Responsibility: Unit and integration tests for the component

8. **Documentation**: Component documentation
   - File suffix: `Docs.R` or `_docs.R` (or `.md`)
   - Responsibility: Document component usage, parameters, and examples

## Implementation Pattern

### Directory Structure
```
10_rshinyapp_components/
└── customer_profile/
    ├── customerProfileUI.R
    ├── customerProfileServer.R
    ├── customerProfileDefaults.R
    ├── customerProfileFilters.R
    ├── customerProfileUtils.R
    ├── customerProfileValidators.R
    ├── customerProfileTests.R
    └── customerProfileDocs.md
```

### File Naming Conventions
1. **CamelCase Component Name**:
   - Example: `customerProfile`

2. **CamelCase Aspect Suffix**:
   - Example: `customerProfileUI.R`

3. **Alternative Snake Case Option**:
   - Example: `customer_profile_ui.R`

### Component Registration Pattern
```r
# Registration function to make component aspects available
register_component <- function(component_name, component_dir) {
  # Basic triple (required)
  ui <- source(file.path(component_dir, paste0(component_name, "UI.R")))$value
  server <- source(file.path(component_dir, paste0(component_name, "Server.R")))$value
  defaults <- source(file.path(component_dir, paste0(component_name, "Defaults.R")))$value
  
  # Extended aspects (optional)
  filters_path <- file.path(component_dir, paste0(component_name, "Filters.R"))
  filters <- if (file.exists(filters_path)) source(filters_path)$value else NULL
  
  utils_path <- file.path(component_dir, paste0(component_name, "Utils.R"))
  utils <- if (file.exists(utils_path)) source(utils_path)$value else NULL
  
  # Return all loaded aspects
  list(
    ui = ui,
    server = server,
    defaults = defaults,
    filters = filters,
    utils = utils
  )
}
```

### Component Usage Pattern
```r
# Load component
customer_profile <- register_component("customerProfile", "10_rshinyapp_components/customer_profile")

# Use component aspects
ui <- fluidPage(
  customer_profile$ui(id = "profile1")
)

server <- function(input, output, session) {
  # Apply server logic
  customer_profile$server(
    id = "profile1", 
    options = customer_profile$defaults
  )
  
  # Use filters if available
  if (!is.null(customer_profile$filters)) {
    output$sidebar <- renderUI({
      customer_profile$filters(NS("profile1"))
    })
  }
}
```

## Benefits of N-tuple Pattern
1. **Scalability**: The pattern scales from simple components to complex ones
2. **Progressive Enhancement**: Start with the basic triple, add more aspects as needed
3. **Clear Responsibility Boundaries**: Each file has a well-defined single responsibility
4. **Simplified Navigation**: File naming makes it easy to find specific component aspects
5. **Focused Development**: Developers can work on specific aspects without conflicts

## Related Principles
- R09 (UI-Server-Defaults Triple)
- MP17 (Separation of Concerns)
- P20 (Sidebar Filtering Only)
- R11 (Hybrid Sidebar Pattern)