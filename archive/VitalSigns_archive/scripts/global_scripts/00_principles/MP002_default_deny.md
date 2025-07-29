# Default Deny Principle

## Overview

This Meta Principle establishes "Default Deny" as a foundational security and operational approach across all systems, components, and processes. No action should be taken unless explicitly permitted by established rules, principles, or authorization mechanisms.

## Rule

**All actions, operations, and modifications must be explicitly permitted before execution. When permission status is unclear or unchecked, default to denial of action.**

## Rationale

A "default deny" approach is fundamental to maintaining system integrity, security, and predictability. Without this principle:

1. **Security Vulnerabilities**: Systems may expose sensitive data or operations without proper guards
2. **Unintended Consequences**: Actions taken without clear permission can lead to system instability
3. **Inconsistent Behavior**: Ad-hoc permission handling creates unpredictable system responses
4. **Scope Creep**: Components may exceed their intended functionality boundaries
5. **Audit Challenges**: Unauthorized or unplanned actions are difficult to track and review

## Implementation Guidelines

### System Design

Apply the Default Deny principle at all architectural levels:

1. **Authentication/Authorization**: 
   - Begin with zero access rights
   - Grant specific permissions only after explicit authorization
   - Implement proper permission checking before operations

2. **File Operations**:
   - No file creation/modification without explicit permission
   - Verify path integrity and authorization before operations
   - Default to read-only access when write permission is unclear

3. **Database Access**:
   - Start with read-only connections by default
   - Upgrade to write access only after permission verification
   - Scope database operations to the minimum required access level

4. **Code Execution**:
   - Validate all inputs before processing
   - Verify function execution permissions based on context
   - Limit execution scope to authorized components

5. **Network Operations**:
   - Block all external connections by default
   - Open communication only for authorized services
   - Validate all incoming connections before processing

### Code Implementation

```r
# INCORRECT: Assuming permission
write_to_database(data)

# CORRECT: Checking permission first
if (has_write_permission("database")) {
  write_to_database(data)
} else {
  log_access_denied("Attempted database write without permission")
  stop("Operation not permitted: write access required")
}
```

### Error Handling

When permission is denied:

1. **Clear Messaging**: Provide explicit error messages about missing permissions
2. **Logging**: Record denied actions for audit and debugging
3. **Graceful Degradation**: Offer limited functionality where appropriate
4. **Recovery Path**: Provide guidance on how to obtain necessary permissions

## Examples

### Database Connection

```r
# Example of Default Deny in database connections
dbConnect_from_list <- function(dataset, path_list = db_path_list, read_only = TRUE, ...) {
  # Start with read_only = TRUE as default
  
  # Check if write access is explicitly granted and permitted
  if (!read_only) {
    # Verify permission to write
    if (!has_write_permission(dataset)) {
      warning("Write access denied - connecting in read-only mode")
      read_only <- TRUE  # Force read-only despite request for write
    }
  }
  
  # Proceed with appropriate permissions
  con <- DBI::dbConnect(duckdb::duckdb(), dbdir = path_list[[dataset]], read_only = read_only)
  return(con)
}
```

### File Operations

```r
# Example of Default Deny in file operations
modify_file <- function(file_path, new_content) {
  # First check if modification is allowed
  if (!can_modify_file(file_path)) {
    log_unauthorized_attempt("file_modification", file_path)
    stop("Permission denied: Cannot modify file ", file_path)
  }
  
  # Only proceed if explicitly permitted
  writeLines(new_content, file_path)
  return(TRUE)
}
```

### Directory Creation

```r
# Example of Default Deny in directory creation
create_directory <- function(dir_path) {
  # Check permission before attempting creation
  if (!permission_to_create_directory(dir_path)) {
    log_denied_action("directory_creation", dir_path)
    return(FALSE)
  }
  
  # Only proceed if explicitly permitted
  dir.create(dir_path, recursive = TRUE)
  return(TRUE)
}
```

## Interaction with Other Principles

The Default Deny principle reinforces and interacts with:

- **R44 Path Modification Principle**: Requiring explicit permission before modifying paths
- **Data Access Layer Hierarchy**: Enforcing strict permission boundaries between data layers
- **Operation Mode Controls**: Limiting capabilities based on current operation mode
- **MP0001 No Fake Data**: Preventing generation of synthetic data without authorization

## Exception Process

Any exception to the Default Deny principle must:

1. Be explicitly documented with clear justification
2. Have a time-limited scope (permanent exceptions are strongly discouraged)
3. Include compensating controls to mitigate associated risks
4. Receive approval from system/data owners
5. Be regularly reviewed for continued necessity

## Compliance Verification

System reviews should verify:

1. All code paths include permission checks before sensitive operations
2. Default values for permission-related parameters are restrictive
3. Logging captures both permitted and denied operations
4. Error messages clearly indicate permission requirements
5. No backdoors or bypass mechanisms exist

By adhering to this Meta Principle, we create systems that are inherently more secure, predictable, and maintainable, with clear boundaries for authorized operations.
