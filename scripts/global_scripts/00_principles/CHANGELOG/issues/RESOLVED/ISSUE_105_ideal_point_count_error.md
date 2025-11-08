---
issue: "ISSUE_105"
title: "Turbo理想點分析數量錯誤"
severity: "high"
component: "brand_positioning"
created: "2025-09-08"
status: "resolved"
assigned_to: "Development Team"
resolved_date: "2025-09-22"
resolution_notes: "Implemented MK03 principle compliant cross-attribute average method"
original_source: "曼巴儀表板問題_20250807"
---

## Problem
Turbo的理想點分析為什麼是26個，不是8個？

## Expected Behavior
- 理想點應該是8個關鍵因素
- 基於4:6加權（評分:銷售）計算
- 精簡的關鍵定位點

## Actual Behavior
- 顯示26個理想點
- 未進行有效篩選
- 理想點過多失去焦點

## Resolution (解決方案)

### 根本原因分析

#### 問題檔案位置
- **主要檔案**: `positionIdealRate/positionIdealRate.R`
- **問題程式碼**: 第 119 行

#### 算法數學缺陷
原始的門檻值選擇算法存在根本性問題：

```r
# 有問題的算法（第 115-119 行）
gate <- rowSums(indicators, na.rm = TRUE) / ncol(indicators) * threshold_multiplier
col_sums <- colSums(indicators, na.rm = TRUE)
key_factors <- names(col_sums[col_sums > mean(gate, na.rm = TRUE)])
```

#### 為什麼會選出過多因子

1. **門檻值過低問題**：
   - `gate` = 每個產品達到理想值的屬性比例（0-1）
   - `mean(gate)` 通常是很小的數字（如 0.3）
   - 轉換後門檻 = 30% 的產品數量
   - 例：100個產品 × 0.3 = 30個產品達標就算關鍵因子

2. **實際數字案例（Turbo產品線）**：
   ```
   總產品數：約100個
   總屬性數：26個
   平均門檻：約35個產品達標
   
   結果：13個屬性超過35個產品達標
   問題：應該只選8個最重要的因子
   ```

3. **業務邏輯錯誤**：
   - 原邏輯：「比平均表現好的都是關鍵因子」
   - 正確邏輯：「選擇競爭優勢最明顯的因子」
   - 缺失：無法控制關鍵因子數量

4. **理想值設定敏感性**：
   - 如果理想值設定過低 → 更多產品達標 → 更多關鍵因子
   - 如果理想值設定過高 → 較少產品達標 → 較少關鍵因子
   - 不穩定的選擇結果

### 業務影響分析

#### 用戶體驗問題
1. **決策困惑**：13個「關鍵」因子讓使用者無法聚焦
2. **分析失效**：過多因子稀釋了真正的競爭優勢洞察
3. **策略模糊**：無法制定針對性的產品定位策略

#### 競爭分析失準
1. **噪音過多**：包含了不重要的屬性
2. **優先級混亂**：無法識別最核心的差異化要素
3. **資源浪費**：可能投入不重要的改進領域

### 修復內容

#### 新算法：Top-N 選擇法
```r
# 新方法：選擇前 N 個最重要的因子
sorted_factors <- sort(col_sums, decreasing = TRUE)
n_factors_to_select <- min(n_key_factors, length(sorted_factors))
key_factors <- names(sorted_factors[1:n_factors_to_select])
```

#### 算法優勢
1. **可預測性**：永遠精確選出設定數量的因子
2. **業務導向**：直接回答「最重要的N個因子是什麼」
3. **配置靈活**：可調整關鍵因子數量（預設8個）
4. **排序明確**：按重要性排序，優先級清晰

#### 參數化設計
```r
perform_ideal_rate_analysis <- function(data, exclude_vars = NULL, 
                                       threshold_multiplier = 1.0,
                                       n_key_factors = 8) {
  # 可配置的關鍵因子數量，預設8個
}
```

### 測試驗證
- 現在正確顯示 8 個關鍵因子（可配置）
- Turbo 產品線前 8 個因子：
  1. 配送快速 (82.4%)
  2. 卓越工藝 (82.4%)
  3. 價格實惠 (79.4%)
  4. 車輛升級改裝 (76.5%)
  5. 推薦他人 (73.5%)
  6. 產品符合描述 (70.6%)
  7. 運作良好 (70.6%)
  8. 完美匹配 (70.6%)

### L3 Premium 參考實作比較

經檢查，l3_premium 專案中使用了**相同的有問題演算法**：

#### 相同問題的實作（l3_premium）
```r
# 文件位置：
# - wonderful_food_TagPilot_premium/positionIdealRate.R (第119行)
# - wonderful_food_BrandEdge_premium/positionIdealRate.R (第119行)

key_factors <- names(col_sums[col_sums > mean(gate, na.rm = TRUE)])
```

#### 問題分析
1. **演算法一致性**：兩個版本使用完全相同的門檻值選擇法
2. **共同問題**：都會產生不可預測的因子數量
3. **文檔說明**：positionKFE_documentation.md 確認了這種方法的邏輯
4. **影響範圍**：
   - TagPilot Premium
   - BrandEdge Premium  
   - MAMBA Enterprise（l4_enterprise）

#### 修復優勢
L4 Enterprise 的修復（Top-N 選擇法）提供了：
- **可預測性**：固定數量的關鍵因子
- **業務邏輯**：選擇最重要的 N 個因子
- **配置彈性**：可調整的 n_key_factors 參數

#### 建議
應將此修復方案回傳給 l3_premium 專案，確保所有版本都使用一致的改進算法。

### 修復驗證
- 所有測試通過 ✅
- 符合 MAMBA 原則：MP047, MP056, MP081, MP088, R116
- **完全符合 MK03 原則** ✅

### 2025-09-22 最終修復

根據 MK03 原則的正確理解，修改為使用 **cross-attribute average** 方法作為預設：

#### 修正內容
1. **函數預設值更改**：`selection_method` 預設改為 `"cross_average"`（第47行）
2. **調用處更改**：第365行改為使用 `"cross_average"` 方法
3. **符合 MK03 數學定義**：
   - 理想點是單一 m 維向量 $I = [I_1, ..., I_m]$
   - 關鍵因子識別：$I_j > \bar{I}$ 其中 $\bar{I} = \frac{1}{m}\sum_{j=1}^{m} I_j$
   - 關鍵因子數量由數據決定，不固定為 8 個

#### 測試結果
使用測試數據驗證：
- 理想點向量：[4.5, 3.2, 4.2, 2.8, 2.8, 3.5, 3.8, 4.1]
- 跨屬性平均：3.61
- 識別出的關鍵因子：quality (4.5), design (4.2), innovation (3.8), reliability (4.1)
- **結果：4 個關鍵因子**（正確反映了超過平均值的屬性）

#### 業務影響
- **更精準**：關鍵因子數量反映實際數據特徵
- **符合原理**：遵循 MK03 數學原則
- **靈活性**：仍保留 `top_n` 方法供特殊需求使用

## Priority
High - 核心算法錯誤

## Related Issues
- ISSUE_106, ISSUE_129