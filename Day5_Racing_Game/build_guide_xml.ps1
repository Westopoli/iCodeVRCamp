Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

$outPath = Join-Path $PSScriptRoot "EscapeSimulator_RoomEditor_Guide.docx"
$tmp = Join-Path $env:TEMP "guide_docx_$(Get-Random)"
New-Item -ItemType Directory -Force $tmp | Out-Null
New-Item -ItemType Directory -Force "$tmp\_rels" | Out-Null
New-Item -ItemType Directory -Force "$tmp\word" | Out-Null
New-Item -ItemType Directory -Force "$tmp\word\_rels" | Out-Null

# ============================================================
# XML helpers
# ============================================================

function rpr([string]$font="Segoe UI", [int]$szHalfPt=22, [bool]$bold=$false, [string]$color="000000", [string]$altFont="") {
    $b = if ($bold) { "<w:b/><w:bCs/>" } else { "" }
    $af = if ($altFont -ne "") { $altFont } else { $font }
    "<w:rPr><w:rFonts w:ascii=`"$font`" w:hAnsi=`"$af`"/><w:sz w:val=`"$szHalfPt`"/><w:szCs w:val=`"$szHalfPt`"/>$b<w:color w:val=`"$color`"/></w:rPr>"
}

function run([string]$text, [string]$font="Segoe UI", [int]$szHalfPt=22, [bool]$bold=$false, [string]$color="000000") {
    $safe = $text -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;' -replace '"','&quot;'
    "<w:r>$(rpr $font $szHalfPt $bold $color)<w:t xml:space=`"preserve`">$safe</w:t></w:r>"
}

function runCode([string]$text) {
    $safe = $text -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;'
    "<w:r><w:rPr><w:rFonts w:ascii=`"Courier New`" w:hAnsi=`"Courier New`"/><w:sz w:val=`"20`"/><w:szCs w:val=`"20`"/><w:color w:val=`"000000`"/></w:rPr><w:t xml:space=`"preserve`">$safe</w:t></w:r>"
}

function para([string]$inner, [string]$align="left", [int]$spaceBefore=0, [int]$spaceAfter=80, [string]$shade="") {
    $al = if ($align -eq "center") { "<w:jc w:val=`"center`"/>" } else { "" }
    $sp = "<w:spacing w:before=`"$spaceBefore`" w:after=`"$spaceAfter`"/>"
    $sh = if ($shade -ne "") { "<w:shd w:val=`"clear`" w:color=`"auto`" w:fill=`"$shade`"/>" } else { "" }
    "<w:p><w:pPr>$al$sp$sh</w:pPr>$inner</w:p>"
}

function h1([string]$text) {
    para (run $text "Segoe UI" 40 $true "1F3864") "left" 160 80
}

function h2([string]$text) {
    para (run $text "Segoe UI" 26 $true "1F3864") "left" 120 60
}

function body([string]$text) {
    para (run $text) "left" 0 80
}

function bullet([string]$text) {
    $r = run "  - " "Segoe UI" 22 $false "000000"
    $r += run $text
    para $r "left" 0 60
}

function step([int]$n, [string]$text) {
    $r = run "  $n.  " "Segoe UI" 22 $true "000000"
    $r += run $text
    para $r "left" 0 60
}

function callout([string]$label, [string]$text, [string]$labelColor) {
    $p1 = para (run $label "Segoe UI" 22 $true $labelColor) "left" 80 40
    $p2 = para (run $text) "left" 0 80
    $p1 + $p2
}

function pageBreak() {
    "<w:p><w:r><w:rPr><w:rFonts w:ascii=`"Segoe UI`" w:hAnsi=`"Segoe UI`"/></w:rPr><w:br w:type=`"page`"/></w:r></w:p>"
}

function emptyPara() {
    para "" "left" 0 80
}

function chainPara([string]$text) {
    $r = runCode "  $text"
    para $r "left" 40 40
}

function bugPara([string]$symptom, [string]$fix) {
    $pad = $symptom.PadRight(40)
    $r = runCode "  $pad -> $fix"
    para $r "left" 0 40
}

# Table helpers
function tcell([string]$text, [bool]$bold=$false, [string]$color="000000", [string]$fill="FFFFFF", [bool]$header=$false) {
    $sz = if ($header) { 22 } else { 20 }
    $c = if ($header) { "FFFFFF" } else { $color }
    $r = run $text "Segoe UI" $sz $bold $c
    $p = "<w:p><w:pPr><w:spacing w:before=`"40`" w:after=`"40`"/></w:pPr>$r</w:p>"
    "<w:tc><w:tcPr><w:shd w:val=`"clear`" w:color=`"auto`" w:fill=`"$fill`"/></w:tcPr>$p</w:tc>"
}

function trow([string[]]$cells, [string[]]$fills, [bool]$header=$false, [bool[]]$bolds=$null) {
    $inner = ""
    for ($i = 0; $i -lt $cells.Count; $i++) {
        $fill = if ($null -ne $fills -and $i -lt $fills.Count) { $fills[$i] } else { "FFFFFF" }
        $bold = if ($null -ne $bolds -and $i -lt $bolds.Count) { $bolds[$i] } else { $false }
        $inner += tcell $cells[$i] $bold "000000" $fill $header
    }
    "<w:tr>$inner</w:tr>"
}

$TBLBORDER = @"
<w:tblBorders>
  <w:top w:val="single" w:sz="4" w:space="0" w:color="1F3864"/>
  <w:left w:val="single" w:sz="4" w:space="0" w:color="1F3864"/>
  <w:bottom w:val="single" w:sz="4" w:space="0" w:color="1F3864"/>
  <w:right w:val="single" w:sz="4" w:space="0" w:color="1F3864"/>
  <w:insideH w:val="single" w:sz="4" w:space="0" w:color="1F3864"/>
  <w:insideV w:val="single" w:sz="4" w:space="0" w:color="1F3864"/>
</w:tblBorders>
"@

function tblWrap([string]$rows, [string]$colWidths) {
    $grid = ($colWidths -split ",") | ForEach-Object { "<w:gridCol w:w=`"$_`"/>" }
    $gridXml = $grid -join ""
    "<w:tbl><w:tblPr><w:tblW w:w=`"9360`" w:type=`"dxa`"/>$TBLBORDER<w:tblLook w:val=`"04A0`"/></w:tblPr><w:tblGrid>$gridXml</w:tblGrid>$rows</w:tbl>"
}

$HDR_FILL = "1F3864"
$ALT_FILL = "E7E6E6"
$WH_FILL  = "FFFFFF"

# ============================================================
# Build document body
# ============================================================

$body = ""

# ── PAGE 1: COVER ──────────────────────────────────────────

$body += para "" "center" 0 200  # top space

$coverTitle = run "Escape Simulator" "Segoe UI" 72 $true "1F3864"
$body += para $coverTitle "center" 0 60

$coverSub = run "Room Editor -- Quick Reference" "Segoe UI" 44 $false "000000"
$body += para $coverSub "center" 0 160

$body += para (run "Keep this guide at your desk all day." "Segoe UI" 26 $false "000000") "center" 0 40
$body += para (run "Every mechanic you need is on these pages." "Segoe UI" 26 $false "000000") "center" 0 200

$body += para (run "CONTENTS" "Segoe UI" 22 $true "000000") "center" 0 60

$contentsLines = @(
    "Page 2   The 3 Physics Modes",
    "Page 3   Keys and Doors",
    "Page 4   Hiding Items in Containers",
    "Page 5   Combination Locks",
    "Page 6   Buttons",
    "Page 7   Win Condition (The Finish Object)",
    "Page 8   Quick Tips and Stuck-Point Guide"
)
foreach ($l in $contentsLines) {
    $body += para (run $l "Segoe UI" 22 $false "000000") "center" 0 40
}

$body += para "" "center" 200 0
$body += para (run "iCode VR Camp -- Day 5" "Segoe UI" 18 $false "808080") "center" 0 0

$body += pageBreak

# ── PAGE 2: THE 3 PHYSICS MODES ────────────────────────────

$body += h1 "Page 2   The 3 Physics Modes"
$body += body "Every object in your room has exactly one physics mode. Getting this wrong is the #1 cause of puzzles that don't work."
$body += emptyPara

# Physics mode table
$r1 = trow @("MODE","WHAT PLAYERS CAN DO","USE IT FOR") @($HDR_FILL,$HDR_FILL,$HDR_FILL) $true @($true,$true,$true)
$r2 = trow @("STATIC","Can't touch it at all","Walls, floors, ceiling, furniture, decorations") @($WH_FILL,$WH_FILL,$WH_FILL) $false @($true,$false,$false)
$r3 = trow @("DRAGGABLE","Can push and slide it around","Boxes, clutter, objects players need to move") @($ALT_FILL,$ALT_FILL,$ALT_FILL) $false @($true,$false,$false)
$r4 = trow @("PICKABLE","Can pick it up and carry it","Keys, notes, items that get collected or used") @($WH_FILL,$WH_FILL,$WH_FILL) $false @($true,$false,$false)
$body += tblWrap ($r1+$r2+$r3+$r4) "1500,2600,5260"
$body += emptyPara

$body += callout "WARNING -- Is Obstacle" "For any container (chest, cabinet, drawer, safe) you MUST check Is Obstacle in its properties panel. Without it, players can grab items through the walls of the container -- the puzzle becomes unsolvable." "CC0000"
$body += para (run "QUICK CHECK before playtesting:" "Segoe UI" 22 $true "008000") "left" 0 60
$body += bullet "Keys and collectible items -- PICKABLE"
$body += bullet "Moveable clutter -- DRAGGABLE"
$body += bullet "Everything else -- STATIC"
$body += bullet "All containers -- Is Obstacle checked"

$body += pageBreak

# ── PAGE 3: KEYS AND DOORS ─────────────────────────────────

$body += h1 "Page 3   Keys and Doors"
$body += body "Goal: Player finds a key -- picks it up -- uses it on a slot -- door opens."
$body += emptyPara
$body += h2 "What you need"
$body += bullet "A Key object  (any key prop from the object library)"
$body += bullet "A Slot  (the receiver that the key clicks into)"
$body += bullet "A Lock  (triggers when the slot is satisfied)"
$body += bullet "A Door  (with an open animation)"
$body += emptyPara
$body += h2 "Steps"
$body += step 1 "Place a Door in your room from the object library."
$body += step 2 "Place a Key object somewhere the player will find it."
$body += step 3 "Select the Key. In its properties, set Physics Mode to PICKABLE."
$body += step 4 "Add a Slot object and position it on or next to the door."
$body += step 5 "Add a Lock object and link it to the Slot (drag Slot into Lock's input field)."
$body += step 6 "Link the Lock to the Door's open animation (drag door into Lock's output field)."
$body += step 7 "Playtest: pick up the key, walk to the slot, use it -- does the door open?"
$body += emptyPara
$body += para (run "Connection chain:" "Segoe UI" 22 $true "1F3864") "left" 0 40
$body += chainPara "Key (PICKABLE)  ->  Slot  ->  Lock  ->  Door animation"
$body += emptyPara
$body += h2 "Common mistakes"
$body += bugPara "Key won't pick up" "Physics mode is STATIC instead of PICKABLE"
$body += bugPara "Door opens without the key" "Lock is not connected to the Slot"
$body += bugPara "Key gone but door stays shut" "Lock output not connected to Door animation"

$body += pageBreak

# ── PAGE 4: HIDING ITEMS IN CONTAINERS ────────────────────

$body += h1 "Page 4   Hiding Items in Containers"
$body += body "Goal: Player opens a chest, drawer, or cabinet and finds something hidden inside."
$body += emptyPara
$body += h2 "What you need"
$body += bullet "A container object  (chest, drawer, cabinet, safe, box -- anything that opens)"
$body += bullet "An item to hide inside it  (key, note, anything PICKABLE)"
$body += emptyPara
$body += h2 "Steps"
$body += step 1 "Place a container (chest, drawer, cabinet) in your room."
$body += step 2 "Select the container. In its properties, check Is Obstacle. This is required."
$body += step 3 "Place the item you want to hide (key, note, etc.) inside the container in the editor."
$body += step 4 "Position the item so it sits inside the container interior, not floating outside."
$body += step 5 "Set the item's Physics Mode to PICKABLE."
$body += step 6 "Add an interaction to the container so players can open it."
$body += step 7 "Playtest: open the container -- does the item appear? Can you pick it up?"
$body += emptyPara
$body += callout "TIP" "Put a combination lock or button puzzle on the container -- players have to solve the puzzle first, then they get to see what's inside. This chains two puzzles without extra wiring." "008000"
$body += h2 "Common mistakes"
$body += bugPara "Player grabs item through wall" "Is Obstacle is NOT checked on the container"
$body += bugPara "Item not visible when opened" "Item is positioned outside the container bounds"
$body += bugPara "Container won't open" "No interaction or animation linked to the container"

$body += pageBreak

# ── PAGE 5: COMBINATION LOCKS ──────────────────────────────

$body += h1 "Page 5   Combination Locks"
$body += body "Goal: Player rotates dials to the correct code -- something unlocks (door, chest, etc.)."
$body += emptyPara
$body += h2 "What you need"
$body += bullet "Turnable Spinner objects -- one per digit of your code (3 spinners for a 3-digit code)"
$body += bullet "A Lock set to Inplace mode"
$body += bullet "The target to unlock (door, chest, container, etc.)"
$body += bullet "A clue somewhere in the room that tells players the code"
$body += emptyPara
$body += h2 "Steps"
$body += step 1 "Place your Turnable Spinner objects and group them as the combination lock."
$body += step 2 "Select each spinner and set its target value (the correct digit for the code)."
$body += step 3 "Set each spinner's min and max range (e.g., 0 to 9 for a digit lock)."
$body += step 4 "Add a Lock object nearby. Set its mode to Inplace."
$body += step 5 "Link all spinners into the Lock's input fields."
$body += step 6 "Link the Lock's output to your target (door, chest, etc.)."
$body += step 7 "Place a clue somewhere in the room -- a note, a painting, a message."
$body += step 8 "Playtest: find the clue, dial in the code -- does the target unlock?"
$body += emptyPara
$body += callout "TIP" "Hide the code in a note inside a locked container to chain two puzzles. Or use a painting on the wall where only certain numbers are highlighted." "008000"
$body += callout "CRITICAL -- Every code must have a findable clue." "A combination lock with no clue anywhere in the room = an unsolvable puzzle. Players will be stuck forever. Always test that a new player can actually find the code." "CC0000"
$body += h2 "Common mistakes"
$body += bugPara "Lock never triggers" "Not all spinners are linked to the Lock"
$body += bugPara "Wrong mode" "Lock mode must be Inplace (not regular Lock)"
$body += bugPara "No clue for the code" "Room is unsolvable -- add a note or clue object"

$body += pageBreak

# ── PAGE 6: BUTTONS ────────────────────────────────────────

$body += h1 "Page 6   Buttons"
$body += body "Goal: Player finds and presses a button -- something in the room changes."
$body += emptyPara
$body += h2 "What you need"
$body += bullet "A Button object"
$body += bullet "A Lock with Password set to 1"
$body += bullet "The target (door, container, etc.)"
$body += emptyPara
$body += h2 "Steps -- Single button"
$body += step 1 "Place a Button object in your room."
$body += step 2 "Add a Lock object. Set its Password field to 1."
$body += step 3 "Link the Button to the Lock's input."
$body += step 4 "Link the Lock's output to your target (door, container, etc.)."
$body += step 5 "Playtest: press the button -- does the target activate?"
$body += emptyPara
$body += para (run "Connection chain:" "Segoe UI" 22 $true "1F3864") "left" 0 40
$body += chainPara "Button  ->  Lock (Password: 1)  ->  Target"
$body += emptyPara
$body += h2 "Sequence puzzle -- press buttons in the right order"
$body += body "Use a Lock with Password set to the sequence (e.g., 123 for three buttons pressed in order 1, 2, 3). Link each button to the Lock. Players must press them in the correct order."
$body += emptyPara
$body += callout "TIP" "Hide a button behind a DRAGGABLE object -- players have to move something to find it. Or put buttons in different parts of the room to force exploration." "008000"
$body += h2 "Common mistakes"
$body += bugPara "Button press does nothing" "Lock Password is not set to 1 (or sequence mismatch)"
$body += bugPara "Target activates itself" "Lock is linked wrong -- check input vs output fields"
$body += bugPara "Players can't find button" "Hint needed: leave a note or visible clue"

$body += pageBreak

# ── PAGE 7: WIN CONDITION ──────────────────────────────────

$body += h1 "Page 7   Win Condition -- The Finish Object"
$body += para (run "Every room MUST have a win condition or players can never escape." "Segoe UI" 24 $true "CC0000") "left" 0 80
$body += body "Goal: When the player solves the final puzzle, the Finish object triggers -- they escape and see the win screen."
$body += emptyPara
$body += h2 "What you need"
$body += bullet "A Finish object  (exit door, portal, or designated escape object from the library)"
$body += bullet "Your final Lock  (the last puzzle in the chain)"
$body += emptyPara
$body += h2 "Steps"
$body += step 1 "Place a Finish object in your room -- this is the escape door."
$body += step 2 "Make sure your final puzzle has a Lock."
$body += step 3 "Link that Lock's output to the Finish object."
$body += step 4 "Playtest the win condition FIRST, before adding all your other puzzles."
$body += step 5 "Once confirmed working, build the rest of your puzzle chain leading up to it."
$body += emptyPara
$body += h2 "Build backwards -- start at the win, work back to the start"
$body += body "This guarantees every puzzle is connected before you finish building."
$body += chainPara "FINISH  <--  Final Lock  <--  Key / Combo / Button"
$body += chainPara "                                   |"
$body += chainPara "                          Earlier Lock  <--  Puzzle  <-- ..."
$body += emptyPara
$body += h2 "Recommended build order"
$body += step 1 "Place the Finish object first."
$body += step 2 "Build the final lock and connect it to Finish."
$body += step 3 "Test that the win screen works."
$body += step 4 "Add the puzzle that unlocks the final lock."
$body += step 5 "Keep adding earlier puzzles until you have the room you want."
$body += step 6 "Final playtest: play through the whole room from scratch."
$body += emptyPara
$body += h2 "Common mistakes"
$body += bugPara "Win screen never appears" "Finish not connected to the final Lock"
$body += bugPara "Win triggers immediately" "Finish is not gated by any Lock"
$body += bugPara "No escape possible" "Finish object is missing from the room entirely"

$body += pageBreak

# ── PAGE 8: QUICK TIPS ─────────────────────────────────────

$body += h1 "Page 8   Quick Tips and Stuck-Point Guide"
$body += emptyPara
$body += h2 "Design Goals"
$body += bullet "Aim for 5 minutes to escape -- not too fast, not frustrating."
$body += bullet "Every puzzle needs a findable answer. No clue = unsolvable = no fun."
$body += bullet "Build backwards from the win condition (see page 7)."
$body += bullet "Playtest your own room before the showcase -- you will catch wiring bugs fast."
$body += bullet "Solvable first, beautiful second. A broken pretty room is worse than a working plain one."
$body += emptyPara
$body += h2 "Stretch Goals (if you finish early)"
$body += bullet "Add a red herring -- a fake key or wrong button that does nothing."
$body += bullet "Build a second room that players unlock after escaping the first."
$body += bullet "Add lore notes -- story text that explains why the player is locked in."
$body += bullet "Make a fake-out ending -- a door that opens but leads to another locked room."
$body += bullet "Time yourself -- can you escape your own room in under 3 minutes?"
$body += emptyPara
$body += h2 "Stuck? Check This First"
$body += emptyPara

# Stuck table
$sr1 = trow @("SYMPTOM","FIX") @($HDR_FILL,$HDR_FILL) $true @($true,$true)
$sr2 = trow @("Key won't pick up","Set physics mode to PICKABLE (not STATIC)") @($WH_FILL,$WH_FILL) $false @($true,$false)
$sr3 = trow @("Players grab items through container","Check Is Obstacle on the container") @($ALT_FILL,$ALT_FILL) $false @($true,$false)
$sr4 = trow @("Door or chest won't open","Check: puzzle output -> Lock -> door animation") @($WH_FILL,$WH_FILL) $false @($true,$false)
$sr5 = trow @("Win screen never appears","Connect final Lock output to the Finish object") @($ALT_FILL,$ALT_FILL) $false @($true,$false)
$sr6 = trow @("Combination lock never triggers","All spinners must link to Lock; mode must be Inplace") @($WH_FILL,$WH_FILL) $false @($true,$false)
$sr7 = trow @("Button does nothing","Lock Password must be 1; check Button -> Lock -> target") @($ALT_FILL,$ALT_FILL) $false @($true,$false)
$body += tblWrap ($sr1+$sr2+$sr3+$sr4+$sr5+$sr6+$sr7) "4320,5040"
$body += emptyPara
$body += emptyPara
$body += para (run "iCode VR Camp -- Day 5 -- Escape Simulator Room Editor Quick Reference" "Segoe UI" 18 $false "808080") "center" 0 0

# ============================================================
# Write XML files
# ============================================================

$contentTypes = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
</Types>
'@

$rels = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>
'@

$docRels = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
</Relationships>
'@

$docXml = @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
  xmlns:mo="http://schemas.microsoft.com/office/mac/office/2008/main"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
  xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
  xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
  xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
  mc:Ignorable="w14 wp14"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006">
<w:body>
<w:sectPr>
  <w:pgSz w:w="12240" w:h="15840"/>
  <w:pgMar w:top="1080" w:right="1200" w:bottom="1080" w:left="1200" w:header="720" w:footer="720" w:gutter="0"/>
</w:sectPr>
</w:body>
</w:document>
"@

# Insert body content before </w:body>
$docXml = $docXml -replace "<w:body>", "<w:body>$body"

[System.IO.File]::WriteAllText("$tmp\[Content_Types].xml", $contentTypes, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText("$tmp\_rels\.rels", $rels, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText("$tmp\word\_rels\document.xml.rels", $docRels, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText("$tmp\word\document.xml", $docXml, [System.Text.Encoding]::UTF8)

# Zip into .docx
if (Test-Path $outPath) { Remove-Item $outPath -Force }
[System.IO.Compression.ZipFile]::CreateFromDirectory($tmp, $outPath)

# Cleanup
Remove-Item $tmp -Recurse -Force

$size = (Get-Item $outPath).Length
Write-Host "Created: $outPath ($size bytes)"
