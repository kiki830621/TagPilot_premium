# Path Modification Principle

## Overview

This principle establishes critical guidelines for modifying, creating, or altering file paths and directory structures within the system. All path-related changes must be guided by explicit principles rather than ad-hoc decisions.

## Rule

**All file path changes, directory structure modifications, or filesystem alterations must adhere to established principles, documented conventions, and explicit requirements.**

## Rationale

File and directory structures form the foundational architecture of any software system. Ad-hoc or unplanned changes to these structures can lead to:

1. Inconsistent organization that impedes maintainability
2. Broken references and dependencies
3. Security vulnerabilities
4. Incompatibility with existing tools and workflows
5. Difficulties in onboarding new team members
6. Version control conflicts

## Implementation Guidelines

### Step 1: Consult Existing Principles

Before any path modification:

- Review relevant path organization principles
- Check existing conventions for similar paths
- Identify any established patterns in related directories
- Verify compatibility with platform-neutral path requirements

```r
# INCORRECT: Creating paths without consulting principles
new_dir <- file.path(base_dir, "data", "new_folder")
dir.create(new_dir)

# CORRECT: Applying established path principles
new_dir <- construct_path_from_convention("data", "new_folder")
if (should_create_directory(new_dir)) {
  dir.create(new_dir)
}
```

### Step 2: Path Construction

When constructing paths:

- Use platform-neutral methods for compatibility
- Follow consistent naming conventions
- Respect hierarchical organization rules
- Apply proper security constraints

```r
# INCORRECT: Hard-coded paths with platform-specific separators
data_path <- "C:\\Users\\data\\raw\\"

# CORRECT: Platform-neutral path construction
data_path <- file.path("data", "raw")
```

### Step 3: Change Justification

For each path modification:

- Document justification based on principles
- Explain compatibility with existing systems
- Note expected impacts on related components
- Reference the principle that guides the change

### Step 4: Path Operation Safety

When performing operations on paths:

- Verify existence before reading
- Confirm permissions before writing
- Validate path legitimacy before any operation
- Apply proper sanitization to prevent injection attacks

```r
# INCORRECT: Unsafe path operation
system(paste("mkdir -p", user_supplied_path))

# CORRECT: Safe path handling
sanitized_path <- sanitize_path(user_supplied_path)
if (is_valid_path(sanitized_path)) {
  dir.create(sanitized_path, recursive = TRUE)
}
```

## Directory Structure Modification Guidelines

When modifying directory structures:

1. **Principle-First Approach**:
   - Consult relevant organizational principles
   - Follow established naming conventions
   - Preserve hierarchical relationships

2. **Impact Assessment**:
   - Analyze dependent systems
   - Check for hard-coded path references
   - Test changes in development environment first

3. **Documentation Updates**:
   - Update relevant documentation
   - Notify stakeholders of changes
   - Provide migration guidance if needed

## Examples

### Incorrect Approach

```r
# BAD: Creating directories without principle guidance
if (!file.exists("new_feature_data")) {
  dir.create("new_feature_data")
}
```

### Correct Approach

```r
# GOOD: Applying principles for directory structure
module_path <- file.path(get_module_base_dir(), MODULE_NAME)
structure_definition <- get_module_structure(MODULE_NAME)

# Create structure based on principles
if (!directory_structure_exists(module_path, structure_definition)) {
  create_directory_structure(module_path, structure_definition)
  log_structure_creation(module_path, "Created following R07 Module Structure principle")
}
```

## Compliance Verification

During code reviews, verify that:

1. Path modifications follow established principles
2. Directory creations have proper documentation and justification
3. Path operations use safe, platform-neutral methods
4. Naming conventions are consistently applied
5. Path-related changes have appropriate error handling

## Integration with Other Principles

This principle should be applied in conjunction with:

- R07: Module Structure Convention
- R21: One Function One File
- R42: Module Naming Convention
- Any platform-specific file organization principles

By adhering to this principle, we ensure our file system organization remains consistent, secure, and maintainable across the entire application.