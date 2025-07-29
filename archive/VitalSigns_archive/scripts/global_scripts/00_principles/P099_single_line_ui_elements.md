# P0099: Single-Line UI Elements Principle

## Principle Statement

Interface elements, especially navigation and control components, should present their content (icons, text, and other indicators) on a single line with consistent height whenever possible to maximize readability, maintain visual consistency, and optimize screen real estate.

## Rationale

1. **Readability**: Single-line elements create a cleaner, more scannable interface that users can quickly parse.

2. **Space Efficiency**: Horizontal layout of UI elements preserves vertical space, which is often more constrained in web applications, especially on mobile devices.

3. **Information Density**: Single-line presentation allows for higher information density without sacrificing clarity.

4. **Visual Consistency**: Maintaining a consistent layout with aligned elements at uniform heights improves visual hierarchy and creates a more professional appearance.

5. **Cognitive Processing**: Related elements placed on the same line with consistent height are perceived as belonging together, improving intuitive understanding of the interface.

6. **Horizontal Alignment**: Elements with consistent height create a clear horizontal alignment that improves scannability and visual organization.

## Implementation Guidelines

1. **Navigation Elements**:
   - Place icons and their corresponding labels on the same line
   - Use flexbox with `flex-direction: row` and `align-items: center` for proper alignment
   - Apply `white-space: nowrap` to prevent awkward text wrapping
   - Use appropriate spacing between the icon and text (typically 5-8px)
   - Set a consistent height for all navigation elements (typically 40px)
   - Apply the same line-height as the element height to ensure vertical centering

2. **Form Elements**:
   - Align labels and inputs horizontally when screen space permits
   - For longer forms, consider using grid layouts to maintain alignment
   - Use consistent spacing across all form elements

3. **Button Groups**:
   - Keep buttons in a single row when possible
   - For responsive designs, define controlled breakpoints for wrapping
   - Maintain consistent height across button groups

4. **Data Tables and Lists**:
   - Ensure column headers and data align properly
   - Use ellipsis (...) for text truncation rather than allowing wrapping
   - Consider horizontal scrolling for tables with many columns

5. **Status Indicators**:
   - Place status icons/badges on the same line as their descriptive text
   - Use color and shape effectively to minimize required text
   - Maintain consistent positioning across similar elements

## Examples

### CSS Implementation

```css
/* Proper single-line navbar elements with consistent height */
.navbar .nav-item .nav-link {
  display: flex;
  flex-direction: row;
  align-items: center;
  white-space: nowrap;
  height: 40px;          /* Consistent height */
  min-height: 40px;
  line-height: 40px;     /* Match height for text alignment */
  padding-top: 0;        /* Remove default padding */
  padding-bottom: 0;
  vertical-align: middle;
}

.navbar .nav-item .nav-link i {
  margin-right: 5px;
  display: inline-flex;
  line-height: inherit;
  vertical-align: middle;
}

/* Consistent height for navbar container */
.navbar-nav {
  min-height: 40px;
  align-items: center;
}

/* Button with icon and text on same line */
.btn-with-icon {
  display: inline-flex;
  align-items: center;
  height: 38px;          /* Standard button height */
}

.btn-with-icon i {
  margin-right: 6px;
}
```

### Shiny/bs4Dash Implementation

```r
# Good implementation - Single-line navbar tab with HTML for consistent height
bs4Dash::navbarTab(
  text = HTML(paste0(
    '<span style="display:flex; align-items:center; height:40px; line-height:40px;">',
    '<i class="fa fa-chart-line mr-1" style="display:inline-flex; margin-right:5px;"></i>',
    '<span>Analysis</span>',
    '</span>'
  )),
  tabName = "analysis_tab"
)

# Standard implementation - Letting the system handle layout
bs4Dash::navbarTab(
  text = "Analysis", 
  icon = icon("chart-line"),
  tabName = "analysis_tab"
)

# Poor implementation - Breaking elements across multiple lines
div(
  icon("chart-line"),
  br(),
  "Analysis"
)
```

### JavaScript Reinforcement

```js
// Fix for navbar elements to ensure consistent height
$(document).ready(function() {
  function fixNavbarLayout() {
    // Standard height for all navbar elements
    const standardHeight = '40px';
    
    // Apply consistent height and layout to navbar items
    $('.navbar .nav-link, .navbarTab')
      .css('display', 'flex')
      .css('align-items', 'center')
      .css('height', standardHeight)
      .css('line-height', standardHeight);
  }
  
  // Run initially and after a delay for dynamic content
  fixNavbarLayout();
  setTimeout(fixNavbarLayout, 1000);
});
```

## Related Principles and Rules

- MP0099: UI Separation Meta Principle
- P0022: CSS Controls Over Shiny Conditionals
- P0077: Performance Optimization Principle
- R0090: bs4Dash Structure Adherence Rule
- R0092: bs4Dash Navbar Navigation Rule
