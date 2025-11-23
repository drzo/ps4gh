#Requires -Version 5.1

<#
.SYNOPSIS
    Manage GitHub account with PowerShell using PowerShellForGitHub module.

.DESCRIPTION
    This script demonstrates how to use PowerShellForGitHub module to:
    - Connect to GitHub
    - List repositories
    - Create new repositories
    - Upload files and README

.NOTES
    File Name      : GitHubManager.ps1
    Prerequisite   : PowerShellForGitHub module
    Author         : GitHub PowerShell Examples
#>

#region Module Installation and Setup

<#
.SYNOPSIS
    Install PowerShellForGitHub module
#>
function Install-GitHubModule {
    [CmdletBinding()]
    param()
    
    Write-Host "Installing PowerShellForGitHub module..." -ForegroundColor Cyan
    
    if (Get-Module -ListAvailable -Name PowerShellForGitHub) {
        Write-Host "PowerShellForGitHub module is already installed." -ForegroundColor Green
    }
    else {
        Install-Module -Name PowerShellForGitHub -Scope CurrentUser -Force
        Write-Host "PowerShellForGitHub module installed successfully." -ForegroundColor Green
    }
    
    Import-Module PowerShellForGitHub
}

<#
.SYNOPSIS
    Configure GitHub authentication
#>
function Set-GitHubAuthentication {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$AccessToken
    )
    
    Write-Host "Configuring GitHub authentication..." -ForegroundColor Cyan
    
    $secureToken = ConvertTo-SecureString -String $AccessToken -AsPlainText -Force
    Set-GitHubAuthentication -SessionOnly -AccessToken $secureToken
    
    Write-Host "GitHub authentication configured successfully." -ForegroundColor Green
}

#endregion

#region Repository Management

<#
.SYNOPSIS
    List all repositories for the authenticated user
#>
function Get-MyGitHubRepositories {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('All', 'Owner', 'Public', 'Private', 'Member')]
        [string]$Type = 'All',
        
        [Parameter()]
        [ValidateSet('Created', 'Updated', 'Pushed', 'FullName')]
        [string]$Sort = 'Updated',
        
        [Parameter()]
        [ValidateSet('Ascending', 'Descending')]
        [string]$Direction = 'Descending'
    )
    
    Write-Host "Fetching GitHub repositories..." -ForegroundColor Cyan
    
    $params = @{
        Visibility = $Type
        Sort = $Sort
        Direction = $Direction
    }
    
    $repos = Get-GitHubRepository @params
    
    Write-Host "Found $($repos.Count) repositories:" -ForegroundColor Green
    $repos | Format-Table Name, Description, Private, Updated_At -AutoSize
    
    return $repos
}

<#
.SYNOPSIS
    Create a new GitHub repository
#>
function New-GitHubRepo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryName,
        
        [Parameter()]
        [string]$Description = "",
        
        [Parameter()]
        [switch]$Private,
        
        [Parameter()]
        [switch]$AutoInit,
        
        [Parameter()]
        [string]$GitignoreTemplate,
        
        [Parameter()]
        [string]$LicenseTemplate
    )
    
    Write-Host "Creating repository '$RepositoryName'..." -ForegroundColor Cyan
    
    $params = @{
        RepositoryName = $RepositoryName
        Description = $Description
        Private = $Private.IsPresent
        AutoInit = $AutoInit.IsPresent
    }
    
    if ($GitignoreTemplate) {
        $params['GitignoreTemplate'] = $GitignoreTemplate
    }
    
    if ($LicenseTemplate) {
        $params['LicenseTemplate'] = $LicenseTemplate
    }
    
    try {
        $repo = New-GitHubRepository @params
        Write-Host "Repository created successfully!" -ForegroundColor Green
        Write-Host "URL: $($repo.html_url)" -ForegroundColor Yellow
        return $repo
    }
    catch {
        Write-Error "Failed to create repository: $_"
    }
}

<#
.SYNOPSIS
    Upload a file to a GitHub repository
#>
function Add-GitHubFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Owner,
        
        [Parameter(Mandatory = $true)]
        [string]$RepositoryName,
        
        [Parameter(Mandatory = $true)]
        [string]$Path,
        
        [Parameter(Mandatory = $true)]
        [string]$Content,
        
        [Parameter(Mandatory = $true)]
        [string]$CommitMessage,
        
        [Parameter()]
        [string]$Branch = "main"
    )
    
    Write-Host "Uploading file '$Path' to repository..." -ForegroundColor Cyan
    
    try {
        $params = @{
            OwnerName = $Owner
            RepositoryName = $RepositoryName
            Path = $Path
            Content = $Content
            CommitMessage = $CommitMessage
            BranchName = $Branch
        }
        
        $result = Set-GitHubContent @params
        Write-Host "File uploaded successfully!" -ForegroundColor Green
        return $result
    }
    catch {
        Write-Error "Failed to upload file: $_"
    }
}

<#
.SYNOPSIS
    Create or update README.md file in a repository
#>
function Set-GitHubReadme {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Owner,
        
        [Parameter(Mandatory = $true)]
        [string]$RepositoryName,
        
        [Parameter(Mandatory = $true)]
        [string]$ReadmeContent,
        
        [Parameter()]
        [string]$Branch = "main"
    )
    
    Write-Host "Updating README.md..." -ForegroundColor Cyan
    
    try {
        $params = @{
            OwnerName = $Owner
            RepositoryName = $RepositoryName
            Path = "README.md"
            Content = $ReadmeContent
            CommitMessage = "Update README.md"
            BranchName = $Branch
        }
        
        $result = Set-GitHubContent @params
        Write-Host "README.md updated successfully!" -ForegroundColor Green
        return $result
    }
    catch {
        Write-Error "Failed to update README: $_"
    }
}

<#
.SYNOPSIS
    Get repository information
#>
function Get-GitHubRepoInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Owner,
        
        [Parameter(Mandatory = $true)]
        [string]$RepositoryName
    )
    
    Write-Host "Fetching repository information..." -ForegroundColor Cyan
    
    try {
        $repo = Get-GitHubRepository -OwnerName $Owner -RepositoryName $RepositoryName
        
        Write-Host "`nRepository Details:" -ForegroundColor Green
        Write-Host "  Name: $($repo.name)"
        Write-Host "  Description: $($repo.description)"
        Write-Host "  URL: $($repo.html_url)"
        Write-Host "  Private: $($repo.private)"
        Write-Host "  Stars: $($repo.stargazers_count)"
        Write-Host "  Forks: $($repo.forks_count)"
        Write-Host "  Language: $($repo.language)"
        Write-Host "  Created: $($repo.created_at)"
        Write-Host "  Updated: $($repo.updated_at)"
        
        return $repo
    }
    catch {
        Write-Error "Failed to get repository information: $_"
    }
}

#endregion

#region Example Usage Functions

<#
.SYNOPSIS
    Example: Complete workflow to create a repository and upload files
#>
function Invoke-GitHubExample {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$AccessToken,
        
        [Parameter(Mandatory = $true)]
        [string]$NewRepoName
    )
    
    Write-Host "`n========================================" -ForegroundColor Magenta
    Write-Host "GitHub Management Example Workflow" -ForegroundColor Magenta
    Write-Host "========================================`n" -ForegroundColor Magenta
    
    # Step 1: Install and import module
    Install-GitHubModule
    
    # Step 2: Authenticate
    Set-GitHubAuthentication -AccessToken $AccessToken
    
    # Step 3: List existing repositories
    Write-Host "`nStep 1: Listing existing repositories..." -ForegroundColor Yellow
    Get-MyGitHubRepositories
    
    # Step 4: Create new repository
    Write-Host "`nStep 2: Creating new repository..." -ForegroundColor Yellow
    $repo = New-GitHubRepo -RepositoryName $NewRepoName `
                           -Description "Created with PowerShellForGitHub" `
                           -AutoInit
    
    # Wait a moment for repository to be ready
    Start-Sleep -Seconds 2
    
    # Step 5: Upload README
    Write-Host "`nStep 3: Creating README.md..." -ForegroundColor Yellow
    $readmeContent = @"
# $NewRepoName

This repository was created using PowerShellForGitHub module.

## About

PowerShellForGitHub is a PowerShell module that provides command-line interaction and automation for GitHub.

## Features

- Easy repository management
- File operations
- Issue and PR management
- And much more!

Created on: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@
    
    $owner = $repo.owner.login
    Set-GitHubReadme -Owner $owner -RepositoryName $NewRepoName -ReadmeContent $readmeContent
    
    # Step 6: Upload additional file
    Write-Host "`nStep 4: Uploading example file..." -ForegroundColor Yellow
    $fileContent = "# Example File`n`nThis is an example file uploaded via PowerShell."
    Add-GitHubFile -Owner $owner `
                   -RepositoryName $NewRepoName `
                   -Path "example.md" `
                   -Content $fileContent `
                   -CommitMessage "Add example.md file"
    
    # Step 7: Display repository info
    Write-Host "`nStep 5: Repository information..." -ForegroundColor Yellow
    Get-GitHubRepoInfo -Owner $owner -RepositoryName $NewRepoName
    
    Write-Host "`n========================================" -ForegroundColor Magenta
    Write-Host "Example workflow completed successfully!" -ForegroundColor Magenta
    Write-Host "========================================`n" -ForegroundColor Magenta
}

#endregion

# Export functions
Export-ModuleMember -Function @(
    'Install-GitHubModule',
    'Set-GitHubAuthentication',
    'Get-MyGitHubRepositories',
    'New-GitHubRepo',
    'Add-GitHubFile',
    'Set-GitHubReadme',
    'Get-GitHubRepoInfo',
    'Invoke-GitHubExample'
)
