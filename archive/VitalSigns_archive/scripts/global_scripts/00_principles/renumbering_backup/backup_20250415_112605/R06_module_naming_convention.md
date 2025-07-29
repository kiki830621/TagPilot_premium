---
id: "R06"
title: "Module, Sequence, and Derivation Naming Convention"
type: "rule"
date_created: "2025-04-02"
date_modified: "2025-04-02"
author: "Claude"
implements:
  - "P05": "Naming Principles"
derives_from:
  - "MP01": "Primitive Terms and Definitions"
  - "MP02": "Structural Blueprint"
related_to:
  - "R01": "File Naming Convention"
  - "R02": "Principle Documentation"
  - "R08": "Update Script Naming"
---

# Module, Sequence, and Derivation Naming Convention Rule

This rule establishes the standard naming convention for modules, sequences, and derivations within the precision marketing system, ensuring consistency, clarity, and proper organization of functional components across company-specific implementations.

## Core Concept

The system distinguishes between three organizational constructs:

1. **Modules (M prefix)**: Collections of related components that define **what** functionality belongs together. Each module organizes one minimal purpose.

2. **Sequences (S prefix)**: Ordered processes that represent a sequence of steps or a workflow using multiple modules. Each sequence organizes one purpose that consists of several minimal purposes.

3. **Derivations (D prefix)**: Complete sequences that trace the full transformation from raw data to Shiny app. Similar to mathematical proofs, derivations document the step-by-step process of how the final application is derived from initial inputs.

All modules, sequences, and derivations should be named following systematic conventions that clearly identify their type, indicate their domain or purpose, and use consistent formatting across the system.

These organizational constructs are implemented in a company-specific manner, with each company having its own directory within the 13_modules folder.

## Identification Systems

### 1. Module Identification (M-prefix)

All module identifiers must start with the capital letter "M" followed by a two-digit number:

```
M01, M02, M03, etc.
```

This prefix serves multiple purposes:
- Distinguishes modules from other code elements
- Creates a chronological or categorical ordering system
- Provides a unique identifier for referencing modules
- Clearly differentiates modules (M) from sequences (S), derivations (D), Meta-Principles (MP), Principles (P), and Rules (R)

### 2. Sequence Identification (S-prefix)

All sequence identifiers must start with the capital letter "S" followed by hierarchical numbering:

```
S1, S2, S3, etc.
S1_1, S1_2, S1_3, etc.
```

This prefix serves multiple purposes:
- Identifies ordered processes or workflows
- Indicates a sequence of operations that may use multiple modules
- Provides a hierarchical organization of business processes
- Clearly differentiates sequences (S) from modules (M) and derivations (D)

### 3. Derivation Identification (D-prefix)

All derivation identifiers must start with the capital letter "D" followed by a number:

```
D1, D2, D3, etc.
```

This prefix serves multiple purposes:
- Identifies complete transformation flows from raw data to Shiny app
- Documents the proof-like derivation of the final application
- Provides a clear reference for understanding the full system pipeline
- Clearly differentiates derivations (D) from modules (M) and sequences (S)

### 3. Hierarchical Module Numbering

Module numbering should follow a decimal notation to indicate hierarchical relationships:

```
M01       # First top-level module
M01.1     # First sub-module of M01
M01.1.1   # First component of sub-module M01.1
M01.2     # Second sub-module of M01
M02       # Second top-level module
```

This hierarchical numbering makes the organizational structure immediately apparent and facilitates:
- Clear parent-child relationships between modules
- Logical grouping of related functionality
- Easy navigation and discovery
- Systematic addition of new modules

### 4. Module Naming Pattern

The complete module naming pattern is:

```
M[XX]_[descriptive_name]
```

Where:
- **M**: The capital letter "M" indicating a module
- **XX**: A two-digit number (or hierarchical decimal number) for ordering and categorization
- **descriptive_name**: A clear, concise snake_case name describing the module's purpose

Examples:
- `M01_data_processing`
- `M02_customer_analytics`
- `M03_visualization`
- `M01.1_data_import`
- `M01.2_data_transformation`

### 5. Sequence Naming Pattern

The complete sequence naming pattern is:

```
S[X]_[Y]_[descriptive_name]
```

Where:
- **S**: The capital letter "S" indicating a sequence
- **X**: A number representing the major sequence category
- **Y**: A number representing the specific sequence within the category
- **descriptive_name**: A clear, concise snake_case name describing the sequence's purpose

Examples:
- `S1_1_customer_DNA`
- `S1_2_customer_segmentation`
- `S2_1_data_import`
- `S2_2_data_transformation`

### 6. Derivation Naming Pattern

The complete derivation naming pattern is:

```
D[X]_[descriptive_name]
```

Where:
- **D**: The capital letter "D" indicating a derivation
- **X**: A sequential number for the derivation
- **descriptive_name**: A clear, concise snake_case name describing the derivation's purpose

Examples:
- `D1_analytics_pipeline`
- `D2_customer_insight_flow`
- `D3_marketing_campaign_derivation`

## Module Naming Rules

### 1. Uniqueness Requirement

Each module must have a unique identifier:
- No two modules can share the same M-number
- Module numbers should be assigned sequentially without gaps
- When a module is deprecated, its number should not be reused

### 2. Descriptive Names

Module descriptive names should:
- Clearly communicate the module's purpose
- Use snake_case (lowercase with underscores)
- Be concise yet descriptive (2-4 words maximum)
- Avoid abbreviations unless widely understood
- Use nouns or noun phrases (avoid verbs)

### 3. Module Documentation

All modules must be documented with:
- A module definition file in the appropriate directory
- Clear descriptions of the module's purpose
- Lists of components included in the module
- Dependencies on other modules

## Directory and File Organization

### 1. Company Organization

All modules, sequences, and derivations are organized by company:

```
/13_modules/
├── COMPANY_A/
│   ├── M01_data_loading/
│   ├── S1_1_customer_dna/
│   └── D1_analytics_pipeline/
│
└── COMPANY_B/
    ├── M01_data_loading/
    └── ...
```

### 2. Module Directory Structure

Each module should have its own directory within the company folder following the module naming convention:

```
/13_modules/COMPANY_A/M01_data_processing/
/13_modules/COMPANY_A/M02_customer_analytics/
```

### 3. Sequence Directory Structure

Each sequence should have its own directory within the company folder following the sequence naming convention:

```
/13_modules/COMPANY_A/S1_1_customer_dna/
/13_modules/COMPANY_A/S1_2_customer_segmentation/
```

### 4. Derivation Directory Structure

Each derivation should have its own directory within the company folder following the derivation naming convention:

```
/13_modules/COMPANY_A/D1_analytics_pipeline/
/13_modules/COMPANY_A/D2_marketing_campaign/
```

### 5. Module Component Files

Files within a module should follow a consistent naming pattern:

```
module_prefix + component_type + descriptive_name
```

Examples:
```
M01_fn_import_data.R
M01_fn_clean_data.R
M01_ui_data_browser.R
M01_server_data_browser.R
```

### 3. Module Configuration

Module-specific configuration should be stored in a dedicated file:

```
M01_config.yaml
```

## Common Module Categories

The following standard module categories should be used when appropriate:

| Module Prefix | Category | Description |
|---------------|----------|-------------|
| M01-M09 | Core Infrastructure | Fundamental system functionality |
| M10-M19 | Data Processing | Data import, transformation, and export |
| M20-M29 | Analytics | Data analysis and computational modules |
| M30-M39 | Visualization | Data visualization and reporting |
| M40-M49 | UI Components | User interface modules |
| M50-M59 | Server Components | Backend business logic |
| M60-M69 | Integration | External system integration |
| M70-M79 | Testing | Test modules and frameworks |
| M80-M89 | Utility | Helper functions and tools |
| M90-M99 | Experimental | Prototype and experimental modules |

## Module Registration Process

To ensure consistency and avoid conflicts, follow this process when creating a new module:

1. **Check Existing Modules**: Review the module registry to avoid duplication
2. **Select Next Available Number**: Choose the next available M-number in the appropriate category
3. **Register the Module**: Add the module to the central module registry
4. **Create Module Structure**: Set up the directory and skeleton files
5. **Document the Module**: Provide clear documentation of the module's purpose and components

## Example Implementation

### Module Definition

```yaml
# M01_data_processing/M01_definition.yaml
id: "M01"
name: "data_processing"
description: "Core data processing functionality for importing, cleaning, and exporting data"
category: "Core Infrastructure"
components:
  - "M01_fn_import_data.R"
  - "M01_fn_clean_data.R"
  - "M01_fn_export_data.R"
dependencies:
  - "M80_utilities"
```

### Module Component

```r
# M01_data_processing/M01_fn_import_data.R

#' Import data from various sources
#'
#' @param source_type Type of data source
#' @param source_location Location of the data source
#' @param options Additional import options
#'
#' @return Imported data frame
#'
#' @examples
#' import_data("csv", "data/example.csv")
M01_import_data <- function(source_type, source_location, options = list()) {
  # Implementation...
}
```

## Relationship to Other Principles

This Module Naming Convention Rule implements the Naming Principles (P05) and derives from:

- **MP01 (Primitive Terms and Definitions)**: Builds on the definition of modules
- **MP02 (Structural Blueprint)**: Follows the structural organization defined in the blueprint

It is also related to:

- **R01 (File Naming Convention)**: Aligns with file naming conventions
- **R02 (Principle Documentation)**: Follows similar documentation requirements

## Difference Between Modules and MP/P/R System

As established in MP01, there is a fundamental conceptual distinction between:

1. **Modules (M)**: Define **what** functionality belongs together, focusing on organizational structure
2. **MP/P/R (Meta-Principles/Principles/Rules)**: Define **how** to implement functionality, focusing on methodology and standards

This distinction is reflected in their different naming conventions:
- Modules use M-prefix and focus on functional domains
- MP/P/R use their respective prefixes and focus on implementation guidelines

## M/S/D Organization

### 1. Documentation Files

Each organizational construct should include proper documentation:

```
/13_modules/COMPANY_A/M01_data_processing/README.md
/13_modules/COMPANY_A/S1_1_customer_dna/S1_1_customer_dna.md
/13_modules/COMPANY_A/D1_analytics_pipeline/D1_analytics_pipeline.md
```

### 2. Relationships Between Constructs

The organizational constructs have complementary relationships:

- **Modules (M)** provide the minimal purpose functional components
- **Sequences (S)** define the ordered steps of a business process using multiple modules
- **Derivations (D)** document complete transformations from raw data to application
- A sequence typically uses functionality from multiple modules
- Multiple sequences may use the same module
- Derivations may include multiple sequences

This relationship follows the principle that:
- Modules define **what minimal functionality** is available
- Sequences define **what should happen** in a specific business context
- Derivations define **how we get from raw data to finished application**

### 3. Update Script Implementation

Implementation scripts following the R08 update script naming convention reference modules through their D_E component:

```
AABB_C_D_E_description.R
```

Where D_E refers to the module (e.g., 2_1 refers to module M21).

Each update script corresponds to one module, since modules represent the minimal organizational unit of purpose.

## Best Practices

### Company Organization Best Practices

1. **Clean Separation**: Maintain clean separation between companies
2. **Consistent Structure**: Use the same organizational structure across all companies
3. **Company-Specific Implementation**: Allow for company-specific implementations of modules, sequences, and derivations
4. **Shared Principles**: All companies follow the same MP/P/R principles

### Module Best Practices

1. **Minimal Purpose**: Each module should address a single minimal purpose
2. **Cohesive Modules**: Each module should represent a cohesive set of related functionality
3. **Clear Boundaries**: Define clear interfaces between modules to minimize dependencies
4. **Consistent Naming**: Maintain consistency in module naming within categories
5. **Appropriate Granularity**: Create modules that are neither too large nor too small
6. **Documentation First**: Document module purpose and structure before implementation
7. **Versioning Awareness**: Consider how modules will evolve over time

### Sequence Best Practices

1. **Process Orientation**: Each sequence should represent a complete business process
2. **Step Definition**: Clearly define the steps involved in the sequence
3. **Module References**: Identify which modules are used in each step
4. **Input/Output Documentation**: Document the inputs and outputs of each sequence
5. **Logical Progression**: Ensure that the sequence represents a logical progression of steps
6. **Dependency Mapping**: Document dependencies between sequences

### Derivation Best Practices

1. **Complete Transformation**: Each derivation should document a complete transformation from raw data to Shiny app
2. **Proof-Like Structure**: Organize the derivation similar to a mathematical proof
3. **Sequence References**: Identify which sequences are used in the derivation
4. **Traceability**: Ensure inputs and outputs at each step are clearly traced
5. **Data Flow Visualization**: Include visualizations of the data flow
6. **Validation Points**: Document validation and verification steps in the transformation

## Conclusion

The Module, Sequence, and Derivation Naming Convention Rule provides a systematic approach to naming and organizing all organizational constructs within the precision marketing system.

By maintaining a company-specific organization and separating **modules** (minimal purpose components), **sequences** (business processes), and **derivations** (complete transformations), we create a clearer organization that:

1. Makes it easier to understand what minimal functionality exists (modules)
2. Makes it easier to understand how that functionality is used in business contexts (sequences)
3. Makes it easier to understand the complete transformation from raw data to application (derivations)
4. Provides better traceability between implementation scripts and their conceptual organization
5. Facilitates reuse of modules across different business processes
6. Allows for company-specific implementations while maintaining consistent organizational principles

Following this rule ensures consistency, clarity, and proper organization, facilitating easier discovery, navigation, and maintenance of the system across multiple company implementations.
