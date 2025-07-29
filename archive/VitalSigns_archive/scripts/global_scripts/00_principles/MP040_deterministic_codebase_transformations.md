# MP0040: Deterministic Codebase Transformations

## Context
When making systematic changes across a codebase (e.g., replacing function names, updating API calls, or refactoring patterns), manual processes are error-prone, inconsistent, and difficult to verify. This applies whether the changes are made by humans or AI assistants.

## Principle
**Deterministic, systematic changes to a codebase should be performed through dedicated transformation modules rather than manual edits or direct AI-assisted replacements.**

## Rationale
1. **Reliability**: Programmatic transformations eliminate human error, typos, and inconsistencies.
2. **Repeatability**: The process can be run multiple times with identical results.
3. **Verifiability**: The transformation can be systematically tested and validated.
4. **Transparency**: The change process is explicitly documented in code.
5. **Efficiency**: Large-scale changes can be performed more quickly and with fewer resources.
6. **Reversibility**: Changes can be more easily rolled back if necessary.

## Implementation
Codebase transformations should be implemented as:

1. **Dedicated modules** that define both the search patterns and their replacements
2. **Versioned scripts** that are stored in the codebase for future reference
3. **Testable functions** with clear inputs and outputs
4. **Documented processes** that explain the rationale and scope of changes

## Examples

### Function Name Replacement
```r
# transform_function_names.R
replace_function_name <- function(old_name, new_name, file_pattern = "\\.R$", 
                                  dir = ".", recursive = TRUE, dry_run = FALSE) {
  # Find all matching files
  files <- list.files(path = dir, pattern = file_pattern, 
                     recursive = recursive, full.names = TRUE)
  
  # Report stats
  replaced_count <- 0
  files_modified <- 0
  
  # Process each file
  for (file in files) {
    content <- readLines(file)
    # Create search pattern that matches function name but not within other words
    pattern <- paste0("\\b", old_name, "\\b")
    new_content <- gsub(pattern, new_name, content)
    
    # Count replacements
    file_replacements <- sum(content != new_content)
    
    if (file_replacements > 0) {
      files_modified <- files_modified + 1
      replaced_count <- replaced_count + file_replacements
      
      if (!dry_run) {
        writeLines(new_content, file)
        message(sprintf("Modified %s: %d replacements", file, file_replacements))
      } else {
        message(sprintf("[DRY RUN] Would modify %s: %d replacements", 
                       file, file_replacements))
      }
    }
  }
  
  # Return summary
  list(
    files_scanned = length(files),
    files_modified = files_modified,
    replacements = replaced_count,
    dry_run = dry_run
  )
}

# Usage example:
# result <- replace_function_name("oneTimeUnionUI", "oneTimeUnionUI2", dir = "components")
```

### Component Pattern Transformation
```r
# transform_component_pattern.R
transform_component_pattern <- function(pattern_detector, transformer_function, 
                                       file_pattern = "\\.R$", dir = ".", 
                                       recursive = TRUE, dry_run = FALSE) {
  # Find all matching files
  files <- list.files(path = dir, pattern = file_pattern, 
                     recursive = recursive, full.names = TRUE)
  
  # Track statistics
  transformed_count <- 0
  files_modified <- 0
  
  # Process each file
  for (file in files) {
    # Read entire file as a single string to preserve formatting
    content <- paste(readLines(file), collapse = "\n")
    
    # Find matches for the pattern
    matches <- gregexpr(pattern_detector, content, perl = TRUE)
    match_count <- length(attr(matches[[1]], "match.length"))
    
    if (match_count > 0 && matches[[1]][1] != -1) {
      # Apply transformations
      new_content <- content
      match_positions <- matches[[1]]
      match_lengths <- attr(matches[[1]], "match.length")
      
      # Process in reverse order to maintain correct positions
      for (i in rev(seq_along(match_positions))) {
        pos <- match_positions[i]
        len <- match_lengths[i]
        match_text <- substr(content, pos, pos + len - 1)
        transformed_text <- transformer_function(match_text)
        
        # Replace the matched text with transformed text
        new_content <- paste0(
          substr(new_content, 1, pos - 1),
          transformed_text,
          substr(new_content, pos + len, nchar(new_content))
        )
      }
      
      if (new_content != content) {
        files_modified <- files_modified + 1
        transformed_count <- transformed_count + match_count
        
        if (!dry_run) {
          writeLines(strsplit(new_content, "\n")[[1]], file)
          message(sprintf("Modified %s: %d transformations", file, match_count))
        } else {
          message(sprintf("[DRY RUN] Would modify %s: %d transformations", 
                         file, match_count))
        }
      }
    }
  }
  
  # Return summary
  list(
    files_scanned = length(files),
    files_modified = files_modified,
    transformations = transformed_count,
    dry_run = dry_run
  )
}

# Usage example:
# transform_oneTimeUnionUI <- function(text) {
#   gsub("oneTimeUnionUI\\(", "oneTimeUnionUI2(", text)
# }
# result <- transform_component_pattern("oneTimeUnionUI\\([^\\)]+\\)", 
#                                     transform_oneTimeUnionUI, 
#                                     dir = "components")
```

## Related Principles
- MP0031: Initialization First
- MP0038: Essential Features First
- MP0039: One-Time Operations at Start
- R58: Evolution Over Replacement
- SLN01: Handling Non-Logical Data Types

## Application
When refactoring code for compliance with SLN01 (Handling Non-Logical Data Types) or other principles, create transformation modules to reliably propagate the changes across the entire codebase. This ensures consistent implementation of the solution pattern.
