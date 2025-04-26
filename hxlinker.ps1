param (
    [string]$folder = "",
    [string]$lib = ""
)

if (-not (Test-Path $folder)) {
    Write-Error "❌ Folder '$folder' not found."
    exit 1
}

$basePath = (Get-Location).Path
$targetPath = (Resolve-Path $folder).Path

Get-ChildItem -Path $targetPath -Recurse -Filter *.hx | ForEach-Object {
    $fullPath = $_.FullName
    $relativePath = $fullPath.Substring($basePath.Length + 1)
    $relativePath = $relativePath -replace '^source[\\/]', ''   # remove "source/"
    $importPath = $relativePath -replace '[\\/]', '.' -replace '\.hx$', ''

    if ($lib) {
        # Remove lib if it's already part of the path
        if ($importPath -match "^$lib\.") {
            $importPath = $importPath -replace "^$lib\.", ""
        }
        $importPath = "$lib.$importPath"
    }

    # Check if the importPath has ".." and remove them
    if ($importPath -match "\.\.") {
        $importPath = $importPath -replace "\.\.", "."
    }

    Write-Output "import $importPath;"
}
