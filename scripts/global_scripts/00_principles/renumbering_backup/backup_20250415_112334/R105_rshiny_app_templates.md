# R105: Shiny App Templates Rule

## Core Rule

Shiny applications should be developed using standardized templates stored in the `/21_rshinyapp_templates/` directory. These templates provide consistent structure, modular components, and proven patterns for creating maintainable and extensible R Shiny applications.

## Requirements

1. **Template Storage Location**:
   - All approved Shiny app templates must be stored in the `/21_rshinyapp_templates/` directory
   - Template files must be named descriptively with the suffix `_app.R` for full applications or `_component.R` for reusable components

2. **Template Structure**:
   - Each template must include clear section comments delineating:
     - Libraries and dependencies
     - Data generation or connection
     - UI components
     - Server logic
     - App initialization
   - Templates must adhere to R102 (Shiny Reactive Observation Rule) for proper reactive execution

3. **Code Organization**:
   - UI components should be organized into logical, reusable functions
   - Server logic should use modularization through Shiny modules where appropriate
   - Data processing should be separated from display logic

4. **Documentation Requirements**:
   - Each template must include a header comment with:
     - Template name and purpose
     - Required libraries
     - Key features demonstrated
     - Usage instructions
     - Related principles

5. **Framework Consistency**:
   - Templates should consistently use either base Shiny, bs4Dash, or other approved frameworks
   - When using bs4Dash, follow the standard layout patterns (dashboardPage, dashboardHeader, etc.)
   - Maintain consistent naming and styling conventions across templates

## Benefits

- **Accelerated Development**: Ready-to-use templates reduce development time for new applications
- **Consistency**: Applications based on templates have consistent structure and behavior
- **Best Practices**: Templates encapsulate proven patterns and best practices
- **Maintainability**: Standardized structure improves long-term code maintainability
- **Knowledge Transfer**: Templates serve as practical examples for new developers

## Current Templates

1. **customer_dna_minimal_app.R**: Basic customer DNA analysis dashboard with filtering and display
   - Demonstrates modular UI and server organization
   - Implements R102 with proper reactive observation
   - Shows standard bs4Dash layout pattern

2. **customer_dna_production_app.R**: Production-ready customer DNA analysis dashboard using microCustomer components
   - Uses the microCustomer component system
   - Implements both R91 (Universal Data Access) and R102 (Reactive Observation)
   - Provides a complete production application structure with settings and help
   - Demonstrates dashboard overview with summary statistics

## Related Principles

- **MP51**: Test Data Design
- **R99**: Test App Building Principles
- **R102**: Shiny Reactive Observation Rule
- **RC03**: App Component Template