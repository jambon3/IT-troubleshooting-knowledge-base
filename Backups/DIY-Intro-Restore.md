# Perform a Restore

## Overview

This guide explains how to restore data from an existing backup. Restores can be performed for individual files, folders, applications, or entire systems, depending on the available backup data.

## Prerequisites

Before starting a restore:

- Verify that a valid backup is available.
- Ensure you have the required permissions to perform a restore.
- Confirm the target location is accessible.
- Review the available restore points and select the appropriate recovery date.

## Start a Restore

### 1. Navigate to Restores

From the main dashboard, open **Restores** and select the type of restore you want to perform.

Examples:

- File Restore
- Folder Restore
- System Restore
- Virtual Machine Restore
- Application Restore

### 2. Select a Restore Point

1. Browse available backups.
2. Select the desired restore point.
3. Verify the backup date and time.

> **Tip:** Choose the most recent successful restore point unless recovering from corruption or accidental changes.

### 3. Select Items to Restore

Choose the data you want to recover:

- Individual files
- Folders
- Entire systems
- Virtual machines
- Application data

Review your selections before proceeding.

### 4. Choose a Restore Destination

Select where the recovered data will be restored:

- Original location
- Alternate location
- Temporary recovery location

If restoring to the original location, verify that existing data will not be overwritten unexpectedly.

### 5. Configure Restore Options

Optional settings may include:

- Overwrite existing files
- Preserve permissions
- Restore ownership attributes
- Network configuration options
- Verification checks

Adjust these settings as required.

### 6. Start the Restore

1. Review the restore configuration.
2. Select **Restore**.
3. Monitor the job progress until completion.

## Verify the Restore

After the restore completes:

1. Confirm the job status shows **Success**.
2. Verify all required data is present.
3. Open restored files or applications to confirm functionality.
4. Review any warnings or errors reported during the process.

## Best Practices

- Test backups regularly by performing restore operations.
- Restore to an alternate location when validating recoverability.
- Document recovery procedures.
- Verify application functionality after restoration.
- Review restore logs for any issues.

## Troubleshooting

| Issue | Resolution |
|---------|---------|
| Restore failed | Verify source backup integrity and permissions |
| Missing files | Check alternative restore points |
| Access denied | Confirm account permissions |
| Insufficient space | Free storage or select a different destination |
| Slow restore | Verify network and storage performance |

## Next Steps

After a successful restore:

- Confirm users can access the recovered data.
- Validate application functionality if applicable.
- Document the recovery action.
- Review backup policies to prevent future data loss.
