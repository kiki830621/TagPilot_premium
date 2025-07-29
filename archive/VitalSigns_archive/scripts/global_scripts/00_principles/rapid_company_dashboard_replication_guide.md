# Rapid Dashboard Replication for New Companies

This guide outlines the systematic approach to quickly replicate the precision marketing dashboard for new companies, following established principles and utilizing the modular architecture.

## Overview

The precision marketing system is designed with company-centered modularity, enabling rapid deployment for new companies through configuration and minimal code changes. This guide follows the M/S/D organizational framework and leverages configuration-driven UI composition.

## Prerequisites

1. Access to the precision marketing app codebase
2. Company-specific data sources identified
3. Business requirements documented
4. Technical environment prepared

## Step-by-Step Replication Process

### Phase 1: Company Directory Setup

#### 1.1 Create Company Module Directory
Following **MP0012 (Company-Centered Design)** and **R0000 (Directory Structure)**:

```bash
# Create new company directory structure
13_modules/NEW_COMPANY/
├── M00_initialization/
├── M01_data_loading/
├── S1_1_customer_dna/
├── D01_dna_analysis/
├── D02_filtered_sales/
├── D03_positioning/
└── README.md
```

#### 1.2 Copy Template Structure
Use existing company implementations as templates:

```bash
# Example: Copy from WISER template
cp -r 13_modules/WISER/* 13_modules/NEW_COMPANY/
# Then customize for the new company
```

### Phase 2: Configuration Setup

#### 2.1 Create Company Configuration
Following **MP0041 (Config-Driven UI Composition)** and **R0097 (Configuration Requirement)**:

```yaml
# app_configs/NEW_COMPANY_config.yaml
company:
  id: "NEW_COMPANY"
  name: "New Company Name"
  logo: "path/to/logo.png"
  
database:
  connections:
    raw_data: "path/to/raw_data.db"
    processed_data: "path/to/processed_data.db"
    app_data: "path/to/app_data.db"
    
ui_components:
  micro:
    customer_profile:
      enabled: true
      primary: customer_details
    sales:
      enabled: true
      data_source: sales_by_customer_dta
  macro:
    trends:
      enabled: true
      data_source: sales_trends
      
product_lines:
  - id: "PL001"
    name: "Product Line 1"
    category: "Category A"
  - id: "PL002"
    name: "Product Line 2"
    category: "Category B"
```

#### 2.2 Platform Configuration
Following **R0038 (Platform Numbering Convention)**:

```csv
# app_data/parameters/platform.csv
platform_id,platform_name,company
2,Amazon,NEW_COMPANY
3,Shopify,NEW_COMPANY
```

### Phase 3: Data Pipeline Setup

#### 3.1 Implement Data Import Modules
Following **MP0044 (Functor-Module Correspondence)**:

```r
# M01_importing_data/fn_import_sales.R
fn_import_sales <- function(company_id, platform_id) {
  # Company-specific import logic
  raw_data <- read_company_data(company_id, platform_id)
  processed_data <- process_sales_data(raw_data)
  return(processed_data)
}
```

#### 3.2 Define Derivation Flows
Following the **D (Derivation)** principle:

```r
# D01_dna_analysis/D01.md
---
id: "D01"
title: "Customer DNA Analysis for NEW_COMPANY"
type: "derivation"
company: "NEW_COMPANY"
---

# D01: Customer DNA Analysis Derivation

## Steps:
1. Import customer data → raw_data.customers
2. Calculate RFM metrics → processed_data.rfm
3. Generate DNA profiles → app_data.customer_dna
4. Create visualizations → Shiny components
```

### Phase 4: UI Component Customization

#### 4.1 Customize Shiny Modules
Following **R0009 (UI-Server-Defaults Triple)**:

```r
# 10_rshinyapp_components/micro/NEW_COMPANY/
├── microCustomerUI.R
├── microCustomerServer.R
└── microCustomerDefaults.R

# microCustomerUI.R
microCustomerUI <- function(id, config) {
  ns <- NS(id)
  
  # Generate UI from configuration
  tagList(
    if (config$ui_components$micro$customer_profile$enabled) {
      customerProfileUI(ns("profile"))
    },
    if (config$ui_components$micro$sales$enabled) {
      customerSalesUI(ns("sales"))
    }
  )
}
```

#### 4.2 Apply Company Branding
Following **MP0012 (Company-Centered Design)**:

```css
/* www/NEW_COMPANY_theme.css */
.navbar-brand {
  background-image: url('NEW_COMPANY_logo.png');
}

.company-primary {
  color: #COMPANY_COLOR;
}
```

### Phase 5: Module Registration

#### 5.1 Register New Modules
Following **MP0044 (Functor-Module Correspondence)**:

```r
# 00_principles/module_registry.yaml
modules:
  NEW_COMPANY:
    M01_importing_data:
      functor: "import data"
      company: "NEW_COMPANY"
    S1_1_customer_dna:
      functor: "analyze customers"
      company: "NEW_COMPANY"
```

### Phase 6: Integration and Testing

#### 6.1 Update Initialization Scripts
Following **R0013 (Initialization Sourcing)**:

```r
# update_scripts/NEW_COMPANY_initialization.R
source(file.path("update_scripts", "global_scripts", 
                 "00_principles", "sc_initialization_app_mode.R"))

# Load company-specific modules
source_directory(file.path("13_modules", "NEW_COMPANY"))

# Load company configuration
config <- read_yaml(file.path("app_configs", "NEW_COMPANY_config.yaml"))
```

#### 6.2 Create Test Suite
Following **MP0051 (Test Data Design)**:

```r
# M70_testing/NEW_COMPANY_tests/
├── test_data_import.R
├── test_ui_components.R
└── test_derivations.R
```

### Phase 7: Deployment

#### 7.1 Docker Configuration
Following **MP0049 (Docker-Based Deployment)**:

```dockerfile
# Dockerfile.NEW_COMPANY
FROM rocker/shiny:latest

# Copy company-specific files
COPY 13_modules/NEW_COMPANY /app/13_modules/NEW_COMPANY
COPY app_configs/NEW_COMPANY_config.yaml /app/app_configs/

# Set company environment variable
ENV COMPANY_ID=NEW_COMPANY
```

#### 7.2 Deployment Script

```bash
#!/bin/bash
# deploy_NEW_COMPANY.sh

# Build Docker image
docker build -f Dockerfile.NEW_COMPANY -t NEW_COMPANY_dashboard .

# Deploy to production
docker run -d -p 3838:3838 NEW_COMPANY_dashboard
```

## Automation Tools

### Company Template Generator

```r
# tools/generate_company_template.R
generate_company_template <- function(company_name) {
  # Create directory structure
  create_company_directories(company_name)
  
  # Copy template files
  copy_template_files(company_name)
  
  # Generate configuration
  generate_config_files(company_name)
  
  # Create initialization scripts
  create_init_scripts(company_name)
  
  message("Company template created for: ", company_name)
}
```

### Configuration Validator

```r
# tools/validate_company_config.R
validate_company_config <- function(company_name) {
  # Check directory structure
  check_directories(company_name)
  
  # Validate configuration files
  validate_configs(company_name)
  
  # Test module registration
  test_modules(company_name)
  
  # Verify data connections
  verify_data_sources(company_name)
  
  message("Validation complete for: ", company_name)
}
```

## Common Customization Points

1. **Data Sources**
   - Platform integrations (Amazon, Shopify, etc.)
   - Custom API connections
   - File format variations

2. **UI Components**
   - Company-specific dashboards
   - Custom visualizations
   - Branded color schemes

3. **Business Logic**
   - Company-specific KPIs
   - Custom analysis algorithms
   - Specialized reporting

4. **Security**
   - Authentication methods
   - Role-based access control
   - Data privacy requirements

## Troubleshooting Guide

### Common Issues and Solutions

1. **Configuration Not Loading**
   - Check file paths in initialization
   - Validate YAML syntax
   - Ensure R0097 compliance

2. **Module Not Found**
   - Verify module registration
   - Check directory structure
   - Validate naming conventions

3. **Data Connection Failures**
   - Test database connections
   - Verify credentials
   - Check network permissions

4. **UI Components Missing**
   - Validate configuration enables components
   - Check UI-Server-Defaults triple
   - Verify module sourcing

## Performance Optimization

1. **Lazy Loading**
   ```r
   # Load modules only when needed
   load_module_lazy <- function(module_name) {
     if (!exists(module_name)) {
       source(file.path("13_modules", company_id, module_name))
     }
   }
   ```

2. **Caching Strategy**
   ```r
   # Cache frequently accessed data
   cache_company_data <- function(company_id) {
     if (!exists("company_cache")) {
       company_cache <<- list()
     }
     company_cache[[company_id]] <<- load_company_data(company_id)
   }
   ```

## Maintenance Checklist

- [ ] Regular configuration validation
- [ ] Module dependency updates
- [ ] Security patch applications
- [ ] Performance monitoring
- [ ] Documentation updates
- [ ] Test suite maintenance

## Related Principles

- **MP0012**: Company-Centered Design
- **MP0016**: Modularity
- **MP0041**: Config-Driven UI Composition
- **MP0044**: Functor-Module Correspondence
- **R0000**: Directory Structure
- **R0009**: UI-Server-Defaults Triple
- **R0097**: Configuration Requirement

## Conclusion

By following this systematic approach and leveraging the modular architecture, new company dashboards can be deployed rapidly while maintaining consistency, quality, and maintainability. The configuration-driven approach ensures flexibility without compromising stability.

---

*Created: 2025-01-18*
*Author: Claude*
*Based on: Precision Marketing System Principles*