---
id: "R0009"
title: "UI-Server-Defaults Triple Rule"
type: "rule"
date_created: "2025-04-02"
date_modified: "2025-04-03"
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
folderorg_implements:
  - "MP0016": "Modularity Principle"
  - "MP0017": "Separation of Concerns Principle" 
  - "MP0018": "Don't Repeat Yourself Principle"
  - "P0007": "App Bottom-Up Construction"
  - "MP0019": "Package Consistency Principle"
---

# UI-Server-Defaults Triple Rule

## Core Requirement

Every Shiny component in the system must be implemented as a trio of coordinated files:
1. A UI component file that defines the interface
2. A server component file that provides the logic
3. A defaults file that supplies fallback values

This structure creates resilient components with clean separation of concerns and ensures interface stability regardless of data availability.

## Implementation Requirements

### 1. File Structure and Naming

#### Folder-Based Organization (Preferred)

Component files should be organized into dedicated folders for each component with filenames matching the exported function names:

```
10_rshinyapp_components/[section]/[componentName]/
├── [componentName]UI.R         # UI definition 
├── [componentName]Server.R     # Server logic
└── [componentName]Defaults.R   # Default values
```

Where:
- **[section]**: Major app section (e.g., "micro", "macro", "target")
- **[componentName]**: Specific component name (e.g., "microCustomer", "macroOverview")

Example for a customer profile component in the micro section:
```
10_rshinyapp_components/micro/microCustomer/
├── microCustomerUI.R
├── microCustomerServer.R
└── microCustomerDefaults.R
```

This folder-based organization:
- Improves component encapsulation
- Makes relationships between triple files explicit
- Reduces directory clutter
- Simplifies management of related files
- Enables addition of component-specific assets (documentation, tests, etc.)
- Follows package consistency by matching filenames to exported function names

#### Legacy File-Based Organization (Alternative)

For compatibility with existing implementations, the following structure is also supported:

```
10_rshinyapp_components/[section]/
├── ui_[section]_[component].R       # UI definition
├── server_[section]_[component].R   # Server logic
└── defaults_[section]_[component].R # Default values
```

Example:
```
10_rshinyapp_components/micro/
├── ui_micro_customer.R
├── server_micro_customer.R
└── defaults_micro_customer.R
```

New components should prefer the folder-based organization.

### 2. UI Component Requirements

UI component files must:

1. **Define all visual elements**: Include all UI elements that users will see
2. **Declare all outputs**: Explicitly create all output elements that will display dynamic content
3. **Use namespace**: Properly namespace all input and output IDs using the `NS(id)` function
4. **Document interfaces**: Include function documentation specifying usage and requirements
5. **Reference server pairing**: Include a comment referring to the corresponding server component
6. **Avoid business logic**: Contain no data processing or business logic

Example UI component:
```r
#' Micro Customer UI Component
#'
#' This component provides the UI elements for displaying detailed customer analytics.
#' IMPORTANT: According to the UI-Server-Defaults Triple Rule, this UI component 
#' MUST be used with its corresponding server component microCustomerServer().
#'
#' @param id The module ID
#' @return A UI component
#' @export
microCustomerUI <- function(id) {
  ns <- NS(id)
  
  card(
    card_header("Customer Profile"),
    card_body(
      selectInput(ns("customer_id"), "Select Customer", choices = NULL),
      valueBox(
        title = "Loyalty Score",
        value = textOutput(ns("loyalty_score"))
      ),
      valueBox(
        title = "Customer Value",
        value = textOutput(ns("customer_value"))
      )
    )
  )
}
```

### 3. Server Component Requirements

Server component files must:

1. **Fulfill all outputs**: Provide rendering functions for every output defined in the UI
2. **Handle NULL data gracefully**: Function correctly even when no data is provided
3. **Use defaults**: Incorporate default values when data is unavailable or invalid
4. **Validate input data**: Include validation checks for all incoming data
5. **Document data requirements**: Clearly specify expected data structure and format
6. **Reference UI pairing**: Include a comment referring to the corresponding UI component

Example server component:
```r
#' Micro Customer Server Component
#'
#' This component provides server-side logic for the customer profile component.
#' IMPORTANT: This server component fulfills all outputs defined in microCustomerUI()
#' and uses values from microCustomerDefaults() when data is unavailable.
#'
#' @param id The module ID
#' @param data_source The data source specification
#' @return None (server component with side effects)
#' @export
microCustomerServer <- function(id, data_source = NULL) {
  moduleServer(id, function(input, output, session) {
    # Load default values
    defaults <- microCustomerDefaults()
    
    # Process data source
    customer_data <- reactive({
      if (is.null(data_source)) return(NULL)
      # Process data source...
      return(processed_data)
    })
    
    # Update customer selection choices
    observe({
      customers <- customer_data()
      if (!is.null(customers) && nrow(customers) > 0) {
        updateSelectInput(session, "customer_id", 
                         choices = customers$customer_id)
      }
    })
    
    # Render loyalty score with fallback to default
    output$loyalty_score <- renderText({
      data <- customer_data()
      if (is.null(data) || nrow(data) == 0) {
        return(defaults$loyalty_score)
      }
      # Process and return actual score...
    })
    
    # Render customer value with fallback to default
    output$customer_value <- renderText({
      data <- customer_data()
      if (is.null(data) || nrow(data) == 0) {
        return(defaults$customer_value)
      }
      # Process and return actual value...
    })
  })
}
```

### 4. Defaults Component Requirements

Defaults component files must:

1. **Define all outputs**: Provide default values for every output defined in the UI
2. **Use meaningful placeholders**: Default values should be reasonable representations
3. **Maintain format consistency**: Defaults should match the expected format of actual data
4. **Document default logic**: Explain the rationale for default value selection
5. **Export a function**: Provide a function that returns the defaults as a named list

Example defaults component:
```r
#' Default Values for Micro Customer Component
#'
#' This file provides standard default values for the micro customer component.
#' These defaults ensure that all UI outputs have appropriate values
#' even when data is unavailable or invalid.
#'
#' @return Named list of output IDs and their default values
#' @export
microCustomerDefaults <- function() {
  list(
    loyalty_score = "N/A",
    customer_value = "$0.00"
    # Add defaults for all other outputs defined in the UI
  )
}
```

## Usage Patterns

### 1. Basic Usage Pattern

The standard pattern for implementing the Triple Rule:

```r
# In app.R or other component files:

# 1. Include the UI component
ui <- fluidPage(
  microCustomerUI("customer_module")
)

# 2. Initialize the server component with data source
server <- function(input, output, session) {
  microCustomerServer("customer_module", data_source = customer_data)
}
```

### 2. Default-Only Usage Pattern

When no real data is available (for testing or previewing):

```r
# In app.R or other component files:

# 1. Include the UI component
ui <- fluidPage(
  microCustomerUI("customer_module")
)

# 2. Initialize the server component without data source
server <- function(input, output, session) {
  # No data source - defaults will be used
  microCustomerServer("customer_module")
}
```

### 3. Default Initialization Pattern

The pattern for implementing default fallback logic in a server component:

```r
# In the server component:
moduleServer(id, function(input, output, session) {
  # 1. Load default values
  defaults <- componentDefaults()
  
  # 2. Initialize outputs with defaults (optional helper function)
  initializeOutputsWithDefaults <- function() {
    for (id in names(defaults)) {
      local({
        local_id <- id
        output[[local_id]] <- renderText({ defaults[[local_id]] })
      })
    }
  }
  
  # 3. Initialize with defaults first (optional)
  initializeOutputsWithDefaults()
  
  # 4. Process data and update outputs if data is available
  observe({
    req(valid_data())
    
    # Update outputs with actual values...
  })
})
```

### 4. Package Consistency Naming Pattern

Following MP0019 (Package Consistency Principle), function names must follow package conventions:

#### For Shiny Module Functions:

```r
# UI Component - camelCase with UI suffix
microCustomerUI <- function(id) {
  ns <- NS(id)
  # UI definition...
}

# Server Component - camelCase with Server suffix
microCustomerServer <- function(id, data_source = NULL) {
  moduleServer(id, function(input, output, session) {
    # Server logic...
  })
}

# Defaults Component - camelCase with Defaults suffix
microCustomerDefaults <- function() {
  list(
    # Default values...
  )
}
```

#### For Database Interface Functions (DBI conventions):

```r
# Database functions use dbPrefix
dbQueryCustomers <- function(conn = NULL, filters = NULL) {
  # Database query implementation...
}

# Error handling wrapper
dbSafeExecute <- function(query, conn = default_conn) {
  # Safe execution with error handling...
}
```

In both cases, file names should match function names for package consistency:

```
microCustomer/
├── microCustomerUI.R       # Contains microCustomerUI() function
├── microCustomerServer.R   # Contains microCustomerServer() function
└── microCustomerDefaults.R # Contains microCustomerDefaults() function

db/
├── dbQueryCustomers.R      # Contains dbQueryCustomers() function
└── dbSafeExecute.R         # Contains dbSafeExecute() function
```

## Implementation Examples

### Example 1: Complete Triple Implementation with Folder Organization

The micro customer profile component demonstrates a complete implementation using the folder-based organization:

```
10_rshinyapp_components/micro/customer/
├── ui.R
├── server.R
└── defaults.R
```

Contents of each file:

```r
# ui.R
microCustomerUI <- function(id) {
  ns <- NS(id)
  
  card(
    selectInput(ns("customer_id"), "Customer ID:", choices = NULL),
    valueBox(
      title = "Customer Status",
      value = textOutput(ns("customer_status"))
    )
  )
}

# server.R
microCustomerServer <- function(id, data_source = NULL) {
  moduleServer(id, function(input, output, session) {
    # Get defaults
    defaults <- microCustomerDefaults()
    
    # Process data source
    data <- reactive({
      if (is.null(data_source)) return(NULL)
      processDataSource(data_source)
    })
    
    # Update customer selection with validation
    observe({
      customers <- data()
      if (!is.null(customers) && "customer_id" %in% names(customers)) {
        updateSelectInput(session, "customer_id", choices = customers$customer_id)
      }
    })
    
    # Render status with fallback to default
    output$customer_status <- renderText({
      if (is.null(data()) || !input$customer_id %in% data()$customer_id) {
        return(defaults$customer_status)
      }
      
      # Get actual status
      customer_row <- data()[data()$customer_id == input$customer_id, ]
      return(customer_row$status)
    })
  })
}

# defaults.R
microCustomerDefaults <- function() {
  list(
    customer_status = "Unknown"
  )
}
```

### Example 2: Triple Implementation with Multiple Outputs

A component with multiple related outputs and fallback values:

```r
# ui_macro_metrics.R
macroMetricsUI <- function(id) {
  ns <- NS(id)
  
  card(
    card_header("Key Performance Metrics"),
    card_body(
      valueBox(title = "Revenue", value = textOutput(ns("revenue"))),
      valueBox(title = "Orders", value = textOutput(ns("orders"))),
      valueBox(title = "Customers", value = textOutput(ns("customers")))
    )
  )
}

# server_macro_metrics.R
macroMetricsServer <- function(id, data_source = NULL) {
  moduleServer(id, function(input, output, session) {
    # Get defaults
    defaults <- macroMetricsDefaults()
    
    # Safe render function that uses defaults when needed
    safeRender <- function(output_id, data_func) {
      output[[output_id]] <- renderText({
        if (is.null(data_source)) {
          return(defaults[[output_id]])
        }
        
        result <- tryCatch({
          data_func()
        }, error = function(e) {
          return(NULL)
        })
        
        if (is.null(result)) {
          return(defaults[[output_id]])
        }
        
        return(result)
      })
    }
    
    # Render all outputs with fallback to defaults
    safeRender("revenue", function() { 
      paste0("$", format(sum(data_source()$revenue), big.mark = ",")) 
    })
    
    safeRender("orders", function() { 
      format(nrow(data_source()), big.mark = ",") 
    })
    
    safeRender("customers", function() { 
      format(length(unique(data_source()$customer_id)), big.mark = ",") 
    })
  })
}

# defaults_macro_metrics.R
macroMetricsDefaults <- function() {
  list(
    revenue = "$0",
    orders = "0",
    customers = "0"
  )
}
```

### Example 3: Complex Data Processing with Defaults

A component that processes data in multiple steps with fallbacks at each level:

```r
# server component excerpt
segmentAnalysisServer <- function(id, data_source = NULL) {
  moduleServer(id, function(input, output, session) {
    # Get defaults
    defaults <- segmentAnalysisDefaults()
    
    # Process data with fallbacks at each step
    raw_data <- reactive({
      if (is.null(data_source)) return(NULL)
      tables <- processDataSource(data_source)
      return(tables$primary)
    })
    
    segment_data <- reactive({
      data <- raw_data()
      if (is.null(data) || nrow(data) == 0) return(NULL)
      
      # Process segments...
      return(processed_segments)
    })
    
    # Render outputs with appropriate defaults at each level
    output$segment_count <- renderText({
      segments <- segment_data()
      if (is.null(segments)) return(defaults$segment_count)
      
      count <- length(unique(segments$segment))
      return(as.character(count))
    })
    
    output$largest_segment <- renderText({
      segments <- segment_data()
      if (is.null(segments)) return(defaults$largest_segment)
      
      segment_sizes <- table(segments$segment)
      largest <- names(which.max(segment_sizes))
      return(largest)
    })
  })
}
```

## Common Errors and Solutions

### Error 1: Missing Defaults File

**Problem**: The UI and server components exist, but no defaults file is provided, leading to broken displays when data is unavailable.

**Solution**: Always create a defaults file with the same base name as the UI and server components, providing default values for all outputs.

```r
# Create this if it doesn't exist:
componentDefaults <- function() {
  list(
    # Add defaults for ALL outputs defined in the UI component
    output1 = "Default value 1",
    output2 = "Default value 2"
  )
}
```

### Error 2: Incomplete Output Coverage

**Problem**: The UI defines outputs that are not rendered in the server component or don't have default values, leading to empty or broken UI elements.

**Solution**: Use a systematic approach to ensure all outputs are covered:

1. List all output IDs defined in the UI
2. Ensure each has a rendering function in the server
3. Ensure each has a default value in the defaults file

### Error 3: Unsafe Data Access

**Problem**: Server component accesses data without checking for NULL or invalid values, causing errors when data is unavailable.

**Solution**: Use defensive programming with proper validation:

```r
# Bad practice - unsafe access
output$metric <- renderText({
  data()$value  # Will error if data() is NULL or doesn't have 'value' column
})

# Good practice - safe access with default fallback
output$metric <- renderText({
  data <- data()
  if (is.null(data) || !"value" %in% names(data) || nrow(data) == 0) {
    return(defaults$metric)
  }
  return(data$value)
})
```

### Error 4: Incomplete Server Component

**Problem**: Server component expects data in a specific format but doesn't handle variations or missing data sources.

**Solution**: Design server components to work with all supported data source formats:

```r
# Make the data_source parameter optional with NULL default
componentServer <- function(id, data_source = NULL) {
  moduleServer(id, function(input, output, session) {
    # Handle NULL data_source gracefully
    data <- reactive({
      if (is.null(data_source)) return(NULL)
      
      # Process different formats
      if (is.character(data_source)) {
        # Handle string format
      } else if (is.list(data_source)) {
        # Handle object format
      }
      
      # Return processed data or NULL if invalid
    })
    
    # Use data with fallbacks to defaults
  })
}
```

### Error 5: Initialization with Folder Structure

**Problem**: Application initialization scripts don't correctly load components organized in folders.

**Solution**: Update initialization scripts to support both folder-based and file-based component organization:

```r
# Function to load components from either structure
loadComponents <- function(base_path) {
  # First check for folder-based components
  component_folders <- list.dirs(base_path, full.names = TRUE, recursive = FALSE)
  
  for (folder in component_folders) {
    component_name <- basename(folder)
    
    # For modern components with function-named files
    ui_pattern <- paste0(component_name, "UI\\.R$")
    server_pattern <- paste0(component_name, "Server\\.R$")
    defaults_pattern <- paste0(component_name, "Defaults\\.R$")
    
    ui_files <- list.files(folder, pattern = ui_pattern, full.names = TRUE)
    server_files <- list.files(folder, pattern = server_pattern, full.names = TRUE)
    defaults_files <- list.files(folder, pattern = defaults_pattern, full.names = TRUE)
    
    if (length(ui_files) > 0 && length(server_files) > 0 && length(defaults_files) > 0) {
      source(ui_files[1])
      source(server_files[1])
      source(defaults_files[1])
    }
  }
  
  # Then load legacy file-based components
  ui_files <- list.files(base_path, pattern = "^ui_.*\\.R$", full.names = TRUE)
  
  for (ui_file in ui_files) {
    # Extract the base name to find matching server and defaults files
    file_base <- sub("^ui_", "", basename(ui_file))
    file_base <- sub("\\.R$", "", file_base)
    
    server_file <- file.path(base_path, paste0("server_", file_base, ".R"))
    defaults_file <- file.path(base_path, paste0("defaults_", file_base, ".R"))
    
    # Load the component triple if all files exist
    if (file.exists(server_file) && file.exists(defaults_file)) {
      source(ui_file)
      source(server_file)
      source(defaults_file)
    }
  }
}
```

## Relationship to Other Principles

### Core Principles Relationships

This rule:

1. **Implements P0004 (App Construction Principles)**: Provides a specific implementation pattern for constructing app components
2. **Derives from MP0016 (Modularity Principle)**: Creates modular components with clear boundaries and independence
3. **Implements MP0017 (Separation of Concerns)**: Separates UI definition, logic, and default value management
4. **Applies MP0018 (Don't Repeat Yourself)**: Centralizes default values and ensures consistent fallback behavior
5. **Supports P0007 (App Bottom-Up Construction)**: Enables testing components in isolation before integration
6. **Relates to R0004 (App YAML Configuration)**: Supports configuration-driven component initialization

### Folder Organization Principle Alignment

The folder-based organization specifically aligns with these principles:

1. **MP0016 (Modularity Principle)**:
   - Strengthens component encapsulation through physical grouping
   - Creates clearer boundaries between components in the file system
   - Promotes independence by organizing components as self-contained units
   - Enhances cohesion by keeping all component-related files together

2. **MP0017 (Separation of Concerns)**:
   - Maintains separation between UI, server, and defaults while acknowledging their relatedness
   - Improves cognitive organization through logical grouping
   - Balances separation (distinct files) with relatedness (same folder)

3. **MP0018 (Don't Repeat Yourself)**:
   - Eliminates redundant prefixes in filenames (no need for repeated component names)
   - Simplifies file references within components
   - Removes need for repetitive path construction

4. **P0007 (App Bottom-Up Construction)**:
   - Facilitates building and testing components as complete units
   - Simplifies component reuse across applications
   - Makes component dependencies more explicit
   - Enables cleaner refactoring during iterative development

5. **MP0019 (Package Consistency Principle)**:
   - Maintains consistency by matching filenames to exported function names
   - Follows R package best practices where files are named after their main function
   - Improves discoverability of function sources through predictable naming
   - Facilitates future modularization as proper R packages
   - Enhances maintainability through standard naming conventions

This pattern demonstrates how physical organization can reinforce logical architecture, creating alignment between the file system structure and the conceptual component model.

## Benefits

### General Triple Rule Benefits

Implementing the UI-Server-Defaults Triple Rule provides several benefits:

1. **UI Stability**: Interface remains usable even when data is unavailable
2. **Error Resilience**: Application continues functioning despite data issues
3. **Clean Architecture**: Clear separation of concerns between UI, logic, and default values
4. **Improved Testing**: Components can be tested in isolation with default values
5. **Better Maintainability**: Changes to one aspect don't require changes to others
6. **Preview Capability**: UI can be previewed without real data using defaults
7. **Consistent UX**: Users see reasonable placeholders rather than errors or empty spaces

### Additional Folder Organization Benefits

The folder-based organization provides additional advantages:

1. **Component Encapsulation**: Logically groups all files related to a single component
2. **Reduced Clutter**: Prevents large sections from having too many files in a single directory
3. **Extensibility**: Provides a natural location for component-specific assets:
   - Component-specific tests
   - Component documentation
   - Component-specific resources (images, data files)
   - Component style files
4. **Improved Navigation**: Makes it easier to locate component files, especially in large applications
5. **Enhanced Modularity**: Strengthens the conceptual boundaries between components
6. **Simpler Refactoring**: Makes it easier to move or rename components as units
7. **Package Compatibility**: Aligns with standard R package organization for potential future packaging
8. **Function-File Consistency**: Ensures each file is named after the function it exports, following R package conventions
9. **Improved Discoverability**: Makes it easier to find function implementations through predictable naming

## Conclusion

The UI-Server-Defaults Triple Rule ensures that Shiny components are robust, maintainable, and error-resistant through a three-part structure. By separating UI definition, server logic, and default values into distinct files, this rule implements the Separation of Concerns and Modularity principles while providing practical benefits for development and user experience. Every component must follow this pattern to ensure a consistent and reliable application architecture.
