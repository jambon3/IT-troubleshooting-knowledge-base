# Lab - Troubleshooting Missing Linux Guest Credentials

## Issue

The backup job failed during the guest processing phase with the following error:

```text
Unable to connect to guest OS for guest processing.
Cannot find Linux guest credentials.
```

## Root Cause

The protected Linux virtual machine did not have valid guest operating system credentials configured. Guest processing requires SSH access and valid credentials to perform operations inside the operating system.

## Troubleshooting Steps

### 1. Review Backup Job Configuration

Navigate to:

```text
Home
└── Jobs
    └── Edit Job
```

Open the **Guest Processing** settings and verify that guest processing is enabled.

---

### 2. Verify Guest OS Credentials

Navigate to:

```text
Guest Processing
└── Guest OS Credentials
```

Review the credentials assigned to the Linux virtual machine.

**Observation:**

```text
No Linux guest credentials configured.
```

---

### 3. Verify SSH Access

Confirmed the following on the Linux server:

```text
SSH service enabled
Network connectivity available
SSH access successful
```

This ruled out connectivity and SSH service issues.

---

### 4. Configure Linux Credentials

Added Linux SSH credentials using the following information:

```text
Server IP Address: [SANITIZED]
Username: [SANITIZED]
Password: [SANITIZED]
```

Assigned the credentials to the affected virtual machine and saved the configuration.

---

## Resolution

Configured and assigned valid Linux SSH credentials within the Guest Processing settings.

---

## Results

```text
Issue Identified:
Missing Linux guest credentials.

Corrective Actions:
✓ Reviewed backup job configuration
✓ Verified Guest Processing settings
✓ Confirmed SSH connectivity
✓ Added Linux SSH credentials
✓ Assigned credentials to target VM

Status:
Resolved - Ready for backup validation and retest.
```

---

## Lessons Learned

- Ensure guest OS credentials are configured before enabling guest processing.
- Verify SSH connectivity prior to troubleshooting backup failures.
- Use a dedicated service account for backup operations.
- Validate credentials after password updates or account changes.
- Periodically review Guest Processing configurations.

## Outcome

The backup job failure was caused by missing Linux guest credentials. After configuring and assigning valid SSH credentials to the virtual machine, the issue was resolved and the backup job was ready for retesting.
