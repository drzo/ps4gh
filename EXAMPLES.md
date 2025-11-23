# Quick Start Examples

This file contains quick copy-paste examples for common GitHub operations using PowerShellForGitHub module directly.

> **Note**: This repository also provides wrapper functions in `GitHubManager.ps1` for convenience (e.g., `Connect-GitHub` instead of `Set-GitHubAuthentication`). See the main README.md for details on using those wrapper functions. The examples below use the PowerShellForGitHub module cmdlets directly.

## Installation and Setup

```powershell
# Install the module
Install-Module PowerShellForGitHub -Scope CurrentUser

# Import the module
Import-Module PowerShellForGitHub

# Set up authentication (replace with your token)
$token = "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$secureToken = ConvertTo-SecureString -String $token -AsPlainText -Force
Set-GitHubAuthentication -SessionOnly -AccessToken $secureToken
```

## List Your Repositories

```powershell
# List all repositories
Get-GitHubRepository

# List only your own repositories
Get-GitHubRepository -Visibility Owner

# List private repositories
Get-GitHubRepository -Visibility Private

# Sort by last updated
Get-GitHubRepository -Sort Updated -Direction Descending
```

## Create a New Repository

```powershell
# Simple repository
New-GitHubRepository -RepositoryName "my-repo"

# Repository with description
New-GitHubRepository -RepositoryName "my-repo" -Description "My awesome project"

# Private repository with README
New-GitHubRepository -RepositoryName "my-repo" -Private -AutoInit

# Repository with .gitignore and license
New-GitHubRepository -RepositoryName "my-python-project" `
    -Description "Python project" `
    -AutoInit `
    -GitignoreTemplate "Python" `
    -LicenseTemplate "mit"
```

## Upload Files to Repository

```powershell
# Upload a simple text file
Set-GitHubContent -OwnerName "your-username" `
    -RepositoryName "your-repo" `
    -Path "hello.txt" `
    -Content "Hello, World!" `
    -CommitMessage "Add hello.txt"

# Upload a README.md
$readmeContent = @"
# My Project
This is my project description.
"@

Set-GitHubContent -OwnerName "your-username" `
    -RepositoryName "your-repo" `
    -Path "README.md" `
    -Content $readmeContent `
    -CommitMessage "Add README"

# Upload to a specific branch
Set-GitHubContent -OwnerName "your-username" `
    -RepositoryName "your-repo" `
    -Path "feature.md" `
    -Content "New feature documentation" `
    -CommitMessage "Add feature docs" `
    -BranchName "develop"
```

## Get Repository Information

```powershell
# Get specific repository details
Get-GitHubRepository -OwnerName "microsoft" -RepositoryName "PowerShellForGitHub"

# Get repository with statistics
$repo = Get-GitHubRepository -OwnerName "your-username" -RepositoryName "your-repo"
Write-Host "Stars: $($repo.stargazers_count)"
Write-Host "Forks: $($repo.forks_count)"
Write-Host "Open Issues: $($repo.open_issues_count)"
```

## Working with Files

```powershell
# Get file content
Get-GitHubContent -OwnerName "your-username" `
    -RepositoryName "your-repo" `
    -Path "README.md"

# List files in a directory
Get-GitHubContent -OwnerName "your-username" `
    -RepositoryName "your-repo" `
    -Path "docs/"

# Update existing file
Set-GitHubContent -OwnerName "your-username" `
    -RepositoryName "your-repo" `
    -Path "README.md" `
    -Content "Updated content" `
    -CommitMessage "Update README" `
    -Sha "current-file-sha"  # Required for updates
```

## Working with Issues

```powershell
# Create an issue
New-GitHubIssue -OwnerName "your-username" `
    -RepositoryName "your-repo" `
    -Title "Bug: Something is broken" `
    -Body "Description of the issue"

# List issues
Get-GitHubIssue -OwnerName "your-username" `
    -RepositoryName "your-repo" `
    -State Open

# Close an issue
Set-GitHubIssue -OwnerName "your-username" `
    -RepositoryName "your-repo" `
    -Issue 1 `
    -State Closed
```

## Working with Branches

```powershell
# List branches
Get-GitHubRepositoryBranch -OwnerName "your-username" `
    -RepositoryName "your-repo"

# Create a new branch
New-GitHubRepositoryBranch -OwnerName "your-username" `
    -RepositoryName "your-repo" `
    -BranchName "feature/new-feature" `
    -TargetBranchName "main"
```

## Repository Settings

```powershell
# Update repository description
Update-GitHubRepository -OwnerName "your-username" `
    -RepositoryName "your-repo" `
    -Description "Updated description"

# Make repository private
Update-GitHubRepository -OwnerName "your-username" `
    -RepositoryName "your-repo" `
    -Private

# Archive a repository
Update-GitHubRepository -OwnerName "your-username" `
    -RepositoryName "your-repo" `
    -Archived
```

## Working with Releases

```powershell
# Get latest release
Get-GitHubRelease -OwnerName "microsoft" `
    -RepositoryName "PowerShellForGitHub" `
    -Latest

# List all releases
Get-GitHubRelease -OwnerName "microsoft" `
    -RepositoryName "PowerShellForGitHub"

# Create a new release
New-GitHubRelease -OwnerName "your-username" `
    -RepositoryName "your-repo" `
    -Tag "v1.0.0" `
    -Name "Version 1.0.0" `
    -Body "Release notes here"
```

## Bulk Operations

```powershell
# Create multiple repositories
$repoNames = @("repo1", "repo2", "repo3")
foreach ($name in $repoNames) {
    New-GitHubRepository -RepositoryName $name -Description "Auto-created repo"
    Start-Sleep -Seconds 1  # Rate limiting
}

# List all repositories and export to CSV
Get-GitHubRepository | 
    Select-Object name, description, private, html_url, stargazers_count, forks_count |
    Export-Csv -Path "my-repos.csv" -NoTypeInformation

# Bulk update repository descriptions
$repos = Get-GitHubRepository -Visibility Owner
foreach ($repo in $repos) {
    if ([string]::IsNullOrEmpty($repo.description)) {
        Update-GitHubRepository -OwnerName $repo.owner.login `
            -RepositoryName $repo.name `
            -Description "Auto-updated description"
    }
}
```

## Advanced: Working with GitHub API Directly

```powershell
# Get authenticated user information
$user = Invoke-GHRestMethod -UriFragment "user"
Write-Host "Logged in as: $($user.login)"

# Search repositories
$searchResults = Invoke-GHRestMethod -UriFragment "search/repositories?q=language:powershell+stars:>100"
$searchResults.items | Select-Object name, description, stargazers_count
```

## Configuration

```powershell
# Set default owner
Set-GitHubConfiguration -DefaultOwnerName "your-username"

# Set log path
Set-GitHubConfiguration -LogPath "$env:TEMP\PowerShellForGitHub.log"

# Disable telemetry
Set-GitHubConfiguration -DisableTelemetry

# Get current configuration
Get-GitHubConfiguration
```

## Cleanup

```powershell
# Clear authentication (end of session)
Clear-GitHubAuthentication
```

## Tips and Best Practices

1. **Always use Personal Access Tokens** instead of passwords for authentication
2. **Set appropriate scopes** when creating PATs (e.g., `repo`, `user`, `delete_repo`)
3. **Use `-SessionOnly`** flag to avoid persisting tokens to disk
4. **Rate limiting**: Add delays between bulk operations with `Start-Sleep`
5. **Error handling**: Wrap operations in try-catch blocks for production scripts
6. **Keep tokens secure**: Never commit tokens to source control
7. **Use variables**: Store owner and repo names in variables for easier maintenance

## Example: Complete Automation Script

```powershell
# Complete automation example
param(
    [Parameter(Mandatory=$true)]
    [string]$Token,
    
    [Parameter(Mandatory=$true)]
    [string]$RepoName
)

try {
    # Setup
    Import-Module PowerShellForGitHub
    $secureToken = ConvertTo-SecureString -String $Token -AsPlainText -Force
    Set-GitHubAuthentication -SessionOnly -AccessToken $secureToken
    
    # Create repository
    Write-Host "Creating repository..."
    $repo = New-GitHubRepository -RepositoryName $RepoName -AutoInit
    
    # Wait for initialization
    Start-Sleep -Seconds 3
    
    # Add README
    Write-Host "Adding README..."
    $readme = "# $RepoName`n`nCreated via automation"
    Set-GitHubContent -OwnerName $repo.owner.login `
        -RepositoryName $RepoName `
        -Path "README.md" `
        -Content $readme `
        -CommitMessage "Initial README"
    
    Write-Host "Success! Repository URL: $($repo.html_url)" -ForegroundColor Green
}
catch {
    Write-Error "Failed: $_"
}
finally {
    Clear-GitHubAuthentication
}
```
