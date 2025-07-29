---
id: "R0038"
title: "Platform Numbering Convention"
type: "rule"
date_created: "2025-04-06"
date_modified: "2025-04-07"
author: "Claude"
implements:
  - "MP0001": "Primitive Terms and Definitions"
  - "MP0009": "Discrepancy Principle"
related_to:
  - "D01": "DNA Analysis Derivation Flow"
  - "R0019": "Object Naming Convention"
  - "P0005": "Naming Principles"
  - "R0007": "Update Script Naming Convention"
---

# R0038: Platform Numbering Convention

This rule establishes the standardized mapping between platform identifiers and sales/marketing platforms across the precision marketing system.

## Core Requirement

All platform-specific scripts, derivations, and analyses must include the appropriate platform number to clearly identify which platform the data originates from or pertains to.

## Directory Structure Requirement

All first-level directories within global_scripts MUST use the numbered prefix format: DD_name (e.g., 04_utils).
Directories without the numbered prefix format (e.g., "utils") are NOT permitted.
This numbering ensures consistent organization and maintains the clear dependency hierarchy.

## Platform Number Mapping

The following numbering scheme establishes the official mapping between numerical identifiers and platforms:

### Platform Dictionary

| Platform Number | Platform Name | Code Alias | Description |
|----------------|---------------|------------|-------------|
| **01** | Amazon | AMZ | Primary e-commerce marketplace |
| **02** | Official Website | WEB | Company's own e-commerce website |
| **03** | Retail Store | RET | Physical retail store locations |
| **04** | Distributor | DST | Third-party distributor channels |
| **05** | Social Media | SOC | Social media marketplaces |
| **06** | eBay | EBY | eBay marketplace platform |
| **07** | Cyberbiz | CBZ | Cyberbiz e-commerce platform |
| **09** | Multi-platform | MPT | Multi-platform integrated analysis |

### Usage Formats

This mapping can be applied in different formats:

1. **Numeric Identifier** (for scripts, database tables):
   - Single-digit: `1`, `2`, `3`...
   - Double-digit: `01`, `02`, `03`...
   
2. **Code Alias** (for human documentation, comments):
   - `AMZ`, `WEB`, `RET`, `DST`, `SOC`, `EBY`, `CBZ`, `MPT`

## Platform Number Usage Rules

### 1. Derivation Scripts

As illustrated in [D01: DNA Analysis Derivation Flow](D01_dna_analysis.md), derivation steps should include the platform number:

```
D01_01_XX: Step description (Amazon)
```

Where:
- `D01`: Represents the derivation type
- `01`: Represents the platform (Amazon)
- `XX`: Represents the sequential step number

### 2. Script Filenames

Scripts that process platform-specific data should include the numeric platform identifier for security and obfuscation purposes:

```
0101g_create_or_replace_sales_dta.R  # For Amazon (01)
0102g_create_or_replace_sales_dta.R  # For Official Website (02)
```

Where:
- `01`: Module identifier
- `01`/`02`: Platform identifier (numeric only)
- `g`: Global script indicator
- Use generic descriptive names where possible for enhanced security

### 3. Table Naming

Database tables that contain platform-specific data should use numeric prefixes for internal processing, but can use platform names in descriptive parts:

```
p01_sales_dta           # Preferred for security-critical contexts
amazon_sales_dta         # Acceptable for internal documentation
```

### 4. Code Comments and Documentation

In code comments and documentation, use the code aliases for improved readability:

```r
# Process AMZ sales data from the raw import
# Transform WEB customer records to standard format
```

### 5. Multi-Platform Analysis

For analyses that integrate data from multiple platforms, use the `09` identifier:

```
D01_09_XX: Multi-platform integration step
```

### 6. Platform Selection in User Interfaces

When presenting platform selection options to users in the UI, use full platform names rather than codes:

```r
selectInput("platform", "Select Platform", 
  choices = c("Amazon", "Official Website", "eBay", "Cyberbiz")
)
```

## Extending the Platform Dictionary

When adding a new platform to the system:

1. Assign the next available number in the sequential series (06, 07, 08, etc.)
2. Update this rule file with the new platform entry
3. Document the data structure and format specific to the new platform
4. Update any cross-platform integration scripts to include the new platform

## Reserved Identifiers

- **00**: Reserved for platform-agnostic operations
- **08**: Reserved for future platform expansion
- **09**: Exclusively for multi-platform integration
- **10-99**: Reserved for future expansion

## Benefits of Platform Numbering

1. **Clear Data Provenance**: Immediately identifies the source platform for any data
2. **Consistent Naming**: Establishes a system-wide convention for referencing platforms
3. **Integration Support**: Facilitates multi-platform data integration with clear source tracking
4. **Script Organization**: Enables logical grouping of scripts by platform
5. **Standardized Documentation**: Creates a common vocabulary for discussing platform-specific processes
6. **Enhanced Security**: Using numeric codes in filenames and system components adds a layer of obfuscation

### Security Through Numeric Codes

The use of numeric codes rather than explicit platform names in script filenames and database objects provides several security benefits:

1. **Reduced External Visibility**: Numeric codes make it harder for external observers to immediately identify which e-commerce platforms are being analyzed
2. **Information Compartmentalization**: Minimizes the exposure of business relationships in code repositories and file systems
3. **Accidental Disclosure Prevention**: Reduces risk of inadvertently revealing platform-specific data processing in logs or error messages
4. **Business Intelligence Protection**: Makes it more difficult for competitors to determine which platforms are strategically important to the business
5. **Separation of Identification and Description**: Allows identification (numeric codes) to be separated from description (platform names)

## Implementation Guidelines

### Security Level Requirements

The level of numeric code usage should be determined by the security sensitivity of the context:

| Security Level | Context | Identifier Format |
|---------------|---------|------------------|
| **High** | Public repositories, Script filenames, Database objects | Numeric codes only (01, 02) |
| **Medium** | Internal code, Processing logic, Variable names | Numeric codes with comments (01 # Amazon) |
| **Low** | Documentation, UI elements, User-facing reports | Code aliases or full names (AMZ or Amazon) |

### Implementation Timeline

This platform numbering convention is effective immediately for all new development. Existing scripts and documents should be updated to conform to this standard as part of regular maintenance cycles.

### Audit Requirements

1. Regular audits should be conducted to ensure:
   - Consistent use of numeric codes in high-security contexts
   - Proper use of code aliases in documentation
   - New platforms are properly registered in the platform dictionary
   
2. Security code reviews should verify that platform names are not exposed in:
   - Public repositories
   - Log files
   - Error messages
   - API response data

## Related Documentation

- [D01: DNA Analysis Derivation Flow](D01_dna_analysis.md) - Contains examples of platform number usage
- [R0019: Object Naming Convention](R0019_object_naming_convention.md) - General naming rules
