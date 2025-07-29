# R0077: Supplemental Description Notation Rule

## Statement
All supplemental descriptions in filenames MUST use the format `basename_description.extension`.

## Description
This rule establishes a standard notation for supplemental descriptions in filenames. When a file variant needs to be distinguished from its original or primary version, the supplemental description must be separated from the base filename using an underscore character (_).

## Rationale
1. **Consistency**: Provides a uniform pattern for supplemental descriptions across the codebase
2. **Clarity**: Makes it immediately clear which part of the filename is the base and which part is a supplemental description
3. **Searchability**: Makes it easier to find all variants of a file by searching for the base name
4. **Sorting**: Files with the same base name will be grouped together in directory listings
5. **Compatibility**: Uses underscores which are widely compatible across operating systems and file systems

## Implementation Guide

### Correct Format
```
basename_description.extension
```

For example:
- `microCustomer_R0076.R` (indicating compliance with Rule 76)
- `config_development.yaml` (indicating a development configuration)
- `report_monthly.pdf` (indicating a monthly report)

### Multi-part Descriptions
For multi-part descriptions, use additional underscores to separate the parts:
```
basename_part1_part2.extension
```

For example:
- `dataProcessor_v2_beta.R` (version 2, beta release)
- `order_2023_summary.csv` (2023 summary of orders)

### Incorrect Formats

Do not use any of these formats:
```
basename.description.extension   # Wrong: uses dots instead of underscores
basename-description.extension   # Wrong: uses hyphens instead of underscores
basenameDescription.extension    # Wrong: uses camelCase instead of underscores
basename (description).extension # Wrong: uses parentheses
```

### File Versioning
For version-based supplemental descriptions, use a consistent format:
```
basename_v1.extension
basename_v2.extension
```

### Rules vs. Implementation
The supplemental description should indicate what is different about the file, not just label it with an arbitrary code:

```
# CORRECT (descriptive)
dataProcessor_optimized.R
dataProcessor_parallel.R

# INCORRECT (non-descriptive)
dataProcessor_1.R
dataProcessor_new.R
```

### Special Case: Temporary Files
For temporary files, use a consistent prefix:
```
basename_temp.extension
basename_backup.extension
```

## Examples

### Correct
- `microCustomer_R0076.R` - microCustomer implementation that follows Rule 76
- `app_production.R` - Production version of app.R
- `config_development.yaml` - Development configuration
- `report_2023_Q1.pdf` - Q1 2023 report
- `database_backup_2023_01_15.sql` - Database backup from January 15, 2023

### Incorrect
- `microCustomerR0076.R` - Missing underscore separator
- `app-production.R` - Uses hyphen instead of underscore
- `config.dev.yaml` - Uses dots instead of underscores
- `report(2023).pdf` - Uses parentheses instead of underscores

## Related Rules and Principles
- R0001: File Naming Convention
- R0028: Archiving Standard
- R0069: Function File Naming

#LOCK FILE
