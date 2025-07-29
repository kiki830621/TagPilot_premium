# R0057: Commented Code Cleanup with Human Permission

## Definition
Once code updates or refactoring are complete and tested, old commented code can be deleted only with explicit human permission. This ensures historical context is maintained until no longer needed while preventing accumulation of technical debt from obsolete comments.

## Explanation
Commented code provides important historical context during transitions but should not remain indefinitely. This rule creates a clear process for removing obsolete commented code:

1. Commented code must be explicitly marked with MP0037-compliant comments
2. Code can only be removed after the replacement implementation is complete and tested
3. Human permission must be obtained before deletion
4. Documentation of the change and rationale should be preserved separately

## Implementation

### 1. Marking Obsolete Code

When code is replaced but temporarily kept for reference:

```r
# DELETION-CANDIDATE (2025-04-06): Original implementation using static filters
# Will be eligible for deletion after modular filters are validated (est. 2025-04-30)
# static_filters <- list(
#   region = "North America",
#   channel = "amazon" 
# )

# New implementation using dynamic filters
dynamic_filters <- get_user_filters(input$region, input$channel)
```

### 2. Requesting Deletion Permission

Request human permission before deletion:

```r
# Before deletion:
# 1. Request explicit permission from code owner
# 2. Document why the code can be safely removed
# 3. Ensure tests validate the new implementation
```

### 3. Deletion Documentation

Document deleting commented code in commit messages:

```
# Commit message:
Remove commented static filter code per R57

- Original code was commented on 2025-04-06
- New dynamic filter implementation validated with tests
- Deletion approved by [Code Owner Name] on 2025-04-30
```

## Benefits

1. **Clarity**: Codebase remains clean without obsolete comments
2. **History**: Important context is preserved until no longer needed
3. **Safety**: Human oversight prevents premature removal of valuable information
4. **Technical Debt**: Prevents accumulation of obsolete commented code
5. **Documentation**: Creates clear process for managing code transitions

## Anti-Patterns

### 1. Premature Deletion

Avoid:
```r
# Never delete commented code without:
# 1. Ensuring replacement is complete and tested
# 2. Getting explicit permission
# 3. Documenting the reason for deletion
```

### 2. Permission Without Validation

Avoid:
```r
# Bad: Got permission to delete comments but didn't verify replacement works
# delete_commented_code("app.R", line_range(150, 175))
```

### 3. Indefinite Comment Retention

Avoid:
```r
# Bad: Ancient commented code from 2+ years ago with no deletion plan
# Legacy commented code with no MP0037 expiration timeline
```

## Integration with Other Principles

This rule works in conjunction with:

1. **MP0037 (Comment Only for Temporary or Uncertain Code)**: Ensures comments are properly marked with dates and intended lifespans
2. **MP0038 (Incremental Single-Feature Release)**: Helps manage the transition between incremental feature versions
3. **MP0014 (Change Tracking)**: Provides governance for how changes are documented and approved
4. **R0028 (Archiving Standard)**: Offers alternative for preserving historical context without keeping code in-line

## Implementation Process

1. **Mark**: Use MP0037 convention to mark commented code eligible for eventual deletion
2. **Complete**: Finish and validate the replacement implementation
3. **Request**: Ask for human review and permission to delete
4. **Document**: Note the deletion approval in commit messages
5. **Delete**: Remove the commented code
6. **Archive**: If needed, preserve context in documentation or version control notes

## Related Principles

- MP0014: Change Tracking
- MP0016: Modularity
- MP0017: Separation of Concerns
- MP0037: Comment Only for Temporary or Uncertain Code
- MP0038: Incremental Single-Feature Release
- R0028: Archiving Standard
