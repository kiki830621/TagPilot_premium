---
id: "R0011"
title: "Hybrid Sidebar Pattern"
type: "rule"
date_created: "2025-04-03"
date_modified: "2025-04-03"
author: "Claude"
implements:
  - "MP0016": "Modularity Principle"
  - "MP0017": "Separation of Concerns Principle"
  - "P0004": "App Construction Principles"
related_to:
  - "R0011": "UI-Server-Defaults Triple Rule"
  - "MP0019": "Package Consistency Principle"
---

# Hybrid Sidebar Pattern

## Core Requirement

Application sidebars must follow a hybrid pattern that combines consistent global controls with context-specific module controls. This pattern ensures that primary filters remain available throughout the application while still providing specialized controls for specific tasks.

## Implementation Requirements

### 1. Two-Section Structure

Every sidebar must be organized into two distinct sections:

1. **Global Section**: Consistent across all modules, containing application-wide filters and controls
2. **Contextual Section**: Changes based on the active module, containing module-specific controls

These sections must be clearly separated by visual indicators (horizontal dividers and/or spacing).

### 2. Global Section Requirements

The global section must:

1. **Maintain Consistency**: Appear in the same location and with the same controls throughout the application
2. **Include Primary Filters**: Contain the most essential application-wide filters
3. **Preserve State**: Maintain filter selections when navigating between modules
4. **Appear First**: Always be positioned at the top of the sidebar
5. **Be Visually Distinct**: Use styling to indicate its global nature

Example global controls:
- Product category selection
- Date range filters
- Geographic region selection
- Channel selection (e.g., Amazon vs. Official Website)

### 3. Contextual Section Requirements

The contextual section must:

1. **Be Module-Specific**: Display controls relevant only to the current module
2. **Change Dynamically**: Update when the user navigates to a different module
3. **Maintain State Per Module**: Remember settings when returning to a previously visited module
4. **Be Clearly Labeled**: Include a heading indicating the current module
5. **Include Module-Specific Actions**: Contain actions relevant to the current module

### 4. Transition Requirements

When the user navigates between modules:

1. **Smooth Transition**: Changes to the contextual section should be visually smooth
2. **Global Section Consistency**: Global section must remain visually stable
3. **Clear Indication**: Provide visual feedback indicating the module change
4. **State Preservation**: Maintain filter states for both global and per-module contexts

### 5. Implementation Pattern

All hybrid sidebars must be implemented following the UI-Server-Defaults Triple Rule (R0011):

- **UI Component**: Defines the sidebar layout with global and contextual sections
- **Server Component**: Manages state and handles filter changes
- **Defaults Component**: Provides fallback values for all controls

## Implementation Examples

### Example 1: Basic Hybrid Sidebar Implementation

```r
# UI Component
sidebarHybridUI <- function(id, active_module = "main") {
  ns <- NS(id)
  
  sidebar(
    # =========================================
    # Global Section - Consistent across modules
    # =========================================
    selectInput(
      inputId = ns("product_category"),
      label = "商品種類",
      choices = NULL  # Will be populated by server
    ),
    
    selectInput(
      inputId = ns("channel"),
      label = "銷售通路",
      choices = list("Amazon" = "amazon", "官網" = "official")
    ),
    
    # Visual separator
    tags$hr(style = "border-top: 1px solid #ddd; margin: 15px 0;"),
    
    # Module label
    tags$div(
      style = "text-align: center; margin-bottom: 10px;",
      tags$span(
        class = "badge bg-primary",
        style = "font-size: 0.9rem;",
        textOutput(ns("active_module_label"))
      )
    ),
    
    # =========================================
    # Contextual Section - Module-specific
    # =========================================
    
    # Main module controls
    conditionalPanel(
      condition = sprintf("input['%s'] == 'main'", ns("active_module_hidden")),
      dateRangeInput(
        inputId = ns("date_range_main"),
        label = "日期範圍",
        start = Sys.Date() - 365,
        end = Sys.Date()
      )
    ),
    
    # Micro module controls
    conditionalPanel(
      condition = sprintf("input['%s'] == 'micro'", ns("active_module_hidden")),
      textInput(
        inputId = ns("customer_search"),
        label = "顧客搜尋",
        placeholder = "輸入顧客 ID 或名稱"
      ),
      sliderInput(
        inputId = ns("recency_filter"),
        label = "最近購買 (R)",
        min = 0,
        max = 365,
        value = c(0, 365)
      )
    ),
    
    # Macro module controls
    conditionalPanel(
      condition = sprintf("input['%s'] == 'macro'", ns("active_module_hidden")),
      selectInput(
        inputId = ns("aggregation_level"),
        label = "資料彙總層級",
        choices = list(
          "產品類別" = "product_category",
          "地區" = "region"
        )
      )
    ),
    
    # Hidden input to store current module
    tags$div(
      style = "display: none;",
      textInput(ns("active_module_hidden"), NULL, value = active_module)
    ),
    
    # Apply filters button
    actionButton(
      inputId = ns("apply_filters"),
      label = "套用篩選條件",
      width = "100%",
      class = "btn-primary mt-3"
    )
  )
}
```

### Example 2: Module Navigation with Hybrid Sidebar

```r
# UI Definition
ui <- page_sidebar(
  title = "Precision Marketing App",
  sidebar = sidebarHybridUI("sidebar", active_module = "main"),
  
  # Navigation with module-specific content
  navset_pill(
    id = "nav",
    nav_panel("Overview", ...), # Main module
    nav_panel("Micro", ...),    # Micro module
    nav_panel("Macro", ...)     # Macro module
  )
)

# Server Logic
server <- function(input, output, session) {
  # Initialize sidebar with main module
  filters <- sidebarHybridServer("sidebar", active_module = "main", ...)
  
  # Update sidebar when navigation changes
  observeEvent(input$nav, {
    # Map navigation to module
    active_module <- switch(input$nav,
      "Overview" = "main",
      "Micro" = "micro",
      "Macro" = "macro",
      "main" # Default
    )
    
    # Replace sidebar with new module context
    removeUI(selector = "#sidebar-content")
    insertUI(
      selector = "#sidebar-placeholder",
      where = "afterBegin",
      ui = div(
        id = "sidebar-content",
        sidebarHybridUI(paste0("sidebar_", active_module), 
                        active_module = active_module)
      )
    )
    
    # Initialize new sidebar server
    new_filters <- sidebarHybridServer(
      paste0("sidebar_", active_module), 
      active_module = active_module,
      ...
    )
  })
}
```

## Relationship to Other Principles

### Relation to Modularity Principle (MP0016)

The Hybrid Sidebar Pattern supports modularity by:

1. **Encapsulating Module-Specific Controls**: Each module's filters are encapsulated within its contextual section
2. **Promoting Component Independence**: Modules can define their own controls without affecting others
3. **Enabling Component Reuse**: The pattern can be applied consistently across different applications
4. **Maintaining Coherence**: Related controls are grouped together in logical units

### Relation to Separation of Concerns Principle (MP0017)

The pattern implements separation of concerns through:

1. **Global vs. Local Separation**: Clearly distinguishing global filters from module-specific ones
2. **Visual Demarcation**: Using dividers to separate different concerns
3. **Logical Grouping**: Organizing controls based on their scope and purpose
4. **State Management Separation**: Handling global and module-specific state independently

### Relation to UI-Server-Defaults Triple Rule (R0011)

The Hybrid Sidebar Pattern extends the Triple Rule by:

1. **Triple Implementation**: Requiring implementation as UI, server, and defaults components
2. **Component Organization**: Following the folder-based organization pattern
3. **Default Value Handling**: Providing fallbacks for all controls
4. **Consistent Naming**: Following the naming conventions established in R11

### Relation to Package Consistency Principle (MP0019)

The pattern follows package consistency by:

1. **Convention Alignment**: Using naming conventions from Shiny ecosystem
2. **Function Naming**: Using camelCase with appropriate suffixes
3. **File Organization**: Matching file names to function names
4. **Interface Consistency**: Following established Shiny module patterns

## Benefits

1. **Improved User Experience**: Users always have access to essential filters while seeing contextual controls when needed
2. **Cognitive Efficiency**: Reduces cognitive load by only showing relevant controls
3. **Spatial Consistency**: Creates predictable UI patterns that users can learn
4. **Visual Organization**: Clearly separates global from contextual concerns
5. **State Preservation**: Maintains filter settings when switching between views
6. **Reduced Clutter**: Avoids overwhelming users with too many controls
7. **Contextual Relevance**: Provides the right tools at the right time
8. **Space Optimization**: Makes efficient use of limited sidebar space

## Conclusion

The Hybrid Sidebar Pattern creates a balanced approach to sidebar design that provides both consistency and contextual relevance. By maintaining global filters that persist across the application while providing specialized controls for each module, this pattern creates an intuitive and efficient user experience. 

The pattern ensures that users always have access to essential filters while also seeing the specific tools they need for their current task. This balance of consistency and specialization supports effective user interactions while maintaining a clean and organized interface.
