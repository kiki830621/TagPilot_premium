# R0058: Evolution Over Replacement

## Definition
When enhancing or modifying functionality, create new functions alongside existing working ones rather than replacing or modifying them directly. This allows for seamless fallback to working code while new implementations are tested.

## Explanation
This rule acknowledges that existing, working code has proven value that should be preserved during enhancement. By creating new implementations as separate functions:

1. The original functionality remains intact and available
2. Enhancements can be tested independently without risk to core functionality
3. Rollback paths are inherently built into the system
4. Progressive adoption of new functionality becomes possible

## Implementation Guidelines

### 1. Parallel Implementation Pattern with Numerical Suffixes

```r
# Original function remains untouched
process_data1 <- function(params) {
  # Proven, working implementation
  result <- compute_result(params)
  return(result)
}

# New enhanced version as a separate function
process_data2 <- function(params) {
  # New implementation with improvements
  enhanced_result <- compute_better_result(params)
  return(enhanced_result)
}

# Usage with feature flag for controlled adoption
process_data <- function(data, version = 1) {
  if (version == 2 && is_version2_stable()) {
    return(process_data2(data))
  } else {
    return(process_data1(data))  # Safe fallback
  }
}
```

### 2. Numerical Suffix Evolution Pattern

```r
# Original implementation
get_customer_data1 <- function(customer_id) {
  # Original implementation
}

# Enhanced implementation
get_customer_data2 <- function(customer_id) {
  # Improved implementation with better performance
}

# Further enhanced implementation
get_customer_data3 <- function(customer_id) {
  # Implementation with additional features and optimizations
}

# Current recommended implementation (forwards to latest stable version)
get_customer_data <- function(customer_id) {
  return(get_customer_data1(customer_id))  # Change to 2 or 3 when stable
}
```

### 3. Graduated Adoption Strategy

```r
# Configuration parameter defines adoption level
adoption_level <- config$features$new_algorithm_level  # 0-3

# Functions implementing different adoption levels
calculate_result <- function(data, level = adoption_level) {
  if (level == 0) {
    return(original_algorithm(data))  # Completely proven
  } else if (level == 1) {
    return(enhanced_preprocessing(data) |> original_algorithm())  # Partial adoption
  } else if (level == 2) {
    return(enhanced_algorithm(data))  # Full adoption, closely monitored
  } else {
    return(experimental_algorithm(data))  # Bleeding edge for testing
  }
}
```

## Benefits

1. **Failure Safety**: Immediate fallback to working code is always possible
2. **A/B Testing**: Different implementations can be compared and evaluated
3. **Progressive Adoption**: New functionality can be rolled out gradually 
4. **Preserves Working Code**: Known good implementations remain untouched
5. **Developer Confidence**: Lower pressure when creating enhancements

## Anti-Patterns

### 1. Direct Modification of Working Functions

Avoid:
```r
# Bad: Directly modifying a working function
process_orders <- function(orders) {
  # Original working code modified with new code
  # If new code fails, everything fails
}
```

### 2. Incomplete Feature Flags

Avoid:
```r
# Bad: Partial feature flag that doesn't cover all changes
if (USE_NEW_ALGORITHM) {
  result <- new_algorithm()  # Protected by flag
} else {
  result <- old_algorithm()  # Protected by flag
}
# Bad: These changes are always applied regardless of flag
post_process(result)  # Modified with new code, not protected by flag
```

### 3. Lack of Version Documentation

Avoid:
```r
# Bad: No version indication or documentation
process_data_enhanced <- function() {
  # Is this 2? 3? What changed? Not clear from name or docs
}

# Bad: Ambiguous naming without clear versioning
process_data_new <- function() {
  # "New" relative to what? Will be confusing when newer versions come
}

# Good: Clear numerical suffixes
process_data2 <- function() {
  # Clearly the second version of this function
}
```

## Practical Application

This rule is particularly valuable:

1. When refactoring performance-critical code
2. When implementing algorithm improvements
3. During major feature enhancements
4. When fixing complex bugs that might introduce new issues

## Related Principles

- MP0042: Runnable-First Development
- MP0038: Incremental Single-Feature Release
- MP0037: Comment Only for Temporary or Uncertain Code
- R0021: One Function One File
