---
id: "R98"
title: "CSS Organization Rule"
type: "rule"
date_created: "2025-04-10"
date_modified: "2025-04-10"
author: "Development Team"
implements:
  - "MP16": "Modularity"
  - "MP17": "Separation of Concerns"
related_to:
  - "R09": "UI-Server-Defaults Triple"
---

# CSS Organization Rule

## Core Requirement

CSS styling must be organized into modular, purpose-specific files stored in the designated CSS directory (`/update_scripts/global_scripts/19_CSS/`). Applications must use the provided utility functions to load and manage CSS resources rather than hard-coding style paths.

## Rationale

Centralizing and organizing CSS improves maintainability, reduces duplication, and ensures consistent styling across the application. By separating styling concerns, we achieve:

1. **Improved Maintainability**: Styles are organized logically and can be updated in one place
2. **Consistent User Experience**: Common styling is applied uniformly across all components
3. **Simplified Development**: Developers can focus on component logic rather than styling details
4. **Better Performance**: CSS can be optimized, minified, and cached appropriately
5. **Separation of Concerns**: UI structure and styling remain decoupled

## Implementation Details

### 1. CSS Directory Structure

All CSS files must be stored in the designated directory structure:

```
/update_scripts/global_scripts/19_CSS/
├── main.css                # Global application styles
├── sidebar-fixes.css       # Sidebar-specific fixes
├── component-styles.css    # Component-specific styles
├── [feature]-styles.css    # Feature-specific styles
└── fn_load_css.R           # CSS loading utility functions
```

### 2. CSS File Organization

CSS files should be organized by purpose:

1. **main.css**: Global styles applied to the entire application
2. **component-styles.css**: Styles for reusable UI components
3. **feature-specific files**: Styles for specific application features
4. **fix/override files**: Targeted fixes for specific issues

### 3. CSS Loading Pattern

Applications must use the provided utility functions to load CSS:

```r
# Load CSS utilities
source(file.path("update_scripts", "global_scripts", "19_CSS", "fn_load_css.R"))

# For Shiny applications, copy CSS to www directory
copy_css_to_www()

# Create CSS dependencies for UI
css_dependencies <- tags$head(
  # Load CSS files with static paths or with utility function
  tags$link(rel = "stylesheet", type = "text/css", href = "main.css"),
  tags$link(rel = "stylesheet", type = "text/css", href = "component-styles.css")
)

# Include dependencies in UI
ui <- fluidPage(
  css_dependencies,
  # Rest of UI...
)
```

Alternatively, use the provided utility function to load all CSS files:

```r
# Load all CSS files automatically
css_dependencies <- load_css_files(add_www_prefix = TRUE)
```

### 4. CSS Best Practices

1. **Component Isolation**: Component styles should be scoped to avoid conflicts
2. **Descriptive Classes**: Use clear, semantic class names
3. **Responsive Design**: CSS should handle different screen sizes
4. **Avoid Inline Styles**: Place all styles in CSS files, not inline
5. **Minimize !important**: Use only when absolutely necessary
6. **Comment Complex Sections**: Provide clear comments for complex styling

## Utility Functions

The following utility functions are provided in `fn_load_css.R`:

1. **load_css_files()**: Creates HTML tags for all CSS files in the directory
   - Parameters: css_dir (directory to search), add_www_prefix (whether to add www/ prefix)
   - Returns: tagList of link tags

2. **copy_css_to_www()**: Copies CSS files to the www directory for Shiny to serve
   - Parameters: source_dir, www_dir
   - Returns: Boolean success indicator

## Relationship to Other Rules and Principles

This rule implements:
- **MP16 (Modularity)**: By organizing CSS in modular, purpose-specific files
- **MP17 (Separation of Concerns)**: By separating content structure from styling

It relates to:
- **R09 (UI-Server-Defaults Triple)**: By providing standardized styling for UI components

## Implementation Checklist

- [ ] Move all CSS files to the designated directory
- [ ] Categorize styles into appropriate files (main, component, feature-specific)
- [ ] Use utility functions to load CSS in applications
- [ ] Remove inline styles and replace with classes
- [ ] Add comments to explain complex styling
- [ ] Ensure responsive design is implemented

## Examples

### Organizing Component Styles

```css
/* In component-styles.css */

/* Component containers */
.component-container {
  border: 1px solid #e0e0e0;
  border-radius: 5px;
  padding: 15px;
  margin-bottom: 20px;
  background-color: #f9f9f9;
}

/* Component headers */
.component-header {
  margin-bottom: 15px;
  border-bottom: 1px solid #eee;
  padding-bottom: 10px;
}

/* Component outputs */
.component-output {
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 15px;
  background-color: #fff;
}
```

### Using CSS in Components

When developing components, reference the common CSS classes:

```r
# Component UI definition
myComponentUI <- function(id) {
  ns <- NS(id)
  
  div(
    class = "component-container",
    div(
      class = "component-header",
      h3("My Component Title"),
      p("Component description")
    ),
    div(
      class = "component-output",
      plotOutput(ns("main_plot"))
    )
  )
}
```

### Loading CSS in Application Startup

```r
# In app.R
library(shiny)

# Load CSS utilities
source(file.path("update_scripts", "global_scripts", "19_CSS", "fn_load_css.R"))

# Copy CSS to www directory
copy_result <- copy_css_to_www()
if (!copy_result) {
  warning("Failed to copy some CSS files. UI may not appear correctly.")
}

# Load CSS dependencies
css_dependencies <- load_css_files(add_www_prefix = TRUE)

# Define UI
ui <- fluidPage(
  css_dependencies,
  titlePanel("Application Title"),
  # Rest of UI...
)

# Define server
server <- function(input, output, session) {
  # Server logic...
}

# Run the app
shinyApp(ui, server)
```