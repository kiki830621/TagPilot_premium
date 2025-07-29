# Templates Directory

This directory contains template files for creating new scripts and components in the precision marketing system.

## Available Templates

### 1. `sc_update_scripts_template.R`
Template for platform-specific update scripts (e.g., amz_D03_01.R)
- Use for: Creating new derivation step scripts
- Location: Copy to `/update_scripts/`
- Naming: `{platform}_D{derivation}_{step}.R` or `D{derivation}_{step}_P{platform}.R`

### 2. `sc_global_scripts_template.R`
Template for general utility scripts in global_scripts
- Use for: Creating new utility or processing scripts
- Location: Copy to appropriate `/global_scripts/{folder}/`
- Naming: `sc_{descriptive_name}.R`

### 3. `fn_function_template.R`
Template for individual function files
- Use for: Creating new utility functions
- Location: Copy to `/global_scripts/04_utils/` or other function directories
- Naming: `fn_{function_name}.R`

### 4. `derivation_template.md`
Template for documenting new derivations
- Use for: Creating new D0X documentation
- Location: Copy to `/00_principles/D0X_{name}/`
- Naming: `D0X.md`

### 5. `principle_template.md`
Template for documenting new principles
- Use for: Creating new MP/P/R principles
- Location: Copy to `/00_principles/`
- Naming: `{type}{number}_{name}.md`

## Usage

1. Copy the appropriate template to your target directory
2. Rename according to conventions
3. Fill in the metadata section
4. Replace placeholder content with your implementation
5. Remove any unnecessary sections

## Template Guidelines

All templates follow these principles:
- MP47: Functional Programming
- R21: One Function One File
- R69: Function File Naming
- MP81: Explicit Parameter Specification
- R007: Update Script Naming Convention

## Quick Start

```bash
# Copy update script template
cp templates/sc_update_scripts_template.R ../../cbz_D05_00.R

# Copy function template
cp templates/fn_function_template.R ../04_utils/fn_my_new_function.R

# Copy derivation template
cp templates/derivation_template.md ../D05_new_analysis/D05.md
```