---
id: "MP0001"
title: "Primitive Terms and Definitions"
type: "meta-principle"
date_created: "2025-04-02"
author: "Claude"
derives_from:
  - "MP0000": "Axiomatization System"
influences:
  - "P02": "Structural Blueprint"
  - "P03": "Project Principles"
  - "P04": "Script Separation"
  - "MP0029": "Terminology Axiomatization"
---

# Primitive Terms and Definitions

This document establishes the fundamental vocabulary of the precision marketing system. It defines the primitive terms upon which all other principles and structures are built, ensuring consistent understanding and usage throughout the codebase.

## Purpose of Primitive Terms

In an axiomatic system, primitive terms are fundamental concepts that cannot be defined in terms of simpler concepts. They form the foundation upon which all other definitions, principles, and structures are built.

This document:
1. Defines the core vocabulary of the system
2. Establishes precise meanings for fundamental concepts
3. Prevents circular definitions
4. Creates a shared understanding across the entire system

## Core Primitive Terms

### System Structure Terms

#### Company
A business entity that utilizes the precision marketing system. Each company has its own specific implementation of modules, sequences, and derivations, which may differ based on business requirements, data sources, and processes.

#### Component
The fundamental unit of modular functionality in the system. A component is a self-contained piece of code that performs a specific function and presents a defined interface for interaction.

#### Module (M)
A collection of related components that work together to provide a cohesive set of functionality for a minimal purpose. Modules define **what** functionality belongs together, focusing on organizational structure rather than implementation details. Identified by the prefix "M" followed by a two-digit number (e.g., M70). Implemented as a folder that may contain multiple files.

#### Sequence (S)
An ordered process that represents a workflow using multiple modules to accomplish a specific business purpose. Sequences define steps that combine multiple minimal purposes into a cohesive business process. Identified by the prefix "S" followed by sequence numbers (e.g., S1_1). Implemented as a folder that may contain multiple files.

#### Derivation (D)
A complete sequence that traces the full transformation from raw data to Shiny app. Similar to mathematical proofs, derivations document the step-by-step process of how the final application is derived from initial inputs. Identified by the prefix "D" followed by a number (e.g., D1). Implemented as a folder that may contain multiple files.

#### Interface
The defined methods, properties, or contracts through which components communicate and interact with each other.

#### Implementation
The specific code that fulfills the contract defined by an interface.

#### Function
A reusable unit of code that performs a specific task, accepts defined inputs, and produces defined outputs. Functions come in different roles:

##### Main Function
The primary function in a file that provides the core functionality and serves as the primary entry point. Main functions are typically called by external code, are part of the public API, and give the file its name. Each file typically contains one main function.

##### Auxiliary Function
A helper function that supports a main function, implementing sub-tasks or utility operations. Auxiliary functions are typically called only by the main function or other auxiliary functions within the same file, and are not usually part of the public API. A file may contain multiple auxiliary functions that support its main function.

##### Function File Name
The name of the file containing the function definition. Must use the "fn_" prefix in accordance with R19 (e.g., `fn_detect_advanced_metrics_availability.R`).

##### Function Object Name
The actual name of the function as it appears in code. Must NOT use the "fn_" prefix in accordance with R19 (e.g., `detect_advanced_metrics_availability`).

#### Library
A collection of related functions that serve a common purpose.

#### Script
An executable sequence of operations that performs a specific task.

##### Section of Script
A clearly delineated portion of a script focused on a specific function or logical unit. In R code, sections are typically marked with `####section_name####` delimiters similar to LaTeX sectioning commands. Sections improve code organization, navigability, and maintainability by dividing scripts into logical components.

### Conceptual Terms

#### Principle Framework Terms

The following terms define the principle classification system:

##### Meta-Principle (MP)
A principle about principles. Meta-principles govern how principles themselves are structured, organized, and related to each other. They are abstract, conceptual, and foundational in nature, establishing the system-wide architecture and organization.

##### Principle (P)
A general rule or guideline that governs system design and implementation decisions. Principles are abstract and conceptual but practically oriented, providing broad implementation patterns and approaches. They are reusable and broadly applicable.

##### Rule (R)
A specific guideline for implementing principles. Rules are concrete, specific, and directly applicable, defining narrow implementation techniques and specific patterns. Rules describe **how** to implement functionality, providing technical guidance and standards.

##### Instance
A specific implementation of a principle or rule in a particular context. Instances are concrete, context-specific, and directly applicable to a particular situation. Unlike principles, instances are not meant to be reusable across contexts.

#### Axiomatic System Terms

The following terms relate to the formal axiomatic system and how they map to our MP/P/R framework:

##### Axiom
A statement that is accepted as true without proof, serving as a starting point for deriving other truths. In our MP/P/R system, axioms are typically expressed as Meta-Principles (MP).

##### Inference Rule
A logical rule that allows the derivation of new principles from existing ones. In our MP/P/R system, inference rules are typically expressed as certain Meta-Principles (MP) that establish relationships between other principles.

##### Theorem
A derived principle that follows logically from axioms through application of inference rules. In our MP/P/R system, theorems are typically expressed as Principles (P).

##### Corollary
A principle that follows directly from another principle with minimal additional proof. In our MP/P/R system, corollaries are typically expressed as Rules (R).

### Data Terms

#### Data Source
A named reference to a specific dataset used by application components, representing accessible data regardless of physical storage location.

#### Platform
The origin system or channel from which data is collected (e.g., Amazon, Official Website).

#### Data
The fundamental information used in the system. Data exists in different states of processing:

##### Raw Data
A token/state of Data representing unprocessed information collected directly from platforms, stored with minimal modifications from its original form.

##### Processed Data
A token/state of Data that has undergone transformation, cleaning, and integration to make it suitable for use by application components. Processed Data is typically organized in a database (collection of related data tables) and accessed through database connections.

#### Database Connection
A configured link to a database that enables reading and writing data. Connections are typically created using connection functions (e.g., `DBI::dbConnect()`) and may connect to different database systems (e.g., DuckDB, PostgreSQL, SQLite). Connection objects provide access to all schemas and tables within a single database.

#### Schema
A namespace or organizational container within a database that groups related tables. Schemas function like folders for database tables, providing organization and preventing naming conflicts. Each database typically has at least one default schema (e.g., `main` in DuckDB, `public` in PostgreSQL).

#### Data Table
A structured collection of records (typically rows and columns) that can be queried, filtered, and manipulated as a unit. Data tables are stored within schemas in a database. In R, data tables are typically loaded as data frames (df) for in-memory manipulation.

#### Data Frame (df)
An in-memory tabular data structure in R that represents a single data table loaded from a database or created during data processing. Data frames are R objects, while data tables exist within database schemas.

#### View
A virtual data table defined by a query, presenting data from one or more underlying tables or data sources. Views exist in the database but don't store their own data.

### Application Terms

#### Application
The complete software system that provides functionality to end users.

#### Parameter
A configuration value that controls component behavior. Parameters do not contain records but rather settings that modify functionality. Parameters are typically specified externally (e.g., in YAML configuration) and represent values that may change between applications or deployments.

#### Default Value
A fallback value used when a parameter is not specified. Default values are defined within components (typically in a Defaults file) and provide sensible values to ensure the component works properly without external configuration.

#### Role
The specific relationship between a data source and a component, defining how the data is used within the component.

## Term Relationships

These primitive terms relate to each other in fundamental ways:

### Type-Token Distinction

The precision marketing system incorporates the philosophical type-token distinction, which is essential for understanding how concepts are instantiated in code:

1. **Types vs. Tokens**: A fundamental distinction exists between:
   - **Type** (also known as "class" or "universal"): A general category or abstract concept (e.g., "Database")
   - **Token** (also known as "individual" or "particular"): A specific instance or concrete realization of a type (e.g., a specific processed data table)

2. **Relationship Between Types and Tokens**:
   - Types are abstract and cannot be directly manipulated in code
   - Tokens are concrete instances that can be created, modified, and deleted
   - Multiple tokens can exist for the same type
   - Tokens inherit properties and behaviors from their type

3. **Application in Code**:
   - **Data Frame** is a type; `df.amazon.sales_data` is a token of that type implemented as an R data frame
   - **Component** is a type; `comp.ui.customer_profile` is a token of that type
   - **Function** is a type; `calc.revenue` is a token of that type

4. **Naming Conventions**:
   - Type prefixes in our naming system (df., calc., mdl.) identify the type
   - The remainder of the name identifies the specific token

### Terminological Relationships (Object-Oriented)

Building on the type-token distinction, the precision marketing system follows an object-oriented approach to terminology, establishing clear hierarchical and categorical relationships between terms:

1. **Type Hierarchy**: Terms exist in hierarchical "is-a" relationships
   - **Data** is the base type for information used in the system
     - **Parameter** is a type of **Data**
     - **Default Value** is a type of **Data**
   - **Code** is the base type for executable elements
     - **Function** is a type of **Code**
     - **Component** is a type of **Code**
     - **Module** is a type of **Code**

   Note: **Raw Data** and **Processed Data** are not separate types but rather tokens/states of the **Data** type, representing different stages in the data processing lifecycle.

2. **Categorical Distinctions**: Terms may share parent types but are categorically distinct
   - **Parameter** and **Default Value** are both types of **Data** but:
     - **Parameters** are configurable values specified externally (in YAML)
     - **Default Values** are fallback values specified internally (in component)
     - A value cannot be both a **Parameter** and a **Default Value** simultaneously
   - **Rule** and **Principle** are both types of **Guidance** but:
     - **Principles** are general, abstract guidelines
     - **Rules** are specific, concrete directives
     - A guidance cannot be both a **Rule** and a **Principle** simultaneously

3. **Composition Relationships**: Terms exist in "has-a" relationships
   - **Component** has **UI**, **Server**, and **Defaults** parts
   - **Module** has multiple **Components**
   - **Application** has multiple **Modules**
   - **Sequence** has multiple **Modules** in order

4. **Attribute Relationships**: Terms may have specific attributes
   - **Parameter** has attributes of "name," "value," and "scope"
   - **Data Source** has attributes of "name," "type," and "access method"
   - **Component** has attributes of "id," "dependencies," and "interface"

5. **Instance vs. Type**: Distinction between general concept and specific implementation
   - **Module** (type) vs. **M70_testing** (instance)
   - **Component** (type) vs. **sidebarHybrid** (instance)
   - **Parameter** (type) vs. **refresh_interval: 300** (instance)

### Implementation Relationships

1. **Functions** are combined to create **Components**
2. **Components** are organized into **Modules**
3. **Modules** are sequenced into **Sequences**
4. **Sequences** are documented as **Derivations** when they trace full transformations
5. **Modules**, **Sequences**, and **Derivations** are integrated to form an **Application**
6. **Interfaces** define how **Components** interact
7. **Implementations** fulfill the contracts defined by **Interfaces**

### Guidance Relationships

8. **Meta-Principles** govern the organization of **Principles**
9. **Principles** guide the creation of **Rules**
10. **Rules** guide the creation of **Instances**

### Data Flow Relationships

11. **Platforms** generate **Raw Data**
12. **Raw Data** is transformed into **Processed Data**
13. **Data Sources** provide access to **Processed Data**
14. **Parameters** configure **Component** behavior
15. **Roles** define the purpose of **Data Sources** within **Components**

### Cross-Framework Relationships

16. **MP/P/R** guide how **M/S/D** are implemented
17. **M/S/D** organize what **MP/P/R** apply to

### Company Relationships

18. **Companies** have specific implementations of **Modules**
19. **Companies** have specific implementations of **Sequences**
20. **Companies** have specific implementations of **Derivations**
21. **Companies** share common **MP/P/R** principles

### Organizational Frameworks Distinction

A fundamental conceptual distinction exists between:

1. **MP/P/R (Meta-Principles/Principles/Rules)**: These tell us **how** to implement functionality, focusing on methodology, guidelines, standards, and best practices.

2. **M/S/D (Modules/Sequences/Derivations)**: These tell us **what** to implement, focusing on functional organization:
   - **Modules (M)**: Organize functionality with a minimal purpose
   - **Sequences (S)**: Organize business processes that consist of several minimal purposes
   - **Derivations (D)**: Document complete transformations from raw data to final application

This distinction separates implementation guidance (MP/P/R) from functional organization (M/S/D), ensuring that our system maintains a clear separation between:
1. How things should be done (principles)
2. What needs to be done (organization)

This separation of concerns allows for modular development, clear documentation, and systematic organization of the codebase.

## Example Usage

The following examples demonstrate how these primitive terms are used in context:

### Code Structures

```r
# Function - a reusable unit of code
calculate_customer_value <- function(customer_id, transaction_history) {
  # Implementation details
}

# Component - a self-contained piece of functionality
customerProfileUI <- function(id) {
  # UI implementation
}

# Module (M) - a collection of related components for a minimal purpose
# File: M70_testing/M70_fn_test_app.R
test_app <- function() {
  # Test app functionality
}

# Sequence (S) implementation in an update script
# File: 0100_1_1_0_execute_customer_dna.R - implements S1_1 (Customer DNA)
source("../13_modules/M01_data_loading/M01_fn_load_customer_data.R")
source("../13_modules/M02_preprocessing/M02_fn_preprocess_customer.R")
# ... sequence of operations using modules
```

### Configuration Structures

```yaml
# Data Source - named reference to a dataset
components:
  micro:
    customer_profile: sales_by_customer_dta

# Parameters - configuration values
components:
  trends:
    data_source: sales_trends
    parameters:
      show_kpi: true
      refresh_interval: 300

# Roles - specific relationships between data sources and components
components:
  advanced_profile:
    primary: customer_details
    history: customer_history
```

### Documentation Structures

```markdown
# Module Documentation (M)
# File: M70_testing/README.md

## Purpose
This module provides testing functionality for verifying application configuration and execution.

# Sequence Documentation (S)
# File: S1_1_customer_dna.md

## Purpose
This sequence transforms raw customer data into a customer DNA profile by:
1. Loading raw customer data (M01)
2. Preprocessing data (M02)
3. Generating customer segments (M03)

# Derivation Documentation (D)
# File: D1_wiser_campaign_analytics.md

## Complete Transformation
This derivation documents the full flow from raw WISER campaign data to interactive analytics dashboard:
1. Raw data collection from platform APIs
2. ETL processing and standardization
3. Feature generation and modeling
4. Interactive visualization in Shiny
```

## Derived Terms

Additional technical terms may be defined throughout the system, but they must ultimately be defined in terms of these primitive concepts.

## Terminology Usage Rules

1. **Consistency**: These terms must be used consistently throughout the system
2. **Precision**: Use the exact term that matches the concept being referenced
3. **Specificity**: Avoid ambiguous terms when precise terms are available
4. **Documentation**: Reference these definitions when introducing new concepts

## Relationship to Other Principles

This document of primitive terms and definitions serves as the foundation for:

1. **Structural Blueprint** (02_structural_blueprint.md): Uses these primitive terms to define the system structure
2. **Terminology Axiomatization Principle** (29_terminology_axiomatization.md): Extends and formalizes the relationships between these terms
3. **All other principles**: Build upon this fundamental vocabulary

## Conclusion

By establishing clear definitions for these primitive terms, we create a solid foundation for the entire axiomatic system. This shared vocabulary ensures consistent understanding and usage across all principles, blueprints, and implementations, reducing ambiguity and enabling precise communication about system design and functionality.
