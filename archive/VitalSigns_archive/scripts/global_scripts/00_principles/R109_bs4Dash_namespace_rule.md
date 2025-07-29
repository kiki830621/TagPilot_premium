# R109: bs4Dash Namespace Rule

## 🔄 Principle Overview

This rule establishes the requirement for explicit namespace prefixing of all bs4Dash functions in Shiny applications to prevent conflicts with other packages, particularly shinydashboard.

## 🧩 Rule Definition

All bs4Dash functions must be explicitly prefixed with the `bs4Dash::` namespace qualifier in Shiny applications, regardless of whether the package has been loaded with library() or not.

## 📋 Requirements

1. **Explicit Namespace**: Always use the `bs4Dash::` prefix for all bs4Dash functions, including:
   - Layout functions (dashboardPage, dashboardHeader, dashboardSidebar, dashboardBody, etc.)
   - UI components (valueBox, box, bs4Card, etc.)
   - Navigation elements (tabItems, tabItem, menuItem, etc.)
   - Theming functions (create_theme, bs4dash_vars, etc.)

2. **Prefer bs4Dash-Specific Functions**: When available, use bs4Dash-specific function names rather than generic ones:
   - Use `bs4Dash::bs4TabItem` instead of `bs4Dash::tabItem`
   - Use `bs4Dash::bs4TabItems` instead of `bs4Dash::tabItems`
   - Use `bs4Dash::bs4Card` instead of `bs4Dash::box`
   - Use `bs4Dash::bs4ValueBox` instead of `bs4Dash::valueBox`
   
   This provides double protection against namespace conflicts: both the namespace prefix and the distinct function name make the intention clear.

3. **Consistency**: Maintain consistency by prefixing all bs4Dash functions, even when:
   - The bs4Dash package is explicitly loaded with library()
   - No apparent conflicts exist in the current environment
   - Functions are used in commented code or examples

4. **Commented Code**: Add namespace prefixes even in commented-out code to ensure correctness if the code is later uncommented.

5. **Documentation**: Include examples with proper namespace prefixing in all documentation.

## 💻 Implementation Pattern

```r
# GOOD:
ui <- bs4Dash::dashboardPage(
  header = bs4Dash::dashboardHeader(title = "My App"),
  sidebar = bs4Dash::dashboardSidebar(
    bs4Dash::sidebarMenu(
      bs4Dash::menuItem("Dashboard", tabName = "dashboard")
    )
  ),
  body = bs4Dash::dashboardBody(
    bs4Dash::tabItems(
      bs4Dash::tabItem("dashboard",
        bs4Dash::box(
          title = "My Box",
          bs4Dash::valueBox(value = 10, subtitle = "Items")
        )
      )
    )
  )
)

# BEST:
ui <- bs4Dash::dashboardPage(
  header = bs4Dash::dashboardHeader(title = "My App"),
  sidebar = bs4Dash::dashboardSidebar(
    bs4Dash::sidebarMenu(
      bs4Dash::menuItem("Dashboard", tabName = "dashboard")
    )
  ),
  body = bs4Dash::dashboardBody(
    bs4Dash::bs4TabItems(
      bs4Dash::bs4TabItem("dashboard",
        bs4Dash::bs4Card(
          title = "My Box",
          bs4Dash::bs4ValueBox(value = 10, subtitle = "Items")
        )
      )
    )
  )
)

# INCORRECT:
ui <- dashboardPage(
  header = dashboardHeader(title = "My App"),
  sidebar = dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard")
    )
  ),
  body = dashboardBody(...)
)
```

## ⚠️ Common Conflicts to Avoid

1. **shinydashboard vs. bs4Dash**: Both packages provide functions with identical names such as:
   - dashboardPage, dashboardHeader, dashboardSidebar, dashboardBody
   - tabItems, tabItem, menuItem, menuSubItem
   - valueBox, box, infoBox

2. **Other UI Package Conflicts**: Be aware of potential conflicts with:
   - shiny.semantic
   - shinyMobile
   - shinymaterial
   - Other UI frameworks with similar component naming

## 🔄 Related Principles

- **MP58**: Namespace Conflict Avoidance
- **R90**: bs4Dash Structure Adherence Rule
- **R95**: Import Requirements Rule
- **MP19**: Package Consistency

## 📝 Notes

The bs4Dash package is commonly used alongside other UI packages, increasing the risk of namespace conflicts. By consistently using explicit namespace prefixes, you ensure that:

1. The correct implementation is always used
2. Code remains robust against changes in package loading order
3. Errors are avoided when functions from multiple UI packages are used
4. Maintenance is easier as namespaces clearly indicate where functions originate

The primary motivation for this rule is to prevent the subtle and hard-to-diagnose errors that can occur when the wrong implementation of a function is used due to namespace conflicts between bs4Dash and other packages, particularly shinydashboard.