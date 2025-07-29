# R0046: Source Directories Not Individual Files

## Rule

**Source entire directories of functions rather than specific files when the collection of files may change over time.**

## Explanation

When working with modules or utilities that contain multiple function files, it's more maintainable to implement a directory-sourcing approach rather than listing individual files. This prevents initialization files from needing updates each time a new function is added to a module.

### Reasons for this rule:

1. **Maintainability**: Adding new function files doesn't require modifying initialization code.

2. **Discoverability**: All functions in a directory are automatically available.

3. **Consistency**: Ensures all functions from a module are loaded together.

4. **Reduced Coupling**: Initialization files aren't tightly coupled to the specific function implementations.

5. **Extensibility**: Modules can grow without requiring changes to dependent code.

## Implementation Guidelines

### Directory Sourcing Implementation

Per Meta Principle MP0028 (Avoid Self-Reference), directory sourcing code should be implemented directly in initialization files, not in utility files within the directories being sourced. This prevents self-reference issues.

```r
# In initialization file (000g_initialization_update_mode.R)

# Get the absolute path to the db_utils directory
db_utils_dir <- file.path(APP_DIR, "update_scripts", "global_scripts", "02_db_utils")
if(dir.exists(db_utils_dir)) {
  # Get all function files in the directory (with fn_ prefix)
  fn_files <- list.files(
    path = db_utils_dir, 
    pattern = "^fn_.*\\.R$",  # Only get function files with fn_ prefix
    full.names = TRUE,
    ignore.case = TRUE
  )
  
  # Sort files to ensure consistent loading order
  fn_files <- sort(fn_files)
  
  message("Found ", length(fn_files), " database utility functions to source")
  
  # Source each function file directly
  for(fn_path in fn_files) {
    tryCatch({
      source(fn_path)
      message("Sourced function file: ", basename(fn_path))
    }, error = function(e) {
      warning("Error sourcing ", basename(fn_path), ": ", e$message)
    })
  }
}
```

### When to Use Pattern Matching

Use filename patterns to control which files are sourced:

```r
# Only source files with fn_ prefix (function files)
pattern = "^fn_.*\\.R$"

# Exclude utility or helper files
pattern = "\\.R$"
exclude_files <- grep("^(util_|helper_)", r_files, value = TRUE)
r_files <- r_files[!r_files %in% exclude_files]
```

## Benefits

- **Future-Proof**: Code automatically adapts to new functions added to modules.
- **Reduced Maintenance**: No need to update initialization files when module content changes.
- **Clarity**: Makes it clear that all functions from a module are being loaded.
- **Consistency**: Promotes a uniform approach to importing functionality.
- **Organization**: Encourages organizing related functions into dedicated directories.

## Best Practices

1. **Organize by Function Type**: Group related functions in well-named directories.
2. **Use Naming Conventions**: Keep file naming consistent within directories.
3. **Provide Loading Feedback**: Include verbose options to show which files are loaded.
4. **Handle Loading Errors**: Use tryCatch to handle sourcing errors gracefully.
5. **Consider Load Order**: Use file naming to control the order of sourcing when needed.

## Integration with Other Principles

This principle complements:

- **R0021 (One Function One File)**: Makes it easier to follow the one function per file rule.
- **R0045 (Initialization Imports Only)**: Simplifies the import process in initialization files.
- **R0001 (File Naming Convention)**: Works well with consistent file naming patterns.
- **R0007 (Module Structure)**: Enhances the organization of modules into function directories.
