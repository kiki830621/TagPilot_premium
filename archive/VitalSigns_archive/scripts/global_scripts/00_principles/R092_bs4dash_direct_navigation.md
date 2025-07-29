# R0092: bs4Dash Navbar Navigation Rule

## Rule Statement

In bs4Dash applications, top-level navigation should be implemented using the bs4Dash navbar navigation components. This provides a consistent, maintainable, and efficient navigation pattern that leverages the built-in features of the bs4Dash package.

## Rationale

1. **Consistency**: Using bs4Dash navbar components for top-level navigation creates a consistent user experience that follows Bootstrap 4 Admin Dashboard conventions.

2. **Built-in Functionality**: The bs4Dash navbar components provide built-in functionality for responsive design, dropdown menus, and proper styling with minimal custom code.

3. **Maintainability**: Standard navbar patterns are easier to maintain than custom navigation implementations or button-based alternatives.

4. **Performance**: bs4Dash navbar components utilize optimized Bootstrap 4 components for efficient rendering and interaction.

5. **Accessibility**: Using proper semantic navigation elements improves keyboard navigation and screen reader compatibility.

## Implementation Guidelines

1. **Use bs4Dash Navbar Components for Top-Level Navigation**:
   - Implement the `bs4Dash::dashboardHeader()` with proper navbarMenu structure
   - Use `bs4Dash::navbarMenu()` as the container for navigation items
   - Use `bs4Dash::navbarTab()` for individual navigation links
   - Use nested navbarTab elements to create hierarchical navigation menus

2. **Use Action Buttons for Second-Level Navigation**:
   - Implement second-level navigation using a row of `actionButton()` components
   - Place buttons in a prominent location at the top of each tab's content
   - Style buttons consistently using `class` parameters
   - Use conditional styling to indicate the active second-level tab
   - Example styling:
     ```r
     actionButton(
       inputId = paste0(comp_name, "_subtab_", subtab_name),
       label = subtab_title,
       icon = icon(subtab_icon),
       class = paste0("btn ", if(active_subtab() == subtab_name) "btn-primary" else "btn-default"),
       style = "margin: 5px; min-width: 120px;"
     )
     ```

3. **For Sidebar Navigation**:
   - Continue using bs4Dash's `sidebarMenu()` and `menuItem()` components
   - Sidebar should complement the navbar, not duplicate it
   - Use sidebar for context-specific or secondary navigation

4. **Navigation Structure**:
   - Top navbar: Primary application sections/modules
   - Second-level buttons: Sub-components/views within a module
   - Sidebar: Context-specific options for the current section
   - Use consistent IDs and naming conventions

5. **Styling and Layout**:
   - Use the built-in navbar classes and styling for top-level navigation
   - Use standard Bootstrap button classes for second-level navigation
   - Maintain the standard layout with proper alignment
   - Follow P0099: Single-Line UI Elements Principle for all navigation components

6. **Event Handling**:
   - Use the built-in tab-based navigation for top-level tabs
   - For second-level navigation, create direct `observeEvent()` handlers for each button
   - Use `updateNavbarTabs()` for programmatic top-level navigation
   - Use reactive values to track the active second-level tab
   - Example second-level handler:
     ```r
     # Create a reactive to track active sub-tab
     active_subtab <- reactiveVal("details")
     
     # Handle button click
     observeEvent(input[[paste0(comp_name, "_subtab_", subtab_name)]], {
       active_subtab(subtab_name)
       
       # Show/hide the appropriate content sections
       for (section in subtab_names) {
         shinyjs::toggle(paste0(comp_name, "_section_", section), condition = section == subtab_name)
       }
     })
     ```

## Examples

### Good Implementation (Following the Rule)

```r
if (interactive()) {
  library(shiny)
  library(bs4Dash)
  library(shinyjs)
  
  # Create tab items for the body content with second-level navigation
  tabs <- tabItems(
    # First tab with second-level navigation using buttons
    tabItem(
      tabName = "Tab1",
      fluidRow(
        column(
          width = 12,
          # Second-level navigation using action buttons
          box(
            title = "Tab 1 Navigation",
            width = 12,
            status = "primary",
            solidHeader = FALSE,
            # Row of buttons for second-level navigation
            div(
              class = "d-flex justify-content-center",
              actionButton("tab1_subtab_details", "Details", 
                           icon = icon("info-circle"), 
                           class = "btn btn-primary mx-2"),
              actionButton("tab1_subtab_history", "History", 
                           icon = icon("history"), 
                           class = "btn btn-default mx-2"),
              actionButton("tab1_subtab_settings", "Settings", 
                           icon = icon("cog"), 
                           class = "btn btn-default mx-2")
            )
          )
        )
      ),
      # Content for each second-level tab
      div(id = "tab1_content_details", plotOutput("detailsPlot")),
      div(id = "tab1_content_history", style = "display: none;", tableOutput("historyTable")),
      div(id = "tab1_content_settings", style = "display: none;", verbatimTextOutput("settingsText"))
    ),
    
    # Simple tab without second-level navigation
    tabItem(
      tabName = "Tab2",
      h2("Tab 2 Content"),
      plotOutput("tab2Plot")
    ),
    
    # Additional tabs
    tabItem(tabName = "Tab3", h2("Tab 3"), verbatimTextOutput("tab3Text")),
    tabItem(tabName = "Tab4", h2("Tab 4"), tableOutput("tab4Table")),
    tabItem(tabName = "Tab5", h2("Tab 5"), plotOutput("tab5Plot")),
    tabItem(tabName = "Tab6", h2("Tab 6"), verbatimTextOutput("tab6Text")),
    tabItem(tabName = "Tab7", h2("Tab 7"), plotOutput("tab7Plot"))
  )
  
  shinyApp(
    ui = dashboardPage(
      header = dashboardHeader(
        # Using the navbarMenu component for top-level navigation
        navbarMenu(
          id = "navmenu",
          # Direct tab links
          navbarTab(tabName = "Tab1", text = "Tab 1"),
          navbarTab(tabName = "Tab2", text = "Tab 2"),
          # Dropdown menu with nested items
          navbarTab(
            text = "Menu",
            dropdownHeader("Dropdown header"),
            navbarTab(tabName = "Tab3", text = "Tab 3"),
            dropdownDivider(),
            navbarTab(
              text = "Sub menu",
              dropdownHeader("Another header"),
              navbarTab(tabName = "Tab4", text = "Tab 4"),
              dropdownHeader("Yet another header"),
              navbarTab(tabName = "Tab5", text = "Tab 5"),
              # Deeply nested menu
              navbarTab(
                text = "Sub sub menu",
                navbarTab(tabName = "Tab6", text = "Tab 6"),
                navbarTab(tabName = "Tab7", text = "Tab 7")
              )
            )
          )
        )
      ),
      body = dashboardBody(
        useShinyjs(),  # Enable shinyjs for toggling content
        tabs
      ),
      controlbar = dashboardControlbar(
        sliderInput(
          inputId = "controller",
          label = "Update the first tabset",
          min = 1,
          max = 4,
          value = 1
        )
      ),
      sidebar = dashboardSidebar(disable = TRUE)
    ),
    server = function(input, output, session) {
      # Create a reactive to track the active sub-tab
      active_subtab <- reactiveVal("details")
      
      # Handle second-level navigation for Tab 1
      observeEvent(input$tab1_subtab_details, {
        active_subtab("details")
        
        # Update button styles
        updateActionButton(session, "tab1_subtab_details", class = "btn btn-primary mx-2")
        updateActionButton(session, "tab1_subtab_history", class = "btn btn-default mx-2")
        updateActionButton(session, "tab1_subtab_settings", class = "btn btn-default mx-2")
        
        # Show/hide content
        shinyjs::show("tab1_content_details")
        shinyjs::hide("tab1_content_history")
        shinyjs::hide("tab1_content_settings")
      })
      
      observeEvent(input$tab1_subtab_history, {
        active_subtab("history")
        
        # Update button styles
        updateActionButton(session, "tab1_subtab_details", class = "btn btn-default mx-2")
        updateActionButton(session, "tab1_subtab_history", class = "btn btn-primary mx-2")
        updateActionButton(session, "tab1_subtab_settings", class = "btn btn-default mx-2")
        
        # Show/hide content
        shinyjs::hide("tab1_content_details")
        shinyjs::show("tab1_content_history")
        shinyjs::hide("tab1_content_settings")
      })
      
      observeEvent(input$tab1_subtab_settings, {
        active_subtab("settings")
        
        # Update button styles
        updateActionButton(session, "tab1_subtab_details", class = "btn btn-default mx-2")
        updateActionButton(session, "tab1_subtab_history", class = "btn btn-default mx-2")
        updateActionButton(session, "tab1_subtab_settings", class = "btn btn-primary mx-2")
        
        # Show/hide content
        shinyjs::hide("tab1_content_details")
        shinyjs::hide("tab1_content_history")
        shinyjs::show("tab1_content_settings")
      })
      
      # Example of programmatic top-level navigation with updateNavbarTabs
      observeEvent(input$controller, {
        updateNavbarTabs(
          session,
          inputId = "navmenu",
          selected = paste0("Tab", input$controller)
        )
      },
      ignoreInit = TRUE
      )
      
      # Sample outputs for the various tabs
      output$detailsPlot <- renderPlot({ plot(1:10, main = "Details Plot") })
      output$historyTable <- renderTable({ data.frame(Date = Sys.Date() - 0:5, Value = rnorm(6)) })
      output$settingsText <- renderText({ "Configuration settings would appear here" })
      output$tab2Plot <- renderPlot({ barplot(1:5, main = "Tab 2 Plot") })
      output$tab3Text <- renderText({ "Tab 3 Content" })
      output$tab4Table <- renderTable({ data.frame(A = 1:3, B = 4:6) })
      output$tab5Plot <- renderPlot({ hist(rnorm(100)) })
      output$tab6Text <- renderText({ "Tab 6 Content" })
      output$tab7Plot <- renderPlot({ plot(cars) })
    }
  )
}
```

### Poor Implementation (Violating the Rule)

```r
# Avoiding bs4Dash navbarMenu and implementing custom navigation - violating the rule
ui <- bs4Dash::dashboardPage(
  header = bs4Dash::dashboardHeader(
    title = "My Dashboard",
    # Not using the proper navbar components
    leftUi = NULL,
    rightUi = NULL
  ),
  sidebar = bs4Dash::dashboardSidebar(),
  body = bs4Dash::dashboardBody(
    # Custom navigation div instead of using navbarMenu components
    div(
      class = "navigation-container",
      uiOutput("dynamicNavigation")
    ),
    
    # Content containers
    uiOutput("dynamicContent")
  )
)

# Custom navigation management instead of using bs4Dash tabs
server <- function(input, output, session) {
  # Using reactive values for navigation state instead of bs4Dash tabs
  nav_state <- reactiveValues(
    current_view = "view1"
  )
  
  # Dynamic navigation rendering instead of static navbar
  output$dynamicNavigation <- renderUI({
    div(
      class = "custom-navbar",
      actionButton("nav_view1", "View 1", 
                   class = if(nav_state$current_view == "view1") "active" else ""),
      actionButton("nav_view2", "View 2", 
                   class = if(nav_state$current_view == "view2") "active" else "")
    )
  })
  
  # Manual observers instead of using bs4Dash built-in tab switching
  observeEvent(input$nav_view1, {
    nav_state$current_view <- "view1"
  })
  
  observeEvent(input$nav_view2, {
    nav_state$current_view <- "view2"
  })
  
  # Custom content rendering instead of tabItems
  output$dynamicContent <- renderUI({
    switch(nav_state$current_view,
      "view1" = plotOutput("plot1"),
      "view2" = tableOutput("table1")
    )
  })
}
```

## Related Rules and Principles

- R0090: bs4Dash Structure Adherence Rule
- MP0099: UI Separation Meta Principle
- P0062: Separation of Concerns
- P0072: UI Package Consistency Principle
- P0073: Server-to-UI Data Flow Principle
- MP0017: Modularity Principle
