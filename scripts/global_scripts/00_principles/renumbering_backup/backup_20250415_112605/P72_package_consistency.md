# P72: UI Package Consistency Principle

**Principle**: Applications should maintain UI component consistency by standardizing on a single UI framework package throughout the interface.

## Description

The UI Package Consistency Principle states that applications should use components from a single UI framework package consistently throughout the application, rather than mixing components from different UI packages or creating custom implementations of already-available components.

## Rationale

Adopting a consistent UI package approach:

1. **Visual Consistency**: Ensures uniform appearance, behavior, and styling across all UI elements
2. **Developer Efficiency**: Reduces the cognitive load of switching between different component APIs
3. **Maintenance Simplicity**: Centralizes dependency management and updates to a single package
4. **Performance Optimization**: Avoids loading multiple overlapping UI frameworks
5. **Documentation Clarity**: Makes it easier to onboard new developers who only need to learn one framework

## Implementation

1. **Primary Framework Selection**: Choose one primary UI framework based on requirements:
   - For Shiny dashboard applications, select either `bs4Dash`, `shinydashboard`, or `shinyMobile`
   - Once selected, use this framework exclusively for all supported component types

2. **Component Usage Guidelines**:
   - Always use the framework's native components over generic HTML or custom implementations
   - Example: Use `bs4Dash::valueBox()` instead of custom `div()` elements with similar styling
   - Example: Use `bs4Dash::box()` instead of `shiny::wellPanel()` when using bs4Dash

3. **Mixed Framework Migration**: When inheriting applications with mixed UI components:
   - Incrementally replace non-primary components with primary framework equivalents
   - Document the primary framework and target state for remaining components

4. **Component Feature Mapping**:
   - When migrating between frameworks, map component features explicitly:

```r
# INCORRECT: Mixing frameworks
shinydashboard::valueBox(...) # in one place
bs4Dash::valueBox(...)        # in another place

# CORRECT: Consistent usage
bs4Dash::valueBox(...)        # everywhere
```

## Exceptions

1. **Missing Components**: When the primary framework lacks a required component
2. **Performance-Critical Sections**: Where framework overhead is demonstrably problematic
3. **Embedded External Applications**: Self-contained modules from external sources
4. **Extension Components**: Components specifically designed to extend the primary framework

## References

* bs4Dash documentation: https://bs4dash.rinterface.com/
* shinydashboard documentation: https://rstudio.github.io/shinydashboard/
* shiny documentation: https://shiny.posit.co/

## Related Principles

* P22: CSS Controls Over Shiny Conditionals
* SLN02: Closure Coercion Errors in UI Component Generation