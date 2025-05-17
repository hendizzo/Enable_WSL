# Intune Detection Script for WSL Features

# Check if the script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "This script must be run as an Administrator. Relaunching with elevated privileges..."
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit 0
}

# Function to check if a Windows feature is enabled
function Test-FeatureEnabled {
    param (
        [string]$FeatureName
    )
    $feature = Get-WindowsOptionalFeature -FeatureName $FeatureName -Online
    return $feature.State -eq "Enabled"
}

# Check for required features
$wslFeature = "Microsoft-Windows-Subsystem-Linux"
$vmPlatformFeature = "VirtualMachinePlatform"

$wslEnabled = Test-FeatureEnabled -FeatureName $wslFeature
$vmPlatformEnabled = Test-FeatureEnabled -FeatureName $vmPlatformFeature

# Detection logic
if ($wslEnabled -and $vmPlatformEnabled) {
    Write-Output "WSL features are enabled."
    exit 0 # Detection successful
} else {
    Write-Output "WSL features are not enabled."
    Write-Output "Please enable the required features in Windows Settings."
    exit 1 # Detection failed
}