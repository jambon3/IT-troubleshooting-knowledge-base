# Managing BitLocker with Microsoft Intune and Microsoft Entra ID

## Overview

This guide explains how to centrally manage BitLocker Drive Encryption on corporate Windows devices using Microsoft Intune and Microsoft Entra ID.

The goal is to protect data stored on corporate laptops, securely back up BitLocker recovery keys, monitor encryption compliance, and support remote recovery without requiring physical access to the device.

## Architecture

```text
Corporate Windows Devices
          |
          v
   Microsoft Intune
          |
          +---- BitLocker encryption policies
          |
          +---- Device compliance monitoring
          |
          v
 Microsoft Entra ID
          |
          +---- BitLocker recovery keys
          |
          v
 Authorized IT Administrators
```

### Components

- **Microsoft Intune:** Deploys BitLocker configuration policies and monitors device status.
- **Microsoft Entra ID:** Stores escrowed BitLocker recovery keys for supported device configurations.
- **Windows BitLocker:** Encrypts operating-system and data volumes.
- **IT administrators:** Investigate encryption failures, manage recovery, and monitor compliance.

## 1. Prerequisites

Before deployment, verify that:

- Windows devices are supported by the organization's BitLocker policy.
- Devices are correctly enrolled in Microsoft Intune.
- Devices have the required Microsoft Entra ID join or registration configuration for recovery-key backup.
- Administrators have appropriate Intune and Entra permissions.
- Existing Group Policy Objects (GPOs) and Intune policies do not conflict.
- A pilot device group is available for testing.

Licensing requirements depend on the organization's Microsoft subscriptions and the management features being used.

## 2. Configure the BitLocker Policy

In the Microsoft Intune admin center:

1. Navigate to **Endpoint security**.
2. Select **Disk encryption**.
3. Create a policy for Windows devices.
4. Configure the required BitLocker settings according to organizational security standards.
5. Configure recovery-password backup to Microsoft Entra ID.
6. Configure recovery-key rotation where supported.
7. Assign the policy to a dedicated pilot device group.
8. Monitor deployment status before expanding the rollout.

### Example configuration

| Setting | Example |
|---|---|
| Operating system | Windows 10/11, as supported |
| Encryption method | XTS-AES 128 or XTS-AES 256 |
| Encryption scope | Operating-system drive and required data drives |
| Recovery-key backup | Microsoft Entra ID |
| Policy assignment | Device group |
| Deployment strategy | Pilot, then phased rollout |
| Compliance monitoring | Intune reports and device validation |

**Important:** Encryption settings must match the organization's security requirements. Confirm compatibility and recovery behavior before deploying changes broadly.

## 3. Validate BitLocker on the Endpoint

Run the following PowerShell command on a test device:

```powershell
Get-BitLockerVolume -MountPoint "C:"
```

Review these properties:

- `VolumeStatus`: Should indicate `FullyEncrypted` when encryption is complete.
- `ProtectionStatus`: Should indicate `On` when BitLocker protection is active.
- `EncryptionMethod`: Confirms the encryption algorithm.
- `KeyProtector`: Lists configured protectors, including a recovery-password protector when present.

You can also use:

```powershell
manage-bde -status C:
```

Check that the operating-system drive is encrypted and protection is enabled.

A recovery key existing in Microsoft Entra ID does **not** prove that the entire drive is encrypted. Validate the actual volume state separately.

## 4. Verify Recovery-Key Backup

In the Microsoft Entra admin center:

1. Open **Devices**.
2. Locate the relevant device.
3. Open its BitLocker recovery-key information, where available.
4. Verify the recovery-key record and key ID.

Alternatively, use the corresponding recovery-key view available in Intune.

Confirm that the recovery record belongs to the correct device and that the key ID matches the recovery-password protector on the endpoint.

Never publish recovery passwords in GitHub, scripts, screenshots, tickets, or logs.

## 5. Monitor Deployment and Compliance

Use Intune device status and encryption reports to identify devices that:

- Have not received the policy.
- Report policy errors.
- Have not completed encryption.
- Have BitLocker protection disabled.
- Are missing the expected recovery-key backup.

Investigate failed or pending deployments before expanding the policy to additional devices.

A successful policy assignment is not sufficient evidence that encryption has completed.

## 6. Troubleshooting

### Device has a recovery key, but C: is not encrypted

Run:

```powershell
Get-BitLockerVolume -MountPoint "C:"
manage-bde -status C:
```

Check the following:

1. Confirm that the BitLocker policy reached the device.
2. Check the Intune policy deployment status and error details.
3. Verify that no conflicting GPO or Intune policy is overriding the configuration.
4. Confirm that the operating-system volume has a valid key protector.
5. Check whether encryption is pending, paused, or not started.
6. Review device join status and the applicable Intune configuration.
7. Recheck encryption status after the issue is corrected.

Do not assume that a recovery key appearing in Entra ID means the encryption process succeeded.

### Intune reports an error

- Review the device's policy status and diagnostic information.
- Confirm the device is checking in successfully.
- Check for conflicting configuration profiles.
- Verify that the selected policy settings are supported.
- Test any policy changes on a small pilot group first.

## 7. Security Best Practices

- Apply least-privilege access to recovery-key information.
- Audit recovery-key access where supported.
- Verify user identity and device ownership before providing a recovery password.
- Rotate the recovery password after recovery or exposure when supported.
- Maintain documented procedures for device reassignment, retirement, and lost devices.
- Never store recovery passwords in source control.
- Do not mark a device compliant solely because a recovery key exists.
- Regularly review encryption status and investigate noncompliant devices.

## 8. Deployment Checklist

- [ ] Device is enrolled in Intune.
- [ ] Device receives the correct BitLocker policy.
- [ ] Recovery-password protector exists.
- [ ] Recovery key is escrowed in Microsoft Entra ID.
- [ ] Operating-system drive is fully encrypted.
- [ ] BitLocker protection is enabled.
- [ ] Intune reporting has been reviewed.
- [ ] Compliance and recovery procedures have been tested.

## Conclusion

A reliable BitLocker deployment requires more than enabling encryption. Administrators must verify that encryption is complete, recovery information is securely backed up, policies are consistently applied, and device compliance is monitored.

Microsoft Intune provides centralized policy management, while Microsoft Entra ID provides a supported location for recovery-key storage. Together, they help organizations manage encrypted Windows devices remotely and securely.

## References

- [Microsoft Learn: BitLocker overview](https://learn.microsoft.com/en-us/windows/security/operating-system-security/data-protection/bitlocker/)
- [Microsoft Learn: BitLocker recovery overview](https://learn.microsoft.com/en-us/windows/security/operating-system-security/data-protection/bitlocker/recovery-overview)
- [Microsoft Learn: Manage BitLocker policies with Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/encrypt-devices)
