# Function to check if a Windows feature is enabled
function Check-FeatureEnabled {
    param (
        [string]$FeatureName
    )
    $feature = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName
    return $feature.State -eq "Enabled"
}

# Function to enable a Windows feature
function Enable-Feature {
    param (
        [string]$FeatureName
    )
    Write-Host "Enabling feature: $FeatureName..."
    dism.exe /online /enable-feature /featurename:$FeatureName /all /norestart
}

# Check if WSL is enabled
$wslFeature = "Microsoft-Windows-Subsystem-Linux"
$wslEnabled = Check-FeatureEnabled -FeatureName $wslFeature

# Check if Virtual Machine Platform is enabled
$vmPlatformFeature = "VirtualMachinePlatform"
$vmPlatformEnabled = Check-FeatureEnabled -FeatureName $vmPlatformFeature

# Output results
Write-Host "Checking Windows features for WSL..."
Write-Host "WSL Feature Enabled: $wslEnabled"
Write-Host "Virtual Machine Platform Enabled: $vmPlatformEnabled"

# Enable features if not enabled
if (-not $wslEnabled) {
    Write-Host "The WSL feature is not enabled. Attempting to enable it..."
    Enable-Feature -FeatureName $wslFeature
}

if (-not $vmPlatformEnabled) {
    Write-Host "The Virtual Machine Platform feature is not enabled. Attempting to enable it..."
    Enable-Feature -FeatureName $vmPlatformFeature
}

# Final check
$wslEnabled = Check-FeatureEnabled -FeatureName $wslFeature
$vmPlatformEnabled = Check-FeatureEnabled -FeatureName $vmPlatformFeature

if ($wslEnabled -and $vmPlatformEnabled) {
    Write-Host "All required features for WSL are now enabled."
} else {
    Write-Host "Some features could not be enabled. Please check manually."
}