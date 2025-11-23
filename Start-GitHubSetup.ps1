#Requires -Version 5.1

<#
.SYNOPSIS
    Quick start script for PowerShellForGitHub

.DESCRIPTION
    This script helps you get started with PowerShellForGitHub by:
    - Checking if the module is installed
    - Installing it if needed
    - Guiding you through authentication
    - Running a simple test

.EXAMPLE
    .\Start-GitHubSetup.ps1
    
.EXAMPLE
    .\Start-GitHubSetup.ps1 -SkipTest
#>

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$SkipTest
)

# Set strict mode
Set-StrictMode -Version Latest

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "PowerShellForGitHub Setup Script" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Step 1: Check PowerShell version
Write-Host "Checking PowerShell version..." -ForegroundColor Yellow
$psVersion = $PSVersionTable.PSVersion
Write-Host "  PowerShell Version: $psVersion" -ForegroundColor Green

if ($psVersion.Major -lt 5) {
    Write-Error "PowerShell 5.1 or higher is required. Current version: $psVersion"
    exit 1
}

# Step 2: Check if module is installed
Write-Host "`nChecking for PowerShellForGitHub module..." -ForegroundColor Yellow

$module = Get-Module -ListAvailable -Name PowerShellForGitHub

if ($module) {
    Write-Host "  Module is installed (Version: $($module.Version))" -ForegroundColor Green
} else {
    Write-Host "  Module is not installed" -ForegroundColor Red
    
    $install = Read-Host "`nWould you like to install PowerShellForGitHub now? (Y/N)"
    
    if ($install -eq 'Y' -or $install -eq 'y') {
        Write-Host "`nInstalling PowerShellForGitHub..." -ForegroundColor Yellow
        
        try {
            Install-Module -Name PowerShellForGitHub -Scope CurrentUser -Force -AllowClobber
            Write-Host "  Module installed successfully!" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to install module: $_"
            exit 1
        }
    } else {
        Write-Host "`nPlease install the module manually:" -ForegroundColor Yellow
        Write-Host "  Install-Module PowerShellForGitHub -Scope CurrentUser" -ForegroundColor White
        exit 0
    }
}

# Step 3: Import module
Write-Host "`nImporting PowerShellForGitHub module..." -ForegroundColor Yellow

try {
    Import-Module PowerShellForGitHub -ErrorAction Stop
    Write-Host "  Module imported successfully!" -ForegroundColor Green
}
catch {
    Write-Error "Failed to import module: $_"
    exit 1
}

# Step 4: Guide user through authentication
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Authentication Setup" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "To use PowerShellForGitHub, you need a Personal Access Token (PAT)." -ForegroundColor White
Write-Host "`nTo create a PAT:" -ForegroundColor Yellow
Write-Host "  1. Go to: https://github.com/settings/tokens" -ForegroundColor White
Write-Host "  2. Click 'Generate new token (classic)'" -ForegroundColor White
Write-Host "  3. Give it a name (e.g., 'PowerShell GitHub Access')" -ForegroundColor White
Write-Host "  4. Select scopes: 'repo', 'user' (minimum)" -ForegroundColor White
Write-Host "  5. Click 'Generate token' and copy it" -ForegroundColor White

Write-Host "`nDo you have a Personal Access Token? (Y/N)" -ForegroundColor Yellow
$hasToken = Read-Host

if ($hasToken -eq 'Y' -or $hasToken -eq 'y') {
    Write-Host "`nPlease enter your GitHub Personal Access Token:" -ForegroundColor Yellow
    Write-Host "(Note: Input will be hidden)" -ForegroundColor Gray
    $secureToken = Read-Host -AsSecureString
    
    try {
        Set-GitHubAuthentication -SessionOnly -AccessToken $secureToken
        Write-Host "  Authentication configured successfully!" -ForegroundColor Green
        
        # Test authentication
        if (-not $SkipTest) {
            Write-Host "`nTesting authentication..." -ForegroundColor Yellow
            
            try {
                $user = Invoke-GHRestMethod -UriFragment "user"
                Write-Host "  Successfully authenticated as: $($user.login)" -ForegroundColor Green
                Write-Host "  Name: $($user.name)" -ForegroundColor White
                Write-Host "  Public Repos: $($user.public_repos)" -ForegroundColor White
            }
            catch {
                Write-Warning "Authentication test failed: $_"
            }
        }
    }
    catch {
        Write-Error "Failed to configure authentication: $_"
        exit 1
    }
} else {
    Write-Host "`nNo problem! You can authenticate later using:" -ForegroundColor Yellow
    Write-Host "  `$token = 'your_token_here'" -ForegroundColor White
    Write-Host "  `$secureToken = ConvertTo-SecureString -String `$token -AsPlainText -Force" -ForegroundColor White
    Write-Host "  Set-GitHubAuthentication -SessionOnly -AccessToken `$secureToken" -ForegroundColor White
}

# Step 5: Show next steps
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Try listing your repositories:" -ForegroundColor White
Write-Host "     Get-GitHubRepository" -ForegroundColor Gray
Write-Host "`n  2. Use our convenient wrapper functions:" -ForegroundColor White
Write-Host "     . .\GitHubManager.ps1" -ForegroundColor Gray
Write-Host "     Connect-GitHub -AccessToken 'your_token'" -ForegroundColor Gray
Write-Host "     Get-MyGitHubRepositories" -ForegroundColor Gray
Write-Host "`n  3. Read the documentation:" -ForegroundColor White
Write-Host "     - README.md (in this repository)" -ForegroundColor Gray
Write-Host "     - EXAMPLES.md (quick reference)" -ForegroundColor Gray
Write-Host "     - https://aka.ms/PowerShellForGitHub (official docs)" -ForegroundColor Gray

Write-Host "`nUseful commands:" -ForegroundColor Yellow
Write-Host "  Get-Command -Module PowerShellForGitHub" -ForegroundColor Gray
Write-Host "  Get-Help New-GitHubRepository -Full" -ForegroundColor Gray
Write-Host "  Get-GitHubConfiguration" -ForegroundColor Gray

Write-Host "`nHappy automating! 🚀`n" -ForegroundColor Green
