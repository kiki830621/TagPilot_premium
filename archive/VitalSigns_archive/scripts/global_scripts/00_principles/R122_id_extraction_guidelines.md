---
id: "R122"
title: "ID Extraction Guidelines for Data Cleansing and Processing"
type: "rule"
category: "data_processing"
tags: ["data_pipeline", "id_management", "cleansing", "processing"]
related_to:
  - "MP58": "Database Table Creation Strategy"
  - "P02": "Data Integrity"
  - "R89": "Integer ID Type Conversion"
  - "R90": "ID Relationship Validation"
  - "D03": "Positioning Analysis Derivation Flow"
date_created: "2025-05-31"
date_modified: "2025-05-31"
status: "active"
---

# R122: ID Extraction Guidelines for Data Cleansing and Processing

## Core Principle

**IDs related to data uniqueness, deduplication, and foreign keys must be established in the Cleanse stage; derived IDs tied to analysis logic should be generated in the Process stage.**

## Two-Stage Purpose

| Stage | Primary Goal | Common Actions | Why Important |
|-------|--------------|----------------|---------------|
| **Cleanse** | Fix **data quality** to ensure data trustworthiness | Deduplication, null handling, type standardization, anomaly detection | Prevent dirty data from contaminating downstream processes |
| **Process** | Transform based on **business logic** for analysis/modeling | Aggregation, KPI calculation, feature engineering | Convert "correct" data into "useful" data |

## ID Placement Guidelines

| ID Purpose | Recommended Stage | Reason |
|------------|-------------------|--------|
| **Unique/Foreign Keys** <br>(`customer_id`, `order_id`, `ebay_item_number`, etc.) | **Cleanse** | Early establishment enables deduplication, data splitting, and clear lineage |
| **Analysis-Derived Keys** <br>(`week_id`, `cohort_id`, `session_id`, etc.) | **Process** | Flexibility for analysis granularity changes |
| **Report-Only Indices** <br>(frontend sorting numbers, etc.) | **Process/Final Report** | No business logic dependency, generate last |

## Standard Workflow

1. **Staging (Raw Landing)**
   - Store raw files with load timestamps only

2. **Cleanse**
   - Execute deduplication, value imputation, validation
   - **Generate or map IDs that affect uniqueness/normalization**

3. **Process/Transform**
   - Aggregate and derive fields based on analysis needs
   - Generate derived IDs (e.g., `session_id_v2`) for maximum flexibility

## Why Establish IDs Early?

- **Avoid Mismatches:** Primary keys ensure correct aggregation/joining
- **Easy Traceability:** Fixed primary keys provide clear Raw → Clean → Process lineage
- **Simplified Debugging:** Use same ID to trace back to original records

## Practical Techniques

| Technique | Description |
|-----------|-------------|
| **Hash/UUID Temporary Keys** | Generate `raw_row_hash` in Cleanse when no natural key exists |
| **Encapsulate ID Logic** | Use UDF/SQL modules for isolation, testing, and version control |
| **Version Derived Keys** | Use names like `session_id_v2` to prevent version conflicts |
| **Update Data Dictionary** | Document IDs immediately in data catalog/ER diagrams |

## Implementation Examples

### Cleanse Stage ID Generation
```r
# In fn_cleanse_eby_reviews.R
cleansed_reviews <- raw_reviews %>%
  mutate(
    # Establish primary identifier early
    ebay_item_number = standardize_item_number(item_number),
    # Create composite key for deduplication
    review_id = paste(ebay_item_number, reviewer, date, sep = "_")
  ) %>%
  distinct(review_id, .keep_all = TRUE)
```

### Process Stage ID Generation
```r
# In fn_process_eby_reviews.R
processed_reviews <- cleansed_reviews %>%
  mutate(
    # Analysis-specific IDs generated during processing
    week_id = format(date, "%Y-W%V"),
    cohort_id = format(first_purchase_date, "%Y-%m"),
    session_id = generate_session_id(user_id, timestamp)
  )
```

## Platform-Specific Considerations

### Amazon (amz)
- Primary ID: `asin` (10-character alphanumeric)
- Establish in Cleanse: Validate format, deduplicate

### eBay (eby)
- Primary ID: `ebay_item_number` (10-13 digits)
- Secondary IDs: `seller`, `country`
- Establish in Cleanse: Standardize format, handle variations

## Related Principles

- **MP58**: Database Table Creation Strategy - Consistent table structures
- **P02**: Data Integrity - Ensure data quality throughout pipeline
- **R89**: Integer ID Type Conversion - Handle ID type conversions properly
- **R90**: ID Relationship Validation - Validate ID relationships before operations