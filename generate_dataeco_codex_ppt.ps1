$ErrorActionPreference = "Stop"

$workspacePath = (Get-Location).ProviderPath
$outputPath = Join-Path $workspacePath "Codex_MBTI_探索工具_15分鐘分享_DataEco版.pptx"
$tempOutputPath = Join-Path $env:TEMP "Codex_MBTI_探索工具_15分鐘分享_DataEco版.pptx"
$cathayIconPath = Join-Path $workspacePath "cathay icon.png"
if (Test-Path $tempOutputPath) { Remove-Item -LiteralPath $tempOutputPath -Force }

$ppLayoutBlank = 12
$msoTextOrientationHorizontal = 1
$msoFalse = 0
$msoTrue = -1

function RgbColor($r, $g, $b) { return $r + ($g * 256) + ($b * 65536) }

$colors = @{
  GreenDark = RgbColor 0 135 92
  Green = RgbColor 0 177 117
  GreenMid = RgbColor 48 199 139
  GreenLight = RgbColor 135 225 177
  Mint = RgbColor 226 250 213
  Yellow = RgbColor 235 255 93
  Ink = RgbColor 17 17 17
  Muted = RgbColor 86 96 106
  Line = RgbColor 224 224 224
  White = RgbColor 255 255 255
  SidebarGray = RgbColor 244 244 244
}

function Add-Text($slide, $text, $x, $y, $w, $h, $size = 20, $bold = $false, $color = $colors.Ink, $align = 1) {
  $shape = $slide.Shapes.AddTextbox($msoTextOrientationHorizontal, $x, $y, $w, $h)
  $shape.TextFrame.TextRange.Text = $text
  $shape.TextFrame.TextRange.Font.NameFarEast = "Microsoft JhengHei"
  $shape.TextFrame.TextRange.Font.Name = "Arial"
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

function Add-Circle($slide, $x, $y, $size, $fill, $transparency = 0) {
  $shape = $slide.Shapes.AddShape(9, $x, $y, $size, $size)
  $shape.Fill.ForeColor.RGB = $fill
  $shape.Fill.Transparency = [single]$transparency
  $shape.Line.Visible = $msoFalse
  return $shape
}

function Add-CathayIcon($slide, $x, $y, $w, $withBackground = $false) {
  if (-not (Test-Path $cathayIconPath)) {
    throw "Missing icon file: $cathayIconPath"
  }

  $h = $w * 43 / 174
  if ($withBackground) {
    $bg = Add-Box $slide ($x - 5) ($y - 4) ($w + 10) ($h + 8) $colors.GreenDark $colors.GreenDark $true
    $bg.Line.Visible = $msoFalse
  }
  $pic = $slide.Shapes.AddPicture($cathayIconPath, $msoFalse, $msoTrue, $x, $y, $w, $h)
  return $pic
}

function Add-CoverBackground($slide) {
  $slide.Background.Fill.ForeColor.RGB = $colors.Green
  $rect = $slide.Shapes.AddShape(1, 0, 0, 960, 540)
  $rect.Fill.ForeColor.RGB = $colors.Green
  $rect.Fill.TwoColorGradient(1, 1)
  $rect.Fill.ForeColor.RGB = $colors.GreenLight
  $rect.Fill.BackColor.RGB = $colors.GreenDark
  $rect.Line.Visible = $msoFalse
  Add-Circle $slide 395 -205 690 $colors.GreenDark 0.18 | Out-Null
  Add-Circle $slide -155 -110 470 $colors.GreenLight 0.18 | Out-Null
  Add-Circle $slide 240 125 710 $colors.GreenLight 0.22 | Out-Null
}

function Add-DataEcoShell($slide, $sectionTitle) {
  $slide.Background.Fill.ForeColor.RGB = $colors.White
  $bar = $slide.Shapes.AddShape(1, 0, 0, 62, 540)
  $bar.Fill.ForeColor.RGB = $colors.SidebarGray
  $bar.Line.Visible = $msoFalse
  $top = $slide.Shapes.AddShape(1, 0, 0, 62, 270)
  $top.Fill.ForeColor.RGB = $colors.GreenMid
  $top.Line.Visible = $msoFalse
  Add-Circle $slide -45 45 185 $colors.GreenDark 0.25 | Out-Null
  Add-Circle $slide -55 150 210 $colors.Green 0.23 | Out-Null
  $v = Add-Text $slide $sectionTitle -8 42 100 18 10 $false $colors.White 2
  $v.Rotation = 90
  Add-CathayIcon $slide 9 500 46 $true | Out-Null
}

function Add-Title($slide, $title, $subtitle = "") {
  Add-Text $slide $title 135 72 620 38 25 $true $colors.Ink | Out-Null
  if ($subtitle) { Add-Text $slide $subtitle 136 122 680 28 13 $false $colors.Muted | Out-Null }
}

function Add-Tag($slide, $text, $x, $y, $fill = $colors.Green) {
  $tag = Add-Box $slide $x $y 104 30 $fill $fill $true
  $tag.TextFrame.TextRange.Text = $text
  $tag.TextFrame.TextRange.Font.NameFarEast = "Microsoft JhengHei"
  $tag.TextFrame.TextRange.Font.Name = "Arial"
  $tag.TextFrame.TextRange.Font.Size = 12
  $tag.TextFrame.TextRange.Font.Bold = $msoTrue
  $tag.TextFrame.TextRange.Font.Color.RGB = $colors.White
  $tag.TextFrame.TextRange.ParagraphFormat.Alignment = 2
  $tag.TextFrame.VerticalAnchor = 3
}

function Add-Notes($slide, $notes) {
  try { $slide.NotesPage.Shapes.Placeholders(2).TextFrame.TextRange.Text = $notes } catch {}
}

$powerPoint = New-Object -ComObject PowerPoint.Application
$powerPoint.Visible = $msoTrue
$presentation = $powerPoint.Presentations.Add()
$presentation.PageSetup.SlideWidth = 960
$presentation.PageSetup.SlideHeight = 540

# 1 Cover
$slide = $presentation.Slides.Add(1, $ppLayoutBlank)
Add-CoverBackground $slide
Add-Text $slide "用 Codex 打造" 88 120 440 42 36 $true $colors.White | Out-Null
Add-Text $slide "MBTI 探索工具" 88 172 520 50 42 $true $colors.White | Out-Null
Add-Text $slide "從一個模糊想法，到可互動、可部署、可排錯的 Web App" 91 252 570 26 17 $true $colors.Yellow | Out-Null
Add-Text $slide "國泰金控　數據暨人工智慧發展部　Jessica Lin" 88 485 560 20 11 $false $colors.White | Out-Null
Add-CathayIcon $slide 735 486 125 | Out-Null
Add-Text $slide "DataEco" 878 489 70 18 10 $false $colors.White | Out-Null
Add-Notes $slide "開場：說明這不是要做嚴肅心理測驗，而是用大家熟悉的題材測試 Codex 如何協助完成一個小型 Web App。"

# 2 Why
$slide = $presentation.Slides.Add(2, $ppLayoutBlank)
Add-DataEcoShell $slide "Background"
Add-Title $slide "為什麼做這個工具？" "用低風險、好理解、好展示的小題目，測試 AI 協作開發流程"
$cards = @(
  @("容易共鳴", "MBTI 題材同事容易理解，也適合現場 Demo。"),
  @("功能完整", "包含前端互動、抽題、計分、結果頁。"),
  @("可驗證後端", "結果寫入 Netlify Database，能檢查部署是否真的成功。")
)
$x = 136
foreach ($c in $cards) {
  Add-Box $slide $x 205 215 135 $colors.Mint $colors.Mint | Out-Null
  Add-Text $slide $c[0] ($x + 24) 230 160 25 20 $true $colors.Ink | Out-Null
  Add-Text $slide $c[1] ($x + 24) 273 160 44 13 $false $colors.Ink | Out-Null
  $x += 245
}
Add-Text $slide "核心問題：Codex 能不能把「我想做一個工具」轉成可以被使用、部署和維護的成品？" 145 405 700 25 17 $true $colors.GreenDark 2 | Out-Null
Add-Notes $slide "選題理由：工具本身不必很複雜，但它涵蓋從產品到部署的一段完整流程。"

# 3 Prompt
$slide = $presentation.Slides.Add(3, $ppLayoutBlank)
Add-DataEcoShell $slide "Prompt"
Add-Title $slide "一開始給 Codex 的任務" "先把目標、限制和期待講清楚，再透過迭代逐步收斂"
Add-Box $slide 135 170 330 235 $colors.White $colors.Line | Out-Null
Add-Tag $slide "我的需求" 158 195
Add-Text $slide "建立 MBTI 探索工具`n50 題題庫，每次隨機抽 30 題`n四個面向盡量平均`n輸入姓名後開始測驗`n顯示 MBTI 結果與職涯風格`n結果寫入 Netlify Database" 158 245 265 130 15 $false $colors.Ink | Out-Null
Add-Box $slide 535 170 330 235 $colors.White $colors.Line | Out-Null
Add-Tag $slide "Codex 收斂" 558 195 $colors.GreenDark
Add-Text $slide "拆出檔案結構`n建立前端流程`n設計題庫與結果資料`n補上 Netlify Functions`n產生 README 與部署說明`n後續協助排錯" 558 245 265 130 15 $false $colors.Ink | Out-Null
Add-Notes $slide "強調 prompt 不必一開始完美。重點是把目標、平台、資料儲存和使用流程說清楚。"

# 4 Architecture
$slide = $presentation.Slides.Add(4, $ppLayoutBlank)
Add-DataEcoShell $slide "Structure"
Add-Title $slide "Codex 拆出的系統架構" "從「一個工具」拆成前端、資料、後端與部署設定"
$items = @(
  @("前端畫面", "index.html`ncss/style.css", 145),
  @("互動邏輯", "js/app.js`n抽題、計分、結果呈現", 335),
  @("內容資料", "data/questions.js`ndata/mbti-types.js", 525),
  @("後端 API", "netlify/functions/results.js`n/api/results", 715)
)
foreach ($it in $items) {
  Add-Circle $slide ($it[2] + 45) 190 78 $colors.GreenMid | Out-Null
  Add-Text $slide $it[0] $it[2] 290 170 24 17 $true $colors.Ink 2 | Out-Null
  Add-Text $slide $it[1] $it[2] 323 170 48 12 $false $colors.Muted 2 | Out-Null
}
Add-Text $slide "Netlify 部署設定：netlify.toml　｜　Database migration：mbti_results" 145 420 700 24 16 $true $colors.GreenDark 2 | Out-Null
Add-Notes $slide "Codex 把想法變成有分工的專案結構，不只是單段程式碼。"

# 5 Interaction
$slide = $presentation.Slides.Add(5, $ppLayoutBlank)
Add-DataEcoShell $slide "Flow"
Add-Title $slide "實作亮點 1：互動測驗流程" "讓使用者可以真的完成一輪測驗，而不是只有靜態頁面"
$steps = @("輸入姓名", "隨機抽題", "逐題作答", "即時計分", "產出結果")
$x = 140
for ($i = 0; $i -lt $steps.Length; $i++) {
  Add-Circle $slide $x 210 86 $(if ($i -eq 4) { $colors.GreenDark } else { $colors.GreenMid }) | Out-Null
  Add-Text $slide ("0" + ($i + 1)) ($x + 27) 230 32 24 18 $true $colors.White 2 | Out-Null
  Add-Text $slide $steps[$i] ($x - 15) 320 116 22 15 $true $colors.Ink 2 | Out-Null
  if ($i -lt $steps.Length - 1) { Add-Text $slide "—" ($x + 102) 238 50 25 24 $false $colors.Line 2 | Out-Null }
  $x += 145
}
Add-Box $slide 180 395 650 52 $colors.Mint $colors.Mint | Out-Null
Add-Text $slide "每次從 50 題中抽 30 題，並讓 E/I、S/N、T/F、J/P 四個面向盡量平均。" 212 411 585 20 15 $true $colors.GreenDark 2 | Out-Null
Add-Notes $slide "可搭配 Demo，快速讓大家看到工具的使用流程。"

# 6 Backend
$slide = $presentation.Slides.Add(6, $ppLayoutBlank)
Add-DataEcoShell $slide "API"
Add-Title $slide "實作亮點 2：從前端到後端" "前端只呼叫 API，由 Netlify Function 寫入 Netlify Database"
$api = @(
  @("Browser", "fetch('/api/results')", 145),
  @("Netlify Functions", "results.js`n驗證與寫入集中在後端", 390),
  @("Netlify Database", "mbti_results`n儲存姓名、類型、答案", 675)
)
foreach ($a in $api) {
  Add-Box $slide $a[2] 200 180 105 $colors.Mint $colors.Mint | Out-Null
  Add-Text $slide $a[0] ($a[2] + 20) 225 140 22 18 $true $colors.GreenDark 2 | Out-Null
  Add-Text $slide $a[1] ($a[2] + 20) 263 140 32 12 $false $colors.Ink 2 | Out-Null
}
Add-Text $slide "→" 342 232 34 30 24 $true $colors.GreenDark 2 | Out-Null
Add-Text $slide "→" 618 232 34 30 24 $true $colors.GreenDark 2 | Out-Null
Add-Text $slide "安全邊界：瀏覽器不直接碰資料庫，資料寫入統一經過 Netlify Function。" 155 405 720 24 16 $true $colors.GreenDark 2 | Out-Null
Add-Notes $slide "講技術邊界：前端只呼叫 API，資料庫連線由 Netlify Function 管理。"

# 7 Troubleshooting
$slide = $presentation.Slides.Add(7, $ppLayoutBlank)
Add-DataEcoShell $slide "Issue"
Add-Title $slide "真實狀況：部署後後端沒有啟用" "這段展示 Codex 如何協助定位問題"
Add-Box $slide 145 185 310 205 $colors.White $colors.Line | Out-Null
Add-Tag $slide "症狀" 168 210 $colors.GreenDark
Add-Text $slide "網站可以開`n測驗流程看似正常`n但結果沒有寫入資料庫`n使用者只看到儲存失敗" 168 262 235 82 16 $false $colors.Ink | Out-Null
Add-Box $slide 545 185 310 205 $colors.Mint $colors.Mint | Out-Null
Add-Tag $slide "排查方向" 568 210
Add-Text $slide "檢查 netlify.toml`n確認 Functions 目錄`n確認 /api/results redirect`n確認 Database 已初始化`n補健康檢查端點" 568 262 235 100 16 $false $colors.Ink | Out-Null
Add-Notes $slide "不要避開問題，真實開發最常花時間的是定位問題。Codex 可以一起看設定、看路徑、看錯誤。"

# 8 Health Check
$slide = $presentation.Slides.Add(8, $ppLayoutBlank)
Add-DataEcoShell $slide "Check"
Add-Title $slide "把排錯產品化：Health Check" "部署後先用一個 URL 判斷 Function 與環境變數狀態"
Add-Box $slide 145 165 700 58 $colors.GreenDark $colors.GreenDark | Out-Null
Add-Text $slide "https://你的-netlify網域/api/results?health=1" 170 184 650 20 18 $true $colors.White 2 | Out-Null
$checks = @(
  @("ok: true", "Function 已部署成功"),
  @("netlifyDatabaseConfigured: false", "資料庫尚未初始化或未連線"),
  @("404", "Function 沒有被部署，檢查部署方式"),
  @("500 database error", "檢查 migration、資料表與欄位")
)
$y = 260
foreach ($c in $checks) {
  Add-Circle $slide 165 ($y - 5) 24 $colors.GreenMid | Out-Null
  Add-Text $slide $c[0] 210 $y 215 20 15 $true $colors.GreenDark | Out-Null
  Add-Text $slide $c[1] 430 $y 380 20 15 $false $colors.Ink | Out-Null
  $y += 42
}
Add-Notes $slide "重點：不要只修掉當下問題，也要留下下次可以快速判斷的檢查機制。"

# 9 Takeaways
$slide = $presentation.Slides.Add(9, $ppLayoutBlank)
Add-DataEcoShell $slide "Learning"
Add-Title $slide "我的 5 個心得" "Codex 最有價值的地方，是把開發流程變成可互動的協作"
$takes = @(
  @("01", "需求可以先粗後細", "先描述目標，再逐步收斂規格。"),
  @("02", "它適合當技術共同作者", "一起拆結構、改程式、補文件、排錯。"),
  @("03", "越具體，產出越穩", "平台、資料表、流程講清楚會更準。"),
  @("04", "人仍然要判斷方向", "取捨、情境和品質標準仍由人掌握。"),
  @("05", "最好把排錯也產品化", "health check 讓問題可重複定位。")
)
$y = 155
foreach ($t in $takes) {
  Add-Text $slide $t[0] 150 $y 50 20 16 $true $colors.GreenDark | Out-Null
  Add-Text $slide $t[1] 220 $y 245 20 17 $true $colors.Ink | Out-Null
  Add-Text $slide $t[2] 490 $y 350 20 13 $false $colors.Muted | Out-Null
  $line = $slide.Shapes.AddShape(1, 145, ($y + 34), 700, 1)
  $line.Fill.ForeColor.RGB = $colors.Line
  $line.Line.Visible = $msoFalse
  $y += 58
}
Add-Notes $slide "每點用一句話帶過，把時間留給最後收束。"

# 10 Closing
$slide = $presentation.Slides.Add(10, $ppLayoutBlank)
Add-CoverBackground $slide
Add-Text $slide "結語" 90 80 200 36 30 $true $colors.White | Out-Null
Add-Text $slide "這次 MBTI 工具不是重點本身，真正的重點是：" 92 150 720 30 20 $true $colors.Yellow | Out-Null
Add-Text $slide "我們可以用 Codex 更快地把一個想法做成`n可以被看見、可以被測試、可以被迭代的東西。" 92 220 800 95 31 $true $colors.White | Out-Null
Add-Box $slide 92 388 760 58 $colors.GreenDark $colors.GreenDark | Out-Null
Add-Text $slide "Demo：輸入姓名 → 回答幾題 → 看結果頁 → 開 /api/results?health=1" 125 407 700 20 17 $true $colors.White 2 | Out-Null
Add-CathayIcon $slide 735 486 125 | Out-Null
Add-Text $slide "Q&A" 800 84 85 28 24 $true $colors.White 3 | Out-Null
Add-Notes $slide "用這句話收束：Codex 讓我把時間從空白開始寫，轉移到判斷要做什麼、怎麼驗證、怎麼改善。"

$presentation.SaveAs($tempOutputPath)
Copy-Item -LiteralPath $tempOutputPath -Destination $outputPath -Force

try { $presentation.Close() } catch { Write-Warning "Saved, but closing returned a COM warning: $($_.Exception.Message)" }
try { $powerPoint.Quit() } catch { Write-Warning "Saved, but quitting returned a COM warning: $($_.Exception.Message)" }

Write-Host "Created: $outputPath"
