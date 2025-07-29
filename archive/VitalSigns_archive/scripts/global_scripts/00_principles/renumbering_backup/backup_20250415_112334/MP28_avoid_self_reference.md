# MP28: Avoid Self-Reference Unless Necessary

## Rule

**Code should not reference or source itself, directly or indirectly, unless absolutely necessary and carefully controlled.**

## Explanation

Self-reference occurs when a piece of code depends on itself, creating circular dependencies. This can lead to infinite recursion, unpredictable behavior, and initialization problems. While there are rare cases where controlled self-reference is necessary (e.g., recursive functions), it should generally be avoided in system architecture.

### Problems with Self-Reference:

1. **Infinite Loops**: Code that sources itself can create infinite sourcing loops
2. **Unpredictable State**: The state of partially initialized modules becomes unpredictable
3. **Order Dependency**: Creates brittle dependencies on the exact order of operations
4. **Debugging Difficulty**: Makes it extremely challenging to trace execution flow
5. **Initialization Failures**: Can prevent proper system initialization
6. **Reduced Maintainability**: Creates complex, intertwined dependencies

## Examples

### Problematic Self-Reference

```r
# In file: db_utils.R
source_directory <- function(dir_path) {
  r_files <- list.files(path = dir_path, pattern = "\\.R$")
  for(file in r_files) source(file.path(dir_path, file))
}

# This will cause self-reference when called!
source_directory(dirname(sys.frame(1)$ofile))
```

When the above code runs, it will attempt to source all files in its directory, including itself, leading to infinite recursion.

### Better Approach

```r
# In initialization file (not in the target directory)
source_directory <- function(dir_path, exclude_pattern = NULL) {
  r_files <- list.files(path = dir_path, pattern = "\\.R$")
  if(!is.null(exclude_pattern)) {
    r_files <- r_files[!grepl(exclude_pattern, r_files)]
  }
  for(file in r_files) source(file.path(dir_path, file))
}

# Call from outside the target directory
source_directory("path/to/db_utils")
```

## Implementation Guidelines

1. **Place Utility Functions Appropriately**: 
   - Directory sourcing utilities should be defined in the initialization file, not in the directories they'll source

2. **Use Pattern Exclusion**: 
   - When sourcing directories, provide mechanisms to exclude certain files (like utility files)

3. **Careful Recursion**: 
   - When implementing recursive functions, ensure proper termination conditions

4. **Explicit Dependencies**: 
   - Make dependencies clear and explicit, avoiding hidden circular references

5. **Initialization Ordering**: 
   - Establish a clear order for initialization steps to prevent circular dependencies

## Special Cases

In rare cases, controlled self-reference may be necessary:

1. **Recursive Algorithms**: Properly implemented with base cases
2. **Plugin Systems**: Where components register themselves with a core system
3. **Hot-Reloading**: Systems that update themselves during runtime

Even in these cases, implement safeguards to prevent infinite loops or recursion.

## Benefits of Avoiding Self-Reference

- **Predictable Initialization**: System components initialize in a clear, reliable order
- **Better Maintainability**: Dependencies are explicit and directional
- **Easier Debugging**: Stack traces and execution flows remain clear and reasonable
- **System Stability**: Fewer unexpected failures from circular dependencies
- **Cleaner Architecture**: Forces better separation of concerns

## Practical Implementation

Rather than creating utility files that source their own directories, implement directory sourcing directly in initialization files:

```r
# In 000g_initialization_update_mode.R

# Source all R files in the db_utils directory
db_utils_dir <- file.path("update_scripts", "global_scripts", "02_db_utils")
if(dir.exists(db_utils_dir)) {
  r_files <- list.files(
    path = db_utils_dir, 
    pattern = "\\.R$", 
    full.names = TRUE
  )
  
  # Sort files to ensure consistent loading order
  r_files <- sort(r_files)
  
  # Source each file
  for(file in r_files) {
    tryCatch({
      source(file)
      message("Sourced: ", basename(file))
    }, error = function(e) {
      warning("Error sourcing ", basename(file), ": ", e$message)
    })
  }
}
```

This approach keeps the directory sourcing functionality in the initialization file where it belongs, avoiding self-reference issues.

## Related Principles

This principle works in conjunction with:

- **R21 (One Function One File)**: Encourages proper organization of functions into separate files
- **R45 (Initialization Imports Only)**: Ensures initialization files don't define functions
- **R46 (Source Directories Not Individual Files)**: When implemented correctly, avoids self-reference issues
- **MP29 (No Fake Data)**: Both principles focus on maintaining system integrity and reliability