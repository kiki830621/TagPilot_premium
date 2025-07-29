# R0054: Component Folder Organization

## Component-First Directory Structure

Components should be organized in a component-first directory structure, where each component has its own folder containing all related n-tuple files.

## Structure

```
/components/
  /componentName/
    - componentNameUI.R
    - componentNameServer.R
    - componentNameDefaults.R
    - componentNameFilters.R
```

## Rationale

Organizing by component rather than by aspect (UI/Server/Defaults/Filters) improves:

1. **Discoverability**: All files related to a single component are in one place
2. **Maintenance**: Changes to a component require navigating to only one location
3. **Cohesion**: Keeps tightly related files together, reflecting their interdependence
4. **Development Flow**: Encourages thinking in terms of complete components rather than layers

## Related Principles

- P0021: Component N-tuple Pattern
- MP0017: Separation of Concerns
- R0009: UI-Server-Defaults Triple

## Implementation

When implementing components:

1. Create a folder for each logical component
2. Name all files consistently with the component name as prefix
3. Include all required n-tuple aspects in the same folder
4. Place component-specific utilities in the same folder if tightly coupled

## Examples

```
# Sidebar Components
/components/sidebar/marketingChannel/
  - marketingChannelUI.R
  - marketingChannelServer.R  
  - marketingChannelDefaults.R
  - marketingChannelFilters.R

# Feature Components
/components/dataTable/
  - dataTableUI.R
  - dataTableServer.R
  - dataTableDefaults.R
```
