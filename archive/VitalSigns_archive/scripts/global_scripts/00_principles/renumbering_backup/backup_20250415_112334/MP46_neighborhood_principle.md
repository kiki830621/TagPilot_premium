# MP46: Neighborhood Principle

**Metaprinciple**: Correlated files should be placed in the same directory or adjacent locations within the file system.

## Description

Files that are functionally or logically related should be physically located near each other in the file system. This proximity enhances discoverability, improves maintainability, and creates a natural organization that mirrors the conceptual relationships between components.

## Rationale

When related files are stored in proximity to each other:
1. Developers can more easily find associated resources
2. Changes to a system component are more likely to involve files in the same location
3. The file system organization itself becomes documentation of the system's structure
4. Cognitive load is reduced when navigating the codebase

## Implementation

1. **Documentation Proximity**: Documentation files should be stored alongside the code or data they describe
   - Example: `app_data_structure.md` is stored in the same directory as `app_data.duckdb`

2. **Component Cohesion**: Files comprising a single component should be grouped together
   - UI components in `/components`
   - Database files in `/app_data`
   - Utility functions in `/utils`

3. **Functional Grouping**: Files serving similar functions should be grouped even if not directly interdependent
   - All principles in `/00_principles`
   - All component generators in their respective component type directories

4. **Avoid Fragmentation**: Resist storing related files in separate locations unless there is a compelling organizational reason

## Exceptions

1. When resource type organization is more important than functional relationships (e.g., static assets)
2. When different security requirements mandate separation
3. When deployment constraints require specific file locations

## Examples

- Configuration files kept with the modules they configure
- Test files adjacent to the code they test
- Schema files stored alongside database files
- CSS files alongside the components they style

## Related Principles

- R56 (Folder-Based Sourcing)
- P55 (N-tuple Independent Loading)
- MP43 (Database Documentation Principle)