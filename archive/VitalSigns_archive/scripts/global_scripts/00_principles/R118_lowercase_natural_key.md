---
id: "R118"
title: "Lowercase Natural Key Rule"
type: "rule"
date_created: "2025-04-30"
author: "Claude"
derives_from:
  - "MP083": "Key Selection Principle"
  - "MP070": "Type-Prefix Naming"
  - "MP071": "Capitalization Convention"
influences:
  - "P": "Database Naming Convention"
  - "P": "Code Readability"
---

# R118: Lowercase Natural Key Rule

## Statement

All natural keys used as identifiers in the system must be lowercase to maintain pattern consistency with existing naming conventions.

## Rationale

Natural keys provide semantic value through meaningful, self-documenting identifiers. However, to maintain consistency with the system's existing naming conventions (which use lowercase with underscores), natural keys must follow the same pattern. This ensures visual coherence, reduces cognitive load, and prevents errors caused by case inconsistencies.

## Implementation Requirements

### 1. Character Case

- All natural key identifiers MUST be lowercase (e.g., "amz", "cas", "spt")
- NO uppercase characters are allowed in natural keys
- This applies to all database objects, variable names, and code references

### 2. Format Requirements

- Natural keys for product lines SHOULD be 3 characters long when possible
- Multiple-word concepts SHOULD use established abbreviation practices without separators
- Keys MUST NOT include special characters, spaces, or punctuation

### 3. Database Implementation

- Column definitions for natural keys SHOULD specify case-insensitive collation where supported
- Input validation MUST convert any uppercase input to lowercase before storage
- Queries SHOULD include case conversion for robustness: `WHERE LOWER(product_line_code) = 'amz'`

### 4. Consistent Application

- Existing tables that use natural keys MUST be modified to use lowercase
- Data migration scripts MUST convert uppercase natural keys to lowercase
- Documentation MUST reflect lowercase examples for all natural keys

## Examples

### Correct Implementation

```sql
-- Correct: lowercase natural key
CREATE TABLE product_lines (
  product_line_code char(3) PRIMARY KEY,
  product_line_name_english text NOT NULL
);

INSERT INTO product_lines VALUES ('cas', 'Casual Wear');
INSERT INTO product_lines VALUES ('spt', 'Sports Apparel');
```

```r
# Correct: lowercase in table and variable names
df_cas_sales <- df_sales %>% 
  filter(product_line_code == 'cas')
```

### Incorrect Implementation

```sql
-- Incorrect: uppercase natural key
CREATE TABLE product_lines (
  product_line_code char(3) PRIMARY KEY
);

INSERT INTO product_lines VALUES ('CAS', 'Casual Wear');
```

```r
# Incorrect: mixed case in variable names
df_CAS_sales <- df_sales %>% 
  filter(product_line_code == 'CAS')
```

## UI Presentation Exception

While natural keys must be lowercase in the database and code, they MAY be displayed in uppercase in user interfaces when emphasis is beneficial, provided that:

1. The conversion to uppercase happens only at the presentation layer
2. Any user input is converted back to lowercase before storage
3. The UI consistently displays all natural keys in the same case

## Relationship to Other Principles

- **MP083: Key Selection Principle** - This rule applies specifically to natural keys as defined in MP083
- **MP070: Type-Prefix Naming** - Natural keys follow similar prefix patterns but use lowercase
- **MP071: Capitalization Convention** - Extends capitalization rules to natural keys

## Benefits

1. **Visual Consistency**: Maintains cohesive pattern across all code and database elements
2. **Reduced Cognitive Load**: Developers don't need to remember case exceptions
3. **Error Prevention**: Reduces errors from inconsistent capitalization
4. **Typing Efficiency**: Lowercase is faster to type without shift keys
5. **Convention Alignment**: Aligns with R and SQL conventions which typically favor lowercase