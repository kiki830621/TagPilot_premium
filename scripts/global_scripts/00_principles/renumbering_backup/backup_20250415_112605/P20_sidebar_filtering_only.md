# P20: Sidebar Filtering Only

## Definition
Sidebars in applications should be used exclusively for data filtering controls, maintaining a clear separation from navigation, content display, and action controls.

## Explanation
The sidebar is a key navigational and organizational element in modern web applications. By dedicating sidebars solely to filtering functionality, we create a consistent mental model for users and a cleaner separation of concerns in the application architecture.

This principle:
1. Creates a consistent location for all filtering controls
2. Prevents confusion between filtering and navigation actions
3. Reinforces the user's mental model of data filtering
4. Simplifies component reuse and modularity

## Implementation Guidelines

### What SHOULD be in a sidebar:
- Data filtering controls (dropdowns, checkboxes, sliders)
- Filter parameter selection (date ranges, categories, regions)
- Filter application and reset buttons
- Filter state indicators or summaries
- Collapsible filter groups

### What should NOT be in a sidebar:
- Navigation links or tabs
- Action buttons (save, export, etc.) unrelated to filtering
- Data visualizations or content display
- User profile information or settings
- Application-wide controls

### Design Considerations
- Ensure all sidebar controls clearly communicate their filtering purpose
- Group related filters logically
- Provide clear visual feedback when filters are applied
- Allow for easy resetting of filter values
- Consider collapsible sections for complex filtering needs

## Examples

**Good Implementation:**
```r
# Sidebar contains only filtering controls
sidebarUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    selectInput(ns("region"), "Region", choices = regions),
    dateRangeInput(ns("date_range"), "Date Range"),
    sliderInput(ns("price_range"), "Price Range", min = 0, max = 1000, value = c(0, 1000)),
    actionButton(ns("apply_filters"), "Apply Filters")
  )
}
```

**Bad Implementation:**
```r
# Sidebar mixes filtering and navigation
sidebarUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Filtering controls
    selectInput(ns("region"), "Region", choices = regions),
    dateRangeInput(ns("date_range"), "Date Range"),
    
    # Should NOT be in sidebar
    hr(),
    navlistPanel(
      tabPanel("Dashboard", icon = icon("dashboard")),
      tabPanel("Reports", icon = icon("file-alt"))
    ),
    hr(),
    actionButton(ns("export_data"), "Export Data")
  )
}
```

## Related Principles
- P21: Component N-tuple Pattern
- R54: Component Folder Organization
- MP17: Separation of Concerns