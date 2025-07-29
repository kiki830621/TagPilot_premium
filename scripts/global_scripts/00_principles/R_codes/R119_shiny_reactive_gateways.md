---
id: "R119"
title: "Shiny Reactive Gateways"
type: "rule"
date_created: "2025-05-14"
date_modified: "2025-05-14"
author: "Claude"
related_to:
  - "MP52": "Unidirectional Data Flow"
  - "MP53": "Feedback Loop"
  - "P76": "Error Handling Patterns"
---

# R119: Shiny Reactive Gateways

以下以 Shiny 的反應式（reactive）語境為主，整理最常見的反應式「閘門」工具：`isolate()`、`req()`、`validate()`/`need()`，以及容易搞混的 `observeEvent(ignoreInit / ignoreNULL)`。每段皆附「典型使用時機」與「常見誤區」，方便快速對照。

## 1　概念速記

| 工具 | 作用核心 | 常見別名／對應思維 |
|------|----------|-------------------|
| `isolate(expr)` | 斷開依賴：在計算 expr 時，不建立對其中 reactive 物件的監聽 | 「只是偷看，不追蹤」 |
| `req(..., cancelOutput = TRUE)` | 守門：任何引數為 NULL / FALSE / "" / NA 時，立即終止本次反應式執行 | 「先確定條件有貨，再往下跑」 |
| `validate( need(cond , msg) , … )` | 表單驗證：條件不符就把 msg 回傳到 UI 而非整段報錯 | 「溫和阻斷並提示使用者」 |

## 2　isolate() —— 偷看值、不想觸發依賴

### 用法

```r
observe({
  input$a               # ← 建立依賴
  val <- isolate(input$b)  # ← 不建立依賴
  output$txt <- renderText(val)
})
```

### 典型時機

| 場景 | 說明 |
|------|------|
| 初始化時先讀一次 reactive | 例如模組啟動時抓 config() 初始值後，就不想讓它再觸發 |
| 批量更新 UI 時 | 在一個 observeEvent 裏呼叫多個 update*Input()，需讀其他 input 卻不希望這些 input 變動就重跑 |
| 計算中途引用但不想形成依賴 | e.g. `reactive({ input$x + isolate(input$y) })` 只讓 x 變動時重算 |

### 常見誤區

1. 把整個 reactive pipeline 掐死
   * 若後續仍希望「外層條件變 → 內層資料重抓」，就不能 isolate 外層。
   * ⇨ 改用 req() 或 validate() 做條件式，而不是 isolate 整個來源。

2. isolate 放在 observeEvent() 裡
   * `observeEvent(input$btn, { isolate({...}) })` 幾乎等同直接 `{...}`，且更易混亂；通常不需要。

## 3　req() —— 條件不滿足就停止（靜默或輸出 NULL）

### 用法

```r
data_r <- reactive({
  req(input$file)        # 檔案未上傳時直接停在這
  read.csv(input$file$datapath)
})

output$table <- renderTable({
  req(data_r())          # 上一步還沒準備好先別畫
  head(data_r())
})
```

### 典型時機

| 場景 | 說明 |
|------|------|
| 依賴對象尚未準備好 | 上傳檔案、URL 回傳、DB 連線皆可能晚於 UI 繪製 |
| 避免 NULL 下游爆 error | 簡化 `if (is.null(x)) return(NULL)` 的大量重複敘述 |
| 多條件一次檢查 | `req(input$a, input$b, nrow(df) > 0)` |

### 常見誤區

1. 想顯示自訂訊息卻用 req()
   * req() 只會靜默取消，UI 端看到是空白。若想顯示文字或提示，改用 validate()/need()。

2. 把 req() 放 observeEvent() 外層
   * 在 observeEvent 的 handler 內用 req() 即可；若放外層反而可能阻斷監聽。

## 4　validate() / need() —— 給使用者看的溫柔守門

### 用法

```r
output$plot <- renderPlot({
  validate(
    need(!is.null(input$file), "請先上傳檔案"),
    need(nrow(df()) > 0,      "檔案沒有資料")
  )
  hist(df()$value)
})
```

### 典型時機

| 場景 | 說明 |
|------|------|
| 表單或篩選必選字段 | 缺少輸入時直接在輸出框顯示訊息 |
| 資料檢核 | 數量不足、類型錯誤先阻斷並提示 |
| 替代 showNotification 的同步提示 | 不需額外彈窗，訊息顯示位置更直觀 |

## 5　observeEvent(..., ignoreInit / ignoreNULL) —— 別讓「一開始」或「空值」觸發

| 參數 | 預設 | 功能 |
|------|------|------|
| ignoreInit | FALSE | TRUE 時不在初始化立即執行一次 |
| ignoreNULL | FALSE | TRUE 時遇到 NULL 不觸發 |

```r
observeEvent(input$run_btn, {
  ...                 # 按鈕被點才跑
}, ignoreInit = TRUE)
```

若你的行為依賴下拉選單第一次傳來 NULL，記得不要設 `ignoreNULL = TRUE`，否則後面選擇同樣值也不會被偵測到。

## 6　實戰心法速查

| 你想做的事 | 建議工具／寫法 |
|------------|----------------|
| 僅初始化時偷看值 | `val <- isolate(config())` （只用一次） |
| 等待輸入就緒才往下 | `req(input$file)` |
| 缺資料時顯示「請選擇…」 | `validate( need(nrow(df()) > 0, "尚無資料") )` |
| 按鈕點擊才計算，且不要初始觸發 | `observeEvent(input$btn, {...}, ignoreInit = TRUE)` |
| 批次更新多個 UI，但不想讓它們互相觸發 | 外層 observeEvent 依主事件，內部讀其他 inputs 用 isolate() |

## 小結

1. isolate()：切依賴，不要用在需要隨時間更新的上游資料。
2. req()：硬條件守門；不滿足就靜默返回。
3. validate()/need()：守門 + 提示訊息。
4. ignoreInit / ignoreNULL：控制 observeEvent 的觸發時機。

把這些「小閘門」放對位置，就能避免重算風暴與空值爆錯，也讓使用者得到即時且友善的回饋。祝開發順利！