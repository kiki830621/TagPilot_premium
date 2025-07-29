# P101: Minimal CSS Usage Principle

## Principle Statement

CSS should be applied judiciously and only when necessary to achieve specific design goals, avoiding unnecessary complexity, excessive overrides, or styling that can be handled through native component properties. When CSS is required, it should be minimal, focused, and organized.

## Rationale

1. **Performance Optimization**: Minimal CSS reduces the performance overhead of the application, leading to faster load times and more responsive interfaces.

2. **Maintainability**: Fewer CSS rules and dependencies make the application easier to maintain, understand, and debug.

3. **Native Behavior Preservation**: Using built-in component styling and behavior where possible ensures consistent operation across different environments and browser versions.

4. **Long-term Stability**: Reduced CSS dependencies minimize the risk of future styling conflicts or incompatibilities during upgrades.

5. **Developer Efficiency**: A minimal CSS approach reduces the time developers spend troubleshooting styling inconsistencies or conflicts.

## Implementation Guidelines

1. **Use Native Component Properties First**:
   - Leverage built-in properties and configurations of UI components when possible
   - Only apply custom CSS when native properties cannot achieve the desired outcome
   - Consider using component libraries that already implement the desired styling

2. **Apply CSS Selectively**:
   - Target only the specific elements that require customization
   - Use class-based selectors rather than overly broad element selectors
   - Create focused, single-purpose classes for reusable styling patterns

3. **Organize CSS Efficiently**:
   - Separate CSS into logical files based on component or functionality
   - Document the purpose of CSS files and key style rules with clear comments
   - Maintain consistent naming conventions for classes and files

4. **Minimize CSS Dependencies**:
   - Use the minimum number of CSS files needed for the application
   - Avoid duplicate or overlapping style rules across multiple files
   - Consider CSS-in-JS approaches for component-specific styling when appropriate

5. **Prioritize Necessary Styling**:
   - Focus on CSS that enhances usability and accessibility
   - Implement styling that supports core functionality and user workflows
   - Limit decorative or purely aesthetic CSS that doesn't improve the user experience

## Examples

### Appropriate CSS Usage

```css
/* Minimal CSS targeting only what's needed */
.navbarTab-content {
  display: flex;
  align-items: center;
  height: 40px;
}

.navbarTab-content i {
  margin-right: 5px;
}
```

### Excessive CSS to Avoid

```css
/* Overly complex with unnecessary selectors and properties */
.navbar .nav-item .nav-link,
.navbar-nav .nav-item > a,
.nav-tabs .nav-link,
.navbarMenu a,
.navbarTab a,
.navbarMenu span,
.navbarTab span,
.main-header .nav-tabs .nav-link,
.main-header .navbar .nav-link {
  display: flex !important;
  flex-direction: row !important;
  align-items: center !important;
  justify-content: start !important;
  white-space: nowrap !important;
  width: auto !important;
  min-height: 40px !important;
  height: 40px !important;
  padding-top: 0 !important;
  padding-bottom: 0 !important;
  vertical-align: middle !important;
  line-height: 40px !important;
  box-sizing: border-box !important;
}
```

### Component Configuration First Approach

```r
# Good: Using component properties directly
bs4Dash::actionButton(
  inputId = "submit_btn",
  label = "Submit",
  icon = icon("paper-plane"),
  status = "primary",
  size = "md"  # Using built-in size property
)

# Avoid: Unnecessary CSS when component properties exist
bs4Dash::actionButton(
  inputId = "submit_btn",
  label = "Submit", 
  icon = icon("paper-plane")
) %>% 
  tagAppendAttributes(
    style = "background-color: #007bff; color: white; padding: 0.5rem 1rem; border-radius: 0.25rem;"
  )
```

## Related Principles and Rules

- P99: Single-Line UI Elements Principle
- P22: CSS Controls Over Shiny Conditionals
- R98: CSS Organization Rule
- MP99: UI Separation Meta Principle
- P77: Performance Optimization Principle