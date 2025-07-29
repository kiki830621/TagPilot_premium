---
id: "R66"
title: "app.R Function Prohibition Rule"
type: "rule"
date_created: "2025-04-08"
author: "Claude"
implements:
  - "P12": "app.R Is Global Principle"
  - "MP17": "Separation of Concerns"
related_to:
  - "R21": "One Function One File"
  - "P04": "App Construction Principles"
  - "R09": "UI-Server-Defaults Triple Rule"
  - "MP16": "Modularity Principle"
---

# app.R Function Prohibition Rule

## Core Requirement

**The app.R file must never contain function definitions beyond the required Shiny server function.** All application functionality, helper utilities, and processing logic must be defined in separate files following the appropriate file organization principles.

## Rationale

The app.R file serves as the entry point and orchestrator for the application, not as a repository for functional logic. By prohibiting function definitions in app.R, we:

1. **Maintain Global Consistency**: Ensure app.R remains a stable, portable template
2. **Enforce Separation of Concerns**: Keep orchestration separate from implementation
3. **Improve Maintainability**: Make functionality easier to locate, test, and update
4. **Support Modularity**: Encourage proper organization of code into modular components
5. **Enhance Reusability**: Enable function reuse across different parts of the application

## Implementation Guidelines

### 1. Permitted Content in app.R

The app.R file should contain **only**:

- Initialization script sourcing
- Configuration loading
- UI definition (structure only)
- The server function definition (which orchestrates but doesn't implement logic)
- The shinyApp() call to launch the application

```r
# Correct app.R structure
source(file.path("update_scripts", "global_scripts", "00_principles", "sc_initialization_app_mode.R"))

# Load configuration
config <- fn_load_app_config("app_config.yaml")

# UI Definition - Structure only
ui <- page_navbar(
  # UI structure elements
)

# Server function - Orchestration only
server <- function(input, output, session) {
  # Module initialization
  moduleServer("module1", module1Server)
  moduleServer("module2", module2Server)
}

# Application launch
shinyApp(ui, server)
```

### 2. Prohibited Content in app.R

The following must **never** appear in app.R:

- **Custom Function Definitions**: No utility, helper, or processing functions
- **Anonymous Function Definitions**: No complex inline functions beyond simple reactivity expressions
- **Function Variables**: No function assignments beyond the server function
- **Complex Logic**: No data transformation or processing logic

### 3. Allowed Exceptions

The only permitted exceptions to this rule are:

1. **The Server Function**: The required `server <- function(input, output, session) {...}` definition
2. **Simple Reactive Expressions**: Such as `observeEvent(input$x, {...})` within the server function
3. **Simple Rendering Functions**: Such as `renderText({...})` within the server function

### 4. Proper Alternative Placement

Instead of defining functions in app.R:

1. **Utility Functions**: Place in `/update_scripts/global_scripts/04_utils/fn_{function_name}.R`
2. **Component Functions**: Place in the appropriate module directory: `/update_scripts/global_scripts/10_rshinyapp_components/{module}/fn_{function_name}.R`
3. **Processing Functions**: Place in `/update_scripts/global_scripts/05_data_processing/fn_{function_name}.R`

## Examples

### Violation Examples

```r
# VIOLATION: Function definition in app.R
formatCurrency <- function(value) {
  paste0("$", format(value, big.mark = ","))
}

# VIOLATION: Complex anonymous function
df <- reactive({
  function(x) {
    # Complex processing logic
    x %>% 
      filter(value > threshold) %>%
      group_by(category) %>%
      summarize(total = sum(value))
  }(data())
})

# VIOLATION: Helper function in server
server <- function(input, output, session) {
  # Helper function defined inside server
  calculateTotal <- function(data) {
    sum(data$value)
  }
  
  output$total <- renderText({
    calculateTotal(dataset())
  })
}
```

### Compliant Examples

```r
# COMPLIANT: No function definitions, proper sourcing
source(file.path("update_scripts", "global_scripts", "00_principles", "sc_initialization_app_mode.R"))

# UI with structure only
ui <- page_navbar(
  title = "Application",
  nav_panel("Analysis", analysisUI("analysis"))
)

# Server with orchestration only
server <- function(input, output, session) {
  # Initialize modules
  analysisServer("analysis")
  
  # Simple reactive expressions are allowed
  observeEvent(input$refresh, {
    # Simple actions only, no complex logic
    session$reload()
  })
}

# Application launch
shinyApp(ui, server)
```

## Implementation Process

### Step 1: Check for Function Violations

Before deploying an application, verify that app.R doesn't contain function definitions:

```r
# Function to check for function definitions in app.R
check_app_r_functions <- function(file_path = "app.R") {
  content <- readLines(file_path)
  
  # Look for function assignment patterns
  function_patterns <- c(
    "<- function\\(",
    "= function\\(",
    "function\\([^)]*\\) \\{",
    "\\}$"
  )
  
  # Find server function definition
  server_line <- grep("server[[:space:]]*<-[[:space:]]*function", content)
  
  # Check for other function definitions
  violations <- lapply(function_patterns, function(pattern) {
    matches <- grep(pattern, content)
    # Remove server function and simple reactive expressions
    matches[!matches %in% c(server_line, server_line+1, server_line-1)]
  })
  
  violations <- unique(unlist(violations))
  
  if (length(violations) > 0) {
    cat("Function definition violations found in app.R:\n")
    for (line in violations) {
      cat(line, ": ", content[line], "\n")
    }
    return(FALSE)
  }
  
  return(TRUE)
}
```

### Step 2: Refactor Function Violations

For each function found in app.R:

1. Create a new file with the appropriate name (e.g., `fn_{function_name}.R`)
2. Move the function definition to the new file
3. Add proper documentation following R21 (One Function One File)
4. Ensure the function is properly sourced during initialization

### Step 3: Update app.R

Modify app.R to remove function definitions and ensure it follows the proper structure:

1. Replace functions with calls to externally defined functions
2. Ensure the initialization script loads all necessary functions
3. Simplify complex logic within the server function by delegating to modules

## Verification Procedures

To verify compliance with this rule:

1. **Static Analysis**: Run a script to check for function definitions
2. **Code Review**: Include an explicit check for app.R function violations
3. **Documentation Check**: Ensure all functions are properly documented in separate files

## Benefits

Adhering to this rule provides several benefits:

1. **Simplified app.R**: Makes the main application file easier to understand
2. **Better Organization**: Ensures functionality is properly organized
3. **Improved Testing**: Makes functions more accessible for unit testing
4. **Enhanced Collaborations**: Clarifies the role of app.R vs. functional components
5. **Consistent Structure**: Ensures consistency across different projects

## Relationship to Other Principles

This rule:

1. **Implements P12 (app.R Is Global Principle)** by enforcing a key aspect of treating app.R as a global resource
2. **Implements MP17 (Separation of Concerns)** by separating orchestration from implementation
3. **Relates to R21 (One Function One File)** by ensuring functions are properly organized in their own files
4. **Supports P04 (App Construction Principles)** by enforcing proper application structure
5. **Complements R09 (UI-Server-Defaults Triple Rule)** by ensuring modularity of component implementation

## Conclusion

The app.R Function Prohibition Rule ensures that app.R serves strictly as an application entry point and orchestrator, not as a repository for functional logic. By prohibiting function definitions in app.R, we maintain a clean separation between structural organization and functional implementation, leading to more maintainable, modular, and reusable code.

This rule reinforces the principles of modularity, separation of concerns, and global consistency established in P12 (app.R Is Global Principle), ensuring that app.R remains a stable template that can be easily shared across different projects and applications.