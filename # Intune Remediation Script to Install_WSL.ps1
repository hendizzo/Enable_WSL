# Intune Script to Enable WSL Features, Install WSL, Update It, and Install Ubuntu 24.04

# Check if the script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "This script must be run as an Administrator. Relaunching with elevated privileges..."
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit 0
}

# Function to enable a Windows feature
function Enable-Feature {
    param (
        [string]$FeatureName
    )
    try {
        Write-Output "Enabling feature: $FeatureName"
        Enable-WindowsOptionalFeature -FeatureName $FeatureName -Online -NoRestart -ErrorAction Stop
        Start-Sleep -Seconds 5 # Wait to ensure the feature is enabled
    } catch {
        Write-Output "Failed to enable feature: $FeatureName. Error: $_"
        exit 1
    }
}

# Enable required features for WSL
$features = @("Microsoft-Windows-Subsystem-Linux", "VirtualMachinePlatform")
foreach ($feature in $features) {
    Enable-Feature -FeatureName $feature
}

# Install WSL
Write-Output "Installing WSL..."
try {
    wsl --install -d Ubuntu 2>$null
    Start-Sleep -Seconds 10 # Wait to ensure WSL installation completes
    Write-Output "WSL installed successfully."
} catch {
    Write-Output "Failed to install WSL. Error: $_"
    exit 1
}

# Update WSL
Write-Output "Updating WSL..."
try {
    wsl --update
    Start-Sleep -Seconds 10 # Wait to ensure WSL update completes
    Write-Output "WSL updated successfully."
} catch {
    Write-Output "Failed to update WSL. Error: $_"
    exit 1
}

# Install Ubuntu 24.04
Write-Output "Installing Ubuntu 24.04 distribution..."
try {
    wsl --install -d "Ubuntu-24.04"
    Start-Sleep -Seconds 10 # Wait to ensure Ubuntu installation completes
    Write-Output "Ubuntu 24.04 installed successfully."
} catch {
    Write-Output "Failed to install Ubuntu 24.04. Error: $_"
    exit 1
}

# Check if a restart is required
if ((Get-PendingRestart).IsRebootPending -or (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending")) {
    Write-Output "A restart is required to complete the changes. Restarting now..."
    Restart-Computer -Force
} else {
    Write-Output "No restart is required. WSL setup completed successfully."
}