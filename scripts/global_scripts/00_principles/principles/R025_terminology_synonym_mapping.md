---
id: "R0025"
title: "Terminology Synonym Mapping"
type: "rule"
date_created: "2025-04-04"
date_modified: "2025-04-04"
author: "Claude"
implements:
  - "MP0001": "Primitive Terms and Definitions"
  - "MP0008": "Terminology Axiomatization"
related_to:
  - "R0023": "Object Naming Convention"
  - "R0028": "Type-Token Distinction in Naming"
---

# Terminology Synonym Mapping

## Core Requirement

Establish clear mappings between conceptual terms and their implementation-specific synonyms to maintain consistency between abstract terminology and concrete code implementations across different languages and platforms.

## Purpose

The precision marketing system operates across multiple programming languages, platforms, and paradigms. This rule ensures that the terminology defined in MP0001 (Primitive Terms and Definitions) is consistently applied regardless of the implementation environment, by creating explicit mappings between conceptual terms and their language-specific or platform-specific equivalents.

## Implementation Guidelines

### 1. Synonym Table Structure

Maintain a formal synonym table with the following columns:

| Conceptual Term | Synonyms | R Implementation | Python Implementation | SQL Implementation | JavaScript Implementation | Description |
|----------------|----------|------------------|----------------------|-------------------|--------------------------|-------------|
| Term from MP0001 | Alternate terms | R-specific term | Python-specific term | SQL-specific term | JavaScript-specific term | Brief description |

The "Synonyms" column includes alternative philosophical or technical terms that may be used interchangeably with the conceptual term. For example, "Type" may be referred to as "Class" or "Universal" in different contexts.

### 2. Required Synonym Mappings

The following core conceptual terms must have clear mappings across all supported implementation languages:

#### Data Structure Terms

| Conceptual Term | Synonyms | R Implementation | Python Implementation | SQL Implementation | JavaScript Implementation | Description |
|----------------|----------|------------------|----------------------|-------------------|--------------------------|-------------|
| Database | Schema | environment, directory of .rds/.RData files | directory of dataframes, database connection | DATABASE, SCHEMA | directory of JSON/data files | Collection of related data tables |
| Data Frame | Data Table | data.frame, tibble | DataFrame, pandas.DataFrame | TABLE, VIEW | Array of objects | Single organized data table structure |
| Data | - | Various (list, data.frame, etc.) | Various (dict, DataFrame, etc.) | Various (TABLE, VIEW, etc.) | Various (Object, Array, etc.) | Information in different states of processing |
| Vector | - | vector, c() | list, array, numpy.array | ARRAY | Array | One-dimensional collection of values |
| List | - | list | dict, list | JSON, JSONB | Object, Array | Collection of named or indexed products |
| Matrix | - | matrix | numpy.ndarray | Two-dimensional array | 2D Array, matrix-like structure | Two-dimensional array of values |

#### Function Terms

| Conceptual Term | Synonyms | R Implementation | Python Implementation | SQL Implementation | JavaScript Implementation | Description |
|----------------|----------|------------------|----------------------|-------------------|--------------------------|-------------|
| Data Transformation | - | function (dt.) | function, method | PROCEDURE, FUNCTION | function | Processes that transform data |
| Calculation | - | function (calc.) | function, method | FUNCTION | function | Numerical calculations |
| Utility | - | function (util.) | function, method | FUNCTION | function | Helper functions |
| Component | - | module, Shiny component | class, component | - | React component | Self-contained functionality unit |
| Interface | - | S3/S4/R006 class | class, Protocol | - | interface, class | Contract for interaction |

#### Value Terms

| Conceptual Term | Synonyms | R Implementation | Python Implementation | SQL Implementation | JavaScript Implementation | Description |
|----------------|----------|------------------|----------------------|-------------------|--------------------------|-------------|
| Parameter | - | option, argument | parameter, argument | PARAMETER | parameter, prop | External configuration value |
| Default Value | - | default argument | default parameter | DEFAULT | default value | Fallback value |
| Constant | - | uppercase variable | CONSTANT | CONSTANT | CONSTANT | Fixed, unchanging value |
| Temporary | - | local variable | local variable | TEMPORARY TABLE | local variable | Short-lived calculation object |

### 3. Implementation Notation

When implementing concepts in specific languages, use the following notation to clarify the relationship between conceptual terms and implementation terms:

```r
# R implementation
# Conceptual: Data Frame
# Implementation: data.frame
df.customer_data <- data.frame(...)
```

```python
# Python implementation
# Conceptual: Data Frame
# Implementation: pandas.DataFrame
customer_data_df = pd.DataFrame(...)
```

```sql
-- SQL implementation
-- Conceptual: Data Frame
-- Implementation: TABLE
CREATE TABLE customer_data (...)
```

```javascript
// JavaScript implementation
// Conceptual: Data Frame
// Implementation: Array of objects
const customerDataDf = [...]
```

### 4. Documentation Requirements

When documenting code that implements primitive terms from MP0001, always:

1. Reference the conceptual term from MP01
2. Clarify the implementation-specific term being used
3. Include this information in function documentation
4. Reference the synonym mapping when training new team members

## Example Applications

### Example 1: Data Structure Documentation

```r
#' Customer Sales Data
#'
#' @description
#' Conceptual Type: Data Frame
#' Implementation Type: data.frame
#'
#' Contains processed customer sales data with transformations applied.
#'
df.customer.sales <- process_data(raw_data)
```

### Example 2: Function Type Documentation

```r
#' Calculate Revenue
#'
#' @description
#' Conceptual Type: Calculation Function
#' Implementation Type: R function
#'
#' Calculates total revenue based on sales data.
#'
#' @param sales_data Data frame containing sales records
#' @return Numeric value representing total revenue
#'
calc.revenue <- function(sales_data) {
  sum(sales_data$amount, na.rm = TRUE)
}
```

### Example 3: Cross-Language Implementation

In R:
```r
# Conceptual: Database/Schema
# Implementation: data.frame
df.customer.purchase_history <- read.csv("purchases.csv")
```

In Python:
```python
# Conceptual: Database/Schema
# Implementation: pandas.DataFrame
df_customer_purchase_history = pd.read_csv("purchases.csv")
```

## Synonym Table Maintenance

### 1. Updating the Synonym Table

The synonym table should be updated when:
- A new implementation language is added to the system
- New conceptual terms are added to MP01
- Implementation technologies evolve

### 2. Handling Ambiguity

When a clear one-to-one mapping doesn't exist:
1. Choose the closest implementation equivalent
2. Document the limitations of the mapping
3. Provide guidance on how to interpret the term in that context

### 3. Version Control

Maintain version history of the synonym table to track how terminology evolves over time. Each update should include:
1. Date of change
2. Rationale for new mappings
3. Impact on existing codebase

## Benefits

1. **Consistency**: Ensures consistent understanding across different languages
2. **Knowledge Transfer**: Facilitates knowledge transfer between technical teams
3. **Documentation**: Improves documentation by standardizing terminology
4. **Onboarding**: Accelerates onboarding of new team members
5. **Translation**: Enables easier translation of concepts between platforms

## Relationship to Other Principles and Rules

### Relation to Primitive Terms and Definitions (MP0001)

This rule implements MP0001 by:
1. Creating concrete mappings for abstract terms defined in MP01
2. Ensuring the primitive terms maintain their meaning across implementations
3. Preventing terminology drift as implementations change

### Relation to Terminology Axiomatization (MP0008)

This rule implements MP0008 by:
1. Formalizing the relationship between abstract and concrete terms
2. Creating a structured approach to terminology mapping
3. Providing a mechanism for managing terminology evolution

### Relation to Object Naming Convention (R0023)

This rule relates to R0023 by:
1. Connecting naming prefixes to their conceptual foundations
2. Providing context for how naming conventions map across languages
3. Supporting consistent application of naming patterns

### Relation to Type-Token Distinction (R0028)

This rule supports R0028 by:
1. Clarifying how types are represented in different languages
2. Maintaining the type-token distinction across implementations
3. Providing language-specific examples of the type-token pattern

## Conclusion

The Terminology Synonym Mapping rule bridges the gap between conceptual terminology and implementation-specific language, ensuring that the precision marketing system maintains conceptual integrity even as it spans multiple programming environments. By explicitly mapping conceptual terms to their implementation equivalents, we create a shared vocabulary that transcends specific programming languages while acknowledging the practical realities of implementation differences.
