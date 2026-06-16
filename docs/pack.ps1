# pack.ps1 - build the js-dos bundle  docs/city.jsdos
#
# Run from anywhere, e.g. from the repo root:
#     powershell -ExecutionPolicy Bypass -File docs\pack.ps1
#
# A .jsdos bundle is a ZIP holding the program files plus .jsdos/dosbox.conf.
# We build it with .NET ZipArchive (NOT Compress-Archive): Windows PowerShell
# 5.1's Compress-Archive writes BACKSLASH entry names, which violate the ZIP
# spec and break js-dos's unzip in the browser. .NET lets us force "/".
#
# NOTE: if the page still fails to start, the bundle layout for your js-dos
# release may differ - build it with the online studio at https://js-dos.com
# (drop in CITY.COM, set command CITY.COM, export .jsdos).

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root = Split-Path -Parent $PSScriptRoot       # repo root (parent of docs)
$com  = Join-Path $root "CITY.COM"
$conf = Join-Path $root "docs\dosbox.conf"
$out  = Join-Path $root "docs\city.jsdos"

if (-not (Test-Path $com)) {
    throw "CITY.COM not found in $root - build it first (see BUILD.BAT)."
}

if (Test-Path $out) { Remove-Item -Force $out }

$fs  = [System.IO.File]::Open($out, [System.IO.FileMode]::CreateNew)
$zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)

function Add-ZipEntry($zip, $path, $name) {
    $entry  = $zip.CreateEntry($name, [System.IO.Compression.CompressionLevel]::Optimal)
    $stream = $entry.Open()
    $bytes  = [System.IO.File]::ReadAllBytes($path)
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Close()
}

Add-ZipEntry $zip $com  "CITY.COM"
Add-ZipEntry $zip $conf ".jsdos/dosbox.conf"

$zip.Dispose()
$fs.Close()
Write-Host "Created docs/city.jsdos"
