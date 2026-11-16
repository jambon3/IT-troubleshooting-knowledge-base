# Visual Paradigm Server Backup Procedure

## Verify Installed Version

Open Programs and Features:

```powershell
appwiz.cpl
```

> Note: This may indicate the licensed version (for example, Visual Paradigm 17.x), but it does not definitively confirm the actual server software version.

---

## Stop the Visual Paradigm Service

```powershell
Stop-Service -Name vpserver
Get-Service -Name vpserver
```

---

## Perform Backup

```powershell
robocopy "D:\VPServer" `
         "D:\Backups\VPServer-Backup\VPServer" `
         /E /COPY:DAT /DCOPY:DAT /R:2 /W:5 /XJ
```

### Robocopy Options

| Option | Description |
|----------|-------------|
| `/E` | Copy all subdirectories, including empty ones |
| `/COPY:DAT` | Copy data, attributes, and timestamps |
| `/DCOPY:DAT` | Copy directory data, attributes, and timestamps |
| `/R:2` | Retry failed copies twice |
| `/W:5` | Wait 5 seconds between retries |
| `/XJ` | Exclude junction points to prevent recursive loops |

---

## Start the Visual Paradigm Service

```powershell
Start-Service -Name vpserver
Get-Service -Name vpserver
```

---

## Monitor Backup Progress

Open a second PowerShell window and run:

```powershell
Get-ChildItem "D:\Backups\VPServer-Backup\VPServer" `
    -Recurse -File -ErrorAction SilentlyContinue |
    Measure-Object -Property Length -Sum
```

This displays the total size of files copied so far and can be used to monitor backup growth during the operation.
