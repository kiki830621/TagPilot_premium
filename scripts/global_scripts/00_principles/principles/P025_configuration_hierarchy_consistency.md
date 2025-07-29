# P0025: Configuration Hierarchy Consistency

## Context
Configuration files often contain settings at different conceptual levels (UI display settings, functional settings, data connections). Without clear principles for organizing these settings, the configuration can become confusing and difficult to maintain.

## Principle
**Configuration hierarchies should maintain consistent conceptual levels within each nesting tier, with settings organized by domain rather than by component, and with sensible defaults reducing the need for explicit configuration.**

## Rationale
1. **Cognitive Coherence**: Each level of the configuration hierarchy should represent a consistent conceptual level.

2. **Domain Separation**: UI display settings should be separated from functional settings and data connection settings.

3. **Convention Over Configuration**: Where possible, sensible defaults should be inferred from names and context.

4. **Progressive Detail**: Configuration should start with essential settings and add more specific details at deeper levels.

5. **Feature Discoverability**: The structure of the configuration should make it clear what can be configured.

## Implementation
Configuration hierarchies should follow these patterns:

1. **Horizontal Domain Separation**:
   ```yaml
   ui:
     component_a: {...}
     component_b: {...}
   data:
     component_a: {...}
     component_b: {...}
   ```

2. **Vertical Component Separation**:
   ```yaml
   components:
     component_a:
       ui: {...}
       data: {...}
     component_b:
       ui: {...}
       data: {...}
   ```

3. **Default Application**:
   - Components should have sensible defaults based on their names
   - Only non-standard settings should require explicit configuration

4. **Configuration Schemas**:
   - Each component should have a clear schema for its configuration
   - Schema validation should be used to catch misconfigurations

## Examples

### Example 1: Mixed Levels (Problematic)
```yaml
# Mixing functional and UI settings at the same level
components:
  micro:
    display:  # UI setting
      label: "Customer Analysis"
    customer_profile:  # Functional setting
      primary: "db_table"
```

### Example 2: Consistent Levels (Better)
```yaml
# Approach 1: Separate by domain first
ui:
  micro:
    label: "Customer Analysis"
data:
  micro:
    customer_profile:
      primary: "db_table"

# Approach 2: Separate by component first, then by domain
components:
  micro:
    ui:
      label: "Customer Analysis"
    data:
      customer_profile:
        primary: "db_table"
```

### Example 3: Convention Over Configuration
```yaml
# Only configure what's non-standard
components:
  # Standard component uses default UI based on name
  micro: 
    data_source: "customer_table"
  
  # Non-standard component needs explicit UI settings
  special_analysis:
    ui:
      label: "Custom Analysis Tool"  # Override default of "Special Analysis"
    data_source: "custom_table"
```

## Related Principles
- MP0041: Type-Dependent Operations
- R0064: Explicit Over Implicit Evaluation
- MP0031: Initialization First

## Application
When designing configuration structures:
1. Choose either horizontal (by domain) or vertical (by component) separation
2. Be consistent with the chosen approach
3. Keep conceptual levels clear within each tier
4. Use sensible defaults based on names
5. Only require explicit configuration for non-standard settings
