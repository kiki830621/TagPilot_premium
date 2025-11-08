---
issue: "ISSUE_107"
title: "不適當變數顯示與缺乏中文說明"
severity: "medium"
component: "brand_positioning"
created: "2025-09-08"
status: "RESOLVED"
resolved: "2025-09-08"
original_source: "曼巴儀表板問題_20250807"
---

## Problem
1. 台中？NATION_na、is_missing等變數不適合納入
2. use_oil等變數應搭配中文說明
3. 品牌類別分析定義不明

## Expected Behavior
- 排除無意義的地理和缺失值變數
- 提供變數的中文說明
- 清楚定義品牌類別分析

## Actual Behavior
- 包含不適當的變數
- 缺乏中文說明
- 品牌類別分析意義不明

## Proposed Resolution
1. 建立變數黑名單機制
2. 加入變數中文對照表
3. 明確定義品牌類別分析
4. 改善變數命名規則

## Priority
Medium - 可用性問題

## Related Issues
- ISSUE_123

## Resolution Details
**Date Resolved**: 2025-09-08
**Resolved By**: MAMBA Debugging Agent

### Solution Implemented

1. **Integrated Centralized Filter System**
   - Connected `positionStrategy.R` to use `fn_filter_covariates.R`
   - Leverages `list_covariate_neglected.yaml` configuration
   - Automatically excludes variables matching patterns:
     - `.*_na$` (catches NATION_na)
     - `.*is_missing.*` (catches is_missing variables)
     - `.*_id$` (catches eby_item_id)
     - URL patterns, temporary variables, etc.

2. **Created Chinese Label System**
   - Added `variable_chinese_labels.yaml` with comprehensive translations
   - Created `fn_get_variable_label.R` helper function
   - Provides Chinese labels for common attributes like:
     - use_oil → "使用油"
     - temperature_control → "溫度控制"
     - price → "價格"

3. **Files Modified**
   - `/scripts/global_scripts/10_rshinyapp_components/position/positionStrategy/positionStrategy.R`
   - Created: `/scripts/global_scripts/global_data/parameters/scd_type2/variable_chinese_labels.yaml`
   - Created: `/scripts/global_scripts/04_utils/fn_get_variable_label.R`

4. **Testing**
   - All problematic variables now correctly filtered
   - Chinese labels functioning properly
   - Backward compatibility maintained with fallback logic

### Principle Compliance
- ✅ **MP064**: Now uses centralized ETL filtering instead of component-level logic
- ✅ **R116**: Leverages existing utility functions
- ✅ **MP047**: Functional programming approach with reusable filter functions

---

## Additional Enhancement (2025-09-08)

### Extended Filter Rules Added
Based on further requirements, enhanced `list_covariate_neglected.yaml` with additional regex patterns:

#### Brand-Related Filters (Lines 194-206)
```yaml
brand_patterns:
  - pattern: ".*brand.*"
    description: "Any variable containing 'brand' anywhere"
    case_sensitive: false
  - pattern: ".*manufacturer.*"
    description: "Manufacturer-related fields (similar to brand)"
    case_sensitive: false
  - pattern: ".*vendor.*"
    description: "Vendor-related fields"
    case_sensitive: false
```

#### Type-Related Filters (Lines 208-224)
```yaml
type_patterns:
  - pattern: ".*type.*"
    description: "Any variable containing 'type' anywhere"
    case_sensitive: false
  - pattern: ".*category.*"
    description: "Category-related fields (similar to type)"
    case_sensitive: false
  - pattern: ".*class.*"
    description: "Classification-related fields"
    case_sensitive: false
  - pattern: ".*kind.*"
    description: "Kind-related fields (similar to type)"
    case_sensitive: false
```

### Impact
These additional filters ensure that:
- Brand-related variables (brand_name, product_brand, manufacturer_id) are excluded
- Type-related variables (product_type, item_type, category_id) are excluded
- Positioning analysis focuses on product attributes rather than categorical identifiers
- Cleaner, more focused strategy analysis without noise from classification variables

### Testing Coverage
Added test cases to validate new patterns:
- `brand_name`, `product_brand` → Correctly filtered
- `manufacturer_id` → Correctly filtered
- `product_type`, `item_type` → Correctly filtered
- `category_id` → Correctly filtered

This enhancement further improves the robustness of the variable filtering system, ensuring only relevant product attributes are included in positioning and strategy analyses.