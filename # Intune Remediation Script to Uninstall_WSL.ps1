# Intune Remediation Script to Uninstall WSL and Remove Features

# Check if the script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "This script must be run as an Administrator. Relaunching with elevated privileges..."
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit 0
}

# Function to remove a Windows feature
function Remove-Feature {
    param (
        [string]$FeatureName
    )
    try {
        Write-Output "Removing feature: $FeatureName"
        Disable-WindowsOptionalFeature -FeatureName $FeatureName -Online -NoRestart -ErrorAction Stop
        Start-Sleep -Seconds 5 # Wait to ensure the feature removal completes
    } catch {
        Write-Output "Failed to remove feature: $FeatureName. Error: $_"
        exit 1
    }
}

# Uninstall WSL distributions
Write-Output "Uninstalling WSL distributions..."
try {
    $distributions = wsl --list --quiet 2>$null
    if ($distributions) {
        foreach ($distro in $distributions) {
            Write-Output "Unregistering WSL distribution: $distro"
            wsl --unregister $distro
            Start-Sleep -Seconds 5 # Wait to ensure the distribution is unregistered
        }
        Write-Output "All WSL distributions unregistered."
    } else {
        Write-Output "No WSL distributions found."
    }
} catch {
    Write-Output "Failed to unregister WSL distributions. Error: $_"
    exit 1
}

# Uninstall WSL
Write-Output "Uninstalling WSL..."
try {
    wsl --uninstall
    Start-Sleep -Seconds 5 # Wait to ensure WSL is uninstalled
    Write-Output "WSL uninstalled successfully."
} catch {
    Write-Output "Failed to uninstall WSL. Error: $_"
    exit 1
}

# Remove required features
Write-Output "Disabling Windows features for WSL..."
$features = @("Microsoft-Windows-Subsystem-Linux", "VirtualMachinePlatform")
foreach ($feature in $features) {
    Remove-Feature -FeatureName $feature
}

# Check if a restart is required
try {
    if ((Get-PendingRestart).IsRebootPending -or (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending")) {
        Write-Output "A restart is required to complete the changes. Restarting now..."
        Restart-Computer -Force
    } else {
        Write-Output "No restart is required. Changes completed successfully."
    }
} catch {
    Write-Output "Failed to restart the computer. Error: $_"
    exit 1
}