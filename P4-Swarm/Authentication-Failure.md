# Incident Report: Perforce Swarm Authentication Failure

**Incident date:** October 29, 2026  
**Environment:** Helix Core / Perforce Swarm  
**Severity:** Service disruption — Swarm web interface unavailable  
**Status:** **CLOSED — RESOLVED**

## 1. Executive Summary

The Perforce Swarm web interface experienced a configuration or authentication error during an attempt to reduce Perforce license consumption.

The original Swarm integration account was believed to be a standard Perforce user consuming a licensed seat. The intended change was to use a free service-type account. During the process, the original account record was forcibly deleted while the Swarm configuration still referenced that account.

The Swarm web interface subsequently displayed a configuration error. Troubleshooting identified an account mismatch and a password-expiration message during a Perforce authentication test.

The configuration and authentication issues were investigated, corrective actions were completed, and the Swarm environment was tested successfully.

**Final outcome:** Swarm functionality has been restored and verified. The incident is closed.

## 2. Incident Objectives

- Investigate the Swarm configuration and authentication failure.
- Identify the impact of changing the integration account.
- Restore the Swarm web interface and expected functionality.
- Preserve pending changelists and shelved content.
- Verify the final account configuration and licensing objective.
- Document the incident without exposing sensitive information.

## 3. Environment

| Item | Sanitized identifier |
|---|---|
| Swarm application server | `[SWARM_SERVER]` |
| Helix Core server | `[HELIX_CORE_SERVER]` |
| Perforce endpoint | `[HELIX_CORE_ENDPOINT]` |
| Swarm integration account | `[SWARM_ACCOUNT]` |
| Main configuration | `/opt/perforce/swarm/data/config.php` |
| Configuration cache | `/opt/perforce/swarm/data/cache/module-config-cache.php` |

Passwords, authentication tickets, internal IP addresses, and customer-specific source-code details have been excluded.

## 4. Timeline and Troubleshooting

### Step 1 — Investigated Perforce license consumption

The account specification was inspected using:

```bash
p4 user -o [SWARM_ACCOUNT]
```

The objective was to determine whether the account was a standard user or a service-type account.

- Standard accounts generally consume a licensed user seat.
- Service accounts are intended for background processes and have different licensing treatment.

**Result:** The account was believed to be a standard user, prompting the attempt to reduce license consumption.

### Step 2 — Deleted the original account

The following command was executed:

```bash
p4 -p [HELIX_CORE_ENDPOINT] -u [ADMIN_ACCOUNT] \
  user -d -f [SWARM_ACCOUNT]
```

Reported output:

```text
User [SWARM_ACCOUNT] deleted.
```

**Result:** The account deletion succeeded.

However, the Swarm configuration still referenced the original account name. Following the deletion, the Swarm web interface displayed a configuration error.

### Step 3 — Inspected the Swarm configuration

Command:

```bash
sudo ls -l /opt/perforce/swarm/data/config.php
```

**Result:** The configuration file existed and was owned by the web-server account.

The relevant configuration fields were inspected without exposing credentials:

```bash
sudo grep -nE "'(port|user)'[[:space:]]*=>" \
  /opt/perforce/swarm/data/config.php
```

Sanitized output:

```text
'port' => '[HELIX_CORE_ENDPOINT]',
'user' => '[SWARM_ACCOUNT]',
```

**Finding:** Swarm was configured to use the original integration account.

### Step 4 — Inspected the configuration cache

Command:

```bash
sudo ls -l /opt/perforce/swarm/data/cache/module-config-cache.php
```

**Result:** The cache file existed.

A stale cache was considered as a possible contributing factor. The main configuration file was preserved.

### Step 5 — Tested Perforce authentication

Command:

```bash
p4 -p [HELIX_CORE_ENDPOINT] -u [SWARM_ACCOUNT] login -s
```

Reported output:

```text
Your password has expired, please change your password.
```

**Finding:** The authentication test encountered a password-expiration condition.

This identified an authentication issue requiring attention. It was not treated as conclusive proof that password expiration was the sole cause of the Swarm outage.

### Step 6 — Verified Helix Core connectivity

Command:

```bash
p4 -p [HELIX_CORE_ENDPOINT] -u [ADMIN_ACCOUNT] info
```

**Result:** The server returned its information successfully, confirming basic connectivity and successful access through the tested administrative session.

This helped distinguish the Swarm integration problem from a general Helix Core connectivity failure.

### Step 7 — Verified the account deletion

Command:

```bash
p4 -p [HELIX_CORE_ENDPOINT] -u [ADMIN_ACCOUNT] users \
  | grep -w '[SWARM_ACCOUNT]'
```

**Result:** No matching account was returned.

This confirmed that the original account was no longer present in the user listing at that point in the investigation.

### Step 8 — Checked pending changelists and shelved content

Pending changelists were inspected using:

```bash
p4 -p [HELIX_CORE_ENDPOINT] -u [ADMIN_ACCOUNT
