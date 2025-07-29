# Shiny App Templates

This directory contains standardized templates for R Shiny applications, following Rule R105 (Shiny App Templates Rule). These templates provide consistent structure, modular components, and proven patterns for creating maintainable and extensible applications.

## Templates Overview

Each template is designed to demonstrate specific principles and best practices while providing a solid foundation for new application development.

### Available Templates

1. **customer_dna_minimal_app.R**
   - Purpose: Basic customer DNA analysis dashboard with filtering and display
   - Framework: bs4Dash
   - Key Features:
     - Modular UI and server organization
     - Customer filtering and selection
     - RFM analysis display
     - Proper implementation of R102 (reactive observation)
     - Error handling with fallback values
     - Responsive bs4Dash layout

2. **customer_dna_production_app.R**
   - Purpose: Production-ready customer DNA analysis dashboard using microCustomer components
   - Framework: bs4Dash with microCustomer module
   - Key Features:
     - Uses production-ready microCustomer components
     - Complete bs4Dash layout with multiple tabs
     - Dashboard overview with summary statistics
     - Settings page with theme and language options
     - Implements R91 Universal Data Access Pattern
     - Control sidebar with help information
     - Ready for deployment with no debug elements

## Usage Guidelines

1. Select the template that most closely matches your requirements
2. Copy the template to your project directory
3. Modify the data source to connect to your actual data (use universal_data_accessor for production)
4. Customize UI components as needed
5. Add additional features while maintaining the modular structure
6. Ensure adherence to principles (particularly R102, R105)

## Structure

All templates follow a consistent structure:

1. **Documentation Header**: Principles, purpose, requirements, features, usage
2. **Libraries**: Required package dependencies
3. **Data**: Data generation, connection, or processing
4. **UI Components**: Modular UI functions
5. **Server Logic**: Reactive expressions and output rendering
6. **Layout**: Application layout and structure
7. **Initialization**: Final setup and launch

## Related Principles

- **R102**: Shiny Reactive Observation Rule
- **R105**: Shiny App Templates Rule
- **MP51**: Test Data Design
- **P76**: Error Handling Patterns
- **P78**: Component Composition
- **RC03**: App Component Template

## Contributing New Templates

When adding a new template to this directory:

1. Follow the naming convention: `{purpose}_app.R` or `{purpose}_component.R`
2. Include comprehensive documentation in the header
3. Organize the code with clear section comments
4. Implement proper error handling
5. Follow R102 for reactive expressions
6. Update this README with the new template information
7. Update R105 to include the new template in the "Current Templates" section