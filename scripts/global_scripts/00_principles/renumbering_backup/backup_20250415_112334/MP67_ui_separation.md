# MP99: UI Separation Meta Principle

## Principle Statement

UI implementation should follow a clear separation of concerns between markup (HTML/Shiny), JavaScript, and CSS, in this specific order of preference. When a UI feature can be implemented with either markup, JavaScript, or CSS, prefer the earlier option in the list.

## Rationale

1. **Maintainability**: Clear separation between structure (HTML/Shiny), behavior (JavaScript), and presentation (CSS) makes code easier to maintain.

2. **Progressive Enhancement**: Building with HTML first, then enhancing with JavaScript and styling with CSS ensures core functionality works across environments.

3. **Accessibility**: HTML-first approaches are inherently more accessible than those that depend on JavaScript or CSS for core functionality.

4. **Performance**: Relying on native HTML/Shiny components often provides better performance than custom JavaScript implementations.

5. **Resilience**: HTML is the most resilient layer, followed by CSS, with JavaScript being the most fragile. Prioritizing HTML provides stronger fault tolerance.

## Implementation Guidelines

1. **HTML/Shiny First**: 
   - Use native Shiny UI components whenever possible
   - Structure content using semantic HTML elements
   - Rely on built-in UI components before custom implementations
   - Use proper element nesting and parent-child relationships

2. **JavaScript for Behavior Only**:
   - Use JavaScript only when HTML/Shiny cannot provide the needed functionality
   - Focus on enhancing existing markup rather than generating it
   - Keep JavaScript focused on interactive behavior, not styling
   - Use JavaScript libraries judiciously, prioritizing those that follow this principle

3. **CSS Last and Minimal**:
   - Use CSS for styling only, not for core functionality
   - Avoid CSS that requires specific markup structures that compromise semantics
   - Minimize the use of !important and other override mechanisms
   - Keep styling separate from structure and behavior

## Examples

### Good Implementation (Following the Principle)

```r
# HTML/Shiny first approach
ui <- fluidPage(
  # Structure in Shiny markup
  tabsetPanel(
    id = "main_tabs",
    tabPanel("Tab 1", "Content for tab 1"),
    tabPanel("Tab 2", "Content for tab 2")
  )
)

# JavaScript only for enhancement
server <- function(input, output, session) {
  observeEvent(input$main_tabs, {
    # JavaScript for behavior only
    shinyjs::runjs(sprintf("console.log('Tab changed to %s')", input$main_tabs))
  })
}

# CSS for styling only
css <- "
.tab-content {
  padding: 15px;
}
"
```

### Poor Implementation (Violating the Principle)

```r
# Using CSS for structure - violating the principle
ui <- fluidPage(
  div(
    id = "tabs-container",
    div(id = "tab1", "Content for tab 1"),
    div(id = "tab2", class = "hidden", "Content for tab 2")
  )
)

# JavaScript doing too much - creating structure and handling presentation
server <- function(input, output, session) {
  shinyjs::runjs("
    $('#tabs-container').prepend('<div class=\"tabs-header\"><button id=\"btn-tab1\">Tab 1</button><button id=\"btn-tab2\">Tab 2</button></div>');
    $('#btn-tab1').on('click', function() {
      $('#tab1').show();
      $('#tab2').hide();
      $(this).css('background-color', 'blue');
      $('#btn-tab2').css('background-color', 'gray');
    });
    $('#btn-tab2').on('click', function() {
      $('#tab2').show();
      $('#tab1').hide();
      $(this).css('background-color', 'blue');
      $('#btn-tab1').css('background-color', 'gray');
    });
  ")
}
```

## Related Principles

- P62: Separation of Concerns
- P72: UI Package Consistency Principle
- P73: Server-to-UI Data Flow Principle
- R09: UI-Server-Defaults Triple Rule
- MP17: Modularity Principle
- MP56: Connected Component Principle
