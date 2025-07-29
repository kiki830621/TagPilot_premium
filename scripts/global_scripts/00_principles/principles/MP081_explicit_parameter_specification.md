---
id: "MP0081"
title: "Explicit Parameter Specification Metaprinciple"
type: "meta-principle"
date_created: "2025-04-19"
author: "Claude"
derives_from:
  - "MP0000": "Axiomatization System"
  - "MP0047": "Functional Programming"
influences:
  - "R094": "Roxygen2 Function Examples Standard"
---

# Explicit Parameter Specification Metaprinciple

## Core Principle

**All functions must explicitly specify their parameters, ensuring clear documentation of input requirements, promoting code readability, and enabling proper function reuse.** Every function definition should include a complete list of parameters with appropriate types and descriptions.

## Conceptual Framework

The Explicit Parameter Specification Metaprinciple establishes a systematic approach to function definition that:

1. **Requires Complete Parameter Lists**: All inputs to a function must be explicitly declared as parameters
2. **Enforces Parameter Documentation**: Parameters must be clearly documented with types and descriptions
3. **Prohibits Implicit Parameters**: Functions should not rely on variables from parent scopes unless passed as parameters
4. **Promotes Interface Stability**: Clear parameter specifications create stable, predictable interfaces

## Theoretical Foundations

### 1. Function as Contract

This principle views functions as contracts between the implementer and the caller:

- **Explicit Inputs**: The contract clearly states what inputs are required
- **Explicit Outputs**: The contract clearly states what outputs will be produced
- **Error Conditions**: The contract specifies when and how it may fail
- **Side Effects**: Any side effects are explicitly documented

### 2. Parameter Types and Constraints

Parameter specifications should clearly communicate:

- **Type Information**: What type of data is expected (e.g., numeric, character, data frame)
- **Structural Constraints**: Requirements for data structure (e.g., columns in a data frame)
- **Value Constraints**: Limitations on allowed values (e.g., positive numbers only)
- **Default Values**: Sensible defaults when applicable

## Implementation Guidelines

### 1. Function Definition Pattern

Functions should be defined following this pattern:

```r
#' Function title
#' 
#' Function description
#'
#' @param param1 Type and description of first parameter
#' @param param2 Type and description of second parameter
#' @return Type and description of return value
#' @examples
#' # Example usage
function_name <- function(param1, param2, ...) {
  # Function body
}
```

### 2. Function Call Pattern

When calling functions with multiple parameters, explicitly name the arguments:

```r
# CORRECT: Named parameters for clarity
result <- complex_function(
  param1 = value1,
  param2 = value2,
  param3 = value3
)

# INCORRECT: Positional parameters can be unclear and error-prone
result <- complex_function(value1, value2, value3)
```

This naming of arguments:
- Makes the code more readable and self-documenting
- Reduces errors if parameter order changes in the future
- Clarifies intent, especially for boolean or numeric parameters
- Increases maintainability for complex function calls

### 2. Roxygen Documentation

All functions should use Roxygen2 documentation that:

1. **Describes Each Parameter**: Type, constraints, and purpose
2. **Documents Return Values**: Type and structure of outputs
3. **Provides Examples**: Shows how to call the function correctly
4. **Notes Side Effects**: Any state changes or external effects

### 3. Default Parameters

When using default parameters:

1. **Use Sensible Defaults**: Defaults should be appropriate for common use cases
2. **Document Default Values**: Document the default value and why it was chosen
3. **Optional Parameters Last**: Required parameters should appear before optional ones

```r
#' @param required_param Required parameter with no default
#' @param optional_param Optional parameter with default value (default: 10)
function_name <- function(required_param, optional_param = 10) {
  # Function body
}
```

### 4. Special Parameter Patterns

For commonly used patterns:

1. **Ellipsis (...)**: Document what additional parameters are used for and where they are passed
2. **Connection Parameters**: Follow the Universal Data Access pattern conventions
3. **Configuration Parameters**: Follow the YAML Parameter Configuration conventions

## Examples

### Example 1: Basic Function

```r
#' Calculate sum with optional scaling
#' 
#' Adds two numbers together and optionally applies a scaling factor.
#'
#' @param x Numeric value to add
#' @param y Numeric value to add
#' @param scale Numeric scaling factor (default: 1)
#' @return Numeric sum of x and y, multiplied by scale
#' @examples
#' add_scaled(5, 10)        # Returns 15
#' add_scaled(5, 10, 2)     # Returns 30
add_scaled <- function(x, y, scale = 1) {
  return((x + y) * scale)
}
```

### Example 2: Component Function

```r
#' Create a Shiny UI component
#' 
#' Creates a standard UI component with consistent styling.
#'
#' @param id Character string with the module ID (required)
#' @param title Character string with component title (required)
#' @param data Data frame containing the data to display (required)
#' @param config List of configuration options (optional)
#' @param translate Function for text translation (default: identity function)
#' @return A Shiny UI element
#' @examples
#' myComponent(
#'   id = "example",
#'   title = "Example Component",
#'   data = data.frame(x = 1:5, y = 6:10)
#' )
myComponent <- function(id, title, data, config = NULL, translate = identity) {
  # Function body
}
```

### Example 3: UI Component - Critical for radioButtons

```r
# ⚠️ IMPORTANT: Always use named parameters for UI components, especially radioButtons ⚠️
# This has been a source of bugs when positional parameters are misinterpreted

# CORRECT - Named parameters (recommended)
radioButtons(
  inputId = "platform",
  label = NULL,
  choices = c("Amazon" = 2, "All Platforms" = 0),
  selected = 2
)

# INCORRECT - Positional parameters (avoid)
radioButtons("platform", NULL, c("Amazon" = 2, "All Platforms" = 0), 2)

# DANGEROUS - Easy to misinterpret last parameter (selected vs width)
# This syntax has caused bugs in production: 
# radioButtons("platform", NULL, c("Amazon"=2,"All"=0), 6) # Is 6 selected or width?
```

## Benefits

1. **Enhanced Readability**: Clear parameter specifications make code easier to understand
2. **Improved Maintainability**: Explicit interfaces simplify function maintenance and updates
3. **Better Documentation**: Complete parameter listings improve automatic documentation
4. **Reduced Bugs**: Clearly specified inputs prevent misuse and type errors
5. **Easier Testing**: Well-defined parameters simplify test case creation
6. **Simplified Refactoring**: Explicit parameters make dependencies clear when refactoring

## Relationship to Other Principles

This metaprinciple:

1. **Derives from MP0000 (Axiomatization System)** as a foundational approach to function definition
2. **Derives from MP0047 (Functional Programming)** by emphasizing explicit inputs and outputs
3. **Influences R0094 (Roxygen2 Function Examples Standard)** by providing parameter specifications for documentation
4. **Complements MP0016 (Modularity)** by creating clear interface boundaries
5. **Supports MP0017 (Separation of Concerns)** by making dependencies explicit
6. **Enables MP0018 (Don't Repeat Yourself)** through improved function reuse

## Conclusion

The Explicit Parameter Specification Metaprinciple establishes a comprehensive framework for function definition that promotes clarity, maintainability, and proper reuse. By requiring complete and well-documented parameters, this principle creates functions with clear contracts, predictable behavior, and improved documentation.

This metaprinciple serves as a foundation for consistent function interfaces throughout the system, enabling developers to understand, use, and maintain functions with confidence.