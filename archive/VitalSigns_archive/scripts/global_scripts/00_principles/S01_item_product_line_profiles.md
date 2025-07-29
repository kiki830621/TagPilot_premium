# S01: Construct Profiles of Item and Product Line

## Overview

This sequence establishes and maintains the foundational product data structure by constructing and synchronizing profiles for product lines and individual items. It uses a 3-character lowercase natural key system for product line identification that balances brevity with business meaning while maintaining naming convention consistency.

## Business Purpose

Creating standardized, hierarchical product profiles with lowercase natural keys enables:
1. Intuitive product categorization that is immediately recognizable
2. Reliable product hierarchy for aggregation and reporting
3. Simplified integration with external systems
4. Cross-referencing between external item data and internal product line classifications
5. Visual consistency with existing naming patterns

## Sequence Steps

### S01_00: Construct Product Line Profiles
- Initialize product line data in app_data/parameters/scd_type1/df_product_line.csv

- Required fields: product_line_name_english, product_line_name_chinese, product_line_id, included

- Implement soft deletion approach: if a product line is no longer used, mark as included=0 rather than deleting

- Use 3-character lowercase natural keys for product_line_id (e.g., "jew" for jewelry box)

  ```
  IMPORT source data to app_data.df_product_line_profile
  ```

- for application use

- (All parameters should be in R memory )

### S01_01: Import and Map Item Profiles
- IMPORT external_data.{dictionary of items} to app_data.item_profile
- Perform left join with app_data.df_product_line_profile by product_line_name_english (or other key)
- Enrich items with product_line_id for hierarchical categorization
- Filter to only include items from platforms listed in app_config.yaml (platform list)

## Key Principles Applied

- **MP008**: Terminology Axiomatization - Using standardized codes
- **MP015**: Currency Principle - Ensuring data profiles stay current
- **MP018**: Don't Repeat Yourself - Centralizing product information
- **MP029**: No Fake Data - Using only verified product information
- **MP070**: Type-Prefix Naming - Consistent prefix convention in product codes
- **MP083**: Key Selection Principle - Using natural keys for immediate context
- **R118**: Lowercase Natural Key Rule - Maintaining pattern consistency

## Data Structure

### Product Line Profile Source CSV
```
app_data/parameters/scd_type1/product_line.csv:
- product_line_name_english (TEXT): English name of product line
- product_line_name_chinese (TEXT): Chinese name of product line
- product_line_id (CHAR(3)): Primary key, 3-character lowercase natural key
- included (INTEGER): 1 for active, 0 for inactive
```

### Product Line Profile Database Table
```
app_data.df_product_line_profile:
- product_line_id (CHAR(3)): Primary key, 3-character lowercase natural key
- product_line_name_english (TEXT): English name
- product_line_name_chinese (TEXT): Chinese name
- included (INTEGER): 1 for active, 0 for inactive
- created_at (TIMESTAMP): Creation timestamp
- modified_at (TIMESTAMP): Last modification timestamp
```

### Item Profile Database Table
```
app_data.item_profile:
- item_id (TEXT): Unique item identifier from external system
- product_line_id (CHAR(3)): Foreign key to product_line_profile
- platform_id (CHAR(3)): Lowercase natural key identifying the platform (e.g., "amz")
```

## Implementation Notes

1. Initialize in both app_mode and update_mode
2. Product line codes follow the R118 Lowercase Natural Key Rule:
   - Lowercase for consistency
   - 3-character mnemonic identifiers
   - Following a standardized pattern across all categories
3. Join logic must handle cases where external item product lines don't match internal classifications
4. Special handling for the "all" product line category which applies to all products
5. Platform filtering should use the platform list from app_config.yaml
6. For UI presentation, codes may be displayed in uppercase for emphasis if needed

## Code Example

```R
# Set up database connection
library(DBI)
library(duckdb)
conn <- dbConnect(duckdb(), dbdir = "app_data.duckdb")

# Read product line data from CSV
product_line_csv <- file.path("app_data", "parameters", "scd_type1", "product_line.csv")
product_lines <- read_csvxlsx(product_line_csv)

# Add timestamps
product_lines$created_at <- Sys.time()
product_lines$modified_at <- Sys.time()

# Create or replace product line profile table
dbExecute(conn, "
  CREATE TABLE IF NOT EXISTS df_product_line_profile (
    product_line_id CHAR(3) PRIMARY KEY,
    product_line_name_english TEXT NOT NULL,
    product_line_name_chinese TEXT,
    included INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )
")

# Write to database (replace existing)
dbWriteTable(conn, "df_product_line_profile", product_lines, overwrite = TRUE)

# Get active platforms from app_config.yaml
app_config <- yaml::read_yaml("app_config.yaml")
active_platforms <- app_config$platform

# Import external item data and map to product lines
external_items <- import_raw_data("item_dictionary", 
                                  data_dir = "data/external",
                                  dest_con = conn)

# Map items to product lines and filter by active platforms
dbExecute(conn, sprintf("
  CREATE OR REPLACE TABLE item_profile AS
  SELECT 
    e.item_id,
    COALESCE(p.product_line_id, 'all') AS product_line_id,
    e.platform_id,
    e.item_name,
    e.price,
    e.currency,
    e.category,
    e.other_attributes,
    CURRENT_TIMESTAMP AS created_at,
    CURRENT_TIMESTAMP AS modified_at
  FROM 
    external_items e
  LEFT JOIN 
    df_product_line_profile p
  ON 
    e.category = p.product_line_name_english
  WHERE 
    e.platform_id IN (%s)
  AND
    (p.included = 1 OR p.included IS NULL)
", paste0("'", active_platforms, "'", collapse = ", ")))

# Close connection
dbDisconnect(conn)
```