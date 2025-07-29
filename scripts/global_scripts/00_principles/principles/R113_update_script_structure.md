---
id: "R113"
title: "Update Script Structure Rule"
type: "rule"
related_to:
  - "MP031": "Initialization First"
  - "MP033": "Deinitialization Final"
  - "MP042": "Runnable First"
  - "MP058": "Database Table Creation Strategy"
  - "MP070": "Type-Prefix Naming"
  - "P076": "Error Handling Patterns"
date_created: "2025-04-15"
date_modified: "2025-04-15"
---

# R113: Four-Part Update Script Structure Rule

## Summary

All update scripts (`sc_` prefix files and implementation scripts) MUST follow a standardized four-part structure: INITIALIZE, MAIN, TEST, and DEINITIALIZE. This ensures proper resource management, error handling, verification, and cleanup across all system modification scripts.

## Motivation

System modification scripts require consistent patterns for reliability, maintainability, and safety. The four-part structure enforces:

1. **Proper initialization** - Setting up the environment before operations
2. **Structured execution** - Clearly defined main processing section
3. **Verification** - Explicit testing that changes were applied correctly
4. **Cleanup** - Reliable resource deallocation regardless of execution path

## Implementation

Every update script MUST contain these four sections, clearly marked with comments:

```r
# 1. INITIALIZE
# Initialization code...

# 2. MAIN
# Main processing code with error handling...

# 3. TEST
# Verification code...

# 4. DEINITIALIZE
# Cleanup code...
```

### 1. INITIALIZE Section

The INITIALIZE section MUST:

- Source the appropriate initialization script for the mode
- Set up database connections
- Load required packages and dependencies
- Configure environment variables
- Initialize error tracking

Example:
```r
# 1. INITIALIZE
# Source initialization script for update mode
source(file.path("update_scripts", "global_scripts", "00_principles", "sc_initialization_update_mode.R"))

# Connect to required database
if (!exists("app_data") || !inherits(app_data, "DBIConnection")) {
  app_data <- dbConnect_from_list("app_data")
  connection_created <- TRUE
  message("Connected to app_data database")
} else {
  connection_created <- FALSE
}

# Initialize error tracking
error_occurred <- FALSE
```

### 2. MAIN Section

The MAIN section MUST:

- Be wrapped in a tryCatch block
- Set error tracking variables on failure
- Perform the core functionality
- Log success/failure appropriately

Example:
```r
# 2. MAIN
tryCatch({
  # Core operation code
  dbExecute(app_data, create_table_query)
  
  message("Main processing completed successfully")
}, error = function(e) {
  message("Error in MAIN section: ", e$message)
  error_occurred <- TRUE
})
```

### 3. TEST Section

The TEST section MUST:

- Verify that changes were applied correctly
- Only run if the MAIN section succeeded
- Set a test_passed variable for the DEINITIALIZE section
- Include appropriate error handling

Example:
```r
# 3. TEST
if (!error_occurred) {
  tryCatch({
    # Verification query
    table_exists <- nrow(dbGetQuery(app_data, "SELECT name FROM sqlite_master WHERE type='table' AND name='target_table'")) > 0
    
    if (table_exists) {
      message("Verification successful: Table exists")
      test_passed <- TRUE
    } else {
      message("Verification failed: Table does not exist")
      test_passed <- FALSE
    }
  }, error = function(e) {
    message("Error in TEST section: ", e$message)
    test_passed <- FALSE
  })
} else {
  message("Skipping tests due to error in MAIN section")
  test_passed <- FALSE
}
```

### 4. DEINITIALIZE Section

The DEINITIALIZE section MUST:

- Release all resources acquired in the script
- Close database connections opened by the script
- Report final status
- Return a success/failure boolean value
- Always execute, regardless of errors in previous sections

Example:
```r
# 4. DEINITIALIZE
tryCatch({
  # Close connections opened in this script
  if (exists("connection_created") && connection_created && 
      exists("app_data") && inherits(app_data, "DBIConnection")) {
    dbDisconnect(app_data)
    message("Database connection closed")
  }
  
  # Report final status
  if (exists("test_passed") && test_passed) {
    message("Script executed successfully with all tests passed")
    final_status <- TRUE
  } else {
    message("Script execution incomplete or tests failed")
    final_status <- FALSE
  }
  
}, error = function(e) {
  message("Error in DEINITIALIZE section: ", e$message)
  final_status <- FALSE
}, finally = {
  # This will always execute
  message("Script execution completed at ", Sys.time())
})

# Return final status
if (exists("final_status")) {
  final_status
} else {
  FALSE
}
```

## Enforcement

All new update scripts MUST follow this structure. Existing scripts SHOULD be updated to this structure when modified.

The implementation of this rule is detailed in the syntax document at:
`/update_scripts/global_scripts/16_NSQL_Language/extensions/sc_update_script_syntax.md`

## Rationale

- Consistent script structure enables rapid comprehension
- Proper resource management prevents connection leaks
- Explicit testing ensures changes are verified
- Clean error handling improves reliability
- Well-defined return values enable automated execution and monitoring

## Related Principles

- **MP031: Initialization First** - Establishes proper setup before operations
- **MP033: Deinitialization Final** - Ensures proper cleanup of resources
- **MP042: Runnable First** - Scripts should be runnable without additional steps
- **MP058: Database Table Creation Strategy** - Approach for creating database tables
- **MP070: Type-Prefix Naming** - Consistent naming with type prefixes
- **P076: Error Handling Patterns** - Standardized approaches to error handling