# MP027: Integrated Natural SQL Language (NSQL) v3

## Overview

The Natural Structured Query Language (NSQL) is a comprehensive, domain-specific language designed for documenting and describing data operations, transformations, reactive flows, component structures, and relationships in precision marketing applications. NSQL integrates SQL's declarative clarity with additional syntax for reactive systems, combining elements from LaTeX, Markdown, Roxygen2, and graph theory.

## Core Principles

1. **Clarity**: Expressions must clearly indicate source, transformation, and destination
2. **Precision**: Syntax must eliminate ambiguity in data operation descriptions
3. **Alignment**: Documentation must align with implementation patterns 
4. **Completeness**: All aspects of data flow must be documentable
5. **Visualization**: Support for generating flow diagrams and visualizations
6. **Hierarchical Organization**: Provide clear structural hierarchy for documentation
7. **Graph Representation**: Support formal representation of component relationships
8. **Integration**: Seamlessly blend with existing documentation systems

## NSQL Integration Model

NSQL integrates four major component systems:

1. **Core NSQL**: Data operation and transformation syntax
2. **Graph Theory Extension**: Component relationship and flow visualization
3. **LaTeX/Markdown Terminology**: Document structure and formatting
4. **Roxygen2-Inspired Annotations**: Function and component documentation

## 1. Core NSQL Elements

### 1.1 Data Operation Expression

The fundamental unit of NSQL is the Data Operation Expression:

```
OPERATION(SOURCE → TRANSFORM → DESTINATION)
```

Example:
```sql
FILTER(transactions → WHERE date > '2023-01-01' → recent_transactions)
```

### 1.2 Data Sources

```sql
-- Simple source
SOURCE: customers

-- Multiple sources
SOURCE: customers, transactions, products

-- Source with metadata
SOURCE: customers {
  Primary: true
  Update_Frequency: "Daily"
  Fields: [
    { Name: "customer_id", Type: "INTEGER", Key: true },
    { Name: "name", Type: "VARCHAR(255)" },
    { Name: "email", Type: "VARCHAR(255)" }
  ]
}
```

### 1.3 Operations

```sql
-- Filter operation
FILTER(customers → WHERE status = 'active' → active_customers)

-- Join operation
JOIN(orders → WITH customers ON orders.customer_id = customers.id → order_details)

-- Aggregate operation
AGGREGATE(sales → GROUP BY product_id | SUM(amount) AS total → product_totals)

-- Transform operation
TRANSFORM(raw_data → CLEAN DUPLICATES | FORMAT DATES → clean_data)

-- Extract operation
EXTRACT(transactions → DISTINCT customer_id → unique_customers)
```

### 1.4 Flow Control

```sql
-- Simple flow
FLOW: input.date_range 
  → FILTER(transactions BY date BETWEEN input.date_range.start AND input.date_range.end) 
  → display_table

-- Branching flow
FLOW: "Dashboard Update" {
  TRIGGER: input.refresh_button
  BRANCH: "Sales Data" {
    FILTER(transactions → RECENT 30 DAYS → recent_sales)
    DISPLAY(recent_sales → sales_chart)
  }
  BRANCH: "Customer Data" {
    FILTER(customers → ACTIVE STATUS → active_customers)
    COUNT(active_customers → total_active)
    DISPLAY(total_active → customer_counter)
  }
}
```

### 1.5 Component Mapping

```sql
-- Input component
COMPONENT: date_filter {
  Type: dateRangeInput
  Default: [CURRENT_DATE - 30 DAYS, CURRENT_DATE]
  Label: "Select Date Range"
  Effects: [
    TRIGGER: FILTER(transactions BY date BETWEEN input.date_filter.start AND input.date_filter.end)
  ]
}

-- Output component
COMPONENT: sales_summary {
  Type: valueBox
  Data_Source: filtered_transactions
  Operation: AGGREGATE(SUM(amount) AS total_sales)
  Format: "$#,##0.00"
  Icon: "dollar-sign"
  Color: "success"
}
```

### 1.6 Reactive Dependencies

```sql
-- Simple reactive dependency
REACTIVE: filtered_customers {
  DEPENDS_ON: [input.status_filter, input.date_range]
  OPERATION: FILTER(customers → WHERE status = input.status_filter AND 
                   date BETWEEN input.date_range.start AND input.date_range.end)
}

-- Complex reactive chain
REACTIVE_CHAIN: "Customer Analysis" {
  STEP 1: filtered_customers {
    DEPENDS_ON: [input.status_filter]
    OPERATION: FILTER(customers → WHERE status = input.status_filter)
  }
  
  STEP 2: customer_metrics {
    DEPENDS_ON: [filtered_customers]
    OPERATION: JOIN(filtered_customers → WITH transactions ON customer_id)
  }
  
  STEP 3: summary_statistics {
    DEPENDS_ON: [customer_metrics]
    OPERATION: AGGREGATE(customer_metrics → GROUP BY status | AVG(amount) AS avg_spend)
  }
  
  OUTPUT: DISPLAY(summary_statistics → summary_table)
}
```

### 1.7 Testing and Validation

```sql
-- Simple test
TEST: "Active Customers Filter" {
  OPERATION: FILTER(customers → WHERE status = 'active')
  EXPECT: result.count > 0
  EXPECT: NOT EXISTS (SELECT 1 FROM result WHERE status != 'active')
}

-- Test with specific inputs
TEST: "Date Range Filter" {
  INPUTS: {
    date_range: ["2023-01-01", "2023-01-31"]
  }
  OPERATION: FILTER(transactions → WHERE date BETWEEN inputs.date_range[0] AND inputs.date_range[1])
  EXPECT: COUNT(*) = (SELECT COUNT(*) FROM transactions WHERE date BETWEEN '2023-01-01' AND '2023-01-31')
  EXPECT: MIN(date) >= '2023-01-01'
  EXPECT: MAX(date) <= '2023-01-31'
}
```

## 2. Graph Theory Extension

### 2.1 Graph Type Definitions

```
TYPE Vertex = Element ID and properties
TYPE Edge = Connection between vertices with optional direction and weight
TYPE Graph = Collection of vertices and edges
TYPE Path = Ordered sequence of vertices connected by edges
TYPE Component = Subgraph where all vertices are connected by some path
```

### 2.2 Graph Definition Syntax

```
GRAPH(name) {
  VERTICES {
    name: properties,
    ...
  }
  EDGES {
    source -> destination [: properties],
    ...
  }
}
```

### 2.3 Component Identification

```
COMPONENT(component_name) FROM graph_name {
  ENTRY_POINTS: [vertex_ids]
  EXIT_POINTS: [vertex_ids]
  INTERNAL_VERTICES: [vertex_ids]
}
```

### 2.4 State Machine Documentation

```
STATE_MACHINE(name) {
  STATES {
    "idle": { type: "initial" },
    "processing": { type: "transient" },
    "success": { type: "terminal" },
    "error": { type: "terminal" }
  }
  
  TRANSITIONS {
    "idle" -> "processing": { event: "start_process", guard: "input_valid" },
    "processing" -> "success": { event: "process_complete", guard: "no_errors" },
    "processing" -> "error": { event: "process_error" },
    "error" -> "idle": { event: "reset" },
    "success" -> "idle": { event: "reset" }
  }
}
```

### 2.5 Component Interconnection

```
SYSTEM(system_name) {
  COMPONENTS {
    "component_a": { type: "input_processor" },
    "component_b": { type: "data_transformer" },
    "component_c": { type: "output_generator" }
  }
  
  CONNECTIONS {
    "component_a.output" -> "component_b.input": { type: "data_flow" },
    "component_b.result" -> "component_c.data_source": { type: "data_flow" },
    "component_c.status" -> "component_a.feedback": { type: "event" }
  }
  
  // Cut sets between components
  CUT_SETS {
    "a_to_b": ["component_a.output", "component_b.input"],
    "b_to_c": ["component_b.result", "component_c.data_source"],
    "feedback_loop": ["component_c.status", "component_a.feedback"]
  }
}
```

### 2.6 Graph Analysis Operations

```
// Find all paths between two vertices
PATHS = FIND_PATHS(graph, source, destination)

// Calculate graph metrics
METRICS = ANALYZE_GRAPH(graph) {
  "connectivity": CONNECTIVITY_SCORE,
  "cyclical": HAS_CYCLES,
  "diameter": MAX_PATH_LENGTH,
  "centrality": {
    vertex_id: centrality_score,
    ...
  }
}

// Identify connected components
COMPONENTS = FIND_COMPONENTS(graph)

// Find minimum cut set
CUT_SET = FIND_MIN_CUT(graph, source_set, destination_set)
```

### 2.7 Integration with Core NSQL

```
// Data flow can reference graph components
DATA_FLOW(component: customer_filter) {
  GRAPH {
    VERTICES {
      "app_data_connection": { type: "data_source" },
      "dna_data": { type: "transformed_data" },
      "profiles": { type: "transformed_data" },
      "valid_ids": { type: "transformed_data" },
      "dropdown_options": { type: "ui_data" }
    }
    
    EDGES {
      "app_data_connection" -> "dna_data": { operation: "EXTRACT" },
      "app_data_connection" -> "profiles": { operation: "EXTRACT" },
      "dna_data" -> "valid_ids": { operation: "DISTINCT" },
      "profiles" -> "dropdown_options": { operation: "FILTER", condition: "customer_id IN valid_ids" }
    }
  }
  
  SOURCE: app_data_connection
  INITIALIZE: {
    EXTRACT(app_data_connection → GET dna_data → dna_data)
    EXTRACT(app_data_connection → GET customer_profiles → profiles)
    EXTRACT(dna_data → DISTINCT customer_id → valid_ids)
    FILTER(profiles → WHERE customer_id IN valid_ids → dropdown_options)
  }
  // ... rest of the data flow
}
```

## 3. LaTeX and Markdown Inspired Documentation

### 3.1 Document Structure Elements (LaTeX-Inspired)

| NSQL Term | LaTeX Equivalent | Description | Usage |
|-----------|------------------|-------------|-------|
| `####name####` | `\section{name}` | Defines a major section in a script | Used to delineate function definitions |
| `###name###` | `\subsection{name}` | Defines a sub-section in a script | Used for components within functions |
| `##name##` | `\subsubsection{name}` | Defines a tertiary section | Used for detailed components |
| `#~name~#` | `\paragraph{name}` | Defines a minor section or block | Used for specific blocks of code |
| `%% name %%` | `\comment{name}` | Structured comment block | Used for extended documentation |

### 3.2 Document Metadata

| NSQL Term | LaTeX Equivalent | Description | Usage |
|-----------|------------------|-------------|-------|
| `@file` | `\documentclass` | Defines the file type | Used at the top of files |
| `@principle` | `\usepackage` | References principles applied | Lists principles implemented |
| `@author` | `\author` | Specifies the author | Identifies creator/modifier |
| `@date` | `\date` | Creation date | When the file was created |
| `@modified` | `\versiondate` | Modification date | When the file was modified |
| `@related_to` | `\input` or `\include` | References related files | Identifies related files |

### 3.3 Environment Blocks

| NSQL Term | LaTeX Equivalent | Description | Usage |
|-----------|------------------|-------------|-------|
| `DATA_FLOW {...}` | `\begin{environment}...\end{environment}` | Data flow documentation block | Documents data flows |
| `FUNCTION_DEP {...}` | `\begin{environment}...\end{environment}` | Function dependency block | Documents dependencies |
| `TEST_CASE {...}` | `\begin{environment}...\end{environment}` | Test case definition block | Defines test cases |
| `EXAMPLE {...}` | `\begin{environment}...\end{environment}` | Example usage block | Shows usage examples |
| `VALIDATION {...}` | `\begin{environment}...\end{environment}` | Input validation block | Defines validation rules |

### 3.4 Markdown-Inspired Elements

| NSQL Term | Markdown Equivalent | Description | Usage |
|-----------|---------------------|-------------|-------|
| `# Title` | `# Heading 1` | Primary heading | File title and divisions |
| `## Subtitle` | `## Heading 2` | Secondary heading | Major sections |
| `- product` | `- Bullet point` | Unordered list product | Listing products |
| `1. Step` | `1. Numbered product` | Ordered list product | Sequential steps |
| `> Note` | `> Blockquote` | Note or callout | Important notes |
| `` `code` `` | `` `inline code` `` | Inline code | Short code snippets |
| `**Important**` | `**Bold**` | Emphasis | Important terms |
| `*Variable*` | `*Italic*` | Variable or term | Parameter names |

## 4. Roxygen2-Inspired Annotations

### 4.1 Standard Documentation Tags

| NSQL Term | Roxygen2 Equivalent | Description | Usage |
|-----------|---------------------|-------------|-------|
| `@title` | `@title` | Function title | Defines function title |
| `@description` | `@description` | Brief description | Describes function purpose |
| `@details` | `@details` | Detailed information | In-depth information |
| `@param` | `@param` | Parameter documentation | Documents a parameter |
| `@return` | `@return` | Return value | Documents return value |
| `@export` | `@export` | Export flag | Indicates export |
| `@examples` | `@examples` | Usage examples | Provides examples |

### 4.2 Extended Documentation Tags

| NSQL Term | Description | Usage |
|-----------|-------------|-------|
| `@implements` | Principle implementation | Indicates implemented principles |
| `@requires` | Dependencies | Lists required packages or functions |
| `@throws` | Error conditions | Documents conditions causing errors |
| `@performance` | Performance notes | Documents performance characteristics |
| `@validation` | Input validation | Documents validation procedures |

## 5. Implementation Directives

NSQL provides syntax for directing the implementation of documented concepts into executable code.

### 5.1 IMPLEMENT Directive

The IMPLEMENT directive specifies that a documentation product should be transformed into executable code:

```sql
-- Implement a derivation section as a script
IMPLEMENT D00_01_00 IN update_scripts
===
# This will create D00_01_00.R in the update_scripts directory
# The script should implement the D00_01 derivation section 00
write_script("D00_01_00.R", "update_scripts") {
  # Script content or implementation details can be specified here
  # The actual implementation will follow the derivation document
}
===

-- Implement multiple derivation sections
IMPLEMENT D00_01_00, D00_01_01 IN update_scripts/global_scripts
===
# Creates multiple implementation scripts as specified
write_script("D00_01_00.R", "update_scripts/global_scripts")
write_script("D00_01_01.R", "update_scripts/global_scripts")
===

-- Implement with execution directive
IMPLEMENT D00_01_00 IN update_scripts AND EXECUTE
===
write_script("D00_01_00.R", "update_scripts") 
execute_script("D00_01_00.R")
===
```

The IMPLEMENT directive uses a three-part format:
1. Intent statement: `IMPLEMENT {section} IN {location} [AND EXECUTE]`
2. Delimiter markers: `===`
3. Implementation details or script generation instructions

This directive helps bridge the gap between documentation and implementation, ensuring that each documented derivation section has a corresponding implementation script.

### 5.2 Table Creation Directive

Similarly, NSQL provides a CREATE directive for defining database tables:

```sql
-- Create a new table at a specific database connection
CREATE df_customer_profile AT app_data
===
CREATE OR REPLACE TABLE df_customer_profile (
  customer_id INTEGER,
  buyer_name VARCHAR,
  email VARCHAR,
  platform_id INTEGER NOT NULL,
  display_name VARCHAR GENERATED ALWAYS AS (buyer_name || ' (' || email || ')') VIRTUAL,
  PRIMARY KEY (customer_id, platform_id)
);

CREATE INDEX IF NOT EXISTS idx_df_customer_profile_platform_id_df_customer_profile 
ON df_customer_profile(platform_id);
===
```

The CREATE syntax follows the same three-part format, providing both human-readable intent and the precise SQL needed for implementation.

## 6. Integration Example

The following example demonstrates how all components of NSQL integrate in a single file:

```r
#' @file fn_analyze_customer_cohort.R
#' @principle R067 Functional Encapsulation
#' @principle P077 Performance Optimization
#' @author Analytics Team
#' @date 2025-04-12
#' @modified 2025-04-15
#' @related_to fn_customer_segmentation.R

# Load required libraries
library(dplyr)
library(tidyr)

# Data flow documentation
DATA_FLOW(component: cohort_analysis) {
  SOURCE: customer_data_connection
  PROCESS: {
    EXTRACT(customer_data_connection → GET transactions → transaction_data)
    GROUP(transaction_data → BY cohort_date → cohort_groups)
    COMPUTE(cohort_groups → retention_rates)
  }
  OUTPUT: cohort_retention_matrix
  
  # Graph representation of data flow
  GRAPH {
    VERTICES {
      "customer_data": { type: "source" },
      "transaction_extract": { type: "transform" },
      "cohort_groups": { type: "transform" },
      "retention_rates": { type: "transform" },
      "cohort_matrix": { type: "output" }
    }
    
    EDGES {
      "customer_data" -> "transaction_extract": { operation: "EXTRACT" },
      "transaction_extract" -> "cohort_groups": { operation: "GROUP" },
      "cohort_groups" -> "retention_rates": { operation: "COMPUTE" },
      "retention_rates" -> "cohort_matrix": { operation: "FORMAT" }
    }
  }
}

####extract_cohort_date####

#' Extract Cohort Date from Customer Data
#'
#' Extracts the cohort date (first purchase date) for each customer.
#'
#' @param transaction_data Transaction data frame
#' @return Data frame with customer_id and cohort_date
#'
extract_cohort_date <- function(transaction_data) {
  ###prepare_data###
  
  # Implementation...
  
  return(cohort_dates)
}

####compute_retention_rates####

#' Compute Retention Rates by Cohort
#'
#' @param transaction_data Transaction data with cohort dates
#' @return Retention rates matrix
#'
#' TEST: "Retention Computation Validation" {
#'   INPUTS: {
#'     transaction_data = sample_transactions
#'   }
#'   EXPECT: all(result$retention_rate >= 0, result$retention_rate <= 1)
#'   EXPECT: all(result$cohort_size > 0)
#' }
#'
compute_retention_rates <- function(transaction_data) {
  ###prepare_data###
  
  # Data preparation steps...
  
  ###calculate_rates###
  
  # Rate calculation steps...
  
  return(retention_matrix)
}

####analyze_customer_cohort####

#' Analyze Customer Cohort Retention
#'
#' Performs cohort analysis on customer transaction data.
#'
#' @param customer_data Customer transaction data
#' @param cohort_period Period for cohort grouping
#' @return Cohort analysis results
#' @export
#'
#' VALIDATION {
#'   REQUIRE: customer_data is data.frame
#'   REQUIRE: contains(customer_data, ["customer_id", "transaction_date", "amount"])
#'   REQUIRE: cohort_period in ["day", "week", "month", "quarter", "year"]
#' }
#'
#' FUNCTION_DEP {
#'   MAIN: analyze_customer_cohort
#'   AUXILIARIES: [
#'     extract_cohort_date,
#'     compute_retention_rates
#'   ]
#'   CALL_GRAPH: {
#'     analyze_customer_cohort → extract_cohort_date
#'     analyze_customer_cohort → compute_retention_rates
#'   }
#' }
#'
analyze_customer_cohort <- function(customer_data, cohort_period = "month") {
  # Implementation...
}

# [EOF]
```

## 6. Implementation Mapping

The following table shows how NSQL elements map to implementation patterns in different frameworks:

| NSQL Element | R Shiny | React | Vue.js |
|--------------|---------|-------|--------|
| COMPONENT | UI function (e.g., `selectInput`) | Component (e.g., `<Select>`) | Component (e.g., `<v-select>`) |
| REACTIVE | `reactive()`, `reactiveVal()` | `useState()`, `useEffect()` | `ref()`, `computed()` |
| FILTER | `filter()` | `filter()` | `filter()` |
| AGGREGATE | `summarize()` | `reduce()` | `reduce()` |
| DISPLAY | `renderUI()`, `renderTable()` | `render()` | `template` |
| DEPENDS_ON | `observe()`, `observeEvent()` | `useEffect([deps])` | `watch()` |

## 7. Best Practices

1. **Be explicit about data types**:
   ```sql
   -- GOOD
   FILTER(customers → WHERE customer_id = as.integer(input.customer_filter))
   
   -- BAD
   FILTER(customers → WHERE customer_id = input.customer_filter)
   ```

2. **Document all reactive dependencies**:
   ```sql
   -- GOOD
   REACTIVE(filtered_data) {
     DEPENDS_ON: [input.filter_a, input.filter_b, source_data]
     ...
   }
   
   -- BAD
   REACTIVE(filtered_data) {
     DEPENDS_ON: [input.filter_a] -- Missing dependencies
     ...
   }
   ```

3. **Maintain hierarchical structure**:
   ```r
   -- GOOD
   ####main_function####
   
   ###sub_component###
   
   ##detailed_step##
   
   -- BAD
   Random comments without structure
   ```

4. **Use proper graph notation for component relationships**:
   ```
   -- GOOD
   GRAPH {
     VERTICES { "input": {}, "process": {}, "output": {} }
     EDGES { "input" -> "process", "process" -> "output" }
   }
   
   -- BAD
   Input feeds process which creates output
   ```

5. **Include formal testing expectations**:
   ```sql
   -- GOOD
   TEST: "Filter Test" {
     OPERATION: FILTER(data → WHERE x > 0)
     EXPECT: COUNT(*) = (SELECT COUNT(*) FROM data WHERE x > 0)
   }
   
   -- BAD
   -- This should filter correctly
   ```

## 8. Benefits of Integrated NSQL

1. **Unified Documentation System**: Provides a single, comprehensive language for all documentation needs
2. **Formal Component Definition**: Enables precise definition of component boundaries and interactions
3. **Flow Visualization**: Supports clear documentation of data and event flows
4. **Property Verification**: Allows verification of component properties like connectivity
5. **System Analysis**: Provides tools for reasoning about system-wide behaviors
6. **Hierarchical Organization**: Creates clear structural hierarchy for improved readability
7. **Enhanced Navigability**: Facilitates easy navigation through consistent section markers
8. **Integration with Tools**: Enables tooling support for navigation and visualization

## 9. Relationship to Other Principles

- **MP024: Natural SQL Language** - Core foundation for NSQL syntax
- **MP025: AI Communication Meta-Language** - Provides terminology alignment with AI systems
- **MP026: R Statistical Query Language** - Extends NSQL with R-specific concepts
- **MP052: Unidirectional Data Flow** - Formalized in NSQL graph notations
- **MP056: Connected Component Principle** - Implemented through NSQL graph theory extension
- **MP059: App Dynamics** - Documented using NSQL state machine notation
- **P079: State Management** - Formalized using NSQL reactive patterns
- **R100: Database Access Tbl Rule** - Implemented in NSQL data source definitions
- **R101: Unified Tbl Data Access** - Structured through NSQL operations

## Conclusion

The Integrated Natural SQL Language (NSQL) v3 provides a comprehensive, unified documentation system that combines the best aspects of SQL's declarative clarity, LaTeX's structured documentation, Markdown's readability, Roxygen2's code documentation, and graph theory's formal notation. By integrating these systems, NSQL enables precise, consistent documentation of all aspects of the precision marketing system, from data operations to component structures and relationships.

As the system evolves, NSQL will continue to be extended with additional capabilities while maintaining backward compatibility with existing documentation.