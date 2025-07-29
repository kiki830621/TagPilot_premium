---
id: "MP072"
title: "Cognitive Distinction Principle"
type: "meta-principle"
related_to:
  - "MP071": "Capitalization Convention"
  - "MP070": "Type-Prefix Naming"
  - "MP068": "Language as Index"
  - "MP024": "Natural SQL Language"
  - "MP017": "Separation of Concerns"
date_created: "2025-04-15"
date_modified: "2025-04-15"
---

# MP072: Cognitive Distinction Principle

## Summary

**Treat similar things similarly, treat different things differently.** This fundamental meta-principle establishes that cognitive differentiation through visual and structural cues should reflect semantic and functional differences in code, while similar elements should maintain consistent representation.

## Core Principle

The Cognitive Distinction Principle states that:

1. Elements with similar semantics, behavior, or purpose should share visual and structural characteristics
2. Elements with fundamentally different semantics, behavior, or purpose should be visibly distinct
3. The degree of visual distinction should correspond to the degree of semantic difference

This principle applies across all aspects of the system: code structure, naming conventions, documentation formats, and language syntax.

## Applications

### 1. Language Syntax Priming

Different language paradigms should have distinct visual signatures:

- **R Code**: Standard camelCase or snake_case for variables and functions
- **NSQL/SNSQL**: CAPITALIZED keywords and directives
- **SQL**: Capitalized keywords (SELECT, FROM) with lowercase identifiers
- **Markdown**: Special syntax markers (*, #, `)

This visual priming prepares the reader's mind to apply the appropriate parsing and interpretation rules.

### 2. Type-Based Differentiation

Different entity types should have distinct naming patterns:

- **Functions**: `fn_` prefix
- **Scripts**: `sc_` prefix
- **Data Frames**: `df_` prefix
- **Constants**: ALL_CAPS
- **Classes**: PascalCase

### 3. Structural Consistency

Similar components should share structural patterns:

- All update scripts follow the same four-part structure (INITIALIZE, MAIN, TEST, DEINITIALIZE)
- All module interfaces expose consistent entry points
- All configuration files use the same format and organization

### 4. Visual Hierarchy

The visual representation should match the semantic hierarchy:

- Headings reflect organizational structure
- Indentation reflects logical nesting
- Font styles reflect importance or emphasis
- Section dividers reflect logical boundaries

## Benefits

This principle delivers numerous cognitive and practical benefits:

1. **Reduced Cognitive Load**: Pattern recognition becomes automatic
2. **Error Prevention**: Visual discrepancies highlight potential errors
3. **Improved Learnability**: Consistent patterns are easier to internalize
4. **Enhanced Communication**: Visual cues establish shared understanding
5. **Faster Comprehension**: Visual patterns speed up code reading
6. **AI Compatibility**: Consistent distinctions help AI tools parse and generate code

## Implementation Guidelines

### 1. Consistency Analysis

Before establishing a new convention, analyze:

- What elements are semantically similar/different?
- What degree of visual distinction is appropriate?
- What existing patterns can be leveraged?
- What conventions exist in related domains?

### 2. Documentation

For each convention based on this principle, document:

- The semantic distinction being represented
- The visual/structural pattern used
- The rationale for the choice
- Examples of correct and incorrect usage

### 3. Progressive Enhancement

Apply cognitive distinctions in layers:

1. **Core Distinctions**: Essential differences that must be visually distinct
2. **Supplementary Distinctions**: Additional cues that enhance understanding
3. **Contextual Distinctions**: Distinctions that matter only in specific contexts

## Example Applications

### Language Paradigm Distinction

```r
# R code using standard conventions
customer_data <- read_csv("customers.csv")
filtered_data <- filter(customer_data, spending > 1000)

# NSQL using capitalized keywords for priming
CREATE df_customer_profile AT app_data
=== CREATE TABLE df_customer_profile ===
CREATE TABLE df_customer_profile (
  customer_id INTEGER PRIMARY KEY,
  name VARCHAR
);
```

### Type-Based Prefixing

```r
# Function with fn_ prefix
fn_calculate_metrics <- function(data) {
  # Implementation
}

# Script with sc_ prefix
source("sc_process_data.R")

# Data frame with df_ prefix
df_customers <- read_csv("customers.csv")
```

### Structural Consistency

```r
# 1. INITIALIZE
# Initialization code
source(file.path("update_scripts", "global_scripts", "sc_initialization_update_mode.R"))

# 2. MAIN
tryCatch({
  # Main processing code
}, error = function(e) {
  # Error handling
})

# 3. TEST
# Verification code

# 4. DEINITIALIZE
# Cleanup code
```

## Relationship to Other Principles

This principle underlies and unifies several other principles:

1. **MP071: Capitalization Convention** - Specific application for NSQL/SNSQL syntax
2. **MP070: Type-Prefix Naming** - Specific application for entity types
3. **MP068: Language as Index** - Leverages visual patterns as indices to knowledge
4. **MP024: Natural SQL Language** - Uses visual distinction to prime interpretation
5. **MP017: Separation of Concerns** - Visual separation reflects conceptual separation

## Historical Context

This principle draws from several established design philosophies:

- **Gestalt Psychology**: Similar products are perceived as groups
- **Information Architecture**: Visual distinction aids navigation
- **Cognitive Load Theory**: Consistent patterns reduce mental effort
- **Programming Language Design**: Syntax highlighting reflects semantic differences
- **Typography**: Visual hierarchy guides attention and comprehension

## Conclusion

The Cognitive Distinction Principle represents a foundational meta-principle that guides how we visually and structurally represent semantic and functional differences in code. By ensuring that similar things appear similar and different things appear different, we create a system that is more intuitive, learnable, and maintainable for both human developers and AI assistants.