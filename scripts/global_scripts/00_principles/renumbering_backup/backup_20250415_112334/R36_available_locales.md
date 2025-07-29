---
id: "R36"
title: "Available Locales Rule"
type: "rule"
date_created: "2025-04-04"
date_modified: "2025-04-04"
author: "Claude"
implements:
  - "MP23": "Language Preferences Meta-Principle"
related_to:
  - "R34": "UI Text Standardization Rule"
  - "R17": "Language Standard Adherence Rule"
---

# Available Locales Rule

## Core Requirement

The application must systematically manage and document available locales to ensure consistent language support throughout the system. Locale availability must be centrally defined, easily verifiable, and appropriately implemented across all components.

## Implementation Requirements

### 1. Locale Availability Determination

On Unix-like systems, the POSIX shell command `locale -a` lists the 'available public' locales. The meaning of available locales is platform-dependent:

- On recent Linux systems, this may indicate locales "available to be installed" (on RPM-based systems, locale data is in separate RPMs)
- On Debian/Ubuntu, available locales are managed by OS-specific facilities such as `locale-gen`, and `locale -a` lists those currently enabled

### 2. Locale Configuration Management

1. **Central Definition**: All supported locales must be centrally defined in the UI terminology dictionary configuration
2. **Verification Mechanism**: The application must include a mechanism to verify available locales at runtime
3. **Fallback Strategy**: A clear fallback strategy must be implemented when requested locales are unavailable

### 3. Locale Implementation Requirements

1. **Dictionary Completeness**: The UI terminology dictionary must include entries for all supported locales (specifically "en_US.UTF-8" and "zh_TW.UTF-8")
2. **Validation Process**: Regular validation must ensure all UI text has translations for all supported locales
3. **Missing Translation Handling**: The system must gracefully handle missing translations with appropriate fallbacks

### 4. Locale Selection Mechanism

1. **User Preference**: The application must provide a mechanism for users to select their preferred locale
2. **Configuration Override**: System administrators must be able to configure default and available locales
3. **Runtime Verification**: The application must verify locale availability at runtime and log any discrepancies

## Implementation Examples

### Example 1: Locale Availability Check

```r
check_locale_availability <- function() {
  # Get system locales
  system_locales <- system("locale -a", intern = TRUE)
  
  # Get configured locales from dictionary
  configured_locales <- colnames(ui_terminology_dictionary)[-1]  # Exclude "en_US.UTF-8" column
  
  # Check for mismatches
  missing_locales <- configured_locales[!configured_locales %in% system_locales]
  
  if (length(missing_locales) > 0) {
    warning("Configured locales not available on system: ", paste(missing_locales, collapse = ", "))
    log_event("locale_mismatch", list(missing_locales = missing_locales))
  }
  
  # Return available locales that are also configured
  available_locales <- configured_locales[configured_locales %in% system_locales]
  return(available_locales)
}
```

### Example 2: Locale Configuration in app_config.yaml

```yaml
localization:
  default_locale: "en_US.UTF-8"
  supported_locales:
    - "en_US.UTF-8"
    - "zh_TW.UTF-8"
  fallback_locale: "en_US.UTF-8"
  dictionary_path: "app_data/parameters/ui_terminology_dictionary.xlsx"
```

### Example 3: Locale Selection UI Component

```r
localeSelectionUI <- function(id) {
  ns <- NS(id)
  
  # Get available locales
  available_locales <- check_locale_availability()
  
  # Create human-readable names for display
  locale_display_names <- c(
    "en_US.UTF-8" = "English (US)",
    "zh_TW.UTF-8" = "中文 (繁體)"
  )
  
  selectInput(
    inputId = ns("locale"),
    label = translate("Display Language"),
    choices = setNames(available_locales, locale_display_names[available_locales]),
    selected = get_current_locale()
  )
}

localeSelectionServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    observe({
      new_locale <- input$locale
      if (!is.null(new_locale) && new_locale != get_current_locale()) {
        set_locale(new_locale)
        session$reload()
      }
    })
  })
}
```

## Common Errors and Solutions

### Error 1: Missing System Locales

**Problem**: Application is configured for locales not available on the system.

**Solution**:
- Implement runtime verification of locale availability
- Document system locale requirements in deployment documentation
- Provide instructions for installing missing locale packages
- Implement automatic fallback to available locales

### Error 2: Incomplete Dictionary Translations

**Problem**: UI terminology dictionary lacks entries for some supported locales.

**Solution**:
- Implement validation checks for dictionary completeness
- Generate reports of missing translations
- Enforce complete translation sets before deployment
- Provide a clear content contribution workflow for translations

### Error 3: Inconsistent Locale Naming

**Problem**: Inconsistent naming conventions between system locales and application configuration.

**Solution**:
- Standardize locale naming conventions
- Implement mapping between system and application locale formats
- Validate locale names against system availability
- Document naming conventions in the codebase

## Relationship to Other Principles

### Relation to UI Text Standardization Rule (R34)

This rule extends R34 by:
1. **Locale Management**: Adding requirements for locale management and availability
2. **System Integration**: Addressing system-level locale integration
3. **Runtime Verification**: Adding runtime verification requirements for locales

### Relation to Language Standard Adherence (R17)

This rule complements R17 by:
1. **Platform Specifics**: Addressing platform-specific locale requirements
2. **Technical Implementation**: Focusing on technical implementation of language standards
3. **Runtime Considerations**: Addressing runtime aspects of language standard adherence

### Relation to Language Preferences Meta-Principle (MP23)

This rule implements MP23 by:
1. **Practical Application**: Providing practical implementation requirements
2. **System Integration**: Addressing system-level integration of language preferences
3. **User Experience**: Focusing on user experience aspects of language selection

## Benefits

1. **Consistency**: Ensures consistent language experience across the application
2. **Reliability**: Reduces runtime errors related to missing locales
3. **Transparency**: Makes locale availability explicitly verifiable
4. **Flexibility**: Supports deployment across diverse environments
5. **Clarity**: Provides clear guidance for locale management
6. **Maintainability**: Centralizes locale configuration for easier maintenance
7. **User Experience**: Improves user experience through reliable language support

## Conclusion

The Available Locales Rule ensures that the application systematically manages and documents available locales to provide consistent language support. By defining requirements for locale determination, configuration, implementation, and selection, this rule establishes a robust framework for multilingual support.

This approach enhances the application's internationalization capabilities while ensuring reliable operation across diverse deployment environments. By following this rule, the system achieves more consistent, reliable, and user-friendly language support across all components.