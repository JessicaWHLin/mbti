$ErrorActionPreference = "Stop"

$workspacePath = (Get-Location).ProviderPath
$outputPath = Join-Path $workspacePath "Codex_MBTI_探索工具_15分鐘分享.pptx"
$tempOutputPath = Join-Path $env:TEMP "Codex_MBTI_探索工具_15分鐘分享.pptx"
if (Test-Path $tempOutputPath) {
  Remove-Item -LiteralPath $tempOutputPath -Force
}

$ppLayoutBlank = 12
$msoTextOrientationHorizontal = 1
$msoFalse = 0
$msoTrue = -1

function RgbColor($r, $g, $b) {
  return $r + ($g * 256) + ($b * 65536)
}

$colors = @{
  Ink = RgbColor 28 35 43
  Muted = RgbColor 92 103 115
  Line = RgbColor 217 224 232
  Blue = RgbColor 37 99 235
  Teal = RgbColor 13 148 136
  Amber = RgbColor 217 119 6
  Rose = RgbColor 225 29 72
  Green = RgbColor 22 163 74
  Paper = RgbColor 248 250 252
  White = RgbColor 255 255 255
  Navy = RgbColor 15 23 42
}

function Add-Text($slide, $text, $x, $y, $w, $h, $size = 20, $bold = $false, $color = $colors.Ink, $align = 1) {
  $shape = $slide.Shapes.AddTextbox($msoTextOrientationHorizontal, $x, $y, $w, $h)
  $shape.TextFrame.TextRange.Text = $text
  $shape.TextFrame.TextRange.Font.NameFarEast = "Microsoft JhengHei"
  $shape.TextFrame.TextRange.Font.Name = "Aptos"
  $shape.TextFrame.TextRange.Font.Size = $size
  $shape.TextFrame.TextRange.Font.Color.RGB = $color
  $shape.TextFrame.TextRange.Font.Bold = if ($bold) { $msoTrue } else { $msoFalse }
  $shape.TextFrame.TextRange.ParagraphFormat.Alignment = $align
  $shape.TextFrame.MarginLeft = 0
  $shape.TextFrame.MarginRight = 0
  $shape.TextFrame.MarginTop = 0
  $shape.TextFrame.MarginBottom = 0
  return $shape
}

function Add-Box($slide, $x, $y, $w, $h, $fill, $line = $colors.Line, $radius = $true) {
  $type = if ($radius) { 5 } else { 1 }
  $shape = $slide.Shapes.AddShape($type, $x, $y, $w, $h)
  $shape.Fill.ForeColor.RGB = $fill
  $shape.Line.ForeColor.RGB = $line
  $shape.Line.Weight = 1
  return $shape
}

function Add-Pill($slide, $text, $x, $y, $w, $fill, $color = $colors.White) {
  $pill = $slide.Shapes.AddShape(5, $x, $y, $w, 28)
  $pill.Fill.ForeColor.RGB = $fill
  $pill.Line.Visible = $msoFalse
  $pill.TextFrame.TextRange.Text = $text
  $pill.TextFrame.TextRange.Font.NameFarEast = "Microsoft JhengHei"
  $pill.TextFrame.TextRange.Font.Name = "Aptos"
  $pill.TextFrame.TextRange.Font.Size = 12
  $pill.TextFrame.TextRange.Font.Bold = $msoTrue
  $pill.TextFrame.TextRange.Font.Color.RGB = $color
  $pill.TextFrame.TextRange.ParagraphFormat.Alignment = 2
  $pill.TextFrame.VerticalAnchor = 3
  return $pill
}

function Add-Footer($slide, $page) {
  Add-Text $slide "Codex x MBTI 探索工具｜15 分鐘內部分享" 52 510 520 18 9 $false $colors.Muted | Out-Null
  Add-Text $slide $page 870 510 40 18 9 $false $colors.Muted 3 | Out-Null
}

function Add-Title($slide, $title, $subtitle = "") {
  Add-Text $slide $title 52 44 700 44 28 $true $colors.Ink | Out-Null
  if ($subtitle) {
    Add-Text $slide $subtitle 54 91 760 24 13 $false $colors.Muted | Out-Null
  }
}

function Add-Notes($slide, $notes) {
  try {
    $notesShape = $slide.NotesPage.Shapes.Placeholders(2)
    $notesShape.TextFrame.TextRange.Text = $notes
  } catch {
    # Notes are optional; some PowerPoint installations expose placeholders differently.
  }
}

$powerPoint = New-Object -ComObject PowerPoint.Application
$powerPoint.Visible = $msoTrue
$presentation = $powerPoint.Presentations.Add()
$presentation.PageSetup.SlideWidth = 960
$presentation.PageSetup.SlideHeight = 540

# Slide 1
$slide = $presentation.Slides.Add(1, $ppLayoutBlank)
$slide.Background.Fill.ForeColor.RGB = $colors.Navy
Add-Pill $slide "Internal Sharing｜15 min" 58 54 175 $colors.Teal | Out-Null
Add-Text $slide "用 Codex 打造`nMBTI 探索工具" 58 126 680 110 44 $true $colors.White | Out-Null
Add-Text $slide "從一個模糊想法，到可互動、可部署、可排錯的 Web App" 62 255 620 32 18 $false (RgbColor 203 213 225) | Out-Null
Add-Box $slide 690 92 190 300 (RgbColor 30 41 59) (RgbColor 51 65 85) | Out-Null
Add-Text $slide "Storyline" 718 125 120 24 16 $true $colors.White | Out-Null
Add-Text $slide "想法`n↓`n需求拆解`n↓`n前後端實作`n↓`n部署排錯`n↓`n協作心得" 718 168 120 175 18 $false (RgbColor 226 232 240) 2 | Out-Null
Add-Text $slide "Jessica Lin｜國泰金控 數據暨人工智慧發展部" 58 470 560 20 12 $false (RgbColor 203 213 225) | Out-Null
Add-Notes $slide "開場重點：這不是要做一個嚴肅心理測驗，而是用大家熟悉的題目測試 Codex 如何協助完成一個小型 Web App。"

# Slide 2
$slide = $presentation.Slides.Add(2, $ppLayoutBlank)
Add-Title $slide "為什麼做這個工具？" "用一個低風險、好理解、好展示的小題目，測試 AI 協作開發流程"
$items = @(
  @("容易共鳴", "MBTI 題材同事容易理解，也適合現場 Demo。", $colors.Blue),
  @("功能完整", "包含前端互動、抽題、計分、結果頁。", $colors.Teal),
  @("可驗證後端", "結果寫入 Netlify Database，能檢查部署是否真的成功。", $colors.Amber)
)
$x = 70
foreach ($item in $items) {
  Add-Box $slide $x 170 245 185 $colors.White $colors.Line | Out-Null
  Add-Pill $slide $item[0] ($x + 24) 195 92 $item[2] | Out-Null
  Add-Text $slide $item[1] ($x + 24) 245 190 70 18 $false $colors.Ink | Out-Null
  $x += 285
}
Add-Text $slide "核心問題：Codex 能不能把「我想做一個工具」轉成可以被使用、部署和維護的成品？" 80 405 800 28 18 $true $colors.Ink 2 | Out-Null
Add-Footer $slide "02"
Add-Notes $slide "這頁用來說明選題理由：不是工具本身多複雜，而是它涵蓋從產品到部署的一段完整流程。"

# Slide 3
$slide = $presentation.Slides.Add(3, $ppLayoutBlank)
Add-Title $slide "一開始給 Codex 的任務" "不用一次寫出完整規格，先把目標、限制和期待講清楚"
Add-Box $slide 70 140 360 260 (RgbColor 239 246 255) (RgbColor 191 219 254) | Out-Null
Add-Text $slide "我的自然語言需求" 95 165 240 24 20 $true $colors.Blue | Out-Null
Add-Text $slide "建立 MBTI 探索工具`n50 題題庫，每次隨機抽 30 題`n四個面向盡量平均`n輸入姓名後開始測驗`n顯示 MBTI 結果與職涯風格`n結果寫入 Netlify Database" 95 210 295 135 17 $false $colors.Ink | Out-Null
Add-Box $slide 510 140 360 260 (RgbColor 240 253 250) (RgbColor 153 246 228) | Out-Null
Add-Text $slide "Codex 協助收斂" 535 165 240 24 20 $true $colors.Teal | Out-Null
Add-Text $slide "拆出檔案結構`n建立前端流程`n設計題庫與結果資料`n補上 Netlify Functions`n產生 README 與部署說明`n後續協助排錯" 535 210 295 135 17 $false $colors.Ink | Out-Null
Add-Text $slide "心得：跟 Codex 合作時，可以先描述目標，再透過迭代逐步收斂細節。" 92 435 770 28 18 $true $colors.Ink 2 | Out-Null
Add-Footer $slide "03"
Add-Notes $slide "這頁強調 prompt 不必一開始完美。重點是把目標、平台、資料儲存和使用流程說清楚。"

# Slide 4
$slide = $presentation.Slides.Add(4, $ppLayoutBlank)
Add-Title $slide "Codex 拆出的系統架構" "從『一個工具』拆成前端、資料、後端與部署設定"
$layers = @(
  @("前端畫面", "index.html`ncss/style.css", 80, 165, $colors.Blue),
  @("互動邏輯", "js/app.js`n抽題、計分、結果呈現", 285, 165, $colors.Teal),
  @("內容資料", "data/questions.js`ndata/mbti-types.js", 490, 165, $colors.Amber),
  @("後端 API", "netlify/functions/results.js`n/api/results", 695, 165, $colors.Rose)
)
foreach ($layer in $layers) {
  Add-Box $slide $layer[2] $layer[3] 170 155 $colors.White $colors.Line | Out-Null
  Add-Pill $slide $layer[0] ($layer[2] + 24) ($layer[3] + 22) 120 $layer[4] | Out-Null
  Add-Text $slide $layer[1] ($layer[2] + 18) ($layer[3] + 72) 134 55 14 $false $colors.Ink 2 | Out-Null
}
Add-Text $slide "Netlify 部署設定：netlify.toml｜Database migration：mbti_results" 110 385 740 28 18 $true $colors.Ink 2 | Out-Null
Add-Footer $slide "04"
Add-Notes $slide "這頁說明 Codex 的價值：它把想法變成有分工的專案結構，不只是單段程式碼。"

# Slide 5
$slide = $presentation.Slides.Add(5, $ppLayoutBlank)
Add-Title $slide "實作亮點 1：互動測驗流程" "讓使用者可以真的完成一輪測驗，而不是只有靜態頁面"
$steps = @("輸入姓名", "隨機抽題", "逐題作答", "即時計分", "產出結果")
$x = 70
for ($i = 0; $i -lt $steps.Length; $i++) {
  Add-Box $slide $x 205 130 96 $colors.White $colors.Line | Out-Null
  Add-Text $slide ("0" + ($i + 1)) ($x + 20) 222 38 24 18 $true $colors.Blue | Out-Null
  Add-Text $slide $steps[$i] ($x + 20) 256 90 24 18 $true $colors.Ink 2 | Out-Null
  if ($i -lt $steps.Length - 1) {
    Add-Text $slide "→" ($x + 138) 238 40 30 24 $true $colors.Muted 2 | Out-Null
  }
  $x += 170
}
Add-Box $slide 110 365 740 64 (RgbColor 248 250 252) $colors.Line | Out-Null
Add-Text $slide "設計重點：每次從 50 題中抽 30 題，並讓 E/I、S/N、T/F、J/P 四個面向盡量平均。" 145 389 670 24 17 $false $colors.Ink 2 | Out-Null
Add-Footer $slide "05"
Add-Notes $slide "這頁可以搭配 Demo，快速讓大家看到工具的使用流程。"

# Slide 6
$slide = $presentation.Slides.Add(6, $ppLayoutBlank)
Add-Title $slide "實作亮點 2：從前端到後端" "前端只呼叫 API，由 Netlify Function 寫入 Netlify Database"
Add-Box $slide 65 165 190 130 (RgbColor 239 246 255) (RgbColor 191 219 254) | Out-Null
Add-Text $slide "Browser" 112 190 95 22 20 $true $colors.Blue 2 | Out-Null
Add-Text $slide "fetch('/api/results')" 92 238 135 22 14 $false $colors.Ink 2 | Out-Null
Add-Text $slide "→" 282 212 45 40 28 $true $colors.Muted 2 | Out-Null
Add-Box $slide 350 165 220 130 (RgbColor 240 253 250) (RgbColor 153 246 228) | Out-Null
Add-Text $slide "Netlify Functions" 386 190 150 22 20 $true $colors.Teal 2 | Out-Null
Add-Text $slide "results.js`n驗證與寫入集中在後端" 382 230 155 45 14 $false $colors.Ink 2 | Out-Null
Add-Text $slide "→" 595 212 45 40 28 $true $colors.Muted 2 | Out-Null
Add-Box $slide 665 165 220 130 (RgbColor 255 251 235) (RgbColor 253 230 138) | Out-Null
Add-Text $slide "Netlify Database" 695 190 160 22 20 $true $colors.Amber 2 | Out-Null
Add-Text $slide "mbti_results`n儲存姓名、類型、答案" 700 230 150 45 14 $false $colors.Ink 2 | Out-Null
Add-Text $slide "安全邊界：瀏覽器不直接碰資料庫，資料寫入統一經過 Netlify Function。" 95 380 770 28 18 $true $colors.Ink 2 | Out-Null
Add-Footer $slide "06"
Add-Notes $slide "這頁講技術邊界：前端只呼叫 API，資料庫連線由 Netlify Function 管理。"

# Slide 7
$slide = $presentation.Slides.Add(7, $ppLayoutBlank)
Add-Title $slide "真實狀況：部署後後端沒有啟用" "這段是最有價值的地方，因為它展示 Codex 如何協助排錯"
Add-Box $slide 80 150 340 230 (RgbColor 255 241 242) (RgbColor 254 205 211) | Out-Null
Add-Text $slide "症狀" 110 180 100 24 22 $true $colors.Rose | Out-Null
Add-Text $slide "網站可以開`n測驗流程看似正常`n但結果沒有寫入資料庫`n使用者只看到儲存失敗" 110 230 245 100 18 $false $colors.Ink | Out-Null
Add-Box $slide 540 150 340 230 (RgbColor 240 253 250) (RgbColor 153 246 228) | Out-Null
Add-Text $slide "排查方向" 570 180 140 24 22 $true $colors.Teal | Out-Null
Add-Text $slide "檢查 netlify.toml`n確認 Functions 目錄`n確認 /api/results redirect`n確認 Database 已初始化`n補健康檢查端點" 570 230 245 115 18 $false $colors.Ink | Out-Null
Add-Footer $slide "07"
Add-Notes $slide "這頁不要避開問題，反而要強調：真實開發最常花時間的是定位問題。Codex 可以一起看設定、看路徑、看錯誤。"

# Slide 8
$slide = $presentation.Slides.Add(8, $ppLayoutBlank)
Add-Title $slide "把排錯產品化：Health Check" "部署後先用一個 URL 判斷 Function 與環境變數狀態"
Add-Box $slide 95 150 770 70 (RgbColor 15 23 42) (RgbColor 15 23 42) | Out-Null
Add-Text $slide "https://你的-netlify網域/api/results?health=1" 125 174 710 24 20 $true $colors.White 2 | Out-Null
$checks = @(
  @("ok: true", "Function 已部署成功", $colors.Green),
  @("netlifyDatabaseConfigured: false", "資料庫尚未初始化或未連線", $colors.Amber),
  @("404", "Function 沒有被部署，檢查部署方式", $colors.Rose),
  @("500 database error", "檢查 migration、資料表與欄位", $colors.Blue)
)
$y = 260
foreach ($check in $checks) {
  Add-Pill $slide $check[0] 130 $y 180 $check[2] | Out-Null
  Add-Text $slide $check[1] 335 ($y + 3) 460 24 17 $false $colors.Ink | Out-Null
  $y += 45
}
Add-Footer $slide "08"
Add-Notes $slide "這頁講一個重要心得：不要只修掉當下問題，也要留下下次可以快速判斷的檢查機制。"

# Slide 9
$slide = $presentation.Slides.Add(9, $ppLayoutBlank)
Add-Title $slide "我的 5 個心得" "Codex 最有價值的地方，是把開發流程變成可互動的協作"
$takeaways = @(
  @("1", "需求可以先粗後細", "先描述目標，再逐步收斂規格。"),
  @("2", "它適合當技術共同作者", "一起拆結構、改程式、補文件、排錯。"),
  @("3", "越具體，產出越穩", "平台、資料表、流程講清楚會更準。"),
  @("4", "人仍然要判斷方向", "取捨、情境和品質標準仍由人掌握。"),
  @("5", "最好把排錯也產品化", "health check 讓問題可重複定位。")
)
$y = 138
foreach ($t in $takeaways) {
  Add-Box $slide 90 $y 70 48 (RgbColor 239 246 255) (RgbColor 191 219 254) | Out-Null
  Add-Text $slide $t[0] 112 ($y + 9) 26 24 20 $true $colors.Blue 2 | Out-Null
  Add-Text $slide $t[1] 190 ($y + 2) 300 22 18 $true $colors.Ink | Out-Null
  Add-Text $slide $t[2] 190 ($y + 27) 620 18 13 $false $colors.Muted | Out-Null
  $y += 67
}
Add-Footer $slide "09"
Add-Notes $slide "這頁是心得總結，可以每點用一句話帶過，把時間留給最後收束。"

# Slide 10
$slide = $presentation.Slides.Add(10, $ppLayoutBlank)
$slide.Background.Fill.ForeColor.RGB = $colors.Navy
Add-Text $slide "結語" 70 64 200 36 28 $true $colors.White | Out-Null
Add-Text $slide "這次 MBTI 工具不是重點本身，真正的重點是：" 72 140 690 32 20 $false (RgbColor 226 232 240) | Out-Null
Add-Text $slide "我們可以用 Codex 更快地把一個想法做成`n可以被看見、可以被測試、可以被迭代的東西。" 72 205 800 95 32 $true $colors.White | Out-Null
Add-Box $slide 72 360 815 70 (RgbColor 30 41 59) (RgbColor 51 65 85) | Out-Null
Add-Text $slide "Demo 建議：輸入姓名 → 回答幾題 → 看結果頁 → 開 /api/results?health=1" 105 384 755 22 18 $false (RgbColor 226 232 240) 2 | Out-Null
Add-Text $slide "Q&A" 790 470 95 28 22 $true $colors.Teal 3 | Out-Null
Add-Notes $slide "最後用這句話收束：Codex 讓我把時間從空白開始寫，轉移到判斷要做什麼、怎麼驗證、怎麼改善。"

$presentation.SaveAs($tempOutputPath)
Copy-Item -LiteralPath $tempOutputPath -Destination $outputPath -Force

try {
  $presentation.Close()
} catch {
  Write-Warning "PowerPoint saved the file, but closing the presentation returned a COM warning: $($_.Exception.Message)"
}

try {
  $powerPoint.Quit()
} catch {
  Write-Warning "PowerPoint saved the file, but quitting PowerPoint returned a COM warning: $($_.Exception.Message)"
}

Write-Host "Created: $outputPath"
