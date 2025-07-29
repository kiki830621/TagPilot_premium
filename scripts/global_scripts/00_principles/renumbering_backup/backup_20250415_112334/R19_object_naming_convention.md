---
id: "R19"
title: "Object Naming Convention"
type: "rule"
date_created: "2025-04-04"
date_modified: "2025-04-04"
author: "Claude"
implements:
  - "P14": "Dot Notation Property Access Principle"
related_to:
  - "MP24": "Natural SQL Language"
  - "MP17": "Separation of Concerns"
  - "MP01": "Primitive Terms and Definitions"
---

# Object Naming Convention

## Core Requirement

All objects within the precision marketing system must follow standardized naming conventions that use dot notation to separate hierarchical components, maintain consistent ordering of components from general to specific, and include type prefixes that identify the nature of the object.

### Fundamental Object Naming Equation

```
object_name = rigid_identifier + optional_descriptors
```

Where:
- `rigid_identifier` is the unique, unchanging part that identifies the object
- `optional_descriptors` are the variable, descriptive tags that characterize the state or processing

In implementation:
- The rigid identifier is used for object loading and identification (get_rigid_id(object))
- The optional descriptors are separated by triple underscore (___) from the rigid identifier
- Multiple versions of the same object can exist with different descriptors

## Type Prefixes Aligned with MP01

| Prefix | Object Type | MP01 Term | Description |
|--------|------------|-----------|-------------|
| df. | Data Frame | Processed Data | Tabular data structure processed for analysis |
| raw. | Raw Data | Raw Data | Unprocessed data collected directly from platforms |
| dt. | Data Transformation | Function | Function that transforms data |
| calc. | Calculation | Function | Function that performs calculations |
| util. | Utility | Function | Utility function for common operations |
| mdl. | Model | - | Statistical or machine learning model |
| lst. | List | - | Collection of named elements |
| vec. | Vector | - | One-dimensional array |
| par. | Parameter | Parameter | Configuration value specified externally |
| def. | Default Value | Default Value | Fallback value specified internally |
| SCOPE. | Constant | - | Fixed value that does not change (using uppercase) |
| tmp. | Temporary | - | Temporary calculation object |
| comp. | Component | Component | Self-contained piece of modular functionality |
| iface. | Interface | Interface | Defined methods and contracts for interaction |
| impl. | Implementation | Implementation | Specific code fulfilling an interface contract |
| g. | Global | - | Global scope variable |
| mod. | Module | Module | Collection of related components (M) |
| seq. | Sequence | Sequence | Ordered process workflow (S) |
| deriv. | Derivation | Derivation | Complete transformation process (D) |

## Naming Convention Principles

### 1. Component Separation vs. Word Separation

Throughout all naming patterns, observe these critical distinctions:
- **Dots (.)** separate hierarchical components and indicate property/domain access
- **Underscores (_)** separate words within a single component

For example:
- `df.amazon.sales_by_region.at_ALL.current_month.001` 
  - Dots separate components: df, amazon, sales_by_region, at_ALL, current_month, 001
  - Underscores separate words within components: sales_by_region, at_ALL, current_month

### 2. Type-Specific Naming Patterns

Different object types follow specific ordering patterns that reflect their purpose:

### 1. Data Frames / Processed Data
```
df.platform.purpose.by_id1.by_id2.by_id3.at_dimension1.at_dimension2.at_dimension3[___identifier]
```

Where:
- `by_id` components identify what entities we're grouping by (can have 0-N components)
- `at_dimension` components identify what dimensions we're slicing at (can have 0-N components)

Examples:
- `df.amazon.sales.by_item_index.at_ALL.at_now.at_001___clean`
  - `df.amazon.sales.by_item_index.at_ALL.at_now.at_001___v1`
  - `df.amazon.sales.by_item_index.at_ALL.at_now.at_001___v2`
  - `df.amazon.sales.by_item_index.at_ALL.at_now.at_001___v3`

- `df.official_website.comment_property.by_all_items.at_NY.at_m1month.at_000___manual`
- `df.sales.transactions.by_customer.at_CT.at_q1_2025.at_000___agg`

Note: The triple underscore (`___`) notation clearly separates the optional identifier. When loading or identifying objects, only the part before the triple underscore is used.

### 2. Functions
```
type.purpose
```

Note: The 'fn_' prefix only appears in the filename (fn_type_purpose.R), not in the actual object name itself. This ensures cleaner function calls while maintaining type identification in the filesystem. Additional subjects or qualifiers should be expressed in the function arguments rather than the name.

#### Terminology Clarification for Functions

When discussing functions, it's important to distinguish between these two concepts:

- **Function file name**: The name of the file containing the function definition (must have "fn_" prefix, e.g., `fn_detect_advanced_metrics_availability.R`)
- **Function object name**: The actual name of the function as it appears in code (must NOT have "fn_" prefix, e.g., `detect_advanced_metrics_availability`)

This distinction ensures clarity between filesystem references and code references, and helps prevent confusion when implementing and documenting functions.

Examples:
- `dt.calculate_sales`
- `calc.aggregate_transactions`
- `util.clean_data`

### 3. Models
```
mdl.algorithm.target.features
```

Examples:
- `mdl.regression.sales.price_seasonality`
- `mdl.cluster.customers.purchase_behavior`
- `mdl.forecast.inventory.seasonal_trends`

### 4. Lists
```
lst.category.content.purpose
```

Examples:
- `lst.products.bestseller.display`
- `lst.parameters.date.filtering`
- `lst.customers.segment.targeting`

### 5. Vectors
```
vec.entity.attribute.filter
```

Examples:
- `vec.customer.id.active`
- `vec.product.price.discounted`
- `vec.date.holiday.us`

### 6. Parameters
```
par.scope.category.name
```

Examples:
- `par.global.threshold.sales`
- `par.ui.color.primary`
- `par.model.cutoff.significance`

### 7. Default Values
```
def.component.parameter.name
```

Examples:
- `def.customer_profile.refresh_interval`
- `def.visualization.color_scheme`
- `def.data_table.page_size`

### 8. Constants
```
SCOPE.RIGID
```

Note: Constants use uppercase letters to distinguish them from variables. They do not use optional descriptors and maintain a simpler two-part structure.

Examples:
- `GLOBAL.API_VERSION`
- `SYSTEM.MAX_RETRY_ATTEMPTS`
- `VALIDATION.MAX_NAME_LENGTH`

### 9. Interface Definitions
```
iface.component.capability
```

Examples:
- `iface.data_source.retrievable`
- `iface.ui_component.renderable`
- `iface.processor.transformable`

### 10. Components
```
comp.role.domain.capability
```

Examples:
- `comp.ui.customer.profile`
- `comp.server.order.processing`
- `comp.defaults.visualization.options`

## Component Definitions

### Data Frame Components

1. **platform**: Data origin platform as defined in MP01
   - `amazon`: Amazon marketplace data
   - `official_website`: Company website data
   - Blank: Combined or derived data
2. **purpose**: Primary function of the data
   - `item_property`: Product information
   - `sales_data`: Sales transactions
   - `sales_zip`: Sales by ZIP code
   - `sku_asin_dictionary`: Lookup mapping
   - `comment_property`: Product reviews
   - `comment_property_rating`: Rated reviews
   - `comment_property_ratingonly`: Ratings without comments
3. **by_id components**: Entity grouping identifiers
   - `by_item_index`: Grouped by product identifier
   - `by_customer`: Grouped by customer
   - `by_date`: Grouped by date
   - `by_region`: Grouped by region
   - `by_category`: Grouped by category
4. **at_dimension components**: Dimensional slices
   - **Location dimension**:
     - `at_ALL`: All locations combined
     - `at_NY`: New York location only
     - `at_CT`: Connecticut location only
     - `at_CA`: California location only
   
   - **Time dimension**:
     - `at_now`: Current period
     - `at_m1year`: Previous year
     - `at_m1quarter`: Previous quarter
     - `at_m1month`: Previous month
     - `at_q1_2025`: Specific quarter
     - `at_all_time`: All time periods
   
   - **Product dimension**:
     - `at_000`: All products
     - `at_001`: electric_can_opener
     - `at_002`: milk_frother
     - `at_003`: salt_and_pepper_grinder
     - `at_004`: silicone_spatula
     - `at_005`: meat_claw
     - `at_006`: pastry_brush
     - `at_007`: bottle_openers
7. **identifier**: Additional data context and identification
   - `raw`: Raw data as defined in MP01
   - `clean`: Processed data as defined in MP01
   - `manual`: Manually edited data
   - `dictionary`: Lookup table
   - `value`: Value table
   - `agg`: Aggregated data
   - `filtered`: Filtered subset of data
   - `joined`: Result of joining multiple datasets
   

You can combine modifiers when needed by adding them as suffixes:
   - `clean_manual`: Processed data that was manually edited
   - `agg_manual`: Aggregated data that was manually edited
   - `filtered_manual`: Filtered data that was manually edited


## Column Naming Standards

### Standard Column Names

- `item_name`: Product name
- `sku`: Stock Keeping Unit
- `product_line`: Product category
- `asin`: Amazon Standard Identification Number
- `item_index`: SKU or ASIN
- `item_id`: Identifier for choice model
- `brand`: Brand name
- `subject_id`: Subject identifier

### Standardized Prefixes for Column Names

- `id_*`: Identifiers (id_customer, id_order)
- `dt_*`: Dates (dt_order, dt_delivery)
- `amt_*`: Monetary amounts (amt_total, amt_tax)
- `cnt_*`: Counts (cnt_orders, cnt_items)
- `pct_*`: Percentages (pct_discount, pct_growth)
- `flg_*`: Flags/booleans (flg_active, flg_promotional)

## Implementation Requirements

### 1. Consistency

- All new objects must follow these naming conventions
- Existing objects should be renamed when revised
- Scripts should use consistent naming throughout

### 2. Documentation

- Include comments explaining component choices for complex objects
- Document any non-standard component values
- Maintain a central register of all component values

### 3. Validation

- Scripts should validate object names against conventions
- Warning should be raised for non-compliant names
- Critical systems should enforce naming compliance

### 4. Data Dictionaries

- Maintain data dictionaries that map object names to descriptions
- Include data types, units, and constraints in dictionaries
- Link objects to their source definitions

## Examples

### Example 1: Data Processing Pipeline

```r
# Raw data from Amazon platform
raw.amazon.sales.all.now.000 <- read_parquet("path/to/file.parquet")

# Processed data after cleaning
df.amazon.sales.all.now.001.clean <- process_sales_data(raw.amazon.sales.all.now.000)

# Parameter for processing
par.processing.threshold.significance <- 0.05

# Default value for visualization
def.visualization.timeframe.default <- "monthly"

# Component that handles visualization
comp.ui.sales.visualization <- function(id) {
  # Component implementation
}
```

### Example 2: Function Definition and Usage

```r
# Function definition
fn.calculate.revenue.by_product <- function(sales_data, date_range) {
  sales_data %>%
    filter(dt_sale >= date_range$start, dt_sale <= date_range$end) %>%
    group_by(id_product) %>%
    summarize(
      total_revenue = sum(amt_sale),
      units_sold = sum(cnt_units),
      avg_price = total_revenue / units_sold
    )
}

# Function usage with processed data
revenue_report <- fn.calculate.revenue.by_product(
  df.amazon.sales.all.now.all.clean,
  list(start = "2025-01-01", end = "2025-03-31")
)
```

### Example 3: Component and Interface Usage

```r
# Interface definition
iface.data_source.retrievable <- list(
  retrieve = function(criteria) { ... },
  count = function(criteria) { ... }
)

# Component implementation
comp.server.sales.retrieval <- function(id) {
  # Implementation that follows the interface
  ns <- NS(id)
  
  # Module server logic
  function(input, output, session) {
    # Server implementation
  }
}

# Module that uses the component
mod.data_retrieval <- function() {
  # Module implementation using components
}
```

## Company-Specific Implementation

In accordance with MP01, companies may have specific implementations of modules, sequences, and derivations, but share the common object naming convention defined in this rule:

```r
# Company-specific implementation of a module
mod.company1.customer_analytics <- function() {
  # Company1-specific implementation
}

mod.company2.customer_analytics <- function() {
  # Company2-specific implementation
}
```

## Relationship to Other Principles

### Relation to Dot Notation Property Access Principle (P14)

This rule implements P14 by:
1. **Using Dot Notation**: Adopting dots as separators between naming components
2. **Hierarchical Structure**: Organizing components from general to specific
3. **Consistent Access**: Creating a naming system that works with property access patterns

### Relation to Natural SQL Language (MP24)

This rule supports MP24 by:
1. **Similar Notation**: Using the same A.B notation as NSQL hierarchical references
2. **Conceptual Alignment**: Creating names that align with query patterns
3. **Data Accessibility**: Making data sources easily referenceable in queries

### Relation to Separation of Concerns (MP17)

This rule supports MP17 by:
1. **Clear Boundaries**: Creating clear type distinctions through prefixes
2. **Component Organization**: Separating different aspects of objects in the name
3. **Purpose Transparency**: Making object purpose clear through standardized naming

### Relation to Primitive Terms and Definitions (MP01)

This rule implements MP01 by:
1. **Terminology Alignment**: Using the precise terms defined in MP01 for type prefixes
2. **Type Hierarchy Respect**: Maintaining the type hierarchies defined in MP01
3. **Categorical Distinctions**: Respecting categorical distinctions (e.g., parameter vs. default value)
4. **Variable/Constant Distinction**: Distinguishing between variables and constants

## Benefits

1. **Clarity**: Names clearly convey object purpose and content
2. **Consistency**: Creates a unified naming system across the project
3. **Navigability**: Makes code easier to navigate and understand
4. **Self-Documentation**: Names serve as micro-documentation
5. **Taxonomy**: Creates a natural taxonomic structure through naming
6. **Integration**: Facilitates integration with query languages
7. **Type Safety**: Promotes type awareness through consistent prefixing
8. **Company Adaptability**: Supports company-specific implementations while maintaining common patterns

## Database Tables Implementation

Database tables in app_data.duckdb follow the same naming convention but require special implementation considerations:

### 1. Database to Object Name Relationship

The database table name must correspond directly to the data frame object name, using the translation principles in R27:

| Object Name | Database Table Name |
|-------------|---------------------|
| df.amazon.sales_data.by_item_index | df_amazon_sales_data_by_item_index |
| df.website.comment_property | df_website_comment_property |

### 2. Table Creation Strategy Pattern

Table creation functions should use the Strategy Pattern to ensure consistent creation while supporting different table types:

```r
# Central registry for table creation strategies
table_creators <- list()

# Registration function
register_table_creator <- function(table_type, creator_fn) {
  table_creators[[table_type]] <- creator_fn
}

# Dispatch function
create_or_replace_table <- function(object_name, data, table_type = "standard") {
  # Convert object name to table name using R27 principles
  table_name <- gsub("\\.", "_", strsplit(object_name, "___")[[1]][1])
  
  # Get the correct strategy
  creator <- table_creators[[table_type]]
  
  if (is.null(creator)) {
    stop("No table creator registered for type: ", table_type)
  }
  
  # Execute the strategy
  return(creator(table_name, data))
}
```

### 3. Table Creation Functions

Table creation functions should follow a consistent naming pattern:

```r
# Pattern: create_or_replace.platform.purpose...
create_or_replace.amazon.sales_data <- function(data) {
  object_name <- "df.amazon.sales_data"
  return(create_or_replace_table(object_name, data))
}
```

### 4. Table Retrieval Functions

Consistent functions should be used to retrieve data from tables:

```r
# Standard function for retrieving a table
get_table <- function(object_name) {
  # Convert object name to table name
  table_name <- gsub("\\.", "_", strsplit(object_name, "___")[[1]][1])
  
  con <- dbConnect(duckdb::duckdb(), "app_data.duckdb")
  on.exit(dbDisconnect(con), add = TRUE)
  
  if (!dbExistsTable(con, table_name)) {
    stop("Table does not exist: ", table_name)
  }
  
  data <- dbReadTable(con, table_name)
  return(data)
}

# Specific retrieval function
get.amazon.sales_data <- function() {
  return(get_table("df.amazon.sales_data"))
}
```

### 5. SQL Query References

When writing SQL queries, use the translated table names:

```r
query <- sprintf("SELECT * FROM %s WHERE date >= '2025-01-01'", 
                 gsub("\\.", "_", "df.amazon.sales_data"))
```

## Conclusion

The Object Naming Convention rule establishes a comprehensive system for naming objects within the precision marketing system that directly aligns with the primitive terms defined in MP01. By using dot notation to separate hierarchical components, maintaining consistent ordering, and including MP01-aligned type prefixes, this rule creates a naming system that enhances code clarity, maintains consistency, and integrates naturally with the Natural SQL Language.

This rule provides specific guidelines for different object types, clear component definitions, and practical examples that demonstrate the naming convention in action. By following this rule, developers can create a codebase that is more readable, maintainable, and internally consistent while respecting the foundational terminology established in MP01.
