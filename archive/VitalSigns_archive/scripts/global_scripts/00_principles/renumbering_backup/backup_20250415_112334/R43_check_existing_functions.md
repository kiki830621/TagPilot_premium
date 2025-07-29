# Verify Existing Functions Before Implementation

## Overview

This principle establishes critical guidelines for working with functions in the codebase, ensuring consistency, avoiding duplication, and maintaining expected behavior across the system.

## Rule

**Always verify if a function already exists before implementing new functionality with the same or similar name.**

## Rationale

Duplicating functions with the same or similar names can lead to:

1. Inconsistent behavior between different parts of the application
2. Difficulty maintaining multiple implementations
3. Unexpected side effects when only one implementation is updated
4. Confusion for developers about which implementation to use
5. Increased likelihood of bugs when implementations diverge

## Implementation Guidelines

### Step 1: Function Existence Check

Before implementing any utility or helper function:

- Use grep/search tools to find existing function definitions
- Check utility modules and common libraries
- Look for similarly named functions that might serve the same purpose
- Examine import statements to identify potential external sources

```r
# CORRECT APPROACH - Check if function exists first
if(!exists("connect_to_database")) {
  # Only define if it doesn't already exist
  connect_to_database <- function(...) {
    # Implementation here
  }
}
```

### Step 2: Function Analysis

If a similar function exists:

- Examine its parameters, return values, and behavior
- Note any environment-specific logic or assumptions
- Check for dependencies and edge cases being handled
- Understand the existing error handling mechanisms

### Step 3: Implementation Decision

Based on your analysis:

- **Reuse the existing function** if it meets requirements (preferred)
- **Extend the existing function** if minor modifications are needed
- **Create a new function with a distinct name** if fundamentally different behavior is required
- **Create a compatibility layer** if you must maintain backward compatibility

### Step 4: Documentation

When working with existing functions:

- Document your decision process
- Update comments if extending functionality
- Cross-reference related functions
- Note any compatibility concerns

## Examples

### Incorrect Approach

```r
# BAD: Creating a duplicate function without checking
dbConnect_from_list <- function(db_name) {
  # New implementation that might conflict with existing one
  # ...
}
```

### Correct Approach

```r
# GOOD: Check and provide a fallback implementation only if needed
if(!exists("dbConnect_from_list")) {
  # Create a warning log
  message("WARNING: Using fallback dbConnect_from_list implementation")
  
  # Fallback implementation
  dbConnect_from_list <- function(db_name, read_only = TRUE, verbose = FALSE) {
    warning("Using provisional implementation of dbConnect_from_list")
    # Basic implementation that matches the interface
    # ...
  }
}
```

## Function Modification Guidelines

If you need to modify an existing function:

1. **Document the original behavior** before changes
2. **Maintain the same parameter interface** when possible
3. **Consider backward compatibility** impacts
4. **Add tests** to verify both old and new use cases
5. **Update all relevant documentation**

## Compliance Verification

Regular code reviews should check for:

1. Duplicate function implementations
2. Proper reuse of existing utility functions
3. Consistent error handling across similar functions
4. Clear documentation of function behavior

By adhering to this principle, we maintain a more consistent, maintainable, and reliable codebase with clear expectations about how utilities and helper functions behave throughout the system.