# Save current directory
$originalDir = Get-Location

# Parse arguments
$ArgsMap = @{}
$debug = $false

foreach ($arg in $args) {
    if ($arg -like "-*") {
        $key = $arg.TrimStart("-")
        $ArgsMap[$key] = $true
        if ($key -eq "debug") {
            $debug = $true
        }
    }
}

# Platform full names and their shortcuts
$platformAliases = @{
    "air" = "air"
    "android" = "android"
    "flash" = "flash"
    "html5" = "html5"
    "ios" = "ios"
    "linux" = "linux"
    "mac" = "mac"
    "tvos" = "tvos"
    "webassembly" = "webassembly"
    "windows" = "windows"

    # shortcuts
    "win" = "windows"
    "macos" = "mac"
    "and" = "android"
}

$selectedPlatforms = @()

foreach ($key in $ArgsMap.Keys) {
    if ($key -ne "debug" -and $platformAliases.ContainsKey($key)) {
        $selectedPlatforms += $platformAliases[$key]
    }
}

if ($selectedPlatforms.Count -eq 0) {
    Write-Error "Please specify at least one platform, e.g. --windows or --win"
    exit 1
}

if ($selectedPlatforms.Count -gt 1) {
    Write-Error "Please specify only one platform"
    exit 1
}

$platform = $selectedPlatforms[0]

# Determine build type
$buildType = if ($debug) { "debug" } else { "release" }
$targetPath = Join-Path -Path "export/$buildType/$platform/bin" -ChildPath "crash"

if (-not (Test-Path $targetPath)) {
    Write-Error "Crash folder not found: $targetPath"
    exit 1
}

Write-Host "Looking for the most recent file in: $targetPath"

# Get the most recently modified file
$latestFile = Get-ChildItem -Path $targetPath -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($null -eq $latestFile) {
    Write-Error "No files found in the crash folder"
    exit 1
}

Write-Host "Opening latest file: $($latestFile.FullName)"
Start-Process -FilePath $latestFile.FullName
