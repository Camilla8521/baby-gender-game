# 猜猜寶寶性別｜網站發布指南

## 這個資料夾包含
- `index.html`：奶油白＋金色網站前端
- `supabase_setup.sql`：資料表及基本權限設定
- `README.md`：發布步驟

## 1. 建立 Supabase 資料庫
1. 前往 https://supabase.com 建立帳號和新專案。
2. 開啟 SQL Editor，貼上 `supabase_setup.sql` 全文並執行。
3. 到 Authentication → Users，新增主持人 Email 和密碼。
4. 複製主持人使用者的 UUID，回到 SQL Editor 執行（替換 UUID）：
   ```sql
   update public.baby_events
   set host_id = '貼上主持人使用者UUID'
   where id = 'baby-shower-2026';
   ```
5. 在 Project Settings → API（或 Connect）複製 Project URL 及 anon/publishable key。
6. 開啟 `index.html`，找到以下兩行並替換：
   `const SUPABASE_URL="YOUR_SUPABASE_PROJECT_URL",SUPABASE_ANON_KEY="YOUR_SUPABASE_ANON_KEY"...`
   將 URL 和 key 換成自己的值。只能使用 anon/publishable key，絕不可放 service_role/secret key。

## 2. 上傳到 GitHub
1. 登入 https://github.com
2. 右上角 `+` → `New repository`。
3. Repository name 可填 `baby-gender-game`，選 `Public`，按 `Create repository`。
4. 在新 repository 頁面按 `Add file` → `Upload files`。
5. 上傳 `index.html`、`supabase_setup.sql`、`README.md`，按 `Commit changes`。

## 3. 用 Vercel 發布
1. 前往 https://vercel.com，使用 GitHub 帳號註冊／登入。
2. 按 `Add New` → `Project`，選取 `baby-gender-game` repository。
3. Framework Preset 選 `Other`；Build Command 留空，Output Directory 填 `.`（如有此欄）。
4. 按 Deploy。完成後取得 `https://專案名稱.vercel.app` 公開網址。
5. 用手機開網址測試投票，再把網址轉成 QR Code 分享。

## 4. 活動當天
- 親友打開網站，輸入暱稱、選男寶寶或女寶寶、送出投票。
- 主持人使用已建立的帳號登入網站底部控制台。
- 先進行實體揭曉，確認答案後才按網站上的揭曉按鈕。
- 所有人頁面會同步看到答案。

## 重要限制
這是入門 MVP：以瀏覽器 localStorage 降低同裝置重複投票；換裝置或清除資料仍可能重投。50 人上限目前是前端限制，並非伺服器端強制。資料表為統計而允許讀取投票紀錄，熟悉 API 的人可能讀取暱稱及選項。若需要嚴格防重投票或高度隱私，應升級成伺服器端驗證/Edge Function。揭曉前不會預先儲存答案。
