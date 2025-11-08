# ISSUE_137: Strategy Plot Text Cutoff

## Issue Type
UI/UX Bug - Text Rendering

## Status
RESOLVED

## Created
2025-09-28

## Resolved
2025-09-28

## Priority
HIGH

## Affected Components
- scripts/global_scripts/10_rshinyapp_components/position/positionStrategy/positionStrategy.R

## Problem Description
Text in the Strategic Position Analysis four-quadrant plot is being cut off at the edges, particularly visible in the bottom-right quadrant (改變 quadrant) where items like "品牌信譽" have their last characters truncated.

## Root Cause Analysis

### Current Implementation Issues
1. **No Plot Margins**: The layout() function doesn't specify margins, using plotly defaults
2. **Edge Positioning**: Text is positioned at x=5/-5, very close to the plot range boundary of -10/10
3. **No Padding Buffer**: No buffer space between text position and plot boundaries
4. **Fixed Range**: Hard-coded range from -10 to 10 with no dynamic adjustment

### Code Location
- File: positionStrategy.R
- Lines: 964-967 (layout configuration)
- Lines: 938-950 (text positioning)

## Principle Violations
- **MP073**: Interactive Visualization Preference - Plot doesn't provide proper readable visualization
- **MP106**: Console Output Transparency - Text cutoff prevents full information display
- **UI/UX Best Practices**: Inadequate margin management for text elements

## Solution Approach

### 1. Add Proper Plot Margins
```r
layout(
  margin = list(l = 80, r = 80, t = 60, b = 60),  # Add generous margins
  xaxis = list(..., range = c(-12, 12)),  # Expand range
  yaxis = list(..., range = c(-12, 12))   # Expand range
)
```

### 2. Adjust Text Positioning
- Move text inward from edges: x=4/-4 instead of x=5/-5
- Keep labels at safe distance from boundaries

### 3. Implement Dynamic Text Wrapping
- Add text wrapping for long strings
- Use str_wrap() function for multi-line text

### 4. Add Responsive Font Sizing Near Edges
- Reduce font size for text near boundaries
- Implement edge-aware sizing logic

## Implementation Plan

1. **Immediate Fix**: Add margins and expand plot range
2. **Text Position Adjustment**: Move text away from edges
3. **Text Processing**: Implement wrapping for long text
4. **Testing**: Verify with various text lengths

## Test Cases

1. Long text strings (>20 characters)
2. Multiple items in single quadrant
3. Chinese characters (wider than Latin)
4. Mixed language content
5. Empty quadrants

## Related Issues
- ISSUE_106: Strategy analysis count error (resolved)
- ISSUE_116: Positioning strategy errors (resolved)

## Resolution Criteria
- [x] No text cutoff in any quadrant
- [x] All text fully visible with proper spacing
- [x] Maintains readability at different screen sizes
- [x] Works with both Chinese and English labels

## Resolution Details
Fixed by implementing the following changes:
1. **Added generous plot margins**: `margin = list(l = 80, r = 80, t = 60, b = 60)`
2. **Expanded axis ranges**: Changed from [-10,10] to [-12,12] for both axes
3. **Moved text positioning inward**: Labels at x=±4, content at x=±3.5 (from x=±5)
4. **Updated cross-hair lines**: Adjusted to match the expanded range
5. **Enhanced format_keys function**: Added text wrapping and bullet point separators

## Test Results
- Test script created and executed successfully
- HTML output generated showing no text cutoff
- All quadrants display text fully within plot boundaries
- Text wrapping function handles long strings appropriately

## Notes
The issue appears consistently in the 改變 (Change) quadrant due to its bottom-right position and typically containing multiple strategic factors that need adjustment. The fix ensures adequate spacing from all edges while maintaining visual balance.