$outPath = Join-Path $PSScriptRoot "EscapeSimulator_RoomEditor_Guide.docx"

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$doc = $word.Documents.Add()

# Color constants (Word BGR decimal)
$COL_WHITE  = 16777215
$COL_BLACK  = 0
$COL_NAVY   = 8388608
$COL_RED    = 255
$COL_ORANGE = 26367
$COL_GREEN  = 32768
$COL_LTGRAY = 15921906
$COL_GRAY   = 8421504

# Page margins
$doc.PageSetup.TopMargin    = $word.InchesToPoints(0.9)
$doc.PageSetup.BottomMargin = $word.InchesToPoints(0.9)
$doc.PageSetup.LeftMargin   = $word.InchesToPoints(1.0)
$doc.PageSetup.RightMargin  = $word.InchesToPoints(1.0)

$sel = $word.Selection
$sel.HomeKey(6) | Out-Null   # wdStory = 6

function Head($sel, $text) {
    $sel.Font.Name  = "Segoe UI"
    $sel.Font.Size  = 20
    $sel.Font.Bold  = $true
    $sel.Font.Color = 8388608   # navy
    $sel.ParagraphFormat.Alignment = 0
    $sel.TypeText($text)
    $sel.TypeParagraph()
    $sel.Font.Color = 0
    $sel.Font.Bold  = $false
    $sel.Font.Size  = 11
}

function Body($sel, $text) {
    $sel.Font.Name  = "Segoe UI"
    $sel.Font.Bold  = $false
    $sel.Font.Size  = 11
    $sel.Font.Color = 0
    $sel.TypeText($text)
    $sel.TypeParagraph()
}

function BulletItem($sel, $text) {
    $sel.Font.Name  = "Segoe UI"
    $sel.Font.Bold  = $false
    $sel.Font.Size  = 11
    $sel.Font.Color = 0
    $sel.TypeText("  - " + $text)
    $sel.TypeParagraph()
}

function StepItem($sel, $num, $text) {
    $sel.Font.Name  = "Segoe UI"
    $sel.Font.Size  = 11
    $sel.Font.Color = 0
    $sel.Font.Bold  = $true
    $sel.TypeText("  $num.  ")
    $sel.Font.Bold  = $false
    $sel.TypeText($text)
    $sel.TypeParagraph()
}

function SubHead($sel, $text) {
    $sel.Font.Name  = "Segoe UI"
    $sel.Font.Size  = 13
    $sel.Font.Bold  = $true
    $sel.Font.Color = 8388608
    $sel.TypeText($text)
    $sel.TypeParagraph()
    $sel.Font.Color = 0
    $sel.Font.Bold  = $false
    $sel.Font.Size  = 11
}

function Callout($sel, $label, $text, $color) {
    $sel.Font.Name  = "Segoe UI"
    $sel.Font.Size  = 11
    $sel.Font.Bold  = $true
    $sel.Font.Color = $color
    $sel.TypeText($label)
    $sel.TypeParagraph()
    $sel.Font.Bold  = $false
    $sel.Font.Color = 0
    $sel.TypeText($text)
    $sel.TypeParagraph()
    $sel.TypeParagraph()
}

function BugRow($sel, $symptom, $fix) {
    $sel.Font.Name  = "Courier New"
    $sel.Font.Size  = 10
    $sel.Font.Color = 0
    $padded = $symptom.PadRight(38)
    $sel.TypeText("  " + $padded + "-> " + $fix)
    $sel.TypeParagraph()
    $sel.Font.Name = "Segoe UI"
    $sel.Font.Size = 11
}

function PageBreak($sel) {
    $sel.InsertBreak(7)   # wdPageBreak
}

# =============================================================================
# PAGE 1 - COVER
# =============================================================================

$sel.ParagraphFormat.Alignment = 1   # center
$sel.Font.Name  = "Segoe UI"
$sel.Font.Bold  = $false
$sel.Font.Size  = 11
$sel.Font.Color = 0
$sel.TypeParagraph()
$sel.TypeParagraph()
$sel.TypeParagraph()
$sel.TypeParagraph()

$sel.Font.Size  = 36
$sel.Font.Bold  = $true
$sel.Font.Color = 8388608
$sel.TypeText("Escape Simulator")
$sel.TypeParagraph()

$sel.Font.Size  = 22
$sel.Font.Bold  = $false
$sel.Font.Color = 0
$sel.TypeText("Room Editor -- Quick Reference")
$sel.TypeParagraph()
$sel.TypeParagraph()

$sel.Font.Size  = 13
$sel.TypeText("Keep this guide at your desk all day.")
$sel.TypeParagraph()
$sel.TypeText("Every mechanic you need is on these pages.")
$sel.TypeParagraph()
$sel.TypeParagraph()
$sel.TypeParagraph()

$sel.Font.Size  = 11
$sel.Font.Bold  = $true
$sel.TypeText("CONTENTS")
$sel.TypeParagraph()
$sel.Font.Bold  = $false

$contents = @(
    "Page 2   The 3 Physics Modes",
    "Page 3   Keys and Doors",
    "Page 4   Hiding Items in Containers",
    "Page 5   Combination Locks",
    "Page 6   Buttons",
    "Page 7   Win Condition (The Finish Object)",
    "Page 8   Quick Tips and Stuck-Point Guide"
)
foreach ($line in $contents) {
    $sel.TypeText($line)
    $sel.TypeParagraph()
}

$sel.TypeParagraph()
$sel.Font.Size  = 10
$sel.Font.Color = 8421504
$sel.TypeText("iCode VR Camp -- Day 5")
$sel.TypeParagraph()

PageBreak $sel

# =============================================================================
# PAGE 2 - THE 3 PHYSICS MODES
# =============================================================================

$sel.ParagraphFormat.Alignment = 0

Head $sel "Page 2   The 3 Physics Modes"
Body $sel "Every object in your room has exactly one physics mode. Getting this wrong is the #1 cause of puzzles that don't work."
$sel.TypeParagraph()

# Table: physics modes
$tbl = $doc.Tables.Add($sel.Range, 4, 3)
$tbl.Borders.Enable = $true
$tbl.PreferredWidthType = 2
$tbl.PreferredWidth = 100

$hdrText = @("MODE", "WHAT PLAYERS CAN DO", "USE IT FOR")
for ($c = 0; $c -lt 3; $c++) {
    $cell = $tbl.Cell(1, $c+1).Range
    $cell.Text = $hdrText[$c]
    $cell.Font.Bold  = $true
    $cell.Font.Size  = 11
    $cell.Font.Name  = "Segoe UI"
    $cell.ParagraphFormat.Alignment = 1
    $cell.Shading.BackgroundPatternColor = 8388608
    $cell.Font.Color = 16777215
}

$modeRows = @(
    @("STATIC",    "Can't touch it at all",           "Walls, floors, ceiling, furniture, decorations"),
    @("DRAGGABLE", "Can push and slide it around",     "Boxes, clutter, objects players need to move"),
    @("PICKABLE",  "Can pick it up and carry it",      "Keys, notes, items that get collected or used")
)
for ($r = 0; $r -lt 3; $r++) {
    for ($c = 0; $c -lt 3; $c++) {
        $cell = $tbl.Cell($r+2, $c+1).Range
        $cell.Text = $modeRows[$r][$c]
        $cell.Font.Size = 11
        $cell.Font.Name = "Segoe UI"
        $cell.Font.Bold = ($c -eq 0)
        if ($c -eq 0) { $cell.Font.Color = 8388608 }
        if ($r % 2 -eq 1) { $cell.Shading.BackgroundPatternColor = 15921906 }
    }
}

$sel.MoveDown(5, 1) | Out-Null
$sel.EndKey(6) | Out-Null
$sel.TypeParagraph()
$sel.TypeParagraph()

Callout $sel "WARNING -- Is Obstacle" "For any container (chest, cabinet, drawer, safe) you MUST check Is Obstacle in its properties panel. Without it, players can grab items through the walls of the container -- the puzzle becomes unsolvable." 255

$sel.Font.Bold  = $true
$sel.Font.Size  = 11
$sel.Font.Color = 32768
$sel.TypeText("QUICK CHECK before playtesting:")
$sel.TypeParagraph()
$sel.Font.Bold  = $false
$sel.Font.Color = 0

$checks = @(
    "Keys and collectible items -- PICKABLE",
    "Moveable clutter -- DRAGGABLE",
    "Everything else -- STATIC",
    "All containers -- Is Obstacle checked"
)
foreach ($chk in $checks) {
    $sel.TypeText("  [x]  " + $chk)
    $sel.TypeParagraph()
}

PageBreak $sel

# =============================================================================
# PAGE 3 - KEYS AND DOORS
# =============================================================================

Head $sel "Page 3   Keys and Doors"
Body $sel "Goal: Player finds a key -- picks it up -- uses it on a slot -- door opens."
$sel.TypeParagraph()

SubHead $sel "What you need"
BulletItem $sel "A Key object  (any key prop from the object library)"
BulletItem $sel "A Slot  (the receiver that the key clicks into)"
BulletItem $sel "A Lock  (triggers when the slot is satisfied)"
BulletItem $sel "A Door  (with an open animation)"
$sel.TypeParagraph()

SubHead $sel "Steps"
StepItem $sel 1 "Place a Door in your room from the object library."
StepItem $sel 2 "Place a Key object somewhere the player will find it."
StepItem $sel 3 "Select the Key. In its properties, set Physics Mode to PICKABLE."
StepItem $sel 4 "Add a Slot object and position it on or next to the door."
StepItem $sel 5 "Add a Lock object and link it to the Slot (drag the Slot into the Lock's input field)."
StepItem $sel 6 "Link the Lock to the Door's open animation (drag the door into the Lock's output field)."
StepItem $sel 7 "Playtest: pick up the key, walk to the slot, use it -- does the door open?"
$sel.TypeParagraph()

$sel.Font.Bold  = $true
$sel.Font.Color = 8388608
$sel.TypeText("Connection chain:")
$sel.TypeParagraph()
$sel.Font.Bold  = $false
$sel.Font.Color = 0
$sel.Font.Name  = "Courier New"
$sel.TypeText("  Key (PICKABLE)  ->  Slot  ->  Lock  ->  Door animation")
$sel.TypeParagraph()
$sel.Font.Name  = "Segoe UI"
$sel.TypeParagraph()

SubHead $sel "Common mistakes"
BugRow $sel "Key won't pick up"              "Physics mode is STATIC instead of PICKABLE"
BugRow $sel "Door opens without the key"     "Lock is not connected to the Slot"
BugRow $sel "Key gone but door stays shut"   "Lock output not connected to the Door animation"

PageBreak $sel

# =============================================================================
# PAGE 4 - HIDING ITEMS IN CONTAINERS
# =============================================================================

Head $sel "Page 4   Hiding Items in Containers"
Body $sel "Goal: Player opens a chest, drawer, or cabinet and finds something hidden inside."
$sel.TypeParagraph()

SubHead $sel "What you need"
BulletItem $sel "A container object  (chest, drawer, cabinet, safe, box -- anything that opens)"
BulletItem $sel "An item to hide inside it  (key, note, anything PICKABLE)"
$sel.TypeParagraph()

SubHead $sel "Steps"
StepItem $sel 1 "Place a container (chest, drawer, cabinet) in your room."
StepItem $sel 2 "Select the container. In its properties, check Is Obstacle. This is required."
StepItem $sel 3 "Place the item you want to hide (key, note, etc.) inside the container in the editor."
StepItem $sel 4 "Position the item so it sits inside the container interior, not floating outside it."
StepItem $sel 5 "Set the item's Physics Mode to PICKABLE."
StepItem $sel 6 "Add an interaction to the container so players can open it."
StepItem $sel 7 "Playtest: open the container -- does the item appear? Can you pick it up?"
$sel.TypeParagraph()

Callout $sel "TIP" "Put a combination lock or button puzzle on the container -- players have to solve the puzzle first, then they get to see what's inside. This chains two puzzles together without extra wiring." 32768

SubHead $sel "Common mistakes"
BugRow $sel "Player grabs item through wall"   "Is Obstacle is NOT checked on the container"
BugRow $sel "Item not visible when opened"     "Item is positioned outside the container bounds"
BugRow $sel "Container won't open"             "No interaction or animation linked to the container"

PageBreak $sel

# =============================================================================
# PAGE 5 - COMBINATION LOCKS
# =============================================================================

Head $sel "Page 5   Combination Locks"
Body $sel "Goal: Player rotates dials to the correct code -- something unlocks (door, chest, etc.)."
$sel.TypeParagraph()

SubHead $sel "What you need"
BulletItem $sel "Turnable Spinner objects -- one per digit of your code (e.g., 3 spinners for a 3-digit code)"
BulletItem $sel "A Lock set to Inplace mode"
BulletItem $sel "The target to unlock (door, chest, container, etc.)"
BulletItem $sel "A clue somewhere in the room that tells players the code"
$sel.TypeParagraph()

SubHead $sel "Steps"
StepItem $sel 1 "Place your Turnable Spinner objects and group them as the combination lock."
StepItem $sel 2 "Select each spinner and set its target value (the correct digit for the code)."
StepItem $sel 3 "Set each spinner's min and max range (e.g., 0 to 9 for a digit lock)."
StepItem $sel 4 "Add a Lock object nearby. Set its mode to Inplace."
StepItem $sel 5 "Link all spinners into the Lock's input fields."
StepItem $sel 6 "Link the Lock's output to your target (door, chest, etc.)."
StepItem $sel 7 "Place a clue somewhere in the room -- a note, a painting, a message. Players need to be able to find the code."
StepItem $sel 8 "Playtest: find the clue, dial in the code -- does the target unlock?"
$sel.TypeParagraph()

Callout $sel "TIP" "Hide the code in a note inside a locked container to chain two puzzles together. Or use a painting on the wall where only certain numbers are highlighted." 32768

Callout $sel "CRITICAL -- Every code must have a findable clue." "A combination lock with no clue anywhere in the room = an unsolvable puzzle. Players will be stuck forever. Always test that a new player can actually find the code." 255

SubHead $sel "Common mistakes"
BugRow $sel "Lock never triggers"    "Not all spinners are linked to the Lock"
BugRow $sel "Wrong mode"             "Lock mode must be Inplace (not regular Lock)"
BugRow $sel "No clue for the code"   "Room is unsolvable -- add a note or clue object"

PageBreak $sel

# =============================================================================
# PAGE 6 - BUTTONS
# =============================================================================

Head $sel "Page 6   Buttons"
Body $sel "Goal: Player finds and presses a button -- something in the room changes (door opens, object reveals, etc.)."
$sel.TypeParagraph()

SubHead $sel "What you need"
BulletItem $sel "A Button object"
BulletItem $sel "A Lock with Password set to 1"
BulletItem $sel "The target (door, container, etc.)"
$sel.TypeParagraph()

SubHead $sel "Steps -- Single button"
StepItem $sel 1 "Place a Button object in your room."
StepItem $sel 2 "Add a Lock object. Set its Password field to 1."
StepItem $sel 3 "Link the Button to the Lock's input."
StepItem $sel 4 "Link the Lock's output to your target (door, container, etc.)."
StepItem $sel 5 "Playtest: press the button -- does the target activate?"
$sel.TypeParagraph()

$sel.Font.Bold  = $true
$sel.Font.Color = 8388608
$sel.TypeText("Connection chain:")
$sel.TypeParagraph()
$sel.Font.Bold  = $false
$sel.Font.Color = 0
$sel.Font.Name  = "Courier New"
$sel.TypeText("  Button  ->  Lock (Password: 1)  ->  Target")
$sel.TypeParagraph()
$sel.Font.Name  = "Segoe UI"
$sel.TypeParagraph()

SubHead $sel "Sequence puzzle -- press buttons in the right order"
Body $sel "Use a Lock with Password set to the sequence (e.g., 123 for three buttons pressed in order 1, 2, 3). Link each button to the Lock. Players must press them in the correct order."
$sel.TypeParagraph()

Callout $sel "TIP" "Hide a button behind a DRAGGABLE object -- players have to move the object to find it. Or put buttons in different parts of the room to force exploration before the door opens." 32768

SubHead $sel "Common mistakes"
BugRow $sel "Button press does nothing"    "Lock Password is not set to 1 (or sequence mismatch)"
BugRow $sel "Target activates itself"      "Lock is linked wrong -- check input vs output fields"
BugRow $sel "Players can't find button"    "Hint needed: leave a note or visible clue"

PageBreak $sel

# =============================================================================
# PAGE 7 - WIN CONDITION
# =============================================================================

Head $sel "Page 7   Win Condition -- The Finish Object"

$sel.Font.Name  = "Segoe UI"
$sel.Font.Size  = 12
$sel.Font.Bold  = $true
$sel.Font.Color = 255
$sel.TypeText("Every room MUST have a win condition or players can never escape.")
$sel.TypeParagraph()
$sel.Font.Bold  = $false
$sel.Font.Size  = 11
$sel.Font.Color = 0
$sel.TypeParagraph()

Body $sel "Goal: When the player solves the final puzzle, the Finish object triggers -- they escape and see the win screen."
$sel.TypeParagraph()

SubHead $sel "What you need"
BulletItem $sel "A Finish object  (exit door, portal, or designated escape object from the library)"
BulletItem $sel "Your final Lock  (the last puzzle in the chain)"
$sel.TypeParagraph()

SubHead $sel "Steps"
StepItem $sel 1 "Place a Finish object in your room -- this is the escape door."
StepItem $sel 2 "Make sure your final puzzle has a Lock."
StepItem $sel 3 "Link that Lock's output to the Finish object."
StepItem $sel 4 "Playtest the win condition FIRST, before adding all your other puzzles. Solve the final puzzle -- does the win screen appear?"
StepItem $sel 5 "Once confirmed working, build the rest of your puzzle chain leading up to it."
$sel.TypeParagraph()

SubHead $sel "Build backwards -- start at the win, work back to the start"
Body $sel "This guarantees every puzzle is connected before you finish building."
$sel.TypeParagraph()
$sel.Font.Name  = "Courier New"
$sel.Font.Size  = 10
$sel.TypeText("  FINISH  <--  Final Lock  <--  Key / Combo / Button")
$sel.TypeParagraph()
$sel.TypeText("                                      |")
$sel.TypeParagraph()
$sel.TypeText("                              Earlier Lock  <--  Another puzzle  <-- ...")
$sel.TypeParagraph()
$sel.Font.Name  = "Segoe UI"
$sel.Font.Size  = 11
$sel.TypeParagraph()

SubHead $sel "Recommended build order"
StepItem $sel 1 "Place the Finish object first."
StepItem $sel 2 "Build the final lock and connect it to Finish."
StepItem $sel 3 "Test that the win screen works."
StepItem $sel 4 "Add the puzzle that unlocks the final lock."
StepItem $sel 5 "Keep adding earlier puzzles until you have the room you want."
StepItem $sel 6 "Final playtest: play through the whole room from scratch."
$sel.TypeParagraph()

SubHead $sel "Common mistakes"
BugRow $sel "Win screen never appears"    "Finish not connected to the final Lock"
BugRow $sel "Win triggers immediately"    "Finish is not gated by any Lock"
BugRow $sel "No escape possible"          "Finish object is missing from the room entirely"

PageBreak $sel

# =============================================================================
# PAGE 8 - QUICK TIPS
# =============================================================================

Head $sel "Page 8   Quick Tips and Stuck-Point Guide"
$sel.TypeParagraph()

SubHead $sel "Design Goals"
$tips = @(
    "Aim for 5 minutes to escape -- not too fast, not frustrating.",
    "Every puzzle needs a findable answer. No clue = unsolvable = no fun.",
    "Build backwards from the win condition (see page 7).",
    "Playtest your own room before the showcase -- you will catch wiring bugs fast.",
    "Solvable first, beautiful second. A broken pretty room is worse than a working plain one."
)
foreach ($t in $tips) { BulletItem $sel $t }
$sel.TypeParagraph()

SubHead $sel "Stretch Goals (if you finish early)"
$stretch = @(
    "Add a red herring -- a fake key or wrong button that does nothing, to confuse players.",
    "Build a second room that players unlock after escaping the first.",
    "Add lore notes -- story text that explains why the player is locked in.",
    "Make a fake-out ending -- a door that opens but leads to another locked room.",
    "Time yourself -- can you escape your own room in under 3 minutes?"
)
foreach ($s in $stretch) { BulletItem $sel $s }
$sel.TypeParagraph()

SubHead $sel "Stuck? Check This First"
$sel.TypeParagraph()

# Stuck table
$stk = $doc.Tables.Add($sel.Range, 7, 2)
$stk.Borders.Enable = $true
$stk.PreferredWidthType = 2
$stk.PreferredWidth = 100

$stkHdr = @("SYMPTOM", "FIX")
for ($c = 0; $c -lt 2; $c++) {
    $cell = $stk.Cell(1, $c+1).Range
    $cell.Text = $stkHdr[$c]
    $cell.Font.Bold  = $true
    $cell.Font.Size  = 11
    $cell.Font.Name  = "Segoe UI"
    $cell.Font.Color = 16777215
    $cell.ParagraphFormat.Alignment = 1
    $cell.Shading.BackgroundPatternColor = 8388608
}

$stkData = @(
    @("Key won't pick up",                     "Set physics mode to PICKABLE (not STATIC)"),
    @("Players grab items through container",  "Check Is Obstacle on the container"),
    @("Door or chest won't open",              "Check Lock is connected: puzzle output -> Lock -> door animation"),
    @("Win screen never appears",              "Connect final Lock output to the Finish object"),
    @("Combination lock never triggers",       "All spinners must link to the Lock; mode must be Inplace"),
    @("Button does nothing",                   "Lock Password must be 1; check Button -> Lock -> target chain")
)
for ($r = 0; $r -lt $stkData.Count; $r++) {
    for ($c = 0; $c -lt 2; $c++) {
        $cell = $stk.Cell($r+2, $c+1).Range
        $cell.Text = $stkData[$r][$c]
        $cell.Font.Size = 10
        $cell.Font.Name = "Segoe UI"
        $cell.Font.Bold = ($c -eq 0)
        if ($r % 2 -eq 1) { $cell.Shading.BackgroundPatternColor = 15921906 }
    }
}

$sel.MoveDown(5, 1) | Out-Null
$sel.EndKey(6) | Out-Null
$sel.TypeParagraph()
$sel.TypeParagraph()

$sel.Font.Name  = "Segoe UI"
$sel.Font.Size  = 9
$sel.Font.Bold  = $false
$sel.Font.Color = 8421504
$sel.ParagraphFormat.Alignment = 1
$sel.TypeText("iCode VR Camp -- Day 5 -- Escape Simulator Room Editor Quick Reference")
$sel.TypeParagraph()

# Save
$doc.SaveAs2($outPath, 16)
$doc.Close()
$word.Quit()

Write-Host "Saved: $outPath"
