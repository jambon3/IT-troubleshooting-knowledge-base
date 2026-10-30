# Appendix A - Initial Setup

## Overview

Before the SharePoint synchronization process can be used, the server must have the required SharePoint PowerShell modules installed and configured.

This setup is typically only performed once per server.

---

# Install SharePoint Online Management Shell

Install the SharePoint Online PowerShell module:

```powershell
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser
```

Import the module:

```powershell
Import-Module Microsoft.Online.SharePoint.PowerShell
```

Connect to the SharePoint Administration Center:

```powershell
Connect-SPOService -Url https://<tenant>-admin.sharepoint.com
```

Successful authentication confirms administrative connectivity to SharePoint Online.

---

# Install PnP PowerShell

Install the PnP PowerShell module:

```powershell
Install-Module -Name PnP.PowerShell -Scope CurrentUser
```

Import the module:

```powershell
Import-Module PnP.PowerShell
```

Verify installation:

```powershell
Get-Module PnP.PowerShell -ListAvailable
```

---

# Register PnP PowerShell Application

Some environments require an Entra ID application registration for interactive authentication.

Example:

```powershell
Register-PnPEntraApp `
    -ApplicationName "PnP PowerShell" `
    -Tenant "<tenant>.onmicrosoft.com" `
    -Interactive
```

Save the generated Application (Client) ID.

Example:

```text
xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

This value is referenced later by synchronization scripts.

---

# Test SharePoint Connectivity

Verify that SharePoint access is functioning correctly.

```powershell
Connect-PnPOnline `
    -Url "https://tenant.sharepoint.com/sites/SiteName" `
    -Interactive `
    -ClientId "<ClientID>"
```

Verify connection:

```powershell
Get-PnPWeb
```

Expected outcome:

```text
Site information is returned successfully.
```

---

# Appendix B - Historical Development

## Initial Synchronization Method

The first version of the process downloaded all document libraries and rebuilt the destination repository during every execution.

Workflow:

```text
Delete Previous Repository
       ↓
Connect to SharePoint
       ↓
Enumerate Libraries
       ↓
Download Everything
```

Example destination:

```text
\\SERVER\SharePointBackup
```

Limitations:

- Transfers took longer
- Downloaded unchanged files repeatedly
- Higher SharePoint bandwidth usage
- No file validation
- No resumable synchronization

This version is retained for historical reference only.

---

# Appendix C - Production Synchronization Method

## Recommended Version

The current production script is the approved synchronization process.

Enhancements include:

- File integrity validation
- Incremental synchronization
- Re-download of incomplete files
- File size verification
- Detailed logging
- Progress reporting
- Transfer statistics
- Error handling
- Resume capability

This version should be used for all future operations.

---

# Synchronization Process

```text
SharePoint
       ↓
Validate Connection
       ↓
Read Library Contents
       ↓
Compare Existing Files
       ↓
Skip Existing Files
       ↓
Download Missing Files
       ↓
Validate Download
       ↓
Generate Statistics
       ↓
Write Log File
```

---

# Execution Procedure

## Step 1

Open PowerShell.

---

## Step 2

Navigate to the script location.

```powershell
cd C:\Scripts
```

---

## Step 3

Execute the synchronization script.

```powershell
.\SharePoint-Sync.ps1
```

---

## Step 4

Authenticate when prompted.

A Microsoft authentication window will appear.

Sign in with an account that has access to the SharePoint site.

---

## Step 5

Monitor progress.

Example:

```text
[DOWNLOAD]
ProjectA\File1.zip

[OK]
Verified size
```

---

## Step 6

Review final summary.

Example:

```text
TRANSFER COMPLETE

Downloaded: 1250
Skipped: 8760
Failed: 0
```

---

# Validation Method

The synchronization process performs validation using file size comparison.

Example:

```text
SharePoint Size = 1,024,000 bytes
Local Size      = 1,024,000 bytes
```

Result:

```text
File Validated
```

If the sizes differ:

```text
SharePoint Size = 1,024,000 bytes
Local Size      = 512,000 bytes
```

Result:

```text
Delete File
Re-download
Verify Again
```

---

# Logging

Every execution generates a transfer log.

Example:

```text
2026-01-01 10:00:00 SUCCESS ProjectA\File.zip
2026-01-01 10:01:00 SKIP ProjectB\File.docx
2026-01-01 10:02:00 ERROR ProjectC\File.iso
```

The log should always be reviewed after execution.

---

# Operational Notes

## Known Issue

During the initial migration process, several archive files were identified as corrupted or unrecoverable.

Symptoms:

- ZIP extraction failures
- Download validation failures
- Corrupt source content

Resolution:

These files were documented and excluded from synchronization.

They are tracked separately and do not impact overall synchronization success.

---

# Recovery Procedure

If the synchronization server is rebuilt:

1. Install PowerShell modules.
2. Install PnP PowerShell.
3. Register or obtain Client ID.
4. Restore synchronization script.
5. Recreate destination repository.
6. Validate SharePoint access.
7. Execute synchronization.

No additional configuration should be required.

---

# Knowledge Transfer Summary

This solution provides:

- SharePoint archival capability
- Secondary storage repository
- Offline file access
- Disaster recovery support
- Data integrity validation
- Repeatable synchronization

Future administrators should use the production synchronization script and review logs after every execution.
