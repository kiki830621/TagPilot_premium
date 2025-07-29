---
id: "R0007"
title: "Update Script Naming Convention"
type: "rule"
date_created: "2025-04-02"
date_modified: "2025-04-08"
author: "Claude"
implements:
  - "P0001": "Script Separation"
  - "P0005": "Naming Principles"
derives_from:
  - "MP0001": "Primitive Terms and Definitions"
  - "MP0002": "Structural Blueprint"
related_to:
  - "R0001": "File Naming Convention"
  - "R0042": "Module Naming"
---

# Update Script Naming Convention Rule

This rule establishes the specific naming convention for update scripts within the precision marketing system, ensuring scripts are properly organized, easily discoverable, and clearly linked to their documentation.

## Core Concept

Update scripts should be named following a structured convention that encodes derivation path, platform specificity, and purpose into the filename, making the organization self-documenting and facilitating proper sequencing.

## Update Script Naming Pattern

Update scripts must follow this structured naming pattern:

```
Daa_bb_Pcc_description.R
```

Where each component has a specific purpose:

- **D**: Derivation identifier prefix (fixed as 'D')
- **aa**: Primary derivation group (00-99) - identifies the derivation category
- **bb**: Secondary derivation group (00-99) - identifies the specific derivation process
- **P**: Platform identifier prefix (fixed as 'P')
- **cc**: Platform number (00-99) - identifies the platform the script applies to
- **description**: Brief descriptive text explaining the script's purpose

### Component Details

#### Derivation Identifier (D)

- The uppercase letter 'D' that identifies this as a derivation script
- Always present as the first character of the filename
- Represents the script's role in a complete transformation process

#### Primary Derivation Group (aa)

- A two-digit number from 00 to 99
- Identifies the major derivation category
- Provides the primary sort order for execution
- Represents major processing domains or analytical approaches

**Examples**:
- **01**: Customer analytics derivation
- **02**: Product analytics derivation
- **03**: Campaign performance derivation
- **04**: Market basket analysis derivation
- **05**: Forecasting derivation

#### Secondary Derivation Group (bb)

- A two-digit number from 00 to 99
- Identifies the specific process within the derivation category
- Scripts with lower numbers execute before those with higher numbers
- Sequential and ideally without gaps (00, 01, 02, ...)

**Examples** (for Customer Analytics, D01):
- **01**: Customer profile creation
- **02**: RFM segmentation
- **03**: Customer DNA synthesis
- **04**: CLV calculation

#### Platform Identifier (P)

- The uppercase letter 'P' that identifies this as platform-specific
- Always present before the platform number
- Represents the script's applicability to a specific platform

#### Platform Number (cc)

- A two-digit number from 00 to 99 that identifies the platform
- Follows the platform numbering convention defined in R38
- Follows these standard assignments:
  - **00**: Platform-independent (applies to all platforms)
  - **01**: Amazon
  - **02**: Official Website
  - **03**: Retail Store
  - **04**: Distributor
  - **05**: Social Media
  - **06**: eBay
  - **07**: Cyberbiz
  - **09**: Multi-platform (applies to multiple specific platforms)

#### Description

- A brief descriptive text explaining the script's purpose
- Uses snake_case (lowercase with underscores)
- Should be concise yet descriptive
- Focuses on the script's function, not implementation details

### File Extension

All update scripts must use the `.R` extension to indicate they are R scripts.

## Naming Examples

```
D01_01_P0000_customer_profile_initialization.R
```
- **D01**: Customer analytics derivation
- **01**: Customer profile creation process
- **P0000**: Platform-independent (applies to all platforms)
- **customer_profile_initialization**: Describes the purpose

```
D01_03_P0001_amazon_dna_synthesis.R
```
- **D01**: Customer analytics derivation
- **03**: Customer DNA synthesis process
- **P0001**: Amazon-specific implementation
- **amazon_dna_synthesis**: Describes the purpose

```
D03_02_P0006_ebay_campaign_performance.R
```
- **D03**: Campaign performance derivation
- **02**: Second process in campaign analysis
- **P0006**: eBay-specific implementation
- **ebay_campaign_performance**: Describes the purpose

```
D05_01_P0009_multiplatform_sales_forecast.R
```
- **D05**: Forecasting derivation
- **01**: First process in forecasting
- **P0009**: Multi-platform implementation
- **multiplatform_sales_forecast**: Describes the purpose

## Implementation Rules

### 1. Consistency Requirement

- All update scripts must follow this naming pattern without exception
- Scripts that don't follow the pattern should be renamed
- No alternative naming schemes are permitted for update scripts

### 2. Derivation Grouping

- Scripts within the same analytical process should share the same primary derivation group (aa)
- Keep the number of derivation categories manageable (ideally under 20)
- Document the purpose of each derivation category in the documentation

### 3. Execution Order

- Within a derivation category and platform, scripts are executed in numerical order of their secondary derivation group (bb)
- Scripts with lower bb values execute before those with higher values
- Cross-platform dependencies should be documented explicitly

### 4. Platform Specificity

- Every script must specify its platform applicability
- Use P0000 for genuinely platform-independent scripts
- Use P0001-P0007 for single-platform scripts
- Use P0009 for multi-platform scripts that aren't truly platform-independent
- The platform number must correspond to the defined platform numbering convention (R0038)

### 5. Naming Process

When creating a new update script:

1. Identify the appropriate derivation category for the script's functionality
2. Determine the specific process within that derivation
3. Identify the platform specificity for the script
4. Create a clear, descriptive name for the script
5. Combine these elements using the standard pattern

## Benefits

The structured naming convention provides multiple benefits:

- **Execution Clarity**: Clear path of execution within a derivation process
- **Platform Specificity**: Explicit indication of which platform the script applies to
- **Derivation Organization**: Groups related analytical processes together
- **Self-Documentation**: Naming structure indicates the script's role and relationship
- **Maintainability**: Makes dependencies and execution flow clear to developers
- **Discoverability**: Makes it easy to locate scripts by function, platform, or derivation category

## Relationship to Module, Derivation, and Platform Systems

This naming convention directly connects with:

1. **Derivation System**: The Daa_bb component explicitly identifies which analytical derivation the script belongs to
2. **Platform System**: The Pcc component explicitly identifies which platform the script applies to
3. **Module Structure**: While not explicitly encoded in the filename, scripts within the same derivation typically use related modules

## Relationship to Other Principles

This Update Script Naming Convention Rule implements:

- **P0001 (Script Separation)**: Supports the separation of update scripts and global scripts
- **P0005 (Naming Principles)**: Provides specific naming patterns for update scripts

And derives from:

- **MP0001 (Primitive Terms and Definitions)**: Follows the defined terminology
- **MP0002 (Structural Blueprint)**: Aligns with the overall system structure

It is also related to:

- **R0001 (File Naming Convention)**: Provides specific conventions for update scripts
- **R0038 (Platform Numbering Convention)**: Uses standard platform number assignments
- **R0042 (Module Naming)**: Complements the module naming conventions

## Migration Plan

For existing scripts that follow the previous AABB_C_DE_description.R naming convention:

1. **Mapping Process**:
   - **AA (Bundle group)** → Convert to appropriate Derivation category (Daa)
   - **BB (Serial number)** → Convert to appropriate Secondary derivation (bb)
   - **C (Sub-script) & DE (Module)** → These are replaced by the Platform designation (Pcc)
   - **Description** → Retain and enhance for clarity if needed

2. **Practical Steps**:
   - Create a mapping document that translates old naming to new naming
   - Implement renames in batches, starting with the most commonly used scripts
   - Update all references in documentation and other scripts

3. **Verification**:
   - After renaming, verify correct execution order
   - Ensure all dependent scripts continue to function properly
   - Update any automation that depends on script naming

## Conclusion

By following this Update Script Naming Convention Rule, we ensure that our update scripts are consistently named, properly organized, and clearly linked to their platforms and derivation processes. This structured approach enhances maintainability, supports proper execution sequencing, and makes the system more accessible to all team members.

#LOCK FILE
