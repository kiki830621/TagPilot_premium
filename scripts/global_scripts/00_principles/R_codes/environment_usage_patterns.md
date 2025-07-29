# Environment Usage Patterns in R

## Core Principle

> "Create a new environment if we want R to do something separately"

This document provides guidelines and examples for using environments in R to achieve proper separation of concerns, encapsulation, and isolation.

## Environment Naming Convention

All environment names should follow a consistent pattern:

- Begin with a period (`.`) to indicate semi-private status
- Use CamelCase for the descriptive part
- End with "Env" suffix to clearly identify as an environment

Examples:
- `.InitEnv` - Initialization environment
- `.ConfigEnv` - Configuration environment
- `.CacheEnv` - Caching environment
- `.LoggingEnv` - Logging environment
- `.ModuleEnv` - Module-specific environment

## Environment Structure Properties

### 1. Parent-Child Inheritance

Environments in R exhibit parent-child relationships that determine variable lookup behavior:

```r
# Create parent environment
.ParentEnv <- new.env(parent = emptyenv())
.ParentEnv$shared_var <- "visible to children"

# Create child environment with parent reference
.ChildEnv <- new.env(parent = .ParentEnv)

# Now .ChildEnv can access shared_var
# But variables defined in .ChildEnv are not visible to .ParentEnv
```

Common parent choices:
- `emptyenv()` - No inheritance, maximum isolation
- `globalenv()` - Inherits from global environment
- Another custom environment - Creates hierarchical inheritance

### 2. Object-Oriented Properties

Environments function as mutable, reference-based objects that can behave like classes:

```r
# Create environment as a "class"
.UserManagerEnv <- new.env(parent = emptyenv())

# Define "methods"
.UserManagerEnv$add_user <- function(name, role) { ... }
.UserManagerEnv$get_user <- function(name) { ... }
.UserManagerEnv$remove_user <- function(name) { ... }

# Use the "methods"
.UserManagerEnv$add_user("john", "admin")
user <- .UserManagerEnv$get_user("john")
```

## Common Usage Patterns

### 1. Namespace Isolation

Use environments to prevent naming conflicts between different parts of an application:

```r
.ModuleAEnv <- new.env(parent = emptyenv())
.ModuleBEnv <- new.env(parent = emptyenv())

# Both can define a function with the same name without conflict
.ModuleAEnv$process <- function(x) { x + 1 }
.ModuleBEnv$process <- function(x) { x * 2 }
```

### 2. State Encapsulation

Preserve and manage state between function calls:

```r
.StateEnv <- new.env(parent = emptyenv())
.StateEnv$counter <- 0

increment_counter <- function() {
  .StateEnv$counter <- .StateEnv$counter + 1
  return(.StateEnv$counter)
}
```

### 3. Caching and Memoization

Store computed results to avoid redundant calculations:

```r
.CacheEnv <- new.env(parent = emptyenv())

cached_computation <- function(input) {
  # Create a cache key
  key <- digest::digest(input)
  
  # Check if result is already cached
  if (exists(key, envir = .CacheEnv)) {
    return(get(key, envir = .CacheEnv))
  }
  
  # Perform expensive computation
  result <- expensive_function(input)
  
  # Store in cache
  assign(key, result, envir = .CacheEnv)
  return(result)
}
```

### 4. Module Pattern

Create self-contained modules with private/public interfaces:

```r
create_module <- function() {
  # Private environment
  .ModuleEnv <- new.env(parent = emptyenv())
  
  # Private variables and functions
  .ModuleEnv$private_data <- "hidden"
  .ModuleEnv$internal_function <- function() { ... }
  
  # Public interface - return functions that access the private environment
  list(
    get_data = function() { ... },
    set_data = function(value) { ... },
    process = function(input) { ... }
  )
}

# Usage
my_module <- create_module()
my_module$process("data")
```

## When to Create a New Environment

Create a separate environment when:

1. You need to maintain state between function calls
2. You want to isolate a group of related functions and data
3. You need to implement caching or memoization
4. You need to prevent naming conflicts with other code
5. You're implementing a module pattern
6. You're creating a package with internal state
7. You need controlled access to variables
8. You're implementing object-oriented programming patterns

## Best Practices

1. **Documentation**: Clearly document the purpose of each environment
2. **Consistency**: Follow naming conventions consistently
3. **Access Control**: Use parent environments to control variable visibility
4. **Cleanup**: Use `rm()` to clean up environments when no longer needed
5. **Organization**: Group related functions and data in the same environment
6. **Encapsulation**: Don't directly access environment variables from outside code
7. **Inheritance**: Set appropriate parent environments based on access needs

## Example in Action

See the accompanying file `environment_usage_patterns.R` for complete code examples demonstrating these principles.