---
id: "R0014"
title: "UI Hierarchy Rule"
type: "rule"
date_created: "2025-04-03"
date_modified: "2025-04-03"
author: "Claude"
implements:
  - "MP0017": "Separation of Concerns Principle"
  - "P0004": "App Construction Principles"
related_to:
  - "P0012": "app.R Is Global Principle"
  - "R0011": "UI-Server-Defaults Triple Rule"
---

# UI Hierarchy Rule

## Core Requirement

The application UI must follow a strict hierarchical structure with `page_navbar` as the top-level container, and `page_sidebar` as a second-level container within navigation panels. This hierarchy ensures consistent navigation structure across applications while allowing module-specific sidebars.

## Implementation Requirements

### 1. Top-Level Navigation Structure

The top-level UI structure must be:

1. **Page Navbar**: The application must use `page_navbar()` as its outermost UI container
2. **Navigation Panels**: Content must be organized in `nav_panel()` components within the navbar
3. **Global Properties**: Title, theme, and navbar options should be set at the `page_navbar` level

### 2. Second-Level Sidebar Structure

Within navigation panels:

1. **Page Sidebar**: Each navigation panel should use `page_sidebar()` as its container
2. **Sidebar Component**: Each `page_sidebar()` must include a sidebar component from the sidebars directory
3. **Module-Specific Sidebars**: Each navigation panel should have its own sidebar instance with appropriate context

### 3. Module Content Structure

Within each `page_sidebar()`:

1. **Content Organization**: Content should be organized using appropriate layout components
2. **Component Composition**: Content should be composed from UI components in the components directory
3. **Consistent Patterns**: Content should follow consistent patterns for similar functionality

### 4. Prohibited Structures

The following UI structures are prohibited:

1. **Top-Level Page Sidebar**: Using `page_sidebar()` as the top-level container
2. **Sidebar Without Navigation**: Using sidebar components outside of navigation context
3. **Direct Content in Navbar**: Placing content directly in the navbar without a navigation panel
4. **Mixed Navigation Patterns**: Mixing different navigation patterns in the same application

## Implementation Examples

### Example 1: Proper UI Hierarchy

```r
ui <- page_navbar(
  title = config$title,
  theme = bs_theme(version = config$theme$version, bootswatch = config$theme$bootswatch),
  navbar_options = navbar_options(bg = "#f8f9fa"),
  
  # Navigation panels with module-specific sidebars
  nav_panel(
    title = "Micro Analysis",
    value = "micro",
    page_sidebar(
      sidebar = sidebarHybridUI("app_sidebar", active_module = "micro"),
      microCustomerUI("customer_module")
    )
  ),
  
  nav_panel(
    title = "Macro Analysis",
    value = "macro",
    page_sidebar(
      sidebar = sidebarHybridUI("macro_sidebar", active_module = "macro"),
      macroAnalysisUI("macro_module")
    )
  )
)
```

### Example 2: Incorrect UI Hierarchy (Violates Rule)

```r
# INCORRECT: page_sidebar at top level instead of page_navbar
ui <- page_sidebar(
  title = config$title,
  theme = bs_theme(version = config$theme$version, bootswatch = config$theme$bootswatch),
  
  sidebar = sidebarHybridUI("app_sidebar", active_module = "micro"),
  
  navset_pill(
    id = "main_nav",
    nav_panel(title = "Micro Analysis", value = "micro", microCustomerUI("customer_module")),
    nav_panel(title = "Macro Analysis", value = "macro", macroAnalysisUI("macro_module"))
  )
)
```

## Common Errors and Solutions

### Error 1: Missing Navigation Context

**Problem**: Using `page_sidebar()` as the top-level container.

**Solution**: 
- Use `page_navbar()` as the top-level container
- Place `page_sidebar()` within each navigation panel
- Create module-specific sidebars for each navigation panel

### Error 2: Single Sidebar Across All Modules

**Problem**: Using the same sidebar instance across all navigation panels.

**Solution**:
- Create separate sidebar instances for each navigation panel
- Use module-specific sidebar configurations
- Ensure each sidebar has the appropriate context

### Error 3: Inconsistent Navigation Structure

**Problem**: Using different navigation patterns in different parts of the application.

**Solution**:
- Standardize on a single navigation pattern throughout the application
- Use `page_navbar()` consistently as the top-level container
- Ensure all modules follow the same navigation structure

### Error 4: Direct Content in Navbar

**Problem**: Placing content directly in the navbar without navigation panels.

**Solution**:
- Always use `nav_panel()` to organize content
- Place all content components within navigation panels
- Use appropriate layout containers within navigation panels

## Relationship to Other Principles

### Relation to Separation of Concerns Principle (MP0017)

This rule supports Separation of Concerns by:
1. **Navigation vs. Content**: Separating navigation structure from content
2. **Global vs. Module-Specific**: Separating global application structure from module-specific structure
3. **Layout vs. Functionality**: Separating layout concerns from functional concerns
4. **Context Boundaries**: Establishing clear boundaries between different navigation contexts

### Relation to App Construction Principles (P0004)

This rule implements App Construction Principles by:
1. **Consistent Structure**: Ensuring a consistent application structure
2. **Module Organization**: Supporting modular organization of the application
3. **Navigation Framework**: Establishing a clear navigation framework
4. **UI Composition**: Supporting composition of UI elements in a consistent way

### Relation to app.R Is Global Principle (P0012)

This rule complements app.R Is Global by:
1. **Standardized Structure**: Providing a standard top-level structure for all applications
2. **Reduced Decisions**: Reducing the number of structural decisions in the main app.R file
3. **Clear Patterns**: Establishing clear patterns for UI organization
4. **Consistency**: Ensuring consistency across applications

## Benefits

1. **Consistent User Experience**: Users encounter a familiar navigation structure across applications
2. **Module Independence**: Modules can have their own sidebars and navigation context
3. **Clear Organization**: UI components are organized in a clear, predictable hierarchy
4. **Simplified Development**: Developers follow a standard pattern for UI organization
5. **Better Maintenance**: UI structure is easier to understand and maintain
6. **Compatibility**: Ensures compatibility with Shiny's design patterns and best practices
7. **Scalability**: Application structure can scale to accommodate new modules and features
8. **Context Awareness**: UI components can be aware of their navigation context

## Conclusion

The UI Hierarchy Rule establishes a consistent, hierarchical structure for application UIs, with `page_navbar` as the top-level container and `page_sidebar` as a second-level container within navigation panels. This structure ensures a consistent user experience, supports module independence, and aligns with Shiny's design patterns. By following this rule, developers create applications that are easier to use, maintain, and extend.
