# R0056: Folder-Based Sourcing

## Definition
Components and dependencies should be sourced at the folder level during initialization, rather than individually throughout the application code. This ensures proper initialization order and reduces dependency issues.

## Explanation
Sourcing files by folder rather than individually promotes cleaner initialization, better organization, and eliminates the risk of circular dependencies or missing prerequisites. This approach:

1. Aligns with MP0031 (Initialization First) by ensuring all required components are loaded during initialization
2. Enforces a clear separation between component definition and component usage
3. Makes dependency relationships explicit through directory structure
4. Simplifies ongoing maintenance through predictable loading patterns
5. Prevents runtime errors caused by missing dependencies

## Implementation Guidelines

### Component Organization
- Group related components into meaningful directory structures
- Use directory names that reflect the purpose of the components they contain
- Follow R0054 (Component Folder Organization) when designing folder structure

### Sourcing Strategy
- Source entire folders rather than individual files
- Use a recursive directory traversal algorithm during initialization
- Source in order by aspect type (UI first, then Server, etc.) following P55
- Log sourcing operations for debugging purposes

### Initialization Script
- Create a dedicated section for component sourcing in the initialization script
- Traverse the component directory structure following aspect-based ordering
- Use a consistent naming pattern for sourcing-related functions

### Example
```r
# In initialization.R:

# Define recursive sourcing function
source_directory <- function(dir_path, pattern = "\\.R$", 
                            recursive = TRUE, verbose = FALSE) {
  # Ensure directory exists
  if (!dir.exists(dir_path)) {
    warning("Directory not found: ", dir_path)
    return(invisible(FALSE))
  }
  
  # Get all matching files
  files <- list.files(
    path = dir_path,
    pattern = pattern,
    full.names = TRUE,
    recursive = recursive
  )
  
  # Sort files to ensure consistent order
  files <- sort(files)
  
  # Source each file
  for (file in files) {
    if (verbose) message("Sourcing: ", file)
    source(file, local = FALSE)
  }
  
  return(invisible(TRUE))
}

# Source components by aspect type
# First UI components
source_directory("components", pattern = "UI\\.R$")

# Then Server components
source_directory("components", pattern = "Server\\.R$")

# Then utility functions
source_directory("components", pattern = "Filters\\.R$")
source_directory("components", pattern = "Defaults\\.R$")
```

## Benefits
- Ensures components are always loaded in the correct order
- Reduces risk of dependency issues or circular references
- Makes codebase more maintainable by centralizing sourcing logic
- Reduces cognitive load during development
- Speeds up initialization through efficient sourcing patterns

## Related Principles
- MP0031: Initialization First
- P0055: N-tuple Independent Loading
- R0054: Component Folder Organization
- MP0017: Separation of Concerns
