# R126 .env 檔案撰寫與管理標準

## 目標
提供專案成員一套統一的環境變數 (.env/.Renviron) 撰寫規範，確保本機、CI、與 Posit Connect 部署行為一致，同時避免憑證外洩。

---

## 命名規範
1. 變數一律使用 **全大寫 + 底線**，不得含空白。  
   範例：`OPENAI_API_KEY`, `PGHOST`, `AWS_ACCESS_KEY_ID`
2. 金鑰/密碼類變數以 `_KEY` / `_SECRET` / `_PASSWORD` 結尾。
3. 日期、布林須存為字串，如 `FEATURE_FLAG="true"`。

---

## 格式
```
# comments 以 # 開頭
KEY=value            # 無空白且值不含空白時可不加引號
KEY_WITH_SPACE="some value"   # 值含空白需雙引號
SPECIAL='p@$$word!'            # 含特殊符號亦建議引號
```

常見錯誤：
* `KEY = value`  ← 等號兩側有空白，部分解析器會留下前導空白。
* `KEY="value`  ← 引號未關閉。

---

## 專案策略
1. **程式碼中統一** `Sys.getenv("OPENAI_API_KEY")` 取值。  
   已移除歷史的 `OPENAI_API_KEY_LIN` 後綴。
2. 本機開發：
   * 建議在專案根 `.Renviron` 或 `~/.Renviron` 設定環境變數；
   * `.env` 僅作為參考範例，務必列入 `.gitignore`。
3. CI / Docker：
   * 在 Runner 或容器的環境變數機制注入同名 key。
4. Posit Connect：
   * 透過 **Variable Set** 為各 App 指派 `OPENAI_API_KEY`；
   * 同一內容重新部署不需重設變數。

---

## 安全要求
* `.Renviron`/`.env` 不可提交到 Git；已在根 `.gitignore` 中列入。  
* 在 PR / log 輸出時避免 `print(Sys.getenv("OPENAI_API_KEY"))`。
* 若需示範，使用 `sk-xxxxxxxx` 假值。

---

## 範例 `.env`
```
# OpenAI
OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# PostgreSQL
PGHOST=db.example.com
PGPORT=5432
PGUSER=insightforge
PGPASSWORD="super secret"
PGDATABASE=prod_db
```

---

## 關聯原則
* 參考 R075_test_script_initialization.md：測試前載入環境變數
* 參考 R095_import_requirements_rule.md：依賴管理與敏感資訊 