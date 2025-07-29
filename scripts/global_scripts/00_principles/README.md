# Precision Marketing Principles

This directory contains the fundamental principles and guidelines that govern the precision marketing framework. These principles establish consistent patterns, standards, and best practices across the project.

## About Principles

Principles are conceptual, reusable guidelines that apply across the project. They are distinct from instances (specific implementations) as defined in the Instance vs. Principle Meta-Principle (MP05_instance_vs_principle.md).

## Principle Coding System

The principles follow a formal coding system that categorizes them into six types:

1. **Meta-Principles (MP)**: Principles about principles that govern how principles are structured, organized, and related
2. **Principles (P)**: Core principles that provide guidance for implementation
3. **Rules (R)**: Specific implementation guidelines that derive from principles
4. **Modules (M)**: Executable code that implements principles and rules
5. **Sequences (S)**: Ordered processes that represent workflows using multiple modules
6. **Derivations (D)**: Complete sequences that trace full transformations from raw data to final application

This coding system is reflected in both the filenames and the YAML front matter within each file:

```yaml
---
id: "MP01"             # Principle identifier
title: "Short Title"   # Concise title
type: "meta-principle" # Classification
date_created: "2025-04-02"
author: "Claude"
derives_from:          # What this principle is based on
  - "MP00": "Axiomatization System"
influences:            # What this principle affects
  - "MP02": "Structural Blueprint"
---
```

## Critical System Rules

### Archiving Standard (R28)

All deprecated or obsolete resources MUST be archived following R28_archiving_standard.md:

1. Move deprecated files to the `99_archive` directory
2. Rename files to include `_archived` suffix
3. Update YAML front matter with `type: "archived_*"` and `date_archived`
4. Add reference to replacement resource(s) and reason for archiving
5. Create a record documenting the archiving decision

This ensures we maintain historical resources while keeping the active system clean and organized.

## Templates Directory

The `templates/` subdirectory contains reusable templates for creating new scripts and components:

- **sc_update_scripts_template.R**: Template for platform-specific update scripts (e.g., amz_D03_01.R)
- **sc_global_scripts_template.R**: Template for utility scripts in global_scripts
- **fn_function_template.R**: Template for individual function files following R21 and R69
- **Additional templates**: See templates/README.md for complete list and usage instructions

These templates enforce consistent structure, documentation, and principle compliance across all new code.

## Recent Updates

**2025-07-16**:
- Added P82 (Data Processing Method Selection) - Principle for selecting appropriate data processing methods (JOIN vs mutate) based on context and requirements including performance considerations, memory usage, and code maintainability

**2024-12-27**:
- Added R124 (Application Structure Standard - L1 Basic) - L1 Basic applications must include `scripts/global_scripts/` as their connection to shared codebase
- Created docs/APP_STRUCTURE_STANDARD.md - Detailed documentation of application structure requirements for L1 Basic
- Established standardized directory structure for L1 Basic applications
- Noted that L2 Pro and L3 Enterprise may have different architectural requirements

**2025-06-08**:
- Created templates/ directory for reusable code templates
- Added sc_update_scripts_template.R for creating consistent update scripts
- Added sc_global_scripts_template.R for utility scripts
- Added fn_function_template.R following R21 (One Function One File) and R69 (Function File Naming)
- Templates enforce principle compliance and consistent documentation

**2024-01-06**:
- Added R123 (Unified product ID Rule) - All platform-specific product identifiers must be standardized to `product_id` in final data structures
- Updated fn_process_position_table.R - Rename platform-specific columns to `product_id` before saving to app_data
- Updated fn_merge_position_tables.R - Use standardized `product_id` for joining, removed platform parameter

**2025-05-31**:
- Added R122 (ID Extraction Guidelines) - Establishes clear guidelines for when IDs should be created in Cleanse vs Process stages of data pipeline
- Created fn_cleanse_eby_reviews.R - eBay-specific review cleansing function with support for eBay product numbers and country statistics
- Updated fn_import_competitor_products.R - Added platform parameter for table naming, skip parameter for header rows, column_names for flexibility, and brand_imputed for handling UNKNOWN brands

**2025-05-28**:
- Added R121 (Localized Activation) - Components should implement conditional execution logic internally to perform expensive operations only when contextually active, improving performance through selective computation

**2025-05-18**:
- Added R120 (Filter Variable Naming Convention) - Filter variables must use the suffix `_filter`
- Updated D01.md to implement the filter variable naming convention for multi-dimensional DNA analysis
- Updated all amz_D01_*.R scripts to use the `product_line_id_filter` naming convention

**2025-04-10**:
- Updated MP27 (Specialized Natural SQL Language) to v2 with enhanced capabilities:
  - Precise data operation expressions with source → transform → destination format
  - Tidyverse-NSQL integration with tidyverse equivalents for SQL
  - Component mapping for UI elements and their data sources
  - Enhanced data flow documentation for reactive dependencies
  - Testing extensions for validating data transformations
  - Visual query representation for generating data flow diagrams
  - Metadata integration for documenting data quality and expectations
  - Entity-relationship documentation for database relationships

**2025-04-09**:
- Added P81 (Tidyverse-Shiny Terminology Alignment) - Component names must align with tidyverse operations
- Added P80 (Integer ID Consistency) - System IDs must be implemented as integers
- Added R88 (Shiny Module ID Handling) - Module IDs must be consistently handled
- Added R89 (Integer ID Type Conversion) - IDs must be converted to integers
- Added R90 (ID Relationship Validation) - ID relationships must be validated
- Added MP52 (Unidirectional Data Flow) - Data should flow in a single, predictable direction
- Added MP53 (Feedback Loop) - User actions trigger server processes which update UI
- Added MP54 (UI-Server Correspondence) - UI elements must have purpose in server functionality
- Added P76 (Error Handling Patterns) - Systematic approach to error detection and recovery
- Added P77 (Performance Optimization) - Optimizing reactive applications for efficiency
- Added P78 (Component Composition) - Patterns for composing smaller components into applications
- Added P79 (State Management) - Structured approach to managing application state
- Added C01 (App Construction Framework) - Comprehensive guide for application construction
- Elevated P73 (Server-to-UI Data Flow) to MP52 as a broader meta-principle

**2025-04-08**:
- Added MP48 (Universal Initialization Metaprinciple) - Everything must be initialized before use
- Added MP49 (Docker-Based Deployment) - All deployments must use Docker containers
- Added MP50 (Debug Code Tracing) - Trace code execution path for effective debugging
- Added MP51 (Test Data Design) - Design test data as realistic application inputs
- Added R68 (Object Initialization Rule) - Variables must be initialized with appropriate default values
- Added R69 (Function File Naming Rule) - Files containing functions must use "fn_" prefix
- Added R70 (N-Tuple Delimiter Rule) - Use "####component.name####" as delimiter pattern
- Added R71 (Enhanced Input Components Rule) - Use enhanced inputs over basic alternatives
- Added R72 (Component ID Consistency Rule) - Shiny components must use consistent IDs
- Added R73 (App.R Change Permission Rule) - All changes to app.R must be explicitly permitted
- Added R74 (Shiny Test Data Rule) - Create standardized test data for Shiny applications
- Added R75 (Test Script Initialization Rule) - Initialize test scripts with proper working directory setup
- Added SLN04 (Shiny Module Namespace Collision) - Resolving Shiny module namespace issues
- Added key notation method to NSQL for identifying dataset keys
- Refactored detect_data_availability.R into separate function files following R21 and R69
- Updated documentation for functionalizing module to clarify variable scoping

**2025-04-07**:
- Added P16 (Component-wise Testing) principle for testing UI components in isolation
- Added P15 (Debug Efficiency Exception) principle
- Implemented example of UI-server-defaults triple under Debug Efficiency Exception
- Created component-level testing framework for microCustomer module
- Updated RShiny app utilities to follow R21, R46, and MP28
- Updated package management utilities to follow MP28
- Updated root path configuration to follow R21, R45, and R46

**2025-04-06**:
- Added MP28 (Avoid Self-Reference Unless Necessary) principle
- Added MP29 (No Fake Data) principle
- Added MP30 (Vectorization Principle) meta-principle
- Added R46 (Source Directories Not Individual Files) rule
- Added R47 (Aggregate Variable Naming Convention) rule
- Added R48 (Use Switch Over Multiple If-Else) rule
- Added R49 (Apply Functions Over For Loops) rule
- Added R50 (data.table Vectorized Operations) rule
- Added R51 (Lowercase Variable Naming Convention) rule
- Updated eBay connection code to follow MP29
- Enhanced database utilities to follow R21, R45, and R46
- Updated transform functions to follow R47, R48, R50, and MP30
- Updated transform functions to handle IPT calculation correctly
- Updated analysis_dna function to use lowercase field names (R51)

**2025-04-04**: 
- Implemented principles renumbering plan to eliminate gaps in numbering
- Converted R05 (Renaming Methods) to M00 (Renumbering Principles Module)
- Renumbered rules from R06-R32 to R05-R28, eliminating gaps
- Archived R10 (Database Table Naming) to 99_archive directory
- Incorporated database table functionality into R19 (Object Naming Convention) and R27 (Data Frame Creation Strategy)
- Detailed documentation available in records/2025_04_04_principles_renumbering_execution.md

**2025-04-02**: 
- Implemented the MP/P/R principle coding system across all principles
- Renamed all principle files to follow the MP/P/R naming convention
- Added YAML front matter to document relationships between principles
- Established a formal axiomatic system as defined in MP00_axiomatization_system.md
- Reclassified YAML Configuration from P27 to R04 as it defines specific implementation rules
- Reclassified Bottom-Up Construction from R16 to P07 as it defines a broader methodology
- Added "app_" prefix to P07 to indicate it's specific to app construction
- Extracted directory structure rules from MP02 into R00_directory_structure.md
- Extracted file naming convention rules from MP02 into R01_file_naming_convention.md
- Extracted principle documentation rules from MP02 into R02_principle_documentation.md
- Created P05_naming_principles.md to document naming guidelines and sequence management
- Created P03_debug_principles.md to document systematic debugging and troubleshooting principles
- Created P06_data_visualization.md to document data visualization standards and best practices
- Renumbered all principles to eliminate gaps in the numeric sequence
- Original versions of the files are archived in 99_archive/00_principles_renumbering_backup_2025_04_02
- Detailed documentation of this reorganization is available in update_scripts/records/2025-04-02_*.md

## Six-Level Conceptual Framework

The MP/P/R/M/S/D coding system represents a six-level conceptual framework for organizing our guidelines:

### 1. Meta-Principles (MP)
- **Purpose**: Govern how principles themselves are structured and related
- **Nature**: Abstract, conceptual, foundational
- **Scope**: System-wide architecture and organizational concepts
- **Examples**: Axiomatization system, primitive terms, structural blueprint
- **Identification**: Prefix "MP" followed by number (e.g., MP01)

### 2. Principles (P)
- **Purpose**: Provide core guidance for implementation
- **Nature**: Conceptual but practical, actionable guidelines
- **Scope**: Broad implementation patterns and approaches
- **Examples**: Project principles, script separation, data integrity
- **Identification**: Prefix "P" followed by number (e.g., P00) 

### 3. Rules (R)
- **Purpose**: Define specific implementation details
- **Nature**: Concrete, specific, directly applicable
- **Scope**: Narrow implementation techniques and specific patterns
- **Examples**: Directory structure, file naming convention, YAML configuration
- **Identification**: Prefix "R" followed by number (e.g., R00)

### 4. Modules (M)
- **Purpose**: Provide reusable implementation of principles
- **Nature**: Concrete, executable code that implements principles
- **Scope**: Specific functionality that operationalizes principles and rules
- **Examples**: Renumbering principles, code generation, validation
- **Identification**: Prefix "M" followed by number (e.g., M00)

### 5. Sequences (S)
- **Purpose**: Organize ordered processes that represent workflows
- **Nature**: Procedural, workflow-oriented
- **Scope**: Business processes using multiple modules
- **Examples**: Customer DNA generation, Campaign analysis workflow
- **Identification**: Prefix "S" followed by sequence numbers (e.g., S1_1)

### 6. Derivations (D)
- **Purpose**: Document complete transformations
- **Nature**: Comprehensive, end-to-end processes
- **Scope**: Full flow from raw data to final application
- **Examples**: WISER campaign analytics, Customer segmentation derivation
- **Identification**: Prefix "D" followed by number (e.g., D1)

This multi-level framework allows principles to be organized hierarchically, with:
- Meta-Principles establishing the foundation
- Principles providing general guidance
- Rules offering specific implementation details
- Modules providing executable implementations
- Sequences organizing workflows
- Derivations documenting complete transformations

There is a fundamental distinction between:
- **MP/P/R**: Tell us **how** to implement functionality (methodology, guidelines)
- **M/S/D**: Tell us **what** to implement (functional organization)

This separation of concerns allows for modular development, clear documentation, and systematic organization of the codebase.

## Meta-Principles (MP) - 54 products

The highest level guiding principles for the system.

1. [MP01: Simplicity Over Complexity](MP01_simplicity.md) - Simple solutions are preferred over complex ones
2. [MP02: Convention Over Configuration](MP02_convention.md) - Follow established patterns rather than requiring explicit configuration
3. [MP03: Explicit Over Implicit](MP03_explicit.md) - Make behaviors and dependencies clear and visible
...
27. [MP27: Specialized Natural SQL Language (v2)](MP62_specialized_natural_sql_language_v2.md) - Enhanced documentation for data operations
...
52. [MP52: Unidirectional Data Flow](MP52_unidirectional_data_flow.md) - Data should flow in a single, predictable direction
53. [MP53: Feedback Loop](MP53_feedback_loop.md) - Interactive systems must implement a complete circular flow of information
54. [MP54: UI-Server Correspondence](MP54_ui_server_correspondence.md) - Every UI element must correspond to server-side functionality

## Principles (P) - 82 products

Specific principles that guide implementation decisions.

1. [P01: Single Responsibility](P01_single_responsibility.md) - Each component should do one thing well
2. [P02: Clear Dependencies](P02_clear_dependencies.md) - Dependencies between components should be explicitly stated
3. [P03: Meaningful Names](P03_meaningful_names.md) - Names should clearly indicate purpose and behavior
...
76. [P76: Error Handling Patterns](P76_error_handling_patterns.md) - Systematic approach to error detection and recovery
77. [P77: Performance Optimization](P77_performance_optimization.md) - Optimizing reactive applications for efficiency
78. [P78: Component Composition](P78_component_composition.md) - Patterns for composing smaller components into applications
79. [P79: State Management](P79_state_management.md) - Structured approach to managing application state
80. [P80: Integer ID Consistency](P80_integer_id_consistency.md) - System identifiers shall be implemented as integers
81. [P81: Tidyverse-Shiny Terminology Alignment](P81_tidyverse_shiny_terminology_alignment.md) - Component names must align with tidyverse operations
82. [P82: Data Processing Method Selection](principles_qmd/P82_data_processing_method_selection.qmd) - Principle for selecting appropriate data processing methods based on context and requirements

## Rules (R) - 124 products

Specific implementation rules that must be followed.

1. [R01: File Naming](R01_file_naming.md) - Files must be named according to established conventions
2. [R02: Function Naming](R02_function_naming.md) - Functions must be named according to established conventions
...
76. [R76: Module Data Connection](R76_module_data_connection.md) - Server modules must receive data source connections rather than pre-filtered data
...
88. [R88: Shiny Module ID Handling](R88_shiny_module_id_handling.md) - Module component IDs must be consistently handled within Shiny's namespacing system
89. [R89: Integer ID Type Conversion](R89_integer_id_type_conversion.md) - All system identifiers must be explicitly converted to integer type when used in data operations
90. [R90: ID Relationship Validation](R90_id_relationship_validation.md) - Applications must validate the existence and relationship of IDs before data operations
...
120. [R120: Filter Variable Naming Convention](R120_filter_variable_naming.md) - Filter variables must use the suffix `_filter` to distinguish from entity identifiers
121. [R121: Localized Activation](R121_localized_activation.md) - Components should implement conditional execution logic internally to perform expensive operations only when active
122. [R122: ID Extraction Guidelines](R122_id_extraction_guidelines.md) - IDs for uniqueness/deduplication must be established in Cleanse stage; analysis-derived IDs in Process stage
123. [R123: Unified product ID](R123_unified_product_id.md) - All platform-specific product identifiers must be standardized to `product_id` in final data structures
124. [R124: Application Structure Standard (L1 Basic)](R124_app_structure_standard.md) - L1 Basic applications must include `scripts/global_scripts/` as their connection to shared codebase

## Modules (M)

- [M00_renumbering_principles](M00_renumbering_principles) - Module for renumbering principles
- [M01_summarizing_database](M01_summarizing_database) - Module for database documentation
- [M48_functionalizing](M48_functionalizing) - Module for converting procedural code to functions

## Sequences (S)

No sequences are currently implemented in this directory. Sequences are typically implemented as ordered update scripts in the update_scripts directory.

## Derivations (D)

- [D01_dna_analysis](D01_dna_analysis) - Customer DNA analysis derivation

## Concept Documents (C)

- [C00_when_to_source.md](C00_when_to_source.md) - Guidelines for when to source components
- [C01_app_construction.md](C01_app_construction.md) - Framework for application construction

## Archived Resources

All deprecated resources are archived in the [99_archive](99_archive) directory according to R28, including:
- R05_renaming_methods (replaced by M00_renumbering_principles)
- R10_database_table_naming (functionality merged into R19 and R27)
- P73_server_to_ui_data_flow (elevated to MP52_unidirectional_data_flow)

## Using Principles

When implementing or modifying code:

1. Review relevant principles first
2. Apply guideline consistently across related files
3. Reference specific principles in code comments when implementing them (using the MP/P/R code)
4. If conflicts arise between principles, document the decision and rationale
5. **When archiving resources, always follow R28_archiving_standard.md**

## Adding New Principles

When adding new principles:

1. Determine the appropriate classification (MP, P, R, M, S, or D) based on the conceptual framework
2. Assign the next available number for that classification
3. Add YAML front matter with id, type, and relationships
4. Follow the established document format with clear sections
5. Reference related principles
6. Update this README.md to include the new principle in the appropriate category
7. Use the M00_renumbering_principles module if you need to renumber principles
