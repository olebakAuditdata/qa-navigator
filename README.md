# QA Navigator — Setup Guide

QA Navigator is an AI agent in Claude Desktop that helps you find test cases, test plans, analyse coverage gaps, and detect duplicates across Azure DevOps and Confluence.

Setup takes about 5 minutes.

---

## Part 1 — Automatic Setup (run once)

### Step 1 — Find the `qa-navigator-plugin` folder

You received it via SharePoint or from a colleague. Save it somewhere convenient, for example on your Desktop.

### Step 2 — Run the setup script

1. Open the `qa-navigator-plugin` folder
2. Right-click on **`setup.ps1`**
3. Select **"Run with PowerShell"**

> If a security warning appears, click **"Yes"** or **"Run anyway"**.

The script will automatically:
- Check if Node.js is installed (and open the installer if not)
- Open your browser to create an Azure DevOps access token, with instructions on what to select
- Save the token and write the Claude Desktop configuration

Just follow the instructions in the script window.

---

## Part 2 — Add the Plugin

Once the script finishes:

1. Fully quit Claude Desktop
   - Right-click the Claude icon in the system tray (bottom-right corner)
   - Select **"Quit"**
2. Reopen Claude Desktop
3. Go to **Settings → Cowork → Plugins**
4. Click **"Add plugin from folder"**
5. Select the `qa-navigator-plugin` folder
6. Fully quit and reopen Claude Desktop once more

---

## Part 3 — Connect Confluence

1. Open **Claude Desktop → Cowork**
2. Go to **Settings → Cowork → Connectors**
3. Find **Atlassian** and click **"Connect"**
4. Sign in with your Auditdata Atlassian account (the same one you use for `auditdata.atlassian.net`)
5. Approve the access request

---

## You're ready! Try these in Cowork

```
Find all test cases for the login functionality
```

```
Which test plans contain test case 12345?
```

```
Find duplicate test cases for the password reset flow
```

```
Which Confluence requirements have no test cases in Azure DevOps?
```

---

## Something not working?

Just write to the agent directly in Cowork:

```
The Azure DevOps connection is not working, help me troubleshoot
```

```
Confluence is not connecting, help me troubleshoot
```

It will walk you through diagnostics on its own.

---

## Questions?

Contact Ole Bakke (olebak@auditdata.com).
