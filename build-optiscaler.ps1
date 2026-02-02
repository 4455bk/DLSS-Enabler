# DLSS-Enabler OptiScaler Build Script
# This script downloads the latest OptiScaler release and copies files to the correct build locations

param(
    [string]$OptiScalerPath = "",
    [string]$OptiScalerVersion = "v0.9.0-pre9",
    [switch]$DownloadLatest = $false
)

$ErrorActionPreference = "Stop"

Write-Host "DLSS-Enabler OptiScaler Build Script" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# Determine OptiScaler archive path
if ($OptiScalerPath -eq "") {
    if ($DownloadLatest) {
        Write-Host "Downloading latest OptiScaler release..." -ForegroundColor Yellow
        # TODO: Add download logic here
        Write-Host "Error: Download functionality not implemented yet. Please provide -OptiScalerPath" -ForegroundColor Red
        exit 1
    } else {
        $OptiScalerPath = "C:\Users\ewojcik\Downloads\OptiScaler_v0.7.7-pre12_20250630.7z"
    }
}

# Verify OptiScaler archive exists
if (!(Test-Path $OptiScalerPath)) {
    Write-Host "Error: OptiScaler archive not found at: $OptiScalerPath" -ForegroundColor Red
    exit 1
}

Write-Host "Using OptiScaler archive: $OptiScalerPath" -ForegroundColor Cyan

# Use existing or create temporary extraction directory
$TempDir = "temp_optiscaler"
if (!(Test-Path $TempDir)) {
    Write-Host "Extracting OptiScaler archive..." -ForegroundColor Yellow
    & 7z x $OptiScalerPath -o$TempDir -y | Out-Null

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to extract OptiScaler archive" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Using existing extracted OptiScaler files..." -ForegroundColor Yellow
}

# Ensure Dll version directory exists
$DllVersionDir = "Dll version"
if (!(Test-Path $DllVersionDir)) {
    New-Item -ItemType Directory -Path $DllVersionDir | Out-Null
}

Write-Host "Copying OptiScaler files to build structure..." -ForegroundColor Yellow

# Define file mappings: Source -> Destination
$FileMappings = @{
    "$TempDir\OptiScaler.dll" = "$DllVersionDir\dlss-enabler-upscaler.dll"
    "$TempDir\OptiScaler.ini" = "$DllVersionDir\OptiScaler.ini"
    "$TempDir\libxell.dll" = "$DllVersionDir\libxell.dll"
    "$TempDir\libxess.dll" = "$DllVersionDir\libxess.dll"
    "$TempDir\libxess_dx11.dll" = "$DllVersionDir\libxess_dx11.dll"
    "$TempDir\libxess_fg.dll" = "$DllVersionDir\libxess_fg.dll"
    "$TempDir\amd_fidelityfx_denoiser_dx12.dll" = "$DllVersionDir\amd_fidelityfx_denoiser_dx12.dll"
    "$TempDir\amd_fidelityfx_dx12.dll" = "$DllVersionDir\amd_fidelityfx_dx12.dll"
    "$TempDir\amd_fidelityfx_framegeneration_dx12.dll" = "$DllVersionDir\amd_fidelityfx_framegeneration_dx12.dll"
    "$TempDir\amd_fidelityfx_radiancecache_dx12.dll" = "$DllVersionDir\amd_fidelityfx_radiancecache_dx12.dll"
    "$TempDir\amd_fidelityfx_upscaler_dx12.dll" = "$DllVersionDir\amd_fidelityfx_upscaler_dx12.dll"
    "$TempDir\amd_fidelityfx_vk.dll" = "$DllVersionDir\amd_fidelityfx_vk.dll"
    "$TempDir\dlssg_to_fsr3_amd_is_better.dll" = "$DllVersionDir\dlssg_to_fsr3_amd_is_better.dll"
    "$TempDir\D3D12_Optiscaler\D3D12Core.dll" = "$DllVersionDir\D3D12Core.dll"
}

# Copy files
foreach ($mapping in $FileMappings.GetEnumerator()) {
    $source = $mapping.Key
    $dest = $mapping.Value
    
    if (Test-Path $source) {
        Write-Host "  $source -> $dest" -ForegroundColor Gray
        Copy-Item $source $dest -Force
    } else {
        Write-Host "  Warning: Source file not found: $source" -ForegroundColor Yellow
    }
}

Write-Host "Cleaning up..." -ForegroundColor Yellow
# Don't remove the temp directory as it might be needed for future builds

Write-Host ""
Write-Host "OptiScaler files copied successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Build directory contents:" -ForegroundColor Cyan
Get-ChildItem $DllVersionDir | Format-Table Name, Length, LastWriteTime -AutoSize

Write-Host ""
Write-Host "You can now compile the installer with Inno Setup." -ForegroundColor Green
