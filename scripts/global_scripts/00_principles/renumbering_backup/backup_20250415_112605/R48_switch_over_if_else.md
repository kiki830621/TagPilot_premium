---
id: "R48"
title: "Use Switch Over Multiple If-Else"
type: "rule"
date_created: "2025-04-06"
author: "Claude"
implements:
  - "MP16": "Modularity"
  - "MP17": "Separation of Concerns"
related_to:
  - "R19": "Object Naming Convention"
  - "R43": "Check Existing Functions"
---

# Use Switch Over Multiple If-Else

## Core Rule

When handling multiple conditional cases based on the same variable or expression, prefer using `switch()` statements over cascading `if-else` constructs.

## Rationale

Using `switch()` statements rather than multiple `if-else` statements:

1. **Improves code readability** by making it immediately clear that different actions correspond to different values of the same expression
2. **Reduces complexity** by eliminating nested conditional structures
3. **Enhances maintainability** by making it easier to add or modify cases
4. **Can improve performance** in languages that optimize switch statements
5. **Reduces the likelihood of logical errors** that can occur in complex if-else chains

## Implementation Guidelines

### When to Use Switch

Use `switch()` statements when:

1. You need to select among multiple options based on the value of a single variable
2. You have more than two alternative cases to handle
3. The conditions are based on equality comparisons (exact matches)

### R Implementation

In R, `switch()` takes the expression to test as its first argument, followed by named or positional values:

```r
# Named values approach (preferred for readability)
result <- switch(column_type,
  "numeric" = calculate_mean(x),
  "character" = calculate_frequency(x),
  "date" = calculate_range(x),
  calculate_default(x)  # Default case
)

# Positional values approach (less readable)
result <- switch(action_code,
  sum(values),           # case 1
  mean(values),          # case 2
  median(values),        # case 3
  max(values)            # case 4
)
```

### Other Language Implementations

Other languages have similar constructs:

```python
# Python example
result = {
    'numeric': lambda: calculate_mean(x),
    'character': lambda: calculate_frequency(x),
    'date': lambda: calculate_range(x)
}.get(column_type, lambda: calculate_default(x))()
```

### Incorrect vs. Correct Examples

**Incorrect (using if-else chain):**
```r
if (column_type == "numeric") {
  result <- calculate_mean(x)
} else if (column_type == "character") {
  result <- calculate_frequency(x)
} else if (column_type == "date") {
  result <- calculate_range(x)
} else {
  result <- calculate_default(x)
}
```

**Correct (using switch):**
```r
result <- switch(column_type,
  "numeric" = calculate_mean(x),
  "character" = calculate_frequency(x),
  "date" = calculate_range(x),
  calculate_default(x)  # Default case
)
```

## Handling Complex Conditions

When using `switch()` for multiple conditions:

1. **Simplify expressions** when possible
2. **Use functions for complex logic** rather than inline code
3. **Handle the default case explicitly** rather than letting it fall through

## Exceptions

`if-else` chains may still be preferable when:

1. Conditions involve **complex expressions** rather than simple value comparisons
2. Using **range comparisons** rather than exact matches
3. Different conditions test **different variables**
4. Very **simple binary conditions** where the intentions are clear

## Benefits

1. **Self-documenting code**: Switch statements clearly indicate that different code paths correspond to different values of the same expression
2. **Maintainable structure**: Adding new cases is simpler and less error-prone than extending if-else chains
3. **Prevention of logical errors**: Switch statements help avoid mistakes like forgetting to check a condition or having unreachable code

## Integration with Other Principles

This rule complements:

1. **MP16 (Modularity)**: Enhances code modularity by clearly separating different conditional paths
2. **MP17 (Separation of Concerns)**: Helps separate different logic paths based on a common decision point
3. **R43 (Check Existing Functions)**: Encourages using established control flow mechanisms effectively