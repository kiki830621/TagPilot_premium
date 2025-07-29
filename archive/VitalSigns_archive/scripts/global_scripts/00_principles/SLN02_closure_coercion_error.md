# SLN02: Closure Coercion Errors in UI Component Generation

**Solution Note**: When creating component visibility lists, use explicit logical values instead of functions/closures to prevent type coercion errors.

## Problem Description

When generating UI components with dynamic visibility (particularly in oneTimeUnionUI2), an error occurs when a list or vector containing closures (functions) is passed to a context where character values are expected:

```
Warning: Error in as.character: cannot coerce type 'closure' to vector of type 'character'
```

This typically occurs when:

1. Using `lapply()` to generate visibility conditions
2. Using reactive functions in non-reactive contexts
3. Returning a function reference instead of a function's return value

## Root Cause Analysis

In R, when a list is created using `lapply()` with an anonymous function, each element of the resulting list can actually be a closure (function) rather than the intended result value, especially in non-standard evaluation contexts.

For example:
```r
# Creates a list of FUNCTIONS, not logical values
initial_visibility <- setNames(
  lapply(tab_names, function(name) name == tab_names[1]),
  tab_names
)
```

The above code does not immediately evaluate `name == tab_names[1]` for each item; it creates a list of functions that *will* evaluate the expression when called.

## Solution Approach

Replace function-generating list operations with explicit value assignments:

```r
# Explicitly create logical values
initial_visibility <- list()
for (name in tab_names) {
  initial_visibility[[name]] <- (name == tab_names[1])
}
```

This ensures each list element contains the actual logical value (TRUE/FALSE) rather than a function that will compute this value when called.

## Prevention Techniques

1. **Avoid Implicit Function Creation**: Be cautious with `lapply()` in UI generation contexts
2. **Force Immediate Evaluation**: When using `lapply()`, force evaluation with `force()` or explicit type conversion
3. **Use Direct Loop Construction**: For critical components, use explicit `for` loops to build lists
4. **Type Checking**: Add validation to ensure values are of expected types before using them

## Implementation

When creating UI component unions, especially with the `oneTimeUnionUI2` function:

```r
# PROBLEMATIC APPROACH
initial_visibility <- setNames(
  lapply(tab_names, function(name) name == tab_names[1]),
  tab_names
)

# CORRECT APPROACH
initial_visibility <- list()
for (name in tab_names) {
  initial_visibility[[name]] <- (name == tab_names[1])
}
```

## Related Principles

- SLN01: Type Safety in Logical Contexts
- P22: CSS Controls Over Shiny Conditionals
- MP28: NSQL Set Theory Foundations