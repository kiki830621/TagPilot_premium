---
issue: "ISSUE_118"
title: "缺少上期相比功能"
severity: "medium"
component: "marketing_vital_signs"
created: "2025-09-08"
status: "in_progress"
original_source: "曼巴儀表板問題_20250807"
---

## Problem
缺上期相比功能。

## Expected Behavior
- 顯示與上期的比較
- 變化率或差異值
- 趨勢指示（上升/下降）

## Actual Behavior
- 沒有期間比較功能
- 無法看到變化趨勢

## Proposed Resolution
1. 增加期間選擇功能
2. 計算期間變化率
3. 加入趨勢箭頭指示
4. 提供同比/環比選項

## Detailed Implementation Plan (2025-09-22)

### 重要更新：實際需求澄清
使用者要求直接在現有 Marketing Vital Signs 的 KPI 卡片上加入上期比較功能，而非創建獨立的比較組件。

### 背景分析
參考 kitchenMAMA 版本的實作（`macro_overview.R`），發現關鍵功能包括：
- **直接整合在卡片**：在每個 KPI value box 中顯示與上期比較
- **自動計算差異**：current_period_data vs previous_period_data
- **視覺化指標**：使用箭頭圖標和百分比顯示變化趨勢

### 技術挑戰
1. **資料同步**：確保不同時間段資料的一致性
2. **計算複雜度**：大量資料的時間段比較需要優化
3. **UI/UX 設計**：清晰展示多個時間段的對比

### 實施方案（修正版）

#### 1. 修改現有 KPI Box 組件
更新 `fn_create_kpi_box.R` 以支援期間比較：
```r
# 增強版 KPI Box 包含比較功能
createKpiBoxWithComparison <- function(ns, title, value_id,
                                      diff_id, perc_id,
                                      prev_value_id = NULL) {
  value_box(
    title = title,
    value = div(
      textOutput(ns(value_id)),  # 當前值
      if (!is.null(prev_value_id)) {
        tags$small(
          class = "text-muted",
          "上期：", textOutput(ns(prev_value_id), inline = TRUE)
        )
      }
    ),
    showcase = uiOutput(ns(diff_id)),  # 趨勢箭頭
    p("變化率：", span(textOutput(ns(perc_id), inline = TRUE)))
  )
}
```

#### 2. 資料處理層（參考 kitchenMAMA 實作）
```r
# 獲取當前期資料
current_period_data <- reactive({
  sales_data <- data_source$sales_by_time_state()
  latest_time <- max(sales_data$time_scale, na.rm = TRUE)
  sales_data %>% filter(time_scale == latest_time)
})

# 獲取上期資料
previous_period_data <- reactive({
  sales_data <- data_source$sales_by_time_state()
  time_periods <- sort(unique(sales_data$time_scale), decreasing = TRUE)
  if (length(time_periods) >= 2) {
    previous_time <- time_periods[2]
    sales_data %>% filter(time_scale == previous_time)
  } else {
    NULL
  }
})
```

#### 3. Server 邏輯實作
```r
# 計算差異並渲染
observe({
  curr <- current_period_data()
  prev <- previous_period_data()

  # 渲染當前值
  output$total_now <- renderText({
    format(sum(curr$total, na.rm = TRUE), big.mark = ",")
  })

  # 計算並渲染差異
  if (!is.null(prev) && nrow(prev) > 0) {
    total_diff <- sum(curr$total) - sum(prev$total)
    total_diff_perc <- total_diff / sum(prev$total)

    # 渲染趨勢箭頭
    output$total_diff <- renderUI({
      if (total_diff >= 0) {
        bs_icon("graph-up-arrow", class = "text-success")
      } else {
        bs_icon("graph-down-arrow", class = "text-danger")
      }
    })

    # 渲染百分比
    output$total_diff_perc <- renderText({
      scales::percent(total_diff_perc, accuracy = 0.1)
    })
  }
})
```

#### 4. 整合到現有 Marketing Vital Signs
```r
# 修改現有的 KPI 卡片定義
vbs <- list(
  createKpiBoxWithComparison(
    ns = ns,
    title = "Monetary Value (RFM-M)",
    value_id = "monetary_value",
    diff_id = "monetary_diff",
    perc_id = "monetary_perc",
    prev_value_id = "monetary_prev"  # 新增：顯示上期值
  ),
  createKpiBoxWithComparison(
    ns = ns,
    title = "Frequency (RFM-F)",
    value_id = "frequency_value",
    diff_id = "frequency_diff",
    perc_id = "frequency_perc",
    prev_value_id = "frequency_prev"
  ),
  # ... 其他 KPI 卡片
)
```

### 整合步驟（修正版）

1. **更新 fn_create_kpi_box.R**：
   - 加入 `createKpiBoxWithComparison` 函數
   - 支援顯示上期值和變化率

2. **修改 Marketing Vital Signs 組件**：
   - 更新 Server 邏輯以計算當前期和上期資料
   - 加入差異計算邏輯
   - 渲染趨勢指標（箭頭、百分比）

3. **更新 UI 定義**：
   - 將現有的 `value_box` 替換為 `createKpiBoxWithComparison`
   - 確保每個 KPI 都有對應的 diff_id 和 perc_id

### 預期成果

1. **功能完整性**：
   - ✅ 支援多種比較類型（環比、同比、自訂）
   - ✅ 靈活的滾動期數選擇（1-12期）
   - ✅ 清晰的視覺化呈現

2. **效能優化**：
   - ✅ 使用向量化運算提升計算效率
   - ✅ 資料快取減少重複查詢
   - ✅ 響應式更新確保流暢體驗

3. **符合 MAMBA 原則**：
   - ✅ R09: UI-Server-Defaults 三元組
   - ✅ R92: Universal DBI 資料存取
   - ✅ MP30: 向量化運算
   - ✅ MP47: 函數式編程

### 測試計劃
```bash
# 執行單元測試
Rscript scripts/global_scripts/98_test/test_period_comparison.R

# 整合測試
Rscript scripts/test_integration_period_comparison.R
```

### 時程估計（修正版）
- 第一階段（1天）：修改 KPI Box 組件加入比較功能
- 第二階段（2天）：整合到 Marketing Vital Signs
- 第三階段（1天）：測試與調整
- 總計：4個工作天

### 關鍵差異（與原始方案比較）
- **不是獨立組件**：直接修改現有 KPI 卡片
- **整合在卡片內**：上期值和變化率顯示在同一個 value box
- **自動計算**：Server 自動獲取前期資料並計算差異
- **視覺化簡潔**：使用箭頭和顏色表示趨勢，不需要額外圖表

## Priority
Medium - 分析功能增強

## Related Issues
- ISSUE_120