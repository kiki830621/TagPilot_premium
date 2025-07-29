---
id: "R0096"
title: "File Lock Notation"
type: "rule"
date_created: "2025-04-10"
date_modified: "2025-04-10"
author: "Development Team"
extends:
  - "MP0017": "Separation of Concerns"
  - "MP0037": "Comment Only for Temporary or Uncertain"
aliases:
  - File Lock Comment
  - LOCK FILE Notation
key_terms:
  - file lock
  - file protection
  - lock notation
  - code protection
---

# R0096: File Lock Notation

## Core Statement

Critical files that should not be modified directly must be clearly marked with a standardized `#LOCK FILE` notation at the beginning of the file in a way that does not conflict with documentation tools like Roxygen2.

## Rationale

Marking files as locked provides several benefits:

1. Prevents accidental modification of critical system files
2. Makes it clear which files should only be changed through approved processes
3. Ensures that automated tools and scripts can identify protected files
4. Establishes a consistent pattern for identifying file status
5. Reduces the risk of breaking core functionality through improper edits

## Implementation Guidelines

Files should be marked as locked using one of the following three approved methods, all of which ensure compatibility with Roxygen2 and other documentation tools:

### Method 1: Top of File

Place the lock notation as the very first line of the file, on a line by itself:

```r
#LOCK FILE

# Rest of the file contents...
```

### Method 2: After License or Header

Place the lock notation after any file preamble, copyright notices, or license headers, but before any Roxygen2 documentation:

```r
# Copyright (c) 2025 Company Name
# License: MIT

#LOCK FILE

#' @title Function title
#' @description Function description
```

### Method 3: After Shebang

For executable scripts that include a shebang line, place the lock notation immediately after the shebang:

```r
#!/usr/bin/env Rscript

#LOCK FILE

# Rest of the script...
```

## Additional Notation

For files that contain multiple sections that need to be protected independently, use secondary lock notations:

```r
#LOCK ON
# Protected content begins
...protected code...
#LOCK OFF

# Unprotected section
...modifiable code...

#LOCK ON
# Another protected section begins
...protected code...
#LOCK OFF
```

## Validation Rules

1. The lock notation must always be on a line by itself
2. Use a regular comment (`#`) not a Roxygen2 comment (`#'`)
3. Place it before any Roxygen2 documentation blocks
4. Ensure it's not inside a function or code block

## Application Scope

This file lock notation should be used for:

1. Core application files like app.R that serve as application entry points
2. Initialization and configuration scripts that establish the application environment
3. Files that implement critical business logic and core functionality
4. Files that define centralized processes like authentication or logging
5. Any file where uncontrolled changes could break the entire application

## Relationship to Other Rules

- **MP0017 (Separation of Concerns)**: By clearly marking which files serve critical system roles
- **MP0037 (Comment Only for Temporary or Uncertain)**: By establishing a standard comment pattern with specific meaning
- **R0073 (App.R Change Permissions)**: By providing a mechanism to implement the permission restrictions

## Implementation Process

1. Identify critical files that should be protected
2. Add the lock notation following one of the three approved methods
3. Document the locked status in relevant project documentation
4. Update build and deployment processes to respect lock notations
5. Educate team members about the meaning and purpose of locked files

## Benefits

- **Reduced Risk**: Lower chance of accidental modifications to critical components
- **Clear Boundaries**: Explicit indication of which files should not be modified directly
- **Enhanced Documentation**: Better understanding of the system's architecture
- **Process Support**: Automated tools can detect and enforce file lock status
- **Team Alignment**: Shared understanding of file status

## Related Concepts

### Shebang Line (Hashbang)

A shebang line (`#!/usr/bin/env Rscript`) is a special notation used at the beginning of script files to specify the interpreter that should be used to execute the script. This allows R scripts to be run directly as executable programs from the command line.

Benefits of using shebang lines:
- **Portability**: Using `/usr/bin/env` locates the interpreter in the user's environment
- **Command-line utility**: Allows scripts to be executed directly without explicitly invoking R
- **Integration**: Makes it easier to include R scripts in system workflows

When used with the lock notation, always place the shebang at the very top, followed by the lock notation.
