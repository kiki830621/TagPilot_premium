---
id: "R0035"
title: "AI Parameter Modification Rule"
type: "rule"
date_created: "2025-04-04"
date_modified: "2025-04-04"
author: "Claude"
derives_from:
  - "MP0014": "Change Tracking"
  - "MP0012": "Company-Centered Design"
---

# AI Parameter Modification Rule

## Core Rule

When AI systems (including LLMs like Claude) modify parameters or configuration files, they must follow the Slowly Changing Dimension Type 2 (SCD Type 2) approach:

1. **Append-Only Principle**: AI must never overwrite or delete existing parameter entries.
2. **Additive Changes**: New parameter values must be added as new rows or entries with appropriate metadata.
3. **Change Tracking**: All AI-generated modifications must include versioning information and rationale.
4. **Original Preservation**: Original parameter values must remain in the system for reference and potential rollback.

## Conceptual Framework

The SCD Type 2 approach maintains a complete history of all parameter changes:

1. **Historical Integrity**: Preserves the full history of parameter evolution
2. **Auditability**: Enables tracking of who made changes and why
3. **Rollback Support**: Facilitates reverting to previous parameter states if needed
4. **Explainability**: Documents the reasoning behind each parameter modification

## Implementation Requirements

### 1. Parameter File Structure

Parameter files should support the SCD Type 2 approach by including:

```
Parameter Name | Parameter Value | Version | Effective Date | End Date | Modified By | Rationale | Active Flag
```

Where:
- **Active Flag**: Indicates whether this is the currently active parameter value (1=active, 0=historical)
- **End Date**: Set to NULL for the current version, otherwise indicates when this version became inactive

### 2. Excel Parameter Files

For Excel-based parameter files:

1. **Sheet Structure**: Include version columns in addition to parameter data
2. **Filter Columns**: Always include an "Active" or "Include" column (1=active, 0=inactive)
3. **Data Processing**: Filter records where `active == 1` or `include != 0` during loading

```r
# Example: Loading data with SCD Type 2 filtering
platform_data <- param_data %>%
  # Filter out inactive rows
  dplyr::filter(is.na(include) | include != 0) %>%
  # Process active data
  dplyr::mutate(
    platform_key = tolower(gsub(" ", "", platform_name_english)),
    platform_display = platform_name_english
  )
```

### 3. AI Modification Procedure

When AI modifies parameters, it must follow this procedure:

```
1. READ current parameter file into a dataframe
2. IDENTIFY records to be changed
3. UPDATE the identified records:
   - Set active=0 or include=0 for the original entries
   - IF end_date column exists, set to current date
4. CREATE new records:
   - Copy all fields from the original entries
   - Set the new parameter values
   - Set active=1 or include=1
   - Set version = previous_version + 1
   - Set modified_by to AI identifier
   - Set effective_date to current date
   - Set end_date to NULL
   - Include modification rationale
5. APPEND the new records to the dataframe
6. WRITE the updated dataframe to the parameter file
```

### 4. Handling Different Parameter Types

Different parameter types require specific handling:

#### Dictionary-Based Parameters

```r
# INCORRECT - Direct replacement
ui_terminology_dictionary$Chinese[5] <- "新的翻譯"

# CORRECT - SCD Type 2 approach
new_entry <- data.frame(
  English = ui_terminology_dictionary$English[5],
  Chinese = "新的翻譯",
  Version = max(ui_terminology_dictionary$Version, na.rm=TRUE) + 1,
  EffectiveDate = Sys.Date(),
  EndDate = NA,
  ModifiedBy = "Claude AI",
  Rationale = "Improved translation accuracy",
  Active = 1
)

# Set old entry to inactive
ui_terminology_dictionary$Active[5] <- 0
ui_terminology_dictionary$EndDate[5] <- Sys.Date()

# Append new entry
ui_terminology_dictionary <- rbind(ui_terminology_dictionary, new_entry)
```

#### YAML Configuration

```yaml
# Example YAML with versioning support
parameters:
  - name: refresh_interval
    values:
      - value: 300
        version: 1
        effective_date: 2025-04-01
        end_date: 2025-04-04
        modified_by: Initial Config
        rationale: Default setting
        active: false
      - value: 600
        version: 2
        effective_date: 2025-04-04
        end_date: null
        modified_by: Claude AI
        rationale: Reduced server load
        active: true
```

## Implementation Examples

### UI Terminology Dictionary Updates

When AI updates UI terminology:

```r
update_terminology <- function(term, new_translation, language, rationale) {
  # Load dictionary
  dict_path <- file.path("app_data", "parameters", "ui_terminology_dictionary.xlsx")
  ui_data <- readxl::read_excel(dict_path)
  
  # Check if term exists
  term_idx <- which(ui_data$English == term)
  
  if (length(term_idx) > 0) {
    # Existing term - SCD Type 2 approach
    if (!"Active" %in% names(ui_data)) {
      # Add Active column if it doesn't exist
      ui_data$Active <- 1
    }
    if (!"Version" %in% names(ui_data)) {
      # Add Version column if it doesn't exist
      ui_data$Version <- 1
    }
    if (!"ModifiedBy" %in% names(ui_data)) {
      # Add ModifiedBy column if it doesn't exist
      ui_data$ModifiedBy <- "Initial Config"
    }
    if (!"Rationale" %in% names(ui_data)) {
      # Add Rationale column if it doesn't exist
      ui_data$Rationale <- NA
    }
    
    # Mark existing entry as inactive
    ui_data$Active[term_idx] <- 0
    
    # Create new entry
    new_entry <- ui_data[term_idx, ]
    new_entry[[language]] <- new_translation
    new_entry$Version <- max(ui_data$Version, na.rm=TRUE) + 1
    new_entry$Active <- 1
    new_entry$ModifiedBy <- "Claude AI"
    new_entry$Rationale <- rationale
    
    # Append new entry
    ui_data <- rbind(ui_data, new_entry)
  } else {
    # New term - simply add it
    new_row <- data.frame(English = term)
    new_row[[language]] <- new_translation
    
    if ("Version" %in% names(ui_data)) {
      new_row$Version <- max(ui_data$Version, na.rm=TRUE) + 1
    }
    if ("Active" %in% names(ui_data)) {
      new_row$Active <- 1
    }
    if ("ModifiedBy" %in% names(ui_data)) {
      new_row$ModifiedBy <- "Claude AI"
    }
    if ("Rationale" %in% names(ui_data)) {
      new_row$Rationale <- rationale
    }
    
    # Append new term
    ui_data <- rbind(ui_data, new_row)
  }
  
  # Write updated dictionary back to file
  openxlsx::write.xlsx(ui_data, dict_path)
  
  return(ui_data)
}
```

### Platform Data Updates

When AI updates platform configurations:

```r
update_platform_parameter <- function(platform_name, parameter_name, new_value, rationale) {
  # Load platform data
  platform_path <- file.path("app_data", "parameters", "platform.xlsx")
  platform_data <- readxl::read_excel(platform_path)
  
  # Find the platform record
  platform_idx <- which(platform_data$platform_name_english == platform_name)
  
  if (length(platform_idx) > 0) {
    # Existing platform - SCD Type 2 approach
    if (!"include" %in% names(platform_data)) {
      # Add include column if it doesn't exist
      platform_data$include <- 1
    }
    
    # Make copy of original row
    new_row <- platform_data[platform_idx, ]
    
    # Mark original as inactive
    platform_data$include[platform_idx] <- 0
    
    # Update parameter in new row
    new_row[[parameter_name]] <- new_value
    new_row$include <- 1
    
    # Add metadata if those columns exist
    if ("modified_by" %in% names(platform_data)) {
      new_row$modified_by <- "Claude AI"
    }
    if ("modification_date" %in% names(platform_data)) {
      new_row$modification_date <- Sys.Date()
    }
    if ("rationale" %in% names(platform_data)) {
      new_row$rationale <- rationale
    }
    
    # Append new row
    platform_data <- rbind(platform_data, new_row)
    
    # Write back to file
    openxlsx::write.xlsx(platform_data, platform_path)
    
    return(platform_data)
  } else {
    warning("Platform not found: ", platform_name)
    return(NULL)
  }
}
```

## Benefits

1. **Accountability**: Clear tracking of all AI-generated changes
2. **Reversibility**: Easy to revert to previous parameter states
3. **Transparency**: Changes include rationale and metadata
4. **Safety**: Original values are never lost or overwritten
5. **Continuous Improvement**: Allows parameter evolution while maintaining history

## Monitoring and Compliance

To ensure compliance with this rule:

1. **Regular Audits**: Periodically review parameter files for correct SCD Type 2 implementation
2. **Automated Checks**: Implement validation to ensure AI tools follow append-only principle
3. **Change Reports**: Generate reports of parameter changes by AI systems
4. **Version Control**: Maintain parameter files in version control systems when possible

## Conclusion

The AI Parameter Modification Rule ensures that all AI-driven changes to system parameters follow the Slowly Changing Dimension Type 2 (SCD Type 2) approach. This append-only strategy preserves the complete history of parameter evolution, providing robust auditability, traceability, and rollback capabilities. 

By requiring AI systems to document the rationale behind each parameter change and maintain historical values, this rule supports effective parameter management and governance in AI-augmented systems.
