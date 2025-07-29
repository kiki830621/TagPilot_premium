# Data Processing Module

This module contains scripts for processing various data sources, including Amazon sales data, official website sales data, and more.

## Amazon Sales Data Processing

### Overview

The Amazon sales data processing pipeline consists of two main steps:

1. **Import**: Reading Excel files from Amazon reports and importing them into the raw data database.
2. **Process**: Transforming the raw data into a standardized format and storing it in the processed data database.

### Usage

#### Basic Usage

```r
# Initialize the environment
source(file.path("update_scripts", "global_scripts", "00_principles", "000g_initialization_update_mode.R"))

# Connect to databases
raw_data <- dbConnect(duckdb::duckdb(), dbdir = "path/to/raw_data.duckdb")
processed_data <- dbConnect(duckdb::duckdb(), dbdir = "path/to/processed_data.duckdb")

# Import Amazon sales data from Excel files
import_amazon_sales_dta(
  folder_path = "path/to/amazon_data", 
  connection = raw_data
)

# Process the imported data
process_amazon_sales(
  raw_data = raw_data,
  Data = processed_data
)

# Disconnect from databases
dbDisconnect_all()
```

#### Advanced Usage

For more control over the import process, you can use the following options:

```r
# Import with overwrite (clear existing data) and verbose output
import_amazon_sales_dta(
  folder_path = "path/to/amazon_data", 
  connection = raw_data,
  clean_columns = TRUE,   # Apply standardized column name cleaning
  overwrite = TRUE,       # Overwrite existing data
  verbose = TRUE          # Show detailed processing information
)
```

### File Structure

The data processing module includes:

- `import_amazon_sales.R`: Main file for importing and processing Amazon sales data
  - `import_amazon_sales_dta()`: Imports Amazon Excel reports into the database
  - `process_amazon_sales()`: Processes raw data into standardized format

- `amazon/`: Directory containing Amazon-specific processing functions
  - `205g_process_amazon_sales.R`: Processing functions for Amazon sales data
  - Other supporting processing scripts

### Table Schema

The Amazon sales data processing creates a table with the following structure:

- `customer_id`: Extracted from buyer email (before @)
- `time`: Timestamp of the purchase
- `sku`: Stock keeping unit
- `lineitem_price`: Price of the item
- `asin`: Amazon Standard Identification Number
- `product_line_id`: Product line identifier
- Additional fields from the Amazon report

### Testing

You can use the test script to verify the import and processing functionality:

```r
source(file.path("update_scripts", "global_scripts", "00_principles", "test_amazon_sales_import.R"))
```

This script will:
1. Set up database connections
2. Create necessary table structures
3. Import and process data
4. Display statistics and a sample of the processed data

## Documentation

For more detailed documentation on each function, see:

- [import_amazon_sales_dta](../docs/functions/05_data_processing/import_amazon_sales.html)
- [process_amazon_sales](../docs/functions/05_data_processing/import_amazon_sales.html)