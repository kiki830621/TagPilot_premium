---
id: "RC01"
title: "Function File Template"
type: "rule-composite"
date_created: "2025-04-10"
date_modified: "2025-04-10"
author: "Claude"
implements:
  - "P95": "Template Organization Principle"
  - "MP17": "Separation of Concerns"
  - "MP18": "Don't Repeat Yourself"
extends:
  - "R21": "One Main Function, One File Rule"
aggregates:
  - "R21": "One Main Function, One File Rule"
  - "R69": "Function File Naming"
  - "R67": "Functional Encapsulation"
  - "R94": "Roxygen2 Function Examples Standard"
---

# Function File Template

## Core Purpose

This Rule Composite defines the standardized template for function files in the precision marketing system, establishing a consistent structure that combines multiple atomic rules into a coherent pattern. This template supports both Top-Down (main function first) and Bottom-Up (auxiliary functions first) organization styles, while maintaining a consistent overall structure.

## Template Structure

Function files must follow this sequential structure:

### 1. File Identification Section

```r
#' @file fn_[function_name].R
#' @principle [principle_id] [principle_name]
#' @principle [principle_id] [principle_name]
#' @related_to [file_id] [file_name]
#' @author [author_name]
#' @date [creation_date]
#' @modified [modification_date]
```

### 2. Required Library Section

```r
# Load required libraries
library(dplyr)
library(tidyr)
# Other libraries as needed
```

### 3. Function Definition Section

Function files must follow the Bottom-Up Organization pattern (Auxiliary Functions First), where dependencies are defined before they're used. Each function should be prefaced with a section marker in the format `####[function_name]####` to clearly delineate sections of the script:

```r
####auxiliary_function_name####

#' Auxiliary Function Description
#'
#' Description of what this auxiliary function does.
#'
#' @param param1 Description of parameter
#' @return Description of return value
#'
auxiliary_function_name <- function(param1) {
  # Implementation of auxiliary functionality
}

####process_result####

#' Another Auxiliary Function
#'
#' Description of another auxiliary function.
#'
#' @param result Result from previous processing
#' @param param2 Additional parameter
#' @return Processed result
#'
process_result <- function(result, param2) {
  # Implementation
}

####function_name####

#' Main Function Description
#'
#' Detailed description of what the main function does.
#' By placing it last, all its dependencies are already defined.
#'
#' @param param1 Description of first parameter
#' @param param2 Description of second parameter
#' @return Description of return value
#' @export
#' @implements [principle_id] [principle_name]
#' @examples
#' # Use case 1
#' example_usage(param1, param2)
#'
#' # Use case 2
#' another_example(different_params)
#'
function_name <- function(param1, param2, ...) {
  # Implementation that calls auxiliary functions
  result <- auxiliary_function_name(param1)
  return(process_result(result, param2))
}
```

This Bottom-Up organization follows the "initialization first" pattern common in functional programming and particularly well-suited to R. It ensures that all dependencies are defined before they're used, creates a natural progression from simple building blocks to their composition, and aligns with R's scoping rules.

The section markers (`####function_name####`) serve as clear delimiters between different sections of the script, making it easier to navigate, especially in files with multiple functions. This follows documentation standards similar to LaTeX sectioning commands.

### 4. Testing Hooks Section (Optional)

```r
# ===== Testing Hooks =====
# Functions exposed for testing purposes only

#' Test Hook for Internal Function
#'
#' @description
#' This function is exported ONLY for testing and should not be used
#' outside of test environments.
#'
#' @param param1 Description of parameter
#' @return Test result
#' @keywords internal
#'
test_hook_auxiliary_function <- function(param1) {
  auxiliary_function_name(param1)
}
```

### 5. End of File Section

```r
# [EOF]
```

## Key Components

### Main Function Requirements

The main function in each file must include:

1. **Comprehensive Documentation**:
   - Purpose and detailed description
   - Parameter descriptions with types
   - Return value specification
   - Usage examples (at least one)
   - Principles implemented

2. **Input Validation**:
   - Parameter type checking
   - Required parameter validation
   - Logical constraint validation

3. **Error Handling**:
   - Appropriate error messages
   - Graceful failure mechanisms
   - Recovery strategies where applicable

4. **Return Value Definition**:
   - Consistent return type
   - Proper documentation of structure
   - Handling of edge cases

### Auxiliary Function Requirements

Auxiliary functions must include:

1. **Clear Purpose**:
   - Specific, focused functionality
   - Limited scope supporting the main function
   - Clear relationship to the main function

2. **Documentation**:
   - Purpose description
   - Parameter descriptions
   - Return value specification

3. **Encapsulation**:
   - No external dependencies beyond the file
   - No state changes outside their scope
   - Single responsibility focus

## File Naming Conventions

Function files must be named according to R69 (Function File Naming):

1. Use the `fn_` prefix
2. Follow with the exact name of the main function
3. Use snake_case for the function name
4. End with the `.R` extension

Example: For a function named `calculate_customer_value`, the file should be named `fn_calculate_customer_value.R`.

## Examples

### Example: Complete Function with Bottom-Up Organization

```r
#' @file fn_calculate_customer_lifetime_value.R
#' @principle R67 Functional Encapsulation
#' @principle P05 Data Integrity
#' @principle R94 Roxygen2 Function Examples Standard
#' @related_to fn_customer_segmentation.R
#' @author Analytics Team
#' @date 2025-04-10
#' @modified 2025-04-10

# Load required libraries
library(dplyr)
library(lubridate)

####calculate_historical_value####

#' Calculate Historical Value
#'
#' Calculates the historical value of a customer based on past transactions.
#'
#' @param transactions Transaction data frame for a specific customer
#' @return Numeric value representing total historical value
#'
calculate_historical_value <- function(transactions) {
  if (nrow(transactions) == 0) {
    return(0)
  }
  
  sum(transactions$amount, na.rm = TRUE)
}

####predict_churn_probability####

#' Predict Churn Probability
#'
#' Predicts the probability of customer churn based on
#' transaction patterns and customer attributes.
#'
#' @param customer_id Customer identifier
#' @param transactions Transaction data frame
#' @param customer_metadata Customer attributes data frame
#' @return Probability of churn (0-1)
#'
predict_churn_probability <- function(customer_id, transactions, customer_metadata) {
  # Get customer record
  customer <- customer_metadata %>%
    filter(id == customer_id)
  
  if (nrow(customer) == 0) {
    return(0.5) # Default when customer not found
  }
  
  # Simple churn model for demonstration
  days_since_last <- as.numeric(Sys.Date() - max(transactions$date))
  
  # Higher churn probability with longer time since last purchase
  base_probability <- min(days_since_last / 365, 0.9)
  
  # Adjust based on purchase frequency
  frequency_factor <- 1 - min(nrow(transactions) / 10, 0.8)
  
  base_probability * frequency_factor
}

####estimate_future_value####

#' Estimate Future Value
#'
#' Estimates the future value of a customer based on
#' historical value and churn probability.
#'
#' @param historical_value Historical customer value
#' @param churn_probability Probability of customer churn
#' @param time_horizon Years to project into future
#' @param discount_rate Annual discount rate
#' @return Estimated future value
#'
estimate_future_value <- function(historical_value, 
                                 churn_probability, 
                                 time_horizon = 3,
                                 discount_rate = 0.1) {
  # Simple future value calculation
  retention_rate <- 1 - churn_probability
  annual_value <- historical_value / 3 # Assume historical value is from past 3 years
  
  future_value <- 0
  for (year in 1:time_horizon) {
    # Discount future value by retention probability and time
    year_value <- annual_value * retention_rate^year / (1 + discount_rate)^year
    future_value <- future_value + year_value
  }
  
  future_value
}

####calculate_customer_lifetime_value####

#' Calculate Customer Lifetime Value
#'
#' Calculates the total lifetime value of a customer based on
#' historical transactions and predicted future value.
#'
#' @param customer_id The unique identifier for the customer
#' @param transactions Data frame of customer transactions
#' @param customer_metadata Additional customer attributes
#' @param time_horizon Years to project into future (default: 3)
#' @param discount_rate Annual discount rate (default: 0.1)
#' @return Numeric value representing estimated lifetime value
#' @export
#' @implements P05 Data Integrity
#' @examples
#' # Basic usage
#' clv <- calculate_customer_lifetime_value(
#'   "CUST123", 
#'   transaction_df,
#'   customer_metadata_df
#' )
#'
#' # With custom time horizon and discount rate
#' clv <- calculate_customer_lifetime_value(
#'   "CUST123", 
#'   transaction_df,
#'   customer_metadata_df,
#'   time_horizon = 5,
#'   discount_rate = 0.08
#' )
#'
calculate_customer_lifetime_value <- function(customer_id, 
                                            transactions, 
                                            customer_metadata,
                                            time_horizon = 3,
                                            discount_rate = 0.1) {
  # Validate inputs
  if (!is.data.frame(transactions) || !is.data.frame(customer_metadata)) {
    stop("Both transactions and customer_metadata must be data frames")
  }
  
  # Filter transactions for this customer
  customer_transactions <- transactions %>%
    filter(customer_id == !!customer_id)
  
  # Calculate components of lifetime value
  historical_value <- calculate_historical_value(customer_transactions)
  churn_probability <- predict_churn_probability(customer_id, customer_transactions, customer_metadata)
  future_value <- estimate_future_value(historical_value, churn_probability, time_horizon, discount_rate)
  
  # Total lifetime value
  lifetime_value <- historical_value + future_value
  
  return(lifetime_value)
}

####test_hooks####

# ===== Testing Hooks =====

#' Test Hook for Historical Value Calculation
#'
#' @description
#' This function is exported ONLY for testing and should not be used
#' outside of test environments.
#'
#' @param transactions Transaction data
#' @return Historical value
#' @keywords internal
#'
test_hook_calculate_historical_value <- function(transactions) {
  calculate_historical_value(transactions)
}

# [EOF]
```

### Example: Minimal Function with Bottom-Up Organization

```r
#' @file fn_format_currency.R
#' @principle R67 Functional Encapsulation
#' @author Data Team
#' @date 2025-04-10

# Load required libraries
library(stringr)

####clean_numeric####

#' Remove Non-numeric Characters
#'
#' Helper function to extract only numeric values from a string.
#'
#' @param value String containing a currency value
#' @return Cleaned numeric string
#'
clean_numeric <- function(value) {
  # Extract digits and decimal point only
  str_extract(value, "[0-9\\.]+")
}

####format_currency####

#' Format Currency Value
#'
#' Consistently formats currency values for display.
#'
#' @param value Numeric value or string to format as currency
#' @param currency Currency symbol to use (default: "$")
#' @param decimal_places Number of decimal places to show (default: 2)
#' @return Formatted currency string
#' @export
#' @examples
#' format_currency(1234.56)  # Returns "$1,234.56"
#' format_currency("1234.56", "€", 0)  # Returns "€1,235"
#'
format_currency <- function(value, currency = "$", decimal_places = 2) {
  # If input is a string, extract the numeric portion
  if (is.character(value)) {
    value <- as.numeric(clean_numeric(value))
  }
  
  # Format with appropriate number of decimal places
  formatted <- format(round(value, decimal_places), 
                     big.mark = ",", 
                     nsmall = decimal_places)
  
  # Add currency symbol
  paste0(currency, formatted)
}

# [EOF]
```

## Rules Aggregated

This Rule Composite aggregates the following atomic rules:

1. **R21 (One Main Function, One File Rule)**: 
   - Each file contains one primary function with a dedicated purpose
   - Auxiliary functions support the main function
   - File name matches the main function name
   - Bottom-up organization with auxiliary functions defined first

2. **R69 (Function File Naming)**:
   - Files use the `fn_` prefix
   - Function name uses snake_case
   - File extension is `.R`

3. **R67 (Functional Encapsulation)**:
   - Functions encapsulate specific behaviors
   - Auxiliary functions are scoped to support the main function
   - Each function has a single responsibility

4. **R94 (Roxygen2 Function Examples Standard)**:
   - Documentation follows Roxygen2 format
   - Examples demonstrate function usage
   - Parameter documentation is comprehensive

## Benefits

1. **Consistency**: Ensures all function files follow the same structure
2. **Comprehensiveness**: Provides guidance for all aspects of function implementation
3. **Clarity**: Makes it easy to find specific elements in any function file
4. **Maintainability**: Enables focused changes to specific sections
5. **Documentation Quality**: Ensures complete and consistent documentation

## Dependencies

This Rule Composite:

1. **Implements**: P95 (Template Organization Principle) by establishing a sequentially structured template
2. **Extends**: R21 (One Main Function, One File Rule) by providing a comprehensive implementation template
3. **Aggregates**: Multiple atomic rules into a coherent implementation pattern
4. **Supports**: Both top-down and bottom-up organization styles while maintaining consistent structure