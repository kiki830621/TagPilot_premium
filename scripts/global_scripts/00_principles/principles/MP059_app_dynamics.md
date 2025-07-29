# MP100: Application Dynamics Principle

## Principle Statement

Application dynamics (animations, transitions, visibility changes, etc.) should be implemented to minimize server load while maintaining readable, maintainable code. When dynamic behaviors are needed, follow this hierarchy of implementation methods:

1. CSS-based solutions for visual transitions and animations
2. Conditional Shiny code for logical state changes and content updates
3. JavaScript-based solutions only as a last resort

## Rationale

1. **Performance**: CSS-based animations and transitions execute client-side, significantly reducing server load compared to server-side re-rendering through Shiny.

2. **Server Efficiency**: By handling visual dynamics in CSS, server resources are preserved for data processing and business logic rather than UI updates.

3. **Perceived Speed**: CSS transitions provide immediate visual feedback to user actions, whereas Shiny reactivity may introduce latency while waiting for server response.

4. **Scalability**: Applications that handle visual transitions in CSS scale better to multiple simultaneous users as they require fewer server resources per interaction.

5. **Progressive Enhancement**: CSS-based dynamics degrade gracefully in environments with limited resources or connectivity issues.

## Implementation Guidelines

1. **Prioritize CSS for Visual Transitions**:
   - Use CSS transitions and animations for all visual effects (fading, sliding, color changes)
   - Keep transitions in external CSS files, not inline styles
   - Use class toggling through Shiny (e.g., `shinyjs::addClass`) to trigger CSS transitions
   - Leverage CSS selectors to create state-based styling (:hover, .active, etc.)
   - Implement subtle transitions between states (300-500ms) for a polished feel

2. **Use Conditional Shiny Code for State Logic**:
   - Reserve Shiny reactivity for logical state changes and data updates
   - Use reactive expressions to determine which CSS classes should be applied
   - Combine reactive observers with CSS class manipulation for state changes
   - Let Shiny handle the "what" and CSS handle the "how" of transitions

3. **Optimize Server-Client Interaction**:
   - Minimize server round-trips for purely visual effects
   - Use `conditionalPanel` with JavaScript conditions rather than server-based rendering when appropriate
   - Prefer toggling CSS classes over re-rendering entire UI components
   - Batch UI updates where possible to reduce server communication

4. **When JavaScript is Necessary**:
   - Use the simplest possible JavaScript solution
   - Wrap JavaScript in proper Shiny interfaces (e.g., `shinyjs::runjs`)
   - Avoid complex state management in JavaScript
   - Document why JavaScript was necessary over CSS or Shiny solutions

5. **Balance and Performance**:
   - Prioritize perceived performance and responsiveness
   - Consider the impact on server resources for multi-user deployments
   - Ensure dynamics enhance rather than hinder the user experience
   - Test dynamics across different devices, browsers, and network conditions

## Examples

### Good Implementation (Following the Principle)

```r
# CSS in an external stylesheet (transitions.css)
# /* Tab content transitions */
# .tab-content {
#   opacity: 0;
#   transition: opacity 0.3s ease-in-out, transform 0.3s ease-out;
#   transform: translateY(10px);
# }
# 
# .tab-content.active {
#   opacity: 1;
#   transform: translateY(0);
# }
# 
# /* Navigation button state */
# .nav-button {
#   transition: background-color 0.2s ease, color 0.2s ease, border-color 0.2s ease;
# }
# 
# .nav-button.active {
#   background-color: #007bff;
#   color: white;
#   border-color: #0062cc;
# }

# Server-side logic for tab switching
server <- function(input, output, session) {
  # Track active tab
  active_tab <- reactiveVal("tab1")
  
  # Create UI elements once - no re-rendering needed
  output$allContent <- renderUI({
    tagList(
      # All content is rendered once, CSS controls visibility
      div(id = "tab1-content", class = "tab-content", 
          h3("Tab 1 Content"), p("This content uses CSS transitions")),
      div(id = "tab2-content", class = "tab-content", 
          h3("Tab 2 Content"), p("Different content for tab 2"))
    )
  })
  
  # Handle tab button clicks - only update classes, not content
  observeEvent(input$tab1Button, {
    active_tab("tab1")
    
    # Update button states with CSS classes
    shinyjs::addClass(id = "tab1Button", class = "active")
    shinyjs::removeClass(id = "tab2Button", class = "active")
    
    # Update content visibility through CSS classes
    shinyjs::addClass(id = "tab1-content", class = "active")
    shinyjs::removeClass(id = "tab2-content", class = "active")
  })
  
  observeEvent(input$tab2Button, {
    active_tab("tab2")
    
    # Update button states with CSS classes
    shinyjs::removeClass(id = "tab1Button", class = "active")
    shinyjs::addClass(id = "tab2Button", class = "active")
    
    # Update content visibility through CSS classes
    shinyjs::removeClass(id = "tab1-content", class = "active")
    shinyjs::addClass(id = "tab2-content", class = "active")
  })
}
```

### Poor Implementation (Violating the Principle)

```r
# Re-rendering entire content on each tab change (server inefficient)
output$tabContent <- renderUI({
  # Get current tab from input
  current_tab <- input$tabs
  
  # Completely re-render content for each tab change
  if (current_tab == "tab1") {
    div(
      style = "animation: fadeIn 0.5s;", # Inline animation
      h3("Tab 1 Content"),
      p("This content is completely re-rendered on server")
    )
  } else if (current_tab == "tab2") {
    div(
      style = "animation: fadeIn 0.5s;", # Inline animation
      h3("Tab 2 Content"),
      p("Different content for tab 2")
    )
  }
})

# Complex JavaScript that duplicates what CSS can do
output$tabScript <- renderUI({
  tags$script(HTML("
    $(document).ready(function() {
      $('.tab-button').click(function() {
        var tabId = $(this).attr('data-tab');
        
        // Complex animations in JavaScript instead of CSS
        $('.tab-content').each(function() {
          $(this).animate({opacity: 0}, 300, function() {
            $(this).hide();
          });
        });
        
        // Show new content with JavaScript animation
        $('#' + tabId).show().animate({
          opacity: 1,
          top: '0px'
        }, 300);
        
        // Update active state with JS instead of CSS classes
        $('.tab-button').css('background-color', '#f8f9fa');
        $(this).css('background-color', '#007bff');
      });
    });
  "))
})
```

## Related Principles

- MP0099: UI Separation Meta Principle
- P62: Separation of Concerns
- P72: UI Package Consistency Principle
- P73: Server-to-UI Data Flow Principle
- R09: UI-Server-Defaults Triple Rule
- R90: bs4Dash Structure Adherence Rule
- R92: bs4Dash Direct Navigation Rule
