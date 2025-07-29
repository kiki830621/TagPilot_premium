---
id: "MP083"
title: "Key Selection Principle"
type: "meta-principle"
date_created: "2025-04-30"
author: "Claude"
derives_from:
  - "MP008": "Terminology Axiomatization"
  - "MP018": "Don't Repeat Yourself"
  - "MP060": "Parsimony"
influences:
  - "P": "Database Design Patterns"
  - "P": "Query Optimization"
  - "R": "Entity Relationship Requirements"
---

# Key Selection Principle

## Statement

When designing data systems, key selection (natural vs. surrogate) must be deliberate and consistent, with selection based on entity stability, semantic significance, and query patterns, not merely technical defaults.

## Natural vs. Surrogate Keys

### Natural Keys
Natural keys derive directly from the inherent properties of the entity they identify.

**Characteristics:**
- Intrinsic business meaning
- Self-documenting
- Context carries through without joins
- No translation layer required
- Directly readable in queries, logs, and exports

**Example:** Using ISO country code "USA" rather than an arbitrary ID 42.

### Surrogate Keys
Surrogate keys are artificial identifiers with no inherent meaning beyond their identifying function.

**Characteristics:**
- No intrinsic meaning
- Stability through entity changes
- Consistent format and size
- Often better indexing performance
- Shields relationships from attribute changes

**Example:** Using auto-incrementing ID 42 for USA, with a separate field for the code "USA".

## Decision Framework

Select key type based on:

1. **Semantic Density**: How much meaning is conveyed by the natural key?
2. **Stability**: How likely is the natural key to change?
3. **Contextualization**: How often will the data be viewed without joins?
4. **Cardinality**: How many unique values exist in the entity set?
5. **Size & Complexity**: How large and complex is the natural key?

## Implementation Guidelines

### When to Choose Natural Keys

Natural keys are preferable when:

- The key has stable, inherent business meaning (e.g., ISO codes, scientific classifications)
- The dataset has few entities relative to query volume (e.g., reference tables)
- The data is frequently consumed in contexts where joins are impractical (e.g., logs, exports)
- The natural key is concise and follows a consistent pattern (e.g., three-letter codes)
- Direct readability has substantial business value (e.g., debugging, auditing)

### When to Choose Surrogate Keys

Surrogate keys are preferable when:

- Natural candidates are unstable or may change (e.g., names, addresses)
- Natural candidates are excessively large or composite (e.g., multiple fields)
- The dataset has high cardinality and frequent joins (e.g., transaction records)
- Performance optimization is critical for the entity (e.g., frequently joined tables)
- The system must merge data from sources with conflicting natural keys

### Context Preservation Principle

**Critical Insight**: Natural keys preserve context without joins, while surrogate keys require joins to convey meaning.

When using surrogate keys, implementers must ensure that:
1. Join operations are optimized and accessible
2. Lookup functionality is standardized
3. Context preservation is considered in API and reporting designs

## Examples

### Natural Key Implementation

```sql
CREATE TABLE product_lines (
  product_line_code CHAR(3) PRIMARY KEY,
  product_line_name_english TEXT NOT NULL,
  product_line_name_chinese TEXT,
  included INTEGER DEFAULT 1
);

-- Natural key provides immediate context
SELECT * FROM products WHERE product_line_code = 'CAS';
```

### Surrogate Key Implementation

```sql
CREATE TABLE product_lines (
  product_line_id INTEGER PRIMARY KEY,
  product_line_code CHAR(3) UNIQUE NOT NULL,
  product_line_name_english TEXT NOT NULL,
  product_line_name_chinese TEXT,
  included INTEGER DEFAULT 1
);

-- Surrogate key requires join for context
SELECT i.* FROM products i
JOIN product_lines pl ON i.product_line_id = pl.product_line_id
WHERE pl.product_line_code = 'CAS';
```

## Hybrid Approach

When appropriate, use a hybrid approach:
- Use surrogate keys for primary identification and relationships
- Include natural keys in the same table for direct reference
- Create unique constraints on natural keys 
- Design APIs to accept either key type

This balances technical benefits of surrogate keys with semantic clarity of natural keys.

## Related Principles

- **MP008: Terminology Axiomatization** - Natural keys can strengthen terminology standardization
- **MP018: Don't Repeat Yourself** - Surrogate keys help maintain referential integrity
- **MP060: Parsimony** - Choose the simplest key structure that meets requirements

## Exceptions

The following exceptions are permitted:

1. Compliance requirements may dictate specific key structures
2. Legacy system integration may constrain key choices
3. Very high performance systems may require specific key types

In these cases, document the rationale for deviation from standard selection criteria.