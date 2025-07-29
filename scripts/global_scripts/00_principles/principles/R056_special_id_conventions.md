# Rule 56: Special ID Conventions

## Core Rule
Special category IDs must follow consistent conventions across the system, with reserved patterns for meta-categories and special values to ensure reliable identification and processing.

## Reserved ID Patterns

### Meta-Categories
1. **ALL Category**: `"000"` or `"all"`
   - Represents all available products
   - Used for "show everything" options
   - Example: "All Products", "All Platforms"

2. **None/Not Applicable**: `"999"` or `"none"`
   - Represents absence of a categorization
   - Used when product doesn't fit any defined category
   - Example: "Uncategorized", "Other", "N/A"

3. **Multiple Selection**: `"998"` or `"multiple"`
   - Represents multiple selected products
   - Used in summary views when multiple products are selected
   - Example: "Multiple Selections (3 products)"

4. **Unknown/Unspecified**: `"997"` or `"unknown"`
   - Represents missing or unknown information
   - Used when category information is truly unknown
   - Example: "Unknown Source", "Unspecified Category"

### ID Formatting
1. **Numeric IDs**
   - Standard categories: `"001"` through `"996"`
   - Category IDs MUST be zero-padded to ensure consistent length
   - For hierarchical categories, use dot notation: `"001.002.003"`

2. **String IDs**
   - Use lowercase with underscores: `"category_name"`
   - For special categories, use prefixes:
     - `"all_"`
     - `"other_"`
     - `"unknown_"`

3. **Compound IDs**
   - Format: `"[type]__[id]"`
   - Example: `"product__001"`, `"platform__002"`
   - Reserved metadata prefix: `"__meta__"`

## Implementation Guidelines

### Database Storage
```sql
-- Include special category ALL in dimension table
INSERT INTO product_categories (id, name_en, name_zh) VALUES ('000', 'All Products', '所有產品');

-- Include special category OTHER in dimension table
INSERT INTO product_categories (id, name_en, name_zh) VALUES ('999', 'Other Products', '其他產品');
```

### Code Usage
```r
# Define constants for special IDs
ALL_CATEGORY_ID <- "000"
OTHER_CATEGORY_ID <- "999"
MULTIPLE_SELECTION_ID <- "998"
UNKNOWN_CATEGORY_ID <- "997"

# Special case handling in filtering logic
filter_products <- function(category_id, products) {
  if (category_id == ALL_CATEGORY_ID) {
    return(products)  # Return all products without filtering
  } else if (category_id == OTHER_CATEGORY_ID) {
    return(products[is.na(products$category_id) | products$category_id == "", ])
  } else {
    return(products[products$category_id == category_id, ])
  }
}
```

### Excel Parameter Files
```
# First row in product_line.xlsx:
| id   | name_en      | name_zh   |
| "000" | "All Products" | "所有產品" |

# Last row in product_line.xlsx:
| id   | name_en      | name_zh   |
| "999" | "Other Products" | "其他產品" |
```

## Benefits
1. **Consistent Processing**: Enables reliable special case handling
2. **Clear Semantics**: Makes code more readable with obvious special cases
3. **Query Optimization**: Allows efficient database queries for common cases
4. **Sort Order**: Ensures predictable sorting in UI components
5. **Translation Support**: Special categories can be translated like regular ones

## Related Rules and Principles
- MP0034 (Special Treatment of "ALL" Category)
- P0015 (Dual ID Format)
- R0055 (Default Selection Conventions)
