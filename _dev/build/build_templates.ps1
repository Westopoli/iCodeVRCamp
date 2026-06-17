<#
build_templates.ps1 — iCode camp build script

Generates the two student ZIPs per day from each DayN_* Godot project folder.
The on-disk DayN_* folder is the COMPLETE game (source of truth, BIBLE §11).

For each DayN_* project:
  dist/DayN_Complete.zip  — full working game (instructor backup)
  dist/DayN_Template.zip  — scaffold with # TODO holes (kids work here)

Marker convention (BIBLE §11, C1 model):
  #@todo  ... lines kept ONLY in Complete (= what the kid's TODO produced)
  #@end   ... ends the block
Marker lines themselves are never emitted. # TODO comments are normal lines.
Template = source with all #@todo blocks stripped, leaving bare # TODO
comments as a worksheet. Template does NOT compile until kids fill chunks
(deliberate — debugging aid).

Usage:
  .\build\build_templates.ps1            # build all days
  .\build\build_templates.ps1 -Day Day1_Pong_Game   # build one day

.godot/ is always excluded from ZIPs (machine-specific import cache).
.exe export stays manual via Godot's export dialog.
#>

param(
    [string]$Day = ""
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$distDir  = Join-Path $repoRoot "dist"

# Strip a .gd file's lines for the given target ("Complete" or "Template").
# NOTE: marker tests use plain if + continue (NOT a switch). `continue`
# inside a PowerShell switch does not skip the rest of the loop body, so a
# switch here would let marker lines fall through and be emitted.
function Convert-GdLines {
    param([string[]]$Lines, [string]$Target)
    $out  = New-Object System.Collections.Generic.List[string]
    $mode = "normal"   # normal | todo
    foreach ($line in $Lines) {
        $trim = $line.Trim()
        if ($trim -eq "#@todo") { $mode = "todo"; continue }
        if ($trim -eq "#@end") {
            if ($Target -eq "Template") {
                # If the last non-blank, non-comment line in $out is a block
                # opener (ends with ":"), the stripped #@todo block was its
                # entire body. Insert pass so GDScript doesn't parse-error.
                for ($ri = $out.Count - 1; $ri -ge 0; $ri--) {
                    $prev = $out[$ri]
                    if ($prev -match '^\s*$' -or $prev -match '^\s*#') { continue }
                    if ($prev -match ':\s*$') {
                        if ($prev -match '^(\s*)') { $bi = $matches[1] }
                        $out.Add($bi + "`t" + "pass  # <- delete this line and write your code above")
                    }
                    break
                }
            }
            $mode = "normal"
            continue
        }
        if ($mode -eq "normal") {
            $out.Add($line)
        } elseif ($mode -eq "todo") {
            if ($Target -eq "Complete") { $out.Add($line) }
        }
    }
    return ,$out
}

# Build one ZIP for one project / target.
function Build-Zip {
    param([string]$ProjectDir, [string]$Target)

    $name    = Split-Path -Leaf $ProjectDir
    $stageDir = Join-Path $env:TEMP "icode_build\${name}_${Target}"
    $zipPath  = Join-Path $distDir "${name}_${Target}.zip"

    if (Test-Path $stageDir) { Remove-Item $stageDir -Recurse -Force }
    New-Item -ItemType Directory -Path $stageDir -Force | Out-Null

    # Copy project, excluding the machine-specific import cache.
    # Use robocopy so .godot/ is skipped during traversal — Copy-Item walks
    # into it first and dies on MAX_PATH for deep shader-cache subdirs.
    # robocopy exit codes 0-7 = success; 8+ = real failure.
    $rc = (robocopy $ProjectDir $stageDir /E /XD ".godot" /NFL /NDL /NJH /NJS /NP /R:1 /W:1) 2>&1 | Out-Null
    if ($LASTEXITCODE -ge 8) { throw "robocopy failed for $ProjectDir (exit $LASTEXITCODE)" }
    $global:LASTEXITCODE = 0

    # Strip solution markers in every .gd file.
    # Read/write via .NET so encoding is UTF-8 with no BOM (PS 5.1's
    # Get-Content reads ANSI and Set-Content -Encoding utf8 adds a BOM).
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    Get-ChildItem -Path $stageDir -Filter "*.gd" -Recurse | ForEach-Object {
        $lines    = [System.IO.File]::ReadAllLines($_.FullName)
        $stripped = Convert-GdLines -Lines $lines -Target $Target
        [System.IO.File]::WriteAllLines($_.FullName, $stripped, $utf8NoBom)
    }

    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
    Compress-Archive -Path (Join-Path $stageDir "*") -DestinationPath $zipPath
    Remove-Item $stageDir -Recurse -Force
    Write-Host "  built $zipPath"
}

# --- main ---
if (-not (Test-Path $distDir)) { New-Item -ItemType Directory -Path $distDir | Out-Null }

$projects = Get-ChildItem -Path $repoRoot -Directory |
    Where-Object { $_.Name -match '^Day\d' }
if ($Day -ne "") {
    $projects = $projects | Where-Object { $_.Name -eq $Day }
    if (-not $projects) { throw "No project folder named '$Day' in $repoRoot" }
}
if (-not $projects) { Write-Host "No DayN_* project folders found yet."; return }

foreach ($p in $projects) {
    Write-Host "$($p.Name):"
    Build-Zip -ProjectDir $p.FullName -Target "Complete"
    Build-Zip -ProjectDir $p.FullName -Target "Template"
}
Write-Host "Done. ZIPs in $distDir"
