---
id: "MP0011"
title: "Sensible Defaults"
type: "meta-principle"
date_created: "2025-04-02"
author: "Claude"
derives_from:
  - "MP0000": "Axiomatization System"
  - "MP0001": "Primitive Terms and Definitions"
influences:
  - "MP0010": "Information Flow Transparency"
  - "P04": "App Construction Principles"
  - "R04": "App YAML Configuration"
related_to:
  - "MP0005": "Instance vs. Principle"
---

# Sensible Defaults Meta-Principle

This meta-principle establishes that systems should provide sensible defaults for all configurable aspects, minimizing required explicit configuration while maintaining flexibility through override capabilities.

## Core Concept

Well-designed systems implement sensible defaults that work for most use cases without explicit configuration, while allowing specific overrides when needed. Defaults should be intuitive, predictable, and follow the principle of least surprise, reducing cognitive load and configuration complexity.

## Default Principles

### 1. Default Existence

Every configurable aspect of the system must have a defined default:

- **Complete Coverage**: All configurable options must have defaults
- **Documented Defaults**: Default values must be explicitly documented
- **Reasonable Assumptions**: Defaults should make reasonable assumptions about common use cases
- **Zero Configuration**: The system should be usable with zero explicit configuration
- **Implied Behavior**: Absence of configuration implies using the default

### 2. Default Preference

Configuration systems should prefer defaults over explicit configuration:

- **Override Principle**: Explicit configuration overrides defaults, not replaces them
- **Minimal Required Configuration**: Users should only need to configure exceptions
- **Progressive Configuration**: Start with defaults, then add specific overrides
- **Default Inheritance**: Lower-level components inherit defaults from higher-level components
- **Layered Defaults**: Defaults can be layered (system, project, user levels)

### 3. Default Discoverability

Defaults should be discoverable and transparent:

- **Inspectable Defaults**: Users should be able to inspect current default values
- **Self-Documenting**: Default values should be self-evident in code and documentation
- **Explicit Declaration**: Defaults should be explicitly declared, not hidden
- **Clear Origin**: The origin of a default should be clear (system, convention, calculated)
- **Default Indicators**: UIs should indicate when values are using defaults

### 4. Default Reasonableness

Defaults should be carefully chosen to be reasonable for most users:

- **Convention Alignment**: Follow established conventions when possible
- **Majority Use Case**: Optimize for the most common use cases
- **Safe Defaults**: Default values should be secure and safe
- **Performance Balanced**: Balance ease of use and performance in defaults
- **Least Surprise**: Choose defaults that cause the least surprise

### 5. Default Evolution

Defaults should evolve thoughtfully:

- **Stable Defaults**: Default values should change infrequently
- **Versioned Defaults**: Changes to defaults should be versioned
- **Migration Path**: Provide migration paths when defaults change
- **Backward Compatibility**: New defaults should consider backward compatibility
- **Forward Looking**: Defaults should anticipate future needs

## Implementation Guidelines

### 1. Default File Locations

Systems should have standard, predictable file locations:

```r
# Bad - Requiring explicit file location with no default
load_data(file_path = "app_data/database.db")

# Good - Using default location with override capability
load_data(file_path = NULL)  # Uses default "app_data/database.db"
```

Documentation should clearly state:
```
load_data(file_path = NULL)
Default: "app_data/database.db"
```

### 2. Default Configuration Structure

Configuration systems should include explicit defaults:

```yaml
# Configuration with defaults
app_settings:
  defaults:
    theme: "light"
    cache_ttl: 3600
    log_level: "info"
    data_path: "app_data/"
  
  # Override specific defaults
  theme: "dark"  # Overrides the default "light" theme
```

### 3. Default Parameters

Functions should have sensible defaults for parameters:

```r
# With sensible defaults for all parameters
render_chart <- function(
  data, 
  type = "bar",          # Default chart type
  colors = default_colors(),
  height = 400,          # Default height
  width = 600,           # Default width
  animate = TRUE,        # Default animation
  responsive = TRUE      # Default responsiveness
) {
  # Implementation...
}

# Can be called simply with: render_chart(data)
```

### 4. Default Documentation Pattern

Consistently document defaults in standard format:

```r
#' Render a data visualization
#' 
#' @param data The data to visualize
#' @param type The chart type (default: "bar")
#' @param colors Color palette (default: system standard colors)
#' @param height Chart height (default: 400px)
#' @param width Chart width (default: 600px)
#' @param animate Enable animations (default: TRUE)
#' @param responsive Make chart responsive (default: TRUE)
```

### 5. Default Calculation

When defaults need to be calculated, do so transparently:

```r
# Calculate a sensible default based on data
get_chart_height <- function(data, min_height = 200, max_height = 800) {
  # Calculate based on data rows, with bounds
  height <- 200 + (nrow(data) * 20)
  return(min(max(height, min_height), max_height))
}

render_chart <- function(data, height = NULL) {
  # Use calculated default if not specified
  if (is.null(height)) {
    height <- get_chart_height(data)
    message(sprintf("Using calculated default height: %dpx", height))
  }
  # Implementation...
}
```

## Benefits of Sensible Defaults

1. **Reduced Cognitive Load**: Users don't need to make every decision
2. **Faster Development**: Developers can focus on exceptions rather than common cases
3. **Consistent Experience**: Provides a more consistent experience across the system
4. **Lower Barrier to Entry**: Makes systems easier to learn and use
5. **Better Documentation**: Forces clear thinking about what options should be
6. **Prioritized Design**: Encourages thinking about the most common use cases
7. **Cleaner Configuration**: Keeps configuration files smaller and cleaner

## Default vs. Explicit Balance

The balance between defaults and explicit configuration should consider:

1. **Criticality**: More critical settings may require explicit configuration
2. **Variability**: Settings that vary widely between users should be explicit
3. **Security Implications**: Security-sensitive settings may require explicit values
4. **Performance Impact**: Settings with significant performance impact may require explicit configuration
5. **Discoverability Need**: Settings users need to know about may benefit from explicitness

## Examples from Modern Frameworks

### SwiftUI Example

SwiftUI exemplifies the power of sensible defaults:

```swift
// Minimal code with sensible defaults
Text("Hello World")

// Same component with explicit overrides
Text("Hello World")
    .font(.headline)
    .foregroundColor(.blue)
    .padding(10)
```

The first example works perfectly with all defaults, while the second allows targeted customization.

### R Shiny Example

R Shiny's approach to sensible defaults:

```r
# Minimal UI with defaults
ui <- fluidPage(
  titlePanel("My App"),
  mainPanel(
    plotOutput("plot")
  )
)

# Uses sensible defaults for:
# - Layout (responsive)
# - Margins and padding
# - Typography
# - Color scheme
# - Plot dimensions
```

## Relationship to Other Principles

This Sensible Defaults Meta-Principle derives from:

- **MP0000 (Axiomatization System)**: Builds on the formal system structure
- **MP0001 (Primitive Terms and Definitions)**: Uses the defined primitive terms

It influences:

- **MP0010 (Information Flow Transparency)**: Defaults should be transparent
- **P04 (App Construction Principles)**: Guides how apps should be constructed with defaults
- **R04 (App YAML Configuration)**: Informs how configuration should use defaults

And is related to:

- **MP0005 (Instance vs. Principle)**: Defaults bridge the gap between principles and instances

## Conclusion

The Sensible Defaults Meta-Principle ensures that systems are usable with minimal configuration while providing the flexibility to customize when needed. By establishing thoughtful defaults, we reduce the burden on users, simplify documentation, and create more intuitive, approachable systems.

This principle recognizes that well-chosen defaults are a fundamental design decision that affects user experience, development efficiency, and system maintainability. Following this principle helps create systems that are both powerful and accessible.
