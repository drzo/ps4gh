# ps4gh - PowerShell for GitHub

Manage your GitHub account with PowerShell using the PowerShellForGitHub module. This repository provides examples and utilities for connecting to GitHub, listing repositories, creating repos, uploading files, and more.

## Table of Contents

- [About PowerShellForGitHub](#about-powershellforgithub)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [Authentication](#authentication)
- [Usage Examples](#usage-examples)
  - [List Repositories](#list-repositories)
  - [Create a Repository](#create-a-repository)
  - [Upload Files](#upload-files)
  - [Update README](#update-readme)
- [Complete Example Workflow](#complete-example-workflow)
- [Available Functions](#available-functions)
- [Resources](#resources)

## About PowerShellForGitHub

**PowerShellForGitHub** is a powerful PowerShell module developed by the Microsoft PowerShell team that provides command-line interaction and automation capabilities for GitHub. It allows you to manage repositories, issues, pull requests, and much more directly from PowerShell.

## Installation

The PowerShellForGitHub module is available on the PowerShell Gallery. You can install it using the following command:

```powershell
Install-Module PowerShellForGitHub -Scope CurrentUser
```

Or if you prefer to install it for all users (requires administrator privileges):

```powershell
Install-Module PowerShellForGitHub -Scope AllUsers
```

After installation, import the module:

```powershell
Import-Module PowerShellForGitHub
```

## Getting Started

1. **Clone this repository:**
   ```powershell
   git clone https://github.com/drzo/ps4gh.git
   cd ps4gh
   ```

2. **Import the GitHubManager script:**
   ```powershell
   . .\GitHubManager.ps1
   ```

3. **Install the PowerShellForGitHub module (if not already installed):**
   ```powershell
   Install-GitHubModule
   ```

## Authentication

To use PowerShellForGitHub, you need to authenticate with GitHub. The recommended method is using a Personal Access Token (PAT).

### Creating a Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Give your token a descriptive name
4. Select the scopes/permissions you need (e.g., `repo`, `user`, `delete_repo`)
5. Click "Generate token"
6. Copy the token immediately (you won't be able to see it again)

### Authenticate in PowerShell

```powershell
$token = "your_github_personal_access_token"
Connect-GitHub -AccessToken $token
```

## Usage Examples

### List Repositories

List all your repositories:

```powershell
Get-MyGitHubRepositories
```

List only private repositories:

```powershell
Get-MyGitHubRepositories -Type Private
```

List repositories sorted by creation date:

```powershell
Get-MyGitHubRepositories -Sort Created -Direction Descending
```

### Create a Repository

Create a simple public repository:

```powershell
New-GitHubRepo -RepositoryName "my-new-repo" -Description "My awesome project"
```

Create a private repository with auto-initialization:

```powershell
New-GitHubRepo -RepositoryName "my-private-repo" `
               -Description "Private project" `
               -Private `
               -AutoInit
```

Create a repository with .gitignore and license:

```powershell
New-GitHubRepo -RepositoryName "python-project" `
               -Description "Python project" `
               -AutoInit `
               -GitignoreTemplate "Python" `
               -LicenseTemplate "mit"
```

### Upload Files

Upload a file to a repository:

```powershell
$fileContent = "# Hello World`n`nThis is my file content."
Add-GitHubFile -Owner "your-username" `
               -RepositoryName "my-repo" `
               -Path "hello.md" `
               -Content $fileContent `
               -CommitMessage "Add hello.md"
```

### Update README

Create or update a README.md file:

```powershell
$readmeContent = @"
# My Project

This is my project description.

## Installation
...
"@

Set-GitHubReadme -Owner "your-username" `
                 -RepositoryName "my-repo" `
                 -ReadmeContent $readmeContent
```

### Get Repository Information

Get detailed information about a repository:

```powershell
Get-GitHubRepoInfo -Owner "your-username" -RepositoryName "my-repo"
```

## Complete Example Workflow

Here's a complete example that demonstrates the entire workflow:

```powershell
# Import the script
. .\GitHubManager.ps1

# Set your GitHub token
$token = "ghp_your_token_here"

# Run the complete example workflow
Invoke-GitHubExample -AccessToken $token -NewRepoName "test-repo-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
```

This will:
1. Install and import the PowerShellForGitHub module
2. Authenticate with GitHub
3. List your existing repositories
4. Create a new repository
5. Create a README.md file
6. Upload an example file
7. Display the repository information

## Available Functions

The `GitHubManager.ps1` script provides the following functions:

| Function | Description |
|----------|-------------|
| `Install-GitHubModule` | Install the PowerShellForGitHub module |
| `Connect-GitHub` | Configure GitHub authentication |
| `Get-MyGitHubRepositories` | List repositories for the authenticated user |
| `New-GitHubRepo` | Create a new GitHub repository |
| `Add-GitHubFile` | Upload a file to a repository |
| `Set-GitHubReadme` | Create or update README.md |
| `Get-GitHubRepoInfo` | Get detailed repository information |
| `Invoke-GitHubExample` | Run a complete example workflow |

## Resources

- [PowerShellForGitHub GitHub Repository](https://github.com/microsoft/PowerShellForGitHub)
- [PowerShellForGitHub Documentation](https://aka.ms/PowerShellForGitHub)
- [GitHub REST API Documentation](https://docs.github.com/en/rest)
- [PowerShell Gallery - PowerShellForGitHub](https://www.powershellgallery.com/packages/PowerShellForGitHub)

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests.

## License

This project is licensed under the terms included in the LICENSE file.