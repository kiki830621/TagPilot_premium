# MP27: Specialized Natural SQL Language (NSQL) - Version 2

## Statement
Natural SQL Language (NSQL) shall be expanded to include precise data flow expressions, tidyverse equivalents, component mappings, and visualization capabilities to document complex data operations within interactive applications.

## Description
This meta-principle establishes an expanded Natural SQL Language (NSQL) for documenting how data flows through applications, with special emphasis on reactive applications, UI components, and their relationships to data operations. NSQL v2 preserves SQL's declarative power while adding precision through standardized operation expressions, flow documentation, test cases, and visual representations.

## Rationale
1. **Complete Documentation**: Capture all aspects of data flow from source to UI
2. **Precise Expression**: Eliminate ambiguity in describing data transformations
3. **Code-Documentation Alignment**: Maintain direct mapping between documentation and implementation
4. **Cross-Paradigm Integration**: Bridge gap between SQL, tidyverse, and reactive programming
5. **Formal Analysis**: Enable automated analysis of data flow patterns
6. **Visual Communication**: Support generation of data flow diagrams
7. **Testability**: Document expected outputs and validation criteria

## Implementation Patterns

### 1. Precise Data Operation Expressions

NSQL v2 introduces a precise data operation expression format:

```
OPERATION(SOURCE → TRANSFORM → DESTINATION)
```

Examples:
```sql
-- Clear data operation with source, transform, and destination
FILTER(dna_data.customer_id → EXTRACT DISTINCT VALUES → customer_dropdown_options)

-- Multi-stage transformation
TRANSFORM(transactions → 
          GROUP BY customer_id | 
          AGGREGATE(COUNT(*) AS transaction_count, SUM(amount) AS total_spend) → 
          customer_metrics)
```

### 2. Tidyverse-NSQL Integration

NSQL v2 provides direct mapping between tidyverse operations and SQL:

```sql
-- NSQL with R tidyverse equivalents
-- Filter customers with DNA data
SELECT * FROM customers 
WHERE customer_id IN (SELECT DISTINCT customer_id FROM dna_data)

-- R equivalent:
-- customers %>% 
--   filter(customer_id %in% (dna_data %>% distinct(customer_id) %>% pull()))

-- NSQL aggregation with tidyverse equivalent
SELECT 
  customer_id,
  COUNT(*) AS transaction_count,
  SUM(amount) AS total_spend
FROM transactions
GROUP BY customer_id

-- R equivalent:
-- transactions %>%
--   group_by(customer_id) %>%
--   summarize(
--     transaction_count = n(),
--     total_spend = sum(amount)
--   )
```

### 3. Data Flow Documentation

Document complete reactive data flows with flow diagrams:

```sql
-- Data Flow: Customer Selection Process
FLOW: user_input[customer_filter]
  -> FILTER(customers BY customer_id = ${input.customer_filter})
  -> JOIN(WITH dna_data ON customer_id)
  -> DISPLAY(customer_details)

-- Complex multi-branch flow
FLOW: "Dashboard Initialization" {
  SOURCE: transactions
  BRANCH: "Transaction Metrics" {
    TRANSFORM(transactions → GROUP BY date → daily_totals)
    DISPLAY(daily_totals → line_chart)
  }
  BRANCH: "Customer Metrics" {
    TRANSFORM(transactions → GROUP BY customer_id → customer_activity)
    DISPLAY(customer_activity → bar_chart)
  }
}
```

### 4. Component Mapping

Document UI components and their data interactions:

```sql
-- COMPONENT: customer_filter
-- Type: selectizeInput
-- Data Source: customers
-- SQL Query:
SELECT customer_id AS value, CONCAT(buyer_name, ' (', email, ')') AS label
FROM customers
WHERE customer_id IN (SELECT DISTINCT customer_id FROM dna_data)

-- COMPONENT: customer_metrics
-- Type: valueBox collection
-- Data Source: dna_data
-- SQL Query:
SELECT 
  COUNT(DISTINCT order_id) AS order_count,
  SUM(amount) AS total_spend,
  AVG(amount) AS avg_order_value,
  DATEDIFF(MAX(order_date), MIN(order_date)) / COUNT(DISTINCT order_id) AS purchase_frequency
FROM dna_data
WHERE customer_id = ${input.customer_filter}
```

### 5. Enhanced Data Flow Expression

Detailed data flow documentation for complex interactions:

```sql
DATA_FLOW(component: customer_filter) {
  SOURCE: dna_data, customer_profiles
  INITIALIZE: {
    EXTRACT(dna_data → DISTINCT customer_id → valid_ids)
    FILTER(customer_profiles → WHERE customer_id IN valid_ids → dropdown_options)
  }
  ON_SELECT: {
    value = customer_filter.selected
    FILTER(customer_profiles → WHERE customer_id = value → customer_detail)
    FILTER(dna_data → WHERE customer_id = value → customer_metrics)
  }
}
```

### 6. Metadata Integration

Include metadata annotations for data quality and expectations:

```sql
-- METADATA: customers.customer_id
-- Type: INTEGER
-- Constraints: NOT NULL, PRIMARY KEY
-- Source: External System (CRM)
-- Update Frequency: Daily
-- Special Considerations: IDs are stable but not sequential

-- METADATA: transactions.amount
-- Type: NUMERIC(10,2)
-- Constraints: NOT NULL, CHECK (amount > 0)
-- Business Rules: Negative amounts should be in refunds table
-- Statistics: Range(0.01-50000.00), Avg(120.50), StdDev(85.30)
-- Missing Value Rate: 0.001%
```

### 7. Testing Extensions

Document test cases and validation rules directly in NSQL:

```sql
-- TEST: Find customers with recent transactions
SELECT customer_id FROM transactions 
WHERE transaction_date > CURRENT_DATE - INTERVAL '30 days'
-- EXPECT: result_count > 0
-- EXPECT: NOT EXISTS (SELECT 1 FROM result WHERE customer_id IS NULL)

-- TEST: Validate customer metrics calculation
SELECT 
  customer_id,
  COUNT(*) AS transaction_count,
  SUM(amount) AS total_spend
FROM transactions
WHERE customer_id = 12345
-- EXPECT: transaction_count = (SELECT COUNT(*) FROM transactions WHERE customer_id = 12345)
-- EXPECT: total_spend = (SELECT SUM(amount) FROM transactions WHERE customer_id = 12345)
-- EXPECT: total_spend / transaction_count < 1000 -- Business rule: avg per transaction < 1000
```

### 8. Visual Query Representation

Define visual data flow diagrams:

```sql
-- VISUALIZE: customer_acquisition_flow
SELECT 
  FLOW_NODE(source='marketing_campaigns', target='leads'),
  FLOW_NODE(source='leads', target='customers', 
            condition='conversion_date IS NOT NULL')

-- VISUALIZE: data_transformation_pipeline
DIAGRAM {
  NODE("Raw Data", type="source")
  NODE("Validated Data", type="transform")
  NODE("Aggregated Metrics", type="transform")
  NODE("Dashboard", type="destination")
  
  EDGE("Raw Data" → "Validated Data", label="Clean & Validate")
  EDGE("Validated Data" → "Aggregated Metrics", label="Group & Summarize")
  EDGE("Aggregated Metrics" → "Dashboard", label="Visualize")
}
```

### 9. Entity-Relationship Documentation

Generate ER diagrams and document relationships:

```sql
-- ENTITY: customers
-- ATTRIBUTES: 
--   customer_id INTEGER PRIMARY KEY, 
--   buyer_name VARCHAR(255), 
--   email VARCHAR(255)
-- RELATIONSHIP: HAS_MANY transactions (customers.customer_id = transactions.customer_id)
-- RELATIONSHIP: HAS_ONE customer_profile (customers.customer_id = customer_profile.customer_id)

-- ENTITY: transactions
-- ATTRIBUTES:
--   transaction_id INTEGER PRIMARY KEY,
--   customer_id INTEGER FOREIGN KEY,
--   amount NUMERIC(10,2),
--   transaction_date DATE
-- RELATIONSHIP: BELONGS_TO customers (transactions.customer_id = customers.customer_id)
```

### 10. Reactive Data Dependencies

Document reactive dependencies in Shiny-like applications:

```sql
-- REACTIVE: filtered_customers
SOURCE: customers
DEPENDS_ON: input.date_range, input.status_filter
QUERY:
  SELECT * FROM customers
  WHERE 
    created_date BETWEEN ${input.date_range[0]} AND ${input.date_range[1]}
    AND status = ${input.status_filter}

-- REACTIVE: customer_metrics
SOURCE: dna_data
DEPENDS_ON: filtered_customers
INVALIDATES_WHEN: dna_data changes
QUERY:
  SELECT 
    AVG(amount) as avg_spend,
    COUNT(*) as transaction_count
  FROM dna_data
  WHERE customer_id IN (SELECT customer_id FROM filtered_customers)
```

## Conceptual Framework

NSQL v2 establishes these core concepts:

1. **Operations**: FILTER, TRANSFORM, JOIN, AGGREGATE, DISPLAY
2. **Flow**: Sequential transformations of data through an application
3. **Component**: UI elements that display or modify data
4. **Reactive Dependencies**: How data changes propagate through the system
5. **Metadata**: Information about data structure, quality, and meaning
6. **Tests**: Expected behaviors and validation rules
7. **Visualizations**: Graphical representations of data and flow

## Anti-patterns

### Ambiguous Data Flow

```sql
-- INCORRECT: Ambiguous operation with unclear source/destination
Set the filter filters customer_id from dna_data

-- CORRECT: Clear source, transformation, and destination
FILTER(dna_data → EXTRACT DISTINCT customer_id → customer_filter.options)
```

### Missing Component Context

```sql
-- INCORRECT: SQL without UI component context
SELECT customer_id, name FROM customers

-- CORRECT: SQL with component context
-- COMPONENT: customer_dropdown
-- Operation: Populate dropdown options
SELECT customer_id AS value, name AS label FROM customers
```

### Incomplete Flow Documentation

```sql
-- INCORRECT: Partial flow documentation
FLOW: input → filter

-- CORRECT: Complete flow with transformations and destination
FLOW: input.date_range 
  → FILTER(transactions BY date BETWEEN input.date_range) 
  → AGGREGATE(BY product_id | SUM(amount) AS product_sales) 
  → DISPLAY(sales_chart)
```

## Examples

### Complete Analysis Module Documentation

```sql
-- MODULE: Customer Analysis Dashboard
-- PURPOSE: Provide detailed metrics for individual customers and segments

-- COMPONENT: date_range_filter
-- Type: dateRangeInput
-- Default: [current_date - 90 days, current_date]
-- Affects: All data queries

-- COMPONENT: customer_segment_filter
-- Type: selectInput
-- Data Source: customer_segments
-- SQL Query:
SELECT segment_id AS value, segment_name AS label FROM customer_segments

-- DATA FLOW: Primary Dashboard Data Flow
FLOW {
  INPUTS: date_range_filter, customer_segment_filter
  
  REACTIVE(filtered_transactions) {
    SOURCE: transactions
    DEPENDS_ON: date_range_filter, customer_segment_filter
    TRANSFORM: transactions 
      → FILTER(transaction_date BETWEEN date_range_filter.start AND date_range_filter.end)
      → JOIN(customers ON transactions.customer_id = customers.customer_id)
      → FILTER(segment_id = customer_segment_filter.value)
  }
  
  REACTIVE(customer_metrics) {
    SOURCE: filtered_transactions
    TRANSFORM: filtered_transactions
      → GROUP BY customer_id
      → AGGREGATE(
          COUNT(*) AS transaction_count,
          SUM(amount) AS total_spend,
          AVG(amount) AS avg_order_value
        )
  }
  
  OUTPUTS {
    DISPLAY(customer_metrics → customer_table)
    DISPLAY(customer_metrics | TOP 10 BY total_spend → top_customers_chart)
    DISPLAY(customer_metrics | AGGREGATE AVG(avg_order_value) BY segment_id → segment_comparison)
  }
}

-- TEST: Validate segment filter correctly limits data
-- INPUT: customer_segment_filter = "premium"
-- EXPECT: All customers in filtered_transactions have segment_id = "premium"
-- EXPECT: customer_metrics contains data for all premium customers
```

## Related Principles
- MP24: Natural SQL Language
- MP17: Separation of Concerns
- MP52: Unidirectional Data Flow
- P73: Server-to-UI Data Flow
- P79: State Management
- P81: Tidyverse-Shiny Terminology Alignment
- R76: Module Data Connection
