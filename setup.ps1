# QA Navigator - Setup Script
# Run once per computer. Installs the plugin and configures Azure DevOps + Confluence.

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   QA Navigator - Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------------------------
# Step 1 - Check / install Node.js
# ---------------------------------------------------------------------------
Write-Host "Step 1/4 - Checking Node.js..." -ForegroundColor Yellow

$nodeOk = $false
try {
    $nodeVersion = & node --version 2>$null
    if ($nodeVersion) {
        Write-Host "  Node.js is installed: $nodeVersion" -ForegroundColor Green
        $nodeOk = $true
    }
} catch {}

if (-not $nodeOk) {
    Write-Host "  Node.js not found. Installing via winget..." -ForegroundColor Yellow
    try {
        & winget install -e --id OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements
        # Refresh PATH so node is available in this session
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
        $nodeVersion = & node --version 2>$null
        if ($nodeVersion) {
            Write-Host "  Node.js installed: $nodeVersion" -ForegroundColor Green
            $nodeOk = $true
        }
    } catch {}

    if (-not $nodeOk) {
        Write-Host "  Could not install Node.js automatically." -ForegroundColor Red
        Write-Host "  Please install it manually from https://nodejs.org and run this script again." -ForegroundColor Gray
        Write-Host "  Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
}

# ---------------------------------------------------------------------------
# Step 2 - Check / install Claude CLI, then install plugin
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Step 2/4 - Installing QA Navigator plugin..." -ForegroundColor Yellow

$claudeOk = $false
try {
    $claudeVersion = & claude --version 2>$null
    if ($claudeVersion) {
        Write-Host "  Claude CLI found: $claudeVersion" -ForegroundColor Green
        $claudeOk = $true
    }
} catch {}

if (-not $claudeOk) {
    Write-Host "  Claude CLI not found. Installing..." -ForegroundColor Yellow
    & npm install -g @anthropic-ai/claude-code
    # Refresh PATH
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
    $claudeVersion = & claude --version 2>$null
    if ($claudeVersion) {
        Write-Host "  Claude CLI installed: $claudeVersion" -ForegroundColor Green
        $claudeOk = $true
    } else {
        Write-Host "  Installation failed. Please restart PowerShell and run this script again." -ForegroundColor Red
        Write-Host "  Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
}

Write-Host "  Adding QA Navigator marketplace..." -ForegroundColor Gray
try {
    & claude plugin marketplace add https://github.com/olebakAuditdata/qa-navigator 2>&1 | Out-Null
    Write-Host "  Marketplace added." -ForegroundColor Green
} catch {
    Write-Host "  Marketplace may already be added, continuing..." -ForegroundColor Gray
}

Write-Host "  Installing qa-navigator plugin..." -ForegroundColor Gray
try {
    & claude plugin install qa-navigator 2>&1 | Out-Null
    Write-Host "  Plugin installed." -ForegroundColor Green
} catch {
    Write-Host "  Plugin may already be installed, continuing..." -ForegroundColor Gray
}

# ---------------------------------------------------------------------------
# Step 3 - Azure DevOps PAT
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Step 3/4 - Azure DevOps token" -ForegroundColor Yellow
Write-Host ""
Write-Host "  You need a Personal Access Token (PAT) from Azure DevOps." -ForegroundColor White
Write-Host "  Opening the token creation page in your browser..." -ForegroundColor White
Write-Host ""

Start-Process "https://dev.azure.com/Auditdatacom/_usersSettings/tokens"

Write-Host "  In the browser:" -ForegroundColor White
Write-Host "   1. Click '+ New Token'" -ForegroundColor Gray
Write-Host "   2. Name: QA Navigator (or anything you like)" -ForegroundColor Gray
Write-Host "   3. Expiration: 1 year" -ForegroundColor Gray
Write-Host "   4. Scopes: select 'Work Items - Read' and 'Test Management - Read'" -ForegroundColor Gray
Write-Host "   5. Click 'Create' and COPY the token (it shows only once!)" -ForegroundColor Gray
Write-Host ""

$pat = ""
while ($pat.Trim() -eq "") {
    $patSecure = Read-Host "  Paste your Azure DevOps PAT and press Enter" -AsSecureString
    $pat = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($patSecure)
    )
    if ($pat.Trim() -eq "") {
        Write-Host "  Token cannot be empty. Please try again." -ForegroundColor Red
    }
}

Write-Host "  Token received." -ForegroundColor Green

# ---------------------------------------------------------------------------
# Step 4 - Confluence API token
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Step 4/4 - Confluence token" -ForegroundColor Yellow
Write-Host ""
Write-Host "  You need an Atlassian API token for Confluence." -ForegroundColor White
Write-Host "  Opening the token creation page in your browser..." -ForegroundColor White
Write-Host ""

Start-Process "https://id.atlassian.com/manage-profile/security/api-tokens"

Write-Host "  In the browser:" -ForegroundColor White
Write-Host "   1. Click 'Create API token'" -ForegroundColor Gray
Write-Host "   2. Name: QA Navigator (or anything you like)" -ForegroundColor Gray
Write-Host "   3. Click 'Create' and COPY the token (it shows only once!)" -ForegroundColor Gray
Write-Host ""

$confluenceToken = ""
while ($confluenceToken.Trim() -eq "") {
    $confluenceSecure = Read-Host "  Paste your Confluence API token and press Enter" -AsSecureString
    $confluenceToken = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($confluenceSecure)
    )
    if ($confluenceToken.Trim() -eq "") {
        Write-Host "  Token cannot be empty. Please try again." -ForegroundColor Red
    }
}

$userEmail = ""
while ($userEmail.Trim() -eq "") {
    $userEmail = Read-Host "  Enter your Auditdata email address"
    if ($userEmail.Trim() -eq "") {
        Write-Host "  Email cannot be empty. Please try again." -ForegroundColor Red
    }
}

Write-Host "  Tokens received." -ForegroundColor Green

# ---------------------------------------------------------------------------
# Write claude_desktop_config.json
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "  Configuring Claude Desktop..." -ForegroundColor Gray

$configDir = Join-Path $env:APPDATA "Claude"
$configPath = Join-Path $configDir "claude_desktop_config.json"

if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir | Out-Null
}

$config = @{}
if (Test-Path $configPath) {
    try {
        $existing = Get-Content $configPath -Raw | ConvertFrom-Json
        $existing.PSObject.Properties | ForEach-Object { $config[$_.Name] = $_.Value }
        Write-Host "  Existing config found - merging." -ForegroundColor Gray
    } catch {
        Write-Host "  Could not read existing config - will create new one." -ForegroundColor Gray
    }
}

if (-not $config.ContainsKey("mcpServers")) {
    $config["mcpServers"] = @{}
}

$mcpServers = @{}
if ($config["mcpServers"] -is [System.Management.Automation.PSCustomObject]) {
    $config["mcpServers"].PSObject.Properties | ForEach-Object { $mcpServers[$_.Name] = $_.Value }
} elseif ($config["mcpServers"] -is [hashtable]) {
    $mcpServers = $config["mcpServers"]
}

# Azure DevOps MCP
$mcpServers["azure-devops"] = @{
    command = "npx"
    args    = @("-y", "@microsoft/azure-devops-mcp")
    env     = @{
        AZURE_DEVOPS_ORG       = "https://dev.azure.com/Auditdatacom"
        AZURE_DEVOPS_AUTH_TYPE = "pat"
        AZURE_DEVOPS_TOKEN     = $pat.Trim()
    }
