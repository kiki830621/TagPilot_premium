---
id: "R28"
title: "Archiving Standard"
type: "rule"
date_created: "2025-04-04"
date_modified: "2025-04-10"
author: "Claude"
implements:
  - "MP05": "Instance vs. Principle"
related_to:
  - "MP07": "Documentation Organization"
  - "M00": "Renaming Module"
---

# Archiving Standard

## Core Requirement

All archived content in the precision marketing system must be stored following proper archiving patterns with metadata and explanatory notes, ensuring a consistent approach to managing deprecated or superseded resources.

## Archiving Guidelines

### 1. Archive Approaches

Two archive approaches are available depending on the situation:

#### 1.1. Archive Directory Approach
For completely deprecated resources that should be removed from active use:
```
/update_scripts/global_scripts/99_archive/
```
This is the standard location for fully archived content that should no longer be used.

#### 1.2. In-Place Archive Approach
For evolutionary changes where the previous version should remain accessible beside the current implementation:
```
filename.ext.archive_description
```
Where:
- `filename.ext` is the original filename with extension
- `archive_description` is a brief descriptor of the archived version (e.g., "pre_optimization", "R76", etc.)
- The new implementation takes the original filename

### 2. Archive Metadata Requirements

When archiving any resource, the following metadata must be added:

1. **Archived Status Indicator**: Append "[ARCHIVED]" to the title
2. **Type Change**: Change the type from the original to "archived_[original_type]" (e.g., "rule" → "archived_rule")
3. **Archive Date**: Add a "date_archived" field with the date of archiving
4. **Archive Reason**: Add an "archived_reason" field explaining why the resource was archived
5. **Related Resources**: Add references to any resources that replace or supersede the archived resource

Example metadata:

```yaml
---
id: "R10"
title: "Database Table Naming and Creation Rule [ARCHIVED]"
type: "archived_rule"
date_created: "2025-04-02"
date_archived: "2025-04-10"
author: "Claude"
archived_reason: "Functionality split between R23 (Object Naming Convention) and R31 (Data Frame Creation Strategy)"
implements:
  - "P02": "Data Integrity"
  - "P11": "Similar Functionality Management Principle"
related_to:
  - "R23": "Object Naming Convention"
  - "R31": "Data Frame Creation Strategy"
---
```

### 3. Archive Content Structure

Archived files should maintain this structure:

1. **Archive Notice**: At the top of the content section, include a notice explaining:
   - That the resource is archived
   - Why it was archived
   - Which resources (if any) replace its functionality
   - Where to find current guidance

2. **Separation Line**: Use a horizontal rule (`---`) to separate the archive notice from the original content

3. **Original Content**: Preserve the original content below the separation line for historical reference

Example:

```markdown
# Resource Name [ARCHIVED]

This resource has been archived. Its functionality has been replaced by Resource X and Resource Y.

Please refer to these resources for current guidance.

For historical reference, the original content is preserved below.

---

# Original Resource Name

[Original content...]
```

### 4. Archive Announcement

When archiving a resource, create a record in the appropriate records directory documenting:

1. The resource that was archived
2. The reason for archiving
3. Any resources that replace it
4. The impact of the archiving

## Archive Types and Naming Conventions

### 1. Full Archive (99_archive directory)

#### 1.1. Archived Rules (R)

Archive naming pattern:
```
R[number]_[name]_archived.md
```

Example:
```
R10_database_table_naming_archived.md
```

#### 1.2. Archived Principles (P)

Archive naming pattern:
```
P[number]_[name]_archived.md
```

Example:
```
P05_old_naming_principles_archived.md
```

#### 1.3. Archived Meta-Principles (MP)

Archive naming pattern:
```
MP[number]_[name]_archived.md
```

Example:
```
MP05_old_instance_vs_principle_archived.md
```

#### 1.4. Archived Modules (M)

Archive naming pattern:
```
M[number]_[name]_archived/
```

For modules (which are directories), archive the entire directory structure.

### 2. In-Place Archive (Same directory)

#### 2.1. Code Files

Archive naming pattern:
```
filename.ext.archive_description
```

Examples:
```
microCustomer.R.archive_pre_optimization
microCustomer_test.R.archive
```

The original filename is used for the new implementation to maintain references.

## Implementation Process

### 1. Choosing the Archive Method

Choose the appropriate archive method based on:

1. **Full Archive (99_archive)** when:
   - The content is completely deprecated with no ongoing use
   - It's been fully replaced by a different approach
   - References to it should be eliminated

2. **In-Place Archive** when:
   - The content represents an evolutionary step
   - It's useful to maintain both versions for comparison
   - References to the file location shouldn't change

### 2. Full Archiving Process

When fully archiving a document:

1. Use M05_renaming module to handle references:
   ```r
   # Load the module
   source("00_principles/M05_renaming/M05_fn_rename.R")
   
   # Prepare archive path
   original_path <- "00_principles/R10_database_table_naming.md"
   archive_path <- "99_archive/R10_database_table_naming_archived.md"
   
   # Move to archive with reference updates
   M05_renaming$move_to_archive(original_path, archive_path, "Functionality split between R23 and R31")
   ```

2. Update the metadata and content structure manually if the module doesn't handle it

3. Create a record documenting the archive

### 3. In-Place Archiving Process

When doing an in-place archive:

1. Rename the original file to the archive pattern:
   ```bash
   mv microCustomer.R microCustomer.R.archive_pre_optimization
   ```

2. Rename the new implementation to the original filename:
   ```bash
   mv microCustomer_optimized.R microCustomer.R
   ```

3. Document the archive information in a comment header

### 4. Finding Archived Content

When looking for archived content:

1. For fully archived content, check the `/update_scripts/global_scripts/99_archive/` directory
2. For in-place archives, look for the `.archive_` suffix in the file's directory
3. Use file prefixes (R, P, MP, M) and suffixes to locate specific types of archived content

## Benefits

1. **Flexibility**: Offers different archive methods based on the situation
2. **Traceability**: Maintains clear links between archived content and its replacements
3. **History Preservation**: Retains historical information for reference
4. **Clear Status**: Makes it immediately obvious that content is archived
5. **Continuity**: Allows for smoother evolutionary changes with in-place archives

## Relationship to Other Rules and Principles

This rule implements MP05 (Instance vs. Principle) by:
1. Establishing a clear separation between active principles and archived ones
2. Providing dedicated approaches for handling archived content

It relates to MP07 (Documentation Organization) by:
1. Defining a consistent approach to organizing archived documentation
2. Ensuring proper metadata for archived resources

It complements M05 (Renaming Module) by:
1. Defining standards that the renaming module should enforce when archiving resources
2. Providing clear guidelines for automated archiving processes

## Conclusion

The Archiving Standard rule ensures that all archived content is handled consistently, properly documented, and stored appropriately. By following these guidelines, we maintain a clean, organized system while preserving historical information for reference. The dual approach of full archiving and in-place archiving provides flexibility based on the specific needs of the situation, ensuring that evolution of components can happen smoothly while maintaining historical context.
