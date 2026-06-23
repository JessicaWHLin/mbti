# MBTI 探索工具

這是一個部署在 Netlify 的 MBTI 測驗網站。使用者完成測驗後，結果會自動寫入後端，結果頁可以看到所有使用者的姓名與 MBTI 類型。

## 我們採用的版本

本專案維持「自動記錄版」：

```text
前端測驗頁
→ Netlify Function
→ Netlify Database（built-in feature）
→ 結果總覽頁
```

不使用 CSV 手動維護，也不使用舊的 Netlify DB extension。

## 重要提醒

Netlify 已停止透過舊的 Netlify DB extension 建立新資料庫。現在要使用 Netlify 內建的 Database 功能。

如果看到這類訊息：

```text
New database creation via the Netlify DB extension is no longer available.
Netlify Database is now available as a built-in feature.
```

請改到 Netlify site 後台使用 built-in Database，不要再找 extension 安裝流程。

## 為什麼需要 Netlify Function + Database

因為我們希望達成：

- 使用者完成測驗後，自動儲存結果
- 不需要人工複製資料
- 結果頁可以看到所有已送出的結果
- 使用者不需要登入後台

本專案使用：

- `Netlify Function`：接收使用者送出的結果
- `Netlify Database`：保存所有人的測驗結果
- `@netlify/database`：Function 內用來連接 built-in Database 的套件

## 使用者流程

1. 使用者打開 MBTI 測驗網站。
2. 輸入姓名。
3. 回答 30 題。
4. 網站顯示 MBTI 結果。
5. 系統自動把姓名與 MBTI 結果寫入 Netlify Database。
6. 使用者可以點「查看所有結果」。
7. 結果頁顯示所有使用者的姓名與 MBTI 類型。

## 專案結構

```text
.
├── index.html
├── results.html
├── netlify.toml
├── package.json
├── css/
│   └── style.css
├── js/
│   ├── app.js
│   └── results.js
├── data/
│   ├── questions.js
│   └── mbti-types.js
└── netlify/
    ├── database/
    │   └── migrations/
    │       └── 001_create_mbti_results/
    │           └── migration.sql
    └── functions/
        └── results.js
```

## Netlify 後台設定步驟

1. 到 Netlify 後台，進入這個 site。
2. 確認這個 site 是從 Git repository 部署，不是只用拖拉資料夾部署。
3. 在 site 後台找到 Netlify Database 的 built-in 功能。
4. 建立或啟用 Database。
5. 重新部署網站，建議使用 `Clear cache and deploy site`。
6. 確認 Function 有成功部署。

## API 路徑

前端送出測驗結果：

```text
POST /api/results
```

結果頁讀取所有結果：

```text
GET /api/results
```

健康檢查：

```text
GET /api/results?health=1
```

## 資料表

資料會寫入 `mbti_results`。

主要欄位：

| 欄位 | 用途 |
| --- | --- |
| `name` | 使用者姓名 |
| `type` | MBTI 結果 |
| `created_at` | 建立時間 |

保留的分析欄位：

| 欄位 | 用途 |
| --- | --- |
| `totals` | 四個面向分數 |
| `question_ids` | 本次抽到的題目 |
| `answers` | 使用者答案 |

## 部署後測試

先開健康檢查：

```text
https://你的-netlify網址/api/results?health=1
```

成功時會看到：

```json
{
  "ok": true,
  "function": "results",
  "netlifyDatabaseConfigured": true
}
```

再測完整流程：

1. 打開網站首頁。
2. 輸入姓名。
3. 完成測驗。
4. 確認結果頁有顯示 MBTI。
5. 點「查看所有結果」。
6. 確認剛剛的姓名與 MBTI 類型出現在列表中。

## 常見錯誤

### `neon is not a function`

代表 Function 使用了舊的 client 寫法。

目前專案已改成 built-in Netlify Database 寫法：

```js
const { getDatabase } = await import("@netlify/database")
const db = getDatabase()
await db.sql`select 1`
```

請重新部署最新版本。

### `relation "mbti_results" does not exist`

代表 Database 已連上，但資料表尚未建立。

請確認 migration 有被套用，或在 Netlify Database 裡建立 `mbti_results` table。

### 結果頁讀取失敗

通常代表：

- Function 沒有部署成功
- Database 沒有啟用
- Database 沒有和目前 site 綁定
- 資料表尚未建立

## 結論

本專案維持自動記錄版：

```text
Netlify Function + built-in Netlify Database
```

這是目前比較適合「自動保存所有使用者結果」的做法。
