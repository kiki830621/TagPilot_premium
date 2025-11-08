---
issue: "ISSUE_106"
title: "策略分析顯示數量錯誤"
severity: "high"
component: "brand_positioning"
created: "2025-09-08"
status: "resolved"
assigned_to: "Development Team"
resolved_date: "2025-09-22"
resolution_notes: "Implemented MK03 principle with cross-attribute average method for dynamic factor selection"
original_source: "曼巴儀表板問題_20250807"
---

## Problem
策略分析應該出現的是8個，而非26個全上在散點圖上。

## Expected Behavior
- 只顯示8個關鍵策略點
- 清晰的散點圖呈現
- 聚焦重要策略因素

## Actual Behavior
- 26個點全部顯示
- 散點圖過於擁擠
- 無法識別關鍵點

## Resolution (解決方案)

### 根本原因分析

#### 問題檔案位置
- **主要檔案**: `positionStrategy/positionStrategy.R`
- **問題程式碼**: 第 119-130 行

#### 算法邏輯缺陷
與 ISSUE_105 不同，此問題使用「全正理想值」邏輯：

```r
# 有問題的算法（第 119-130 行）
# 計算每個變數是否為「正向理想」
positive_ideal <- ideal_row[numeric_cols] > 0 & !is.na(ideal_row[numeric_cols])

# 所有正向理想變數都被視為關鍵因子
if (any(positive_ideal)) {
  key_factors <- names(numeric_cols)[positive_ideal]
} else {
  key_factors <- numeric_cols[1:min(8, length(numeric_cols))]
}
```

#### 為什麼會選出過多因子

1. **邏輯錯誤問題**：
   - 只要理想值 > 0 就算「關鍵因子」
   - 大部分屬性的理想值都是正數
   - 例：26個屬性中可能有24個都有正向理想值

2. **實際數字案例**：
   ```
   總屬性數：26個
   正向理想值屬性：約24個
   
   結果：24個被選為關鍵因子
   問題：應該只選8個最重要的因子
   ```

3. **業務邏輯錯誤**：
   - 原邏輯：「有正向目標的都重要」
   - 正確邏輯：「競爭優勢最明顯的因子」
   - 缺失：無法區分重要性程度

4. **與 ISSUE_105 的差異**：
   - ISSUE_105：門檻值選擇問題（threshold-based）
   - ISSUE_106：正向篩選問題（positive filtering）
   - 共同結果：都產生過多關鍵因子（26個）
   - 共同影響：策略分析失去焦點

### 業務影響分析

#### 散點圖視覺化問題
1. **視覺混亂**：26個點擠在散點圖上無法識別
2. **策略迷失**：無法聚焦最重要的8個策略因子
3. **決策困難**：使用者無法從中獲得清晰的策略洞察

#### 策略分析失效
1. **優先級混淆**：無法識別最核心的差異化要素
2. **資源分散**：可能投入次要的改進領域
3. **競爭分析失準**：包含了不重要的屬性

### 修復內容

#### 新算法：適配 ISSUE_105 的 Top-N 選擇法
```r
# 計算各因子重要性（可以基於多種標準）
col_importance <- sapply(numeric_cols, function(col) {
  ideal_val <- ideal_row[[col]][1]
  if (is.na(ideal_val) || ideal_val <= 0) return(0)
  
  # 計算該因子的重要性分數
  # 可結合理想值大小、變異程度等
  return(abs(ideal_val))  # 簡單版本：使用理想值絕對值
})

# 選擇前 N 個最重要的因子
sorted_factors <- sort(col_importance, decreasing = TRUE)
n_factors_to_select <- min(8, length(sorted_factors))  # 固定選8個
key_factors <- names(sorted_factors[1:n_factors_to_select])
```

#### 算法優勢
1. **可預測性**：永遠精確選出8個關鍵因子
2. **重要性排序**：基於量化標準選擇最重要的因子
3. **業務導向**：直接回答「最重要的8個策略點是什麼」
4. **視覺化友善**：散點圖只顯示真正關鍵的8個點

#### 與 ISSUE_105 的一致性
- 使用相同的 Top-N 選擇原理
- 確保兩個組件的行為一致
- 提升整個系統的策略分析品質

### 測試驗證計劃
- 驗證散點圖只顯示8個關鍵點
- 確認關鍵點是按重要性選出的
- 檢查策略分析的清晰度和實用性
- 與 ISSUE_105 修復後的 IdealRate 組件保持一致

### 修復優先級
- 高優先級：視覺化核心功能失效
- 直接影響：策略決策品質
- 修復複雜度：中等（可參考 ISSUE_105 成功經驗）

### 2025-09-22 最終修復

根據 principle-explorer 分析，ISSUE_106 需要獨立修復（不會因 ISSUE_105 而自動解決）：

#### 修正內容（第 573-589 行）
1. **移除舊邏輯**：不再使用 `ideal_val > 0` 的簡單判斷
2. **實施 MK03 原則**：
   - 提取理想點向量
   - 計算跨屬性平均：`cross_attr_avg = mean(valid_ideal)`
   - 選擇超過平均的因子：`valid_ideal > cross_attr_avg`

#### 關鍵程式碼
```r
# MK03 principle: Use cross-attribute average as threshold
cross_attr_avg <- mean(valid_ideal, na.rm = TRUE)
key_factors <- names(valid_ideal[valid_ideal > cross_attr_avg])
```

#### 與 ISSUE_105 的一致性
- 兩個組件現在都使用 MK03 原則的跨屬性平均方法
- 確保了理想點分析和策略分析的一致性
- 散點圖視覺化得到改善（完全動態，反映真實數據特徵）

## Priority
High - 視覺化和策略分析核心功能失效

## Related Issues
- ISSUE_105 (已修復，採用相同的 MK03 原則), ISSUE_129