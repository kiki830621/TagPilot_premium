---
issue: "ISSUE_113"
title: "品牌名稱顯示空白"
severity: "low"
component: "brand_positioning"
created: "2025-09-08"
status: "resolved"
resolved_date: "2025-09-22"
resolution_notes: "Fixed empty string handling in brand field, added validation and transparency logging"
original_source: "曼巴儀表板問題_20250807"
---

## Problem
一個品牌空掉，沒有顯示名稱。

## Expected Behavior
- 所有品牌都應顯示名稱
- 若無名稱應顯示預設值或提示

## Actual Behavior
- 某個品牌位置空白
- 無任何提示

## Resolution (已解決)

### 根本原因
Item ID 185889598631 的品牌欄位是**空字串** (`""`)，不是 `NA`。原程式碼只處理 `NA` 值，導致空字串通過驗證但顯示為空白。

### 修復內容

#### 1. fn_process_position_table.R (第 163 行)
```r
# 修復前
brand = dplyr::na_if(brand, NA_character_)

# 修復後
brand = dplyr::na_if(brand, "")  # 先處理空字串
brand = tidyr::replace_na(brand, "UNKNOWN")
```

#### 2. positionTable.R
- 增加品牌欄位驗證
- 空字串轉為 "UNKNOWN"
- 增加透明度記錄（MP106）
- 符合輸入驗證原則（MP114）

### 測試驗證
- ✅ 空字串正確轉換
- ✅ 空資料行被過濾
- ✅ 透明度記錄運作正常

## Priority
Low - 顯示問題

## Related Issues
None