# Create a Backup Job

## Overview

This guide explains how to create, configure, and run a backup job for a server, workstation, virtual machine, or other supported workload.

## Prerequisites

Before you begin, ensure that:

- The source system is accessible.
- The backup destination has sufficient free space.
- Required permissions have been assigned.
- Network connectivity is available between the backup server and the protected system.

## Create a Backup Job

### 1. Navigate to Jobs

From the main dashboard, open **Jobs** and select **Create Job**.

### 2. Select Backup Type

Choose **Backup** and select the workload you want to protect.

Examples:

- Virtual Machine
- Physical Server
- Workstation
- Application Server
- Cloud Resource

### 3. Add Resources

1. Select **Add Resources**.
2. Browse for the systems you want to back up.
3. Add the selected resources to the job.

### 4. Configure Storage

1. Select the backup destination.
2. Verify available storage space.
3. Configure retention policies as required.

### 5. Configure Schedule

Choose when the backup should run:

- Daily
- Weekly
- Monthly
- On Demand

Set the desired execution time and frequency.

### 6. Configure Advanced Settings (Optional)

Optional settings may include:

- Compression
- Encryption
- Backup verification
- Application-aware processing
- Notifications
- Performance tuning

### 7. Save and Run

1. Review the configuration.
2. Save the job.
3. Run the backup immediately or allow it to run according to the configured schedule.

## Verify the Backup

After the job completes:

1. Confirm the job status shows **Success**.
2. Review any warnings or errors.
3. Verify that a restore point was created.

## Best Practices

- Regularly test backup restores.
- Monitor job status and storage usage.
- Retain multiple restore points.
- Store backups in a separate location whenever possible.
- Enable encryption for sensitive data.

## Troubleshooting

| Issue | Resolution |
|---------|---------|
| Backup failed | Verify connectivity and permissions |
| Storage full | Increase capacity or adjust retention settings |
| Resource unavailable | Confirm the source system is online |
| Slow backup performance | Review network and storage performance |

## Next Steps

After creating a successful backup, perform a test restore to confirm that the data can be recovered when needed.
