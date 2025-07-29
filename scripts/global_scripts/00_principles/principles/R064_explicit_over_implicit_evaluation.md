# R0064: Explicit Over Implicit Evaluation

## Context
R provides multiple ways to pass arguments to functions, including standard function calls, do.call(), and tidyverse-inspired meta-programming operators like !!! (splice operator). Each has different semantics for evaluating and passing arguments, which can lead to subtle bugs and type errors when used inappropriately.

## Rule
**Prefer explicit, controlled evaluation mechanisms like do.call() over implicit, meta-programming operators like !!! when passing variable argument lists or working with data of uncertain type or structure.**

## Rationale
1. **Evaluation Control**: Explicit evaluation mechanisms like do.call() provide precise control over when and how arguments are evaluated.

2. **Type Safety**: Meta-programming operators can cause type errors when they attempt to evaluate expressions in contexts where their types are incompatible.

3. **Predictability**: Base R functions like do.call() follow standard evaluation rules that are more predictable across different contexts.

4. **Error Clarity**: Errors from explicit evaluation tend to be more informative and point more directly to the root cause.

5. **Defensive Programming**: Explicit evaluation allows pre-validation of arguments and graceful handling of edge cases.

## Examples

### Example 1: Argument List Construction

```r
# Problematic: Using !!! splice operator can cause type errors
# if tab_filters isn't structured exactly as expected
filters <- oneTimeUnionUI2(
  !!!tab_filters,  # Error: invalid argument type
  id = ns("tab_filters"),
  initial_visibility = initial_visibility
)

# Preferred: Using do.call for explicit evaluation control
arg_list <- list(id = ns("tab_filters"), initial_visibility = initial_visibility)
if (length(tab_filters) > 0) {
  for (name in names(tab_filters)) {
    if (!is.null(name) && !is.null(tab_filters[[name]])) {
      arg_list[[name]] <- tab_filters[[name]]
    }
  }
}
filters <- do.call(oneTimeUnionUI2, arg_list)
```

### Example 2: Parameter Validation

```r
# Problematic: Parameters are evaluated before validation
result <- render_component(!!!params)  # Can fail with invalid parameters

# Preferred: Validate before passing to function
validated_params <- validate_params(params)
result <- do.call(render_component, validated_params)
```

### Example 3: Conditional Arguments

```r
# Problematic: Difficult to conditionally include arguments with !!!
if (include_details) {
  ui_call <- function_call(!!!base_args, details = detail_data)
} else {
  ui_call <- function_call(!!!base_args)
}

# Preferred: Build argument list conditionally
args <- base_args
if (include_details) {
  args$details <- detail_data
}
ui_call <- do.call(function_call, args)
```

## Formal Representation
In NSQL notation, this rule can be expressed as:

$$\text{For function } f \text{ and arguments } A = \{a_1, a_2, ..., a_n\}:$$
$$f(A) \text{ via } do.call(f, A) \succ f(!!!A)$$

Where $\succ$ denotes "is preferred to" in terms of evaluation safety and control.

## Related Principles
- MP0041: Type-Dependent Operations 
- P0024: Reactive Value Access Safety
- SLN01: Handling Non-Logical Data Types in Logical Contexts

## Applications
This rule should be applied:
- When passing variable argument lists to functions
- When working with data of uncertain type or structure
- When precise control over argument evaluation is needed
- When creating defensive, robust code that must handle edge cases
- In reactive contexts where evaluation timing is critical
