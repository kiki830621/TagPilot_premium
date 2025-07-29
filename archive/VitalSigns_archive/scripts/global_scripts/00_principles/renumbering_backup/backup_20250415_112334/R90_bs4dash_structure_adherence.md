# R90: bs4Dash Structure Adherence Rule

## Rule Statement

When using the bs4Dash package in Shiny applications, adhere strictly to its intended structural patterns and component hierarchy. Never attempt to override the core structural components with custom CSS or JavaScript.

## Rationale

1. **Compatibility**: bs4Dash is built on AdminLTE and Bootstrap 4, which have specific structural dependencies. Adhering to these structures ensures compatibility across components.

2. **Maintainability**: Following bs4Dash's conventions and structure ensures that code remains maintainable as the package evolves.

3. **Consistency**: By using standard bs4Dash patterns, the application maintains a consistent look and feel with other AdminLTE/bs4Dash applications.

4. **Stability**: The structure of bs4Dash components is tested and optimized for stability. Custom modifications can break this stability.

5. **Performance**: bs4Dash's structure is optimized for performance in Shiny applications, particularly for layout rendering and reactivity.

## Implementation Guidelines

1. **Use Standard Layout Components**:
   - Always use `dashboardPage` as the top-level container
   - Always use `dashboardHeader`, `dashboardSidebar`, and `dashboardBody` as direct children
   - Never attempt to relocate or restructure these core components

2. **Follow Component Conventions**:
   - Use bs4Dash components exactly as documented in their API
   - Adhere to the proper nesting hierarchy of components
   - Use the expected parameters and child components for each bs4Dash element

3. **Styling Approach**:
   - Use bs4Dash's built-in parameters for styling (status, color, etc.)
   - Add classes to existing components rather than changing their structure
   - Use bs4Dash themes and skins rather than custom CSS overrides when possible

4. **Avoid Structural Modification**:
   - Never use CSS to hide, reposition, or fundamentally alter bs4Dash structural components
   - Avoid JavaScript that changes the DOM structure of bs4Dash components
   - Do not try to convert or transform one bs4Dash component type into another

5. **Proper Navbars and Sidebars**:
   - Use `tabItems` and `tabItem` for content organization
   - Use `sidebarMenu` and `menuItem` for sidebar navigation
   - Use `dropdownMenu` and its child components for header notifications

## Examples

### Good Implementation (Following the Rule)

```r
# Proper bs4Dash structure
ui <- bs4Dash::dashboardPage(
  header = bs4Dash::dashboardHeader(
    title = "My Dashboard",
    # Using proper header content
    rightUi = bs4Dash::dropdownMenu(
      type = "notifications",
      bs4Dash::notificationItem(
        text = "System update completed",
        icon = icon("info")
      )
    )
  ),
  sidebar = bs4Dash::dashboardSidebar(
    # Using proper sidebar content
    bs4Dash::sidebarMenu(
      bs4Dash::menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      bs4Dash::menuItem("Reports", tabName = "reports", icon = icon("file"))
    )
  ),
  body = bs4Dash::dashboardBody(
    # Using proper body content
    bs4Dash::tabItems(
      bs4Dash::tabItem(tabName = "dashboard", 
        bs4Dash::box(
          title = "Summary", 
          plotOutput("summaryPlot")
        )
      ),
      bs4Dash::tabItem(tabName = "reports", 
        bs4Dash::box(
          title = "Reports",
          tableOutput("reportsTable")
        )
      )
    )
  )
)
```

### Poor Implementation (Violating the Rule)

```r
# Violating bs4Dash structure
ui <- bs4Dash::dashboardPage(
  # Improper structure - custom elements for core components
  header = div(class = "custom-header", 
    h2("Dashboard Title"), 
    div(class = "nav-buttons", actionButton("tab1", "Tab 1"), actionButton("tab2", "Tab 2"))
  ),
  
  # Using CSS to modify core structure
  sidebar = tags$head(tags$style(
    ".main-sidebar { width: 300px !important; }"
  )),
  
  # Improper content organization
  body = fluidPage(
    div(id = "my-custom-tabs",
      div(id = "tab1-content", "Tab 1 content"),
      div(id = "tab2-content", style = "display: none;", "Tab 2 content")
    ),
    
    # JavaScript to handle custom navigation
    tags$script("
      $('#tab1').click(function() {
        $('#tab1-content').show();
        $('#tab2-content').hide();
      });
      $('#tab2').click(function() {
        $('#tab2-content').show();
        $('#tab1-content').hide();
      });
    ")
  )
)
```

## Related Rules and Principles

- MP99: UI Separation Meta Principle
- P62: Separation of Concerns
- P72: UI Package Consistency Principle
- R09: UI-Server-Defaults Triple Rule
- R11: Hybrid Sidebar Pattern