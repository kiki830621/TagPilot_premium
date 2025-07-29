---
id: "R0065"
title: "AI-Guided Structure and File Modification Rule"
type: "rule"
date_created: "2025-04-08"
author: "Claude"
implements:
  - "MP0002": "Structural Blueprint"
  - "MP0031": "Initialization First"
related_to:
  - "R0000": "Directory Structure"
  - "MP0017": "Separation of Concerns"
  - "R0035": "AI Parameter Modification Rule"
  - "R0044": "Path Modification"
---

# AI-Guided Structure and File Modification Rule

## Core Requirement

AI systems assisting with code development may create or propose new folders in the codebase **only if** the creation is explicitly based on and justified by established principles. Any folder structure modification must reference the relevant principle that guides the structural decision and explain how the new structure implements that principle.

## File Locking Protocol

To prevent AI systems from modifying critical files, the following protocol must be followed:

1. **Lock Designation**: Files that should not be modified by AI systems must include the text `#LOCK FILE` at the beginning of the file content.

2. **AI Responsibility**: AI systems must check for this designation before proposing or making any modifications to files.

3. **Lock Respect**: When encountering a locked file, AI must:
   - Inform the user that the file is locked
   - Decline to make modifications
   - Suggest alternatives if appropriate
   - Offer to create a new file following R0035's SCD Type 2 pattern (appending changes rather than overwriting)

4. **Inappropriate Designations**: The use of file naming patterns like "(lock)" in filenames is deprecated and should be replaced with the in-file designation.

5. **Scope of Lock**: The lock applies to:
   - Direct content modifications
   - Renaming
   - Moving
   - Deletion
   - Any operation that would alter the file or its accessibility

6. **Alternative Approaches**: When encountering locked files, AI should propose:
   - Creating a wrapper function or complementary file that works with the locked file
   - Creating a new file version with a different name
   - Generating implementation suggestions for manual application

## Key Guidelines

### 1. Principle-Based Justification

Before creating a new folder or proposing a folder structure change, AI must:

1. **Identify the governing principle** that justifies the folder's creation
2. **Cite the specific principle ID** (e.g., MP0002, P0007, R0000)
3. **Explain how** the folder structure implements that principle
4. **Document the justification** in comments or documentation

### 2. Valid Justification Sources

Folder creation may be justified by:

1. **Meta-Principles (MP)** regarding structural organization
2. **Principles (P)** that define implementation patterns requiring specific structures
3. **Rules (R)** that establish directory organization requirements
4. **Explicit user request** that references a principle

### 3. Required Documentation

When creating a new folder, AI must include:

1. A **README.md** file explaining:
   - Purpose of the folder
   - Governing principle(s)
   - Relationship to existing structures
   - Content guidelines

2. **Appropriate file structure** that follows established patterns:
   - Follows R0000 directory structure guidelines
   - Maintains consistent naming conventions
   - Preserves existing hierarchy patterns

### 4. Prohibited Actions

AI must not:

1. Create folders based solely on personal judgment or convenience
2. Introduce arbitrary organizational structures not tied to principles
3. Fragment existing structures without principle-based justification
4. Create deeply nested folder structures that violate R0000 rules
5. Modify files marked with `#LOCK FILE` at the beginning of the file content
6. Use or create files with "(lock)" in the filename (deprecated approach)

## Implementation Process

### 1. Evaluation Workflow

Before creating a folder, AI should follow this workflow:

```
1. Identify need for a new folder
2. Check if existing folders meet the need
3. Identify relevant structural principle
4. Verify principle application with user
5. Propose folder with justification
6. Create folder with documentation
```

### 2. Interaction Pattern

When suggesting a new folder structure:

```
Based on [PRINCIPLE-ID], I recommend creating a new folder structure for [PURPOSE].
This aligns with the principle's requirement that [REQUIREMENT].
The structure would be:

/path/to/new_folder/
├── README.md (explaining purpose and governing principle)
├── [relevant_files]
└── [sub_folders]

Would you like me to implement this structure?
```

### 3. Documentation Template

Each newly created folder should include a README.md with:

```markdown
# [Folder Name]

## Purpose

This folder [description of purpose].

## Governing Principle

This structure implements [PRINCIPLE-ID: Principle Name] by [explanation].

## Contents

This folder contains:
- [Description of contents]

## Usage Guidelines

When adding to this folder:
1. [Guideline 1]
2. [Guideline 2]
```

## Examples

### Example 1: Valid Folder Creation

Scenario: Creating a new module folder for testing functionality

```
User: We need to add testing functionality to the system.

AI: Based on MP0016 (Modularity Principle), I recommend creating a dedicated module folder for testing functionality:

/update_scripts/global_scripts/M71_testing/
├── README.md (explaining the testing module)
├── M71_fn_run_tests.R (main entry point)
├── M71_fn_generate_test_data.R
└── examples/
    └── example_test_case.R

This follows the module structure pattern established in R0000 and implements MP0016's requirement for high cohesion and low coupling in functional units.

Would you like me to implement this structure?
```

### Example 2: Invalid Folder Creation

Scenario: Creating folders without principle justification

```
User: Let's organize the code better.

AI: I should not create arbitrary folder structures without principle-based justification. 
Instead, let me help you identify which organizational principles might guide our restructuring:

1. MP0016 (Modularity Principle) for functional organization
2. MP0017 (Separation of Concerns) for logical separation
3. R0000 (Directory Structure) for specific patterns

Which aspects of the codebase would you like to reorganize, and which principles should guide this reorganization?
```

### Example 3: Locked File Respect

Scenario: User asks to modify a locked file

```
User: Can you update the database connection function in fn_get_default_db_paths.R?

AI: I've checked the file fn_get_default_db_paths.R and noticed it contains "#LOCK FILE" at the beginning. 
This indicates it's a locked file that should not be modified by AI systems.

Instead of directly modifying this locked file, I could:
1. Create a new complementary function in a separate file
2. Suggest changes for you to implement manually
3. Help you create a wrapper function that works with the existing locked function

Which alternative approach would you prefer?
```

## Benefits

1. **Structural Consistency**: Ensures all folder structures follow established principles
2. **Reduced Fragmentation**: Prevents proliferation of arbitrary folder structures
3. **Self-Documentation**: Makes organizational choices explicit and traceable to principles
4. **Better Maintainability**: Consistent structures are easier to navigate and maintain
5. **Principle Reinforcement**: Strengthens adherence to the system's architectural principles

## Relationship to Other Principles

This rule:

1. **Implements MP0002 (Structural Blueprint)** by ensuring structural changes adhere to the blueprint
2. **Implements MP0031 (Initialization First)** by ensuring proper initialization of new structures
3. **Relates to R0000 (Directory Structure)** by enforcing its guidelines for folder organization
4. **Relates to MP0017 (Separation of Concerns)** by ensuring folder structures properly separate concerns
5. **Extends R0035 (AI Parameter Modification Rule)** by applying similar protection measures to all files, not just parameters
6. **Complements R0044 (Path Modification)** by providing specific rules for AI systems when handling paths and files

## Conclusion

The AI-Guided Structure and File Modification Rule ensures that AI systems assisting with development:

1. Only create or propose folder structures that are explicitly justified by and aligned with the system's architectural principles
2. Respect file locking designations by not modifying files marked with `#LOCK FILE`
3. Follow a consistent approach to file and folder modification that maintains structural integrity

This comprehensive approach maintains structural integrity, consistency, and principled organization throughout the codebase's evolution while protecting critical system files from unintended AI modifications.
