param([string]$GodotPath = 'C:\Program Files\Godot\Godot_v4.7.2-stable_win64_console.exe')
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$stageRoot = Join-Path $repoRoot 'local/t06/export-original'
$demoRoot = Join-Path $repoRoot 'docs/demo'
New-Item -ItemType Directory -Force -Path $stageRoot, (Join-Path $stageRoot 'assets'), (Join-Path $demoRoot 'original'), (Join-Path $demoRoot 'reviewed'), (Join-Path $demoRoot 'runtime') | Out-Null
foreach ($name in @('project.godot','main.tscn','main.gd','icon.svg')) {
    Copy-Item -LiteralPath (Join-Path $repoRoot ('examples/last-lantern/godot/' + $name)) -Destination (Join-Path $stageRoot $name)
}
Copy-Item -LiteralPath (Join-Path $repoRoot 'examples/last-lantern-reviewed/godot/assets/NotoSansKR.ttf') -Destination (Join-Path $stageRoot 'assets/NotoSansKR.ttf')
# Adapt font delivery in the disposable original build; gameplay source stays intact.
$originalScript = Get-Content -Raw -LiteralPath (Join-Path $stageRoot 'main.gd')
$originalScript = $originalScript.Replace('var font: SystemFont','var font: Font')
$originalScript = $originalScript.Replace("`tfont = SystemFont.new()", "`tvar bundled_font: FontVariation = FontVariation.new()`n`tbundled_font.base_font = preload(`"res://assets/NotoSansKR.ttf`")`n`tbundled_font.variation_opentype = {`"wght`": 500.0}`n`tfont = bundled_font")
$originalScript = [regex]::Replace($originalScript, '(?m)^\tfont\.font_names = .*\r?\n', '')
$snapshotCode = @'
func _publish_snapshot() -> void:
	if not OS.has_feature("web"):
		return
	var foes: Array[Dictionary] = []
	for foe: Dictionary in enemies:
		foes.append({"kind": foe.kind, "x": foe.pos.x, "y": foe.pos.y, "hp": foe.hp, "awake": foe.awake})
	var loot: Array[Dictionary] = []
	for tile: Vector2i in items:
		loot.append({"kind": items[tile], "x": tile.x, "y": tile.y})
	var value: Dictionary = {"version": "original", "state": state, "paused": restart_dialog.visible, "seed": run_seed, "floor": floor_number, "hp": hp, "maxHp": max_hp, "fuel": null, "potions": potions, "turns": turns, "kills": kills, "level": level, "attack": attack, "x": player.x, "y": player.y, "stairs": {"x": stairs.x, "y": stairs.y}, "cells": Array(cells), "enemies": foes, "items": loot, "marks": [], "bossPhase": "none"}
	JavaScriptBridge.eval("window.gameSnapshot=" + JSON.stringify(value) + ";window.parent.postMessage({type:'lantern-state',data:window.gameSnapshot},window.location.origin);", true)
'@
$originalScript = $originalScript.Replace("`t_show_title()", "`t_show_title()`n`t_publish_snapshot()")
$originalScript = $originalScript.Replace("func _refresh() -> void:", "func _refresh() -> void:`n`t_publish_snapshot()")
$originalScript = $originalScript.Replace("`tui.add_child(restart_dialog)", "`tui.add_child(restart_dialog)`n`trestart_dialog.visibility_changed.connect(_publish_snapshot)")
[IO.File]::WriteAllText((Join-Path $stageRoot 'main.gd'), $originalScript + "`n`n" + $snapshotCode.Replace('\t', "`t") + "`n", [Text.UTF8Encoding]::new($false))
$shellPath = (Join-Path $PSScriptRoot 'web-shell.html').Replace('\','/')
$preset = @"
[preset.0]
name="Web"
platform="Web"
runnable=true
export_filter="all_resources"
include_filter=""
exclude_filter="self_check.gd,assets/OFL.txt"
export_path=""
[preset.0.options]
variant/extensions_support=false
variant/thread_support=false
vram_texture_compression/for_desktop=false
vram_texture_compression/for_mobile=false
html/custom_html_shell="$shellPath"
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
progressive_web_app/enabled=false
"@
foreach ($build in @(@{Name='original';Path=$stageRoot}, @{Name='reviewed';Path=(Join-Path $repoRoot 'examples/last-lantern-reviewed/godot')})) {
    # The reviewed preset is also generated locally, keeping absolute paths out of Git.
    $buildPath = $build.Path
    if ($build.Name -eq 'reviewed') {
        $buildPath = Join-Path $repoRoot 'local/t06/export-reviewed'
        New-Item -ItemType Directory -Force -Path $buildPath,(Join-Path $buildPath 'assets') | Out-Null
        foreach ($name in @('project.godot','main.tscn','main.gd','icon.svg')) {
            Copy-Item -LiteralPath (Join-Path $build.Path $name) -Destination (Join-Path $buildPath $name)
        }
        Copy-Item -LiteralPath (Join-Path $build.Path 'assets/NotoSansKR.ttf') -Destination (Join-Path $buildPath 'assets/NotoSansKR.ttf')
    }
    [IO.File]::WriteAllText((Join-Path $buildPath 'export_presets.cfg'),$preset,[Text.UTF8Encoding]::new($false))
    & $GodotPath --headless --path $buildPath --editor --import --quit *> (Join-Path $repoRoot ('local/t06/import-' + $build.Name + '.log'))
    if ($LASTEXITCODE -ne 0) { throw ('Import failed: ' + $build.Name) }
    $exportPath = Join-Path $repoRoot ('local/t06/' + $build.Name + '-web/index.html')
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $exportPath) | Out-Null
    & $GodotPath --headless --path $buildPath --export-release Web $exportPath *> (Join-Path $repoRoot ('local/t06/export-' + $build.Name + '.log'))
    if ($LASTEXITCODE -ne 0) { throw ('Export failed: ' + $build.Name) }
    $htmlContent = (Get-Content -Raw -LiteralPath $exportPath).TrimEnd() + "`n"
    [IO.File]::WriteAllText((Join-Path $demoRoot ($build.Name + '/index.html')), $htmlContent, [Text.UTF8Encoding]::new($false))
    Copy-Item -LiteralPath ([IO.Path]::ChangeExtension($exportPath,'.pck')) -Destination (Join-Path $demoRoot ($build.Name + '/index.pck'))
    foreach ($extension in @('.js','.wasm','.audio.worklet.js','.audio.position.worklet.js')) {
        $runtimeSource = [IO.Path]::ChangeExtension($exportPath,$extension)
        $runtimeDest = Join-Path $demoRoot ('runtime/godot' + $extension)
        if ($build.Name -eq 'original') { Copy-Item -LiteralPath $runtimeSource -Destination $runtimeDest }
        elseif ((Get-FileHash -LiteralPath $runtimeSource).Hash -ne (Get-FileHash -LiteralPath $runtimeDest).Hash) { throw 'Shared Godot runtime differs' }
    }
}
Copy-Item -LiteralPath (Join-Path $repoRoot 'examples/last-lantern/review-board.html') -Destination (Join-Path $demoRoot 'review-board.html')
Copy-Item -LiteralPath (Join-Path $repoRoot 'examples/last-lantern/review-viz.html') -Destination (Join-Path $demoRoot 'review-viz.html')
Copy-Item -LiteralPath (Join-Path $repoRoot 'examples/last-lantern/preview.png') -Destination (Join-Path $demoRoot 'original-preview.png')
Copy-Item -LiteralPath (Join-Path $repoRoot 'examples/last-lantern-reviewed/preview.png') -Destination (Join-Path $demoRoot 'reviewed-preview.png')
Write-Output 'Both Godot Web demos exported with one shared runtime.'
