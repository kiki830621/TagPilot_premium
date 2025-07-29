# R108: Function Deployment Rule

## 🔄 Principle Overview

This rule establishes the proper implementation patterns for deploying functions in Shiny applications, ensuring they are properly scoped, initialized at the right time, and explicitly passed to components when needed.

## 🧩 Rule Definition

Functions must be correctly implemented with appropriate scope considerations, properly initialized early in the application lifecycle, and explicitly passed to components that require them.

## 📋 Requirements

1. **Early Definition**: Define critical functions early in the initialization process, before any UI components or server logic attempts to use them.

2. **Proper Global Assignment**: For functions requiring global scope, use explicit assignment to `.GlobalEnv` instead of relying on implicit scoping rules.

3. **Explicit Function Passing**: Pass functions explicitly to components as parameters rather than relying on their global availability.

4. **Fallback Mechanisms**: Include fallback mechanisms for critical functions to prevent application failure if the function isn't available in the expected scope.

5. **Scope Awareness**: Be mindful of scope boundaries, especially in reactive contexts where function availability may change.

## 💻 Implementation Patterns

### Global Function Assignment

```r
# Early in your initialization code:
my_function <- function(args) {
  # Function logic here
  return(result)
}

# Ensure global availability when needed
assign("my_function", my_function, envir = .GlobalEnv)
```

### Function Existence Checking

```r
# Check for function existence in component initialization
if (!exists("required_function") || !is.function(required_function)) {
  warning("Required function not found. Using fallback.")
  required_function <- function(...) {
    # Default implementation
    warning("Using fallback implementation")
    return(NULL)
  }
}
```

### Explicit Function Passing

```r
# Pass explicitly to components
my_component <- createComponent(
  id = "component_id",
  data_connection = some_connection,
  processor_function = my_function  # Pass the function explicitly
)
```

## ⚠️ Common Issues to Avoid

1. **Late Definition**: Defining functions after code that depends on them has already executed.

2. **Incorrect Assignment**: Using `<<-` which is the non-local assignment operator but not reliable for creating truly global variables in Shiny contexts.

3. **Scope Confusion**: Not understanding R's lexical scoping rules, causing functions to be inaccessible where needed.

4. **Missing Fallbacks**: Not providing fallback mechanisms for critical functions.

5. **Implicit Dependency**: Assuming functions will be available without explicit passing.

## 🔄 Related Principles

- **R102**: Shiny Reactive Observation Rule
- **MP31**: Initialization First
- **R95**: Import Requirements Rule
- **R21**: One Function One File
- **R67**: Functional Encapsulation

## 📝 Notes

When developing complex Shiny applications with multiple components, proper function deployment is critical. Common issues include:

1. Functions being defined too late in the application lifecycle
2. Functions not being properly assigned to the appropriate environment
3. Relying on implicit scoping rather than explicit function passing
4. Lack of fallback mechanisms for critical functionality

By following this rule, you ensure consistent function availability throughout your application regardless of the execution context.