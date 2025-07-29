# Debug script for initializing with verbose output
# This script can be sourced before running any script that needs initialization

# Set verbose mode to enable detailed loading information
VERBOSE_INITIALIZATION <- TRUE

# To run non-verbose mode, comment out the line above and uncomment below:
# VERBOSE_INITIALIZATION <- FALSE

message("Verbose initialization mode enabled.")
message("Now source your main script to see detailed loading information.")
message("Example: source('update_scripts/004_import_amazon_sales_dta.R')")