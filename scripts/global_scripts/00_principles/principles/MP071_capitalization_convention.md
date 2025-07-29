---
id: "MP071"
title: "Capitalization Convention"
type: "meta-principle"
related_to:
  - "MP024": "Natural SQL Language"
  - "MP027": "Integrated Natural SQL Language"
  - "MP062": "Specialized Natural SQL Language"
  - "MP068": "Language as Index"
  - "MP070": "Type-Prefix Naming"
date_created: "2025-04-15"
date_modified: "2025-04-15"
---

# MP071: Capitalization Convention

## Summary

**Capital letters in code are typically used to denote NSQL (Natural SQL) or SNSQL (Specialized Natural SQL) syntax elements.** This convention provides visual differentiation between regular R code and NSQL/SNSQL directives, parameters, or patterns.

## Convention Details

### 1. Core Convention

Capital letters in code, especially all-caps identifiers, typically indicate one of the following:

1. **NSQL/SNSQL Directives**: `CREATE`, `IMPLEMENT`, `SYNC GIT`, `INITIALIZE`, etc.
2. **NSQL/SNSQL Context Identifiers**: `UPDATE_MODE`, `SINGLE REPOSITORY`
3. **Special NSQL/SNSQL Parameters**: `$AUTO_COMMIT`, `$VERBOSE`
4. **Section Markers**: `INITIALIZE`, `MAIN`, `TEST`, `DEINITIALIZE`

This convention follows a similar pattern to SAS, where capitalized keywords denote language directives.

### 2. Exceptions

The following exceptions to this convention apply:

1. **Constants**: Constants in R code may be in all capital letters (e.g., `PI`, `MAX_RETRIES`)
2. **Environment Variables**: System or environment variables may be capitalized
3. **Package Names**: Some R package names contain capital letters by convention
4. **Class Names**: Some class names may start with capital letters

### 3. Application in Code

#### NSQL/SNSQL Directives:

```
CREATE df_customer_profile AT app_data
=== CREATE TABLE df_customer_profile ===
CREATE OR REPLACE TABLE df_customer_profile (
  customer_id INTEGER,
  ...
);
```

#### Section Markers:

```r
# 1. INITIALIZE
source(file.path("update_scripts", "global_scripts", "00_principles", "sc_initialization_update_mode.R"))

# 2. MAIN
tryCatch({
  # Main processing code
}, error = function(e) {
  message("Error in MAIN section: ", e$message)
})
```

#### NSQL Parameters:

```
SYNC GIT
=== Git Synchronization Details ===
$commit_message = "[R008] Update implementation patterns"
$AUTO_COMMIT = TRUE
```

## Rationale

This convention provides several benefits:

1. **Visual Differentiation**: Makes NSQL/SNSQL elements immediately recognizable in mixed code
2. **Syntax Highlighting**: Facilitates syntax highlighting in editors
3. **Code Parsing**: Simplifies automated parsing and processing of NSQL/SNSQL elements
4. **Cognitive Load**: Reduces cognitive load by clearly separating regular code from NSQL/SNSQL directives
5. **Language Consistency**: Aligns with conventions in other languages like SAS

## Implementation Guidelines

### 1. For Developers

- Use all-caps for NSQL/SNSQL directives and section markers
- Use camelCase or snake_case for regular R variables and functions
- Pay attention to capitalization in existing code to maintain consistency

### 2. For Documentation

- Document NSQL/SNSQL elements in all-caps in code examples and documentation
- Explain the capitalization convention in NSQL/SNSQL syntax documentation
- Use consistent capitalization in all syntax examples

### 3. For Tools and Editors

- Configure syntax highlighting to recognize all-caps NSQL/SNSQL elements
- Develop linting rules to enforce proper capitalization
- Implement auto-completion suggestions that respect this convention

## Relationship to Other Principles

This meta-principle directly supports:

1. **MP072: Cognitive Distinction Principle** - Implements "treat similar things similarly, treat different things differently"
2. **MP024: Natural SQL Language** - Establishes a clear visual syntax for NSQL elements
3. **MP027: Integrated Natural SQL Language** - Distinguishes NSQL from surrounding R code
4. **MP062: Specialized Natural SQL Language** - Provides consistent formatting for SNSQL
5. **MP068: Language as Index** - Capitalization helps index and identify language constructs
6. **MP070: Type-Prefix Naming** - Complements type prefixes by adding another visual cue

## Examples

### Mixed R and NSQL Code:

```r
# Regular R code
customer_data <- read_csv("customers.csv")

# NSQL directive
CREATE df_customer_profile AT app_data
=== CREATE TABLE df_customer_profile ===
CREATE OR REPLACE TABLE df_customer_profile (
  customer_id INTEGER PRIMARY KEY,
  name VARCHAR
);

# Back to R code
result <- dbGetQuery(conn, "SELECT * FROM df_customer_profile")
```

### Four-Part Script Structure:

```r
# 1. INITIALIZE
source(file.path("update_scripts", "global_scripts", "00_principles", "sc_initialization_update_mode.R"))

# 2. MAIN
tryCatch({
  dbExecute(app_data, create_table_query)
}, error = function(e) {
  message("Error in MAIN section: ", e$message)
})

# 3. TEST
if (!error_occurred) {
  tryCatch({
    table_exists <- nrow(dbGetQuery(app_data, check_query)) > 0
  }, error = function(e) {
    message("Error in TEST section: ", e$message)
  })
}

# 4. DEINITIALIZE
tryCatch({
  dbDisconnect(app_data)
}, error = function(e) {
  message("Error in DEINITIALIZE section: ", e$message)
})
```

## Conclusion

The Capitalization Convention helps visually organize code that mixes standard R with NSQL/SNSQL elements. By reserving capital letters primarily for NSQL/SNSQL directives and section markers, we create a more readable and maintainable codebase with clear visual separation between different code elements.