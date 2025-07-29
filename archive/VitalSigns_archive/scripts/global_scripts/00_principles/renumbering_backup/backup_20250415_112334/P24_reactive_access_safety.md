# P24: Reactive Value Access Safety

## Context
In reactive programming frameworks like Shiny, values are often wrapped in reactive containers to manage dependencies and trigger updates when values change. However, incorrect access patterns can lead to runtime errors that are difficult to debug.

## Principle
**Reactive values must always be accessed using the appropriate access pattern for their specific reactive container type, and direct access to reactive containers should be prevented through static analysis.**

## Rationale
1. **Type Confusion**: Reactive objects look like regular R objects but behave differently, leading to type confusion errors.

2. **Runtime Errors**: Incorrect access to reactive values often manifests as runtime errors rather than compile-time errors.

3. **Cascading Failures**: Errors in reactive access can cause cascading failures throughout a reactive system.

4. **Silent Failures**: Some reactive access errors produce silent failures that are hard to detect.

5. **Consistency**: Consistent access patterns make code more readable and maintainable.

## Implementation
Safe reactive value access requires:

1. **Appropriate Function Calls**:
   - `reactive()` values must be called as functions: `value()`
   - `reactiveVal()` values must be called as functions: `value()`
   - `reactiveValues()` elements must be accessed as: `values$element`

2. **Static Analysis**:
   - Use linting tools to detect inappropriate access patterns
   - Include checks in build processes to prevent deployment of code with unsafe access

3. **Defensive Programming**:
   - Always check if reactive values are NULL or invalid before using them
   - Use safe access patterns like tryCatch when calling reactive expressions
   - Provide reasonable defaults for when reactive values are unavailable

4. **Verification**:
   - Test reactive expressions with mock inputs to ensure proper access
   - Add specific tests that verify correct behavior when reactive values are not yet available

## Examples

### Example 1: Safe Reactive Expression Access
```r
# BAD - Direct access to reactive expression
if (search_results) { # Error: invalid argument type
  show_results()
}

# GOOD - Proper function call
if (search_results()) {
  show_results()
}
```

### Example 2: Safe ReactiveVal Access
```r
# BAD - Direct access to reactiveVal
active_tab_name <- active_tab # Error: wrong, doesn't access the current value

# GOOD - Proper function call
active_tab_name <- active_tab()
```

### Example 3: Safe Null Handling
```r
# BAD - Assuming non-NULL value
current_filter <- filters()$selected_filter # Error if filters() returns NULL

# GOOD - Safe access with NULL check
result <- tryCatch({
  filters_value <- filters()
  if (is.null(filters_value)) NULL else filters_value$selected_filter
}, error = function(e) NULL)
```

## Related Principles
- SLN01: Handling Non-Logical Data Types in Logical Contexts
- P23: Exception-Driven Rule Evolution

## Applications
This principle should be applied:
- Throughout all reactive UI and server code
- When integrating new UI components that use reactive values
- During code reviews of reactive systems
- When debugging type-related errors in reactive applications

By consistently following safe reactive access patterns, the system becomes more robust and errors become easier to locate and fix.