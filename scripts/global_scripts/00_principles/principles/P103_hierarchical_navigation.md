# P103: Hierarchical Navigation Principle

## Core Principle

The UI should implement a clear hierarchy of navigation elements, with primary navigation at the top level and consistent secondary navigation within each primary section. This hierarchical approach makes the application's structure intuitive and provides clear context for user interactions.

## Implementation Requirements

1. **Top-Level Navigation**:
   - Use bs4Dash navbarMenu and navbarTab components for primary navigation (following R92)
   - Place at the top of the interface in a consistent location
   - Clearly distinguish active vs. inactive states
   - Focus on major application sections/modules

2. **Second-Level Navigation**:
   - Implement using action buttons at the top of each primary section's content
   - Apply consistent styling for all second-level navigation elements
   - Ensure buttons have both icon and text for improved usability
   - Place in a container with proper spacing and alignment
   - Use active/inactive visual styling to indicate current selection

3. **Navigation State Management**:
   - Track active state for each level of navigation independently
   - Use reactive values for managing the active state
   - Implement proper event handlers to update navigation state
   - Ensure content visibility toggles correctly with navigation changes

4. **Visual Consistency**:
   - Maintain consistent height and alignment of all navigation elements
   - Follow P99: Single-Line UI Elements Principle for button layout
   - Use minimal CSS following P101: Minimal CSS Usage Principle
   - Apply proper spacing between navigation levels
   - Ensure clear visual hierarchy between primary and secondary navigation

## Benefits

1. **Improved User Experience**:
   - Intuitive navigation flow from general to specific
   - Clear visual indicators of current location in the application
   - Reduced cognitive load through consistent patterns

2. **Maintenance Benefits**:
   - Standardized approach for implementing navigation
   - Clearer code organization separating navigation levels
   - Easier to extend with additional sections or sub-sections

3. **Performance Advantages**:
   - Reduced server load by toggling visibility rather than rebuilding UI
   - Minimized UI redraws when switching between secondary options
   - Better responsiveness for navigation interactions

## Implementation Examples

### Top-Level Navigation (R92)

```r
# In UI definition
header = bs4Dash::dashboardHeader(
  navbarMenu(
    id = "main_navbar",
    navbarTab(
      text = HTML('<span class="navbarTab-content"><i class="fa fa-user mr-1"></i><span>Micro Analysis</span></span>'),
      tabName = "micro_tab"
    ),
    navbarTab(
      text = HTML('<span class="navbarTab-content"><i class="fa fa-chart-bar mr-1"></i><span>Macro Analysis</span></span>'),
      tabName = "macro_tab"
    )
  )
)
```

### Second-Level Navigation

```r
# In UI definition
div(
  class = "second-level-nav-container",
  bs4Dash::box(
    width = 12,
    status = "primary",
    solidHeader = FALSE,
    uiOutput("micro_subtabs")
  )
)

# In server function
micro_active_subtab <- reactiveVal("customer")

output$micro_subtabs <- renderUI({
  div(
    class = "d-flex justify-content-center my-2",
    actionButton(
      inputId = "micro_subtab_customer",
      label = translate("Customer Profile"),
      icon = icon("user"),
      class = paste0("btn ", if(micro_active_subtab() == "customer") "btn-primary" else "btn-default"),
      style = "margin: 5px; min-width: 120px;"
    ),
    actionButton(
      inputId = "micro_subtab_dna",
      label = translate("DNA Distribution"),
      icon = icon("dna"),
      class = paste0("btn ", if(micro_active_subtab() == "dna") "btn-primary" else "btn-default"),
      style = "margin: 5px; min-width: 120px;"
    )
  )
})
```

### Event Handling for Navigation

```r
# Handle clicks on micro subtabs
observeEvent(input$micro_subtab_customer, {
  micro_active_subtab("customer")
  
  # Toggle component visibility
  if (!is.null(micro_components_union) && 
      !is.null(micro_components_union$component_state) && 
      is.function(micro_components_union$component_state$toggle_component)) {
    micro_components_union$component_state$toggle_component("customer", TRUE)
    micro_components_union$component_state$toggle_component("dna", FALSE)
  }
})
```

## Relationship to Other Principles

- **Implements**: MP17: Modularity Principle, MP99: UI Separation Meta Principle
- **Builds Upon**: R92: bs4Dash Navbar Navigation Rule, R11: Hybrid Sidebar Pattern
- **Related To**: P99: Single-Line UI Elements Principle, P101: Minimal CSS Usage Principle, R14: UI Hierarchy Rule

## Conclusion

The Hierarchical Navigation Principle provides a structured approach to implementing multi-level navigation in the application. By clearly defining and separating top-level and second-level navigation, it creates an intuitive user experience that helps users navigate effectively through the application. This principle complements existing UI principles while addressing the specific requirements of hierarchical navigation structure.