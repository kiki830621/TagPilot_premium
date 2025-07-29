# MP41: Type-Dependent Operations

## Context
Software systems operate on diverse data types, each with its own semantics, constraints, and appropriate operations. Applying operations uniformly across all types often leads to bugs, type errors, and unpredictable behavior.

## Principle
**Operations performed on objects must be determined by and appropriate for the specific type of the object, with explicit handling for each distinct type category.**

## Rationale
1. **Type Safety**: Different types have fundamentally different properties and behaviors that must be respected.

2. **Semantic Correctness**: Operations only make sense in the context of the type they're operating on.

3. **Error Prevention**: Many runtime errors occur when operations designed for one type are applied to another.

4. **Predictable Behavior**: Type-specific operations create more predictable and consistent outcomes.

5. **Extensibility**: Well-defined type-dependent behavior makes adding new types more straightforward.

## Implementation
Type-dependent operations should be implemented through:

1. **Type Checking**: Explicitly verify object types before applying operations.
   ```r
   # Before operating on an object
   if (is.reactive(value)) {
     # Handle reactive values
     result <- value()
   } else if (is.list(value)) {
     # Handle list values
     result <- value[[index]]
   } else {
     # Handle primitive values
     result <- value
   }
   ```

2. **Polymorphism**: Use language features that dispatch operations based on type.
   ```r
   # Using S3 dispatch in R
   print.data.frame <- function(x, ...) { /* data frame specific printing */ }
   print.matrix <- function(x, ...) { /* matrix specific printing */ }
   ```

3. **Type Coercion**: When necessary, explicitly convert between types rather than relying on implicit conversion.
   ```r
   # Explicit conversion rather than implicit
   value <- as.character(numeric_value)  # Explicit
   value <- numeric_value + ""           # Implicit (avoid)
   ```

4. **Type-Based Function Selection**: Choose different function implementations based on input types.
   ```r
   sum_values <- function(x) {
     if (is.data.frame(x)) {
       return(sum(unlist(x)))
     } else if (is.list(x)) {
       return(sum(unlist(x)))
     } else {
       return(sum(x))
     }
   }
   ```

5. **Type Documentation**: Clearly document the expected types for function parameters and return values.
   ```r
   #' Process user input
   #'
   #' @param input Either a character string or a reactive expression returning a string
   #' @return Processed character string
   process_input <- function(input) {
     # Type-dependent handling
     if (is.reactive(input)) {
       text <- input()
     } else {
       text <- as.character(input)
     }
     # Process text
     return(text)
   }
   ```

## Examples

### Example 1: Reactive Value Handling
```r
# Wrong: Direct logical operation on a reactive value
if (!user_selection) {  # Error: invalid argument type
  show_default()
}

# Right: Type-dependent operation
if (is.reactive(user_selection)) {
  # It's a reactive value, so call it first
  if (!user_selection()) {
    show_default()
  }
} else {
  # It's a regular value
  if (!user_selection) {
    show_default()
  }
}

# Or more concisely with a helper function
is_empty <- function(x) {
  if (is.reactive(x)) return(!x())
  else return(!x)
}

if (is_empty(user_selection)) {
  show_default()
}
```

### Example 2: Collection Processing
```r
# Wrong: Uniform treatment of all collection types
result <- lapply(data, function(x) x * 2)  # May fail for non-list types

# Right: Type-dependent processing
process_data <- function(data) {
  if (is.data.frame(data)) {
    return(as.data.frame(lapply(data, function(x) if(is.numeric(x)) x * 2 else x)))
  } else if (is.matrix(data)) {
    return(data * 2)  # Uses matrix multiplication semantics
  } else if (is.list(data)) {
    return(lapply(data, function(x) if(is.numeric(x)) x * 2 else x))
  } else if (is.atomic(data)) {
    return(data * 2)  # Vector semantics
  } else {
    stop("Unsupported data type")
  }
}
```

### Example 3: UI Component Generation
```r
# Generate the appropriate UI based on parameter type
generate_ui <- function(parameter) {
  if (inherits(parameter, "DateParameter")) {
    return(dateInput(parameter$id, parameter$label, value = parameter$default))
  } else if (inherits(parameter, "NumericParameter")) {
    return(numericInput(parameter$id, parameter$label, value = parameter$default))
  } else if (inherits(parameter, "ChoiceParameter")) {
    return(selectInput(parameter$id, parameter$label, choices = parameter$options, 
                     selected = parameter$default))
  } else {
    return(textInput(parameter$id, parameter$label, value = as.character(parameter$default)))
  }
}
```

## Related Principles
- SLN01: Handling Non-Logical Data Types in Logical Contexts
- P24: Reactive Value Access Safety
- MP28: NSQL Set Theory Foundations

## Applications
This principle should be applied when:
- Dealing with heterogeneous data types
- Processing user input that could be of multiple types
- Working with reactive programming frameworks
- Implementing generic functions that need to work across different types
- Designing APIs that accept various input formats

The key is to always consider "What type of thing am I working with?" before deciding how to operate on it.
