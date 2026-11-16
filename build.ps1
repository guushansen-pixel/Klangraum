<#
.SYNOPSIS
    Baut den Klangraum ueber apk-builder und haengt die Display-Bruecke an
    (Display an, solange Klang laeuft; Helligkeit fuer den Nachtbildschirm).
.DESCRIPTION
    Aufbau wie gym-coach\build.ps1. apps\Klangraum unter apk-builder wird bei
    jedem Lauf per -Force neu aus dem Template erzeugt, der Patch laeuft
    deshalb jedes Mal erneut. Throw-Guard: Aendert sich das Template, bricht
    der Build laut ab, statt still eine APK ohne Bruecke zu bauen.

    Bewusst OHNE -KeepScreenOn: Das Display soll nur an bleiben, waehrend
    Klang laeuft; das steuert die Web-App ueber die Bruecke.

    Mit -Release landet die signierte APK zusaetzlich als
    dist\klangraum-<Version>.apk (aeltere dist-APKs werden entfernt).
.EXAMPLE
    .\build.ps1 -VersionName 1.1 -VersionCode 2 -Release
#>
[CmdletBinding()]
param(
    [string]$VersionName = '1.2',
    [int]$VersionCode = 3,
    [switch]$Release,
    [switch]$Install
)

$ErrorActionPreference = 'Stop'

# javac lehnt eine UTF-8-BOM ab; PS 5.1 schreibt mit -Encoding utf8 immer eine.
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
function Write-TextNoBom {
    param([string]$Path, [string]$Content)
    [System.IO.File]::WriteAllText($Path, $Content, $Utf8NoBom)
}
function Replace-Once {
    param([string]$Text, [string]$Needle, [string]$Replacement, [string]$What)
    $idx = $Text.IndexOf($Needle)
    if ($idx -lt 0) {
        throw "Patchziel '$What' nicht gefunden - hat sich das apk-builder-Template geaendert?"
    }
    return $Text.Substring(0, $idx) + $Replacement + $Text.Substring($idx + $Needle.Length)
}

$ProjectRoot = $PSScriptRoot
$ApkBuilder  = "D:\claude code projects\apk-builder"
$PackageId   = "com.daniel.klangraum"
$AppName     = "Klangraum"
$appDir      = Join-Path $ApkBuilder "apps\$AppName"

& "$ApkBuilder\new-app.ps1" -Name $AppName -PackageId $PackageId `
    -WebRoot (Join-Path $ProjectRoot 'web') `
    -Icon (Join-Path $ProjectRoot 'icon.xml') `
    -IconBackground "#12171E" -Portrait `
    -VersionName $VersionName -VersionCode $VersionCode -Force

$javaDir = Join-Path $appDir ("app\src\main\java\" + $PackageId.Replace('.', '\'))

# --- ScreenBridge.java -----------------------------------------------------
$bridge = [System.IO.File]::ReadAllText((Join-Path $ProjectRoot 'android-src\ScreenBridge.java'))
$bridge = Replace-Once $bridge 'package __PACKAGE__;' "package $PackageId;" 'package-Platzhalter'
Write-TextNoBom -Path (Join-Path $javaDir 'ScreenBridge.java') -Content $bridge

# --- MainActivity.java -----------------------------------------------------
$mainActivityPath = Join-Path $javaDir 'MainActivity.java'
$java = [System.IO.File]::ReadAllText($mainActivityPath)

$java = Replace-Once $java 'webView.setWebViewClient(new LocalWebViewClient());' @'
webView.setWebViewClient(new LocalWebViewClient());

        // Display-Bruecke: siehe klangraum\android-src\ScreenBridge.java.
        webView.addJavascriptInterface(new ScreenBridge(this), "KrAndroid");
'@.TrimEnd() 'setWebViewClient'

Write-TextNoBom -Path $mainActivityPath -Content $java
Write-Host "  [ok] Display-Bruecke eingebaut" -ForegroundColor Green

$buildArgs = @{ App = $AppName }
if ($Release) { $buildArgs.Release = $true }
if ($Install) { $buildArgs.Install = $true }
& "$ApkBuilder\build-apk.ps1" @buildArgs

if ($Release) {
    $latest = Get-ChildItem (Join-Path $ApkBuilder 'out') -Filter "$AppName-release-*.apk" |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $latest) { throw "Keine Release-APK in apk-builder\out gefunden" }
    $dist = Join-Path $ProjectRoot 'dist'
    if (-not (Test-Path $dist)) { New-Item -ItemType Directory -Path $dist | Out-Null }
    Get-ChildItem $dist -Filter 'klangraum-*.apk' | Remove-Item -Force
    $target = Join-Path $dist "klangraum-$VersionName.apk"
    Copy-Item $latest.FullName $target -Force
    Write-Host "  [ok] $target" -ForegroundColor Green
}
