# Sanitized

# Incident Report: Perforce Swarm Authentication Failure

**Incident date:** October 29, 2026  
**Environment:** Helix Core / Perforce Swarm  
**Severity:** Service disruption — Swarm web interface unavailable  
**Status:** CLOSED — RESOLVED

## 1. Executive Summary

The Perforce Swarm web interface displayed a configuration or authentication error during an attempt to reduce Perforce license consumption.

The original Swarm integration account was believed to be a standard Perforce user consuming a licensed seat. The intended change was to use a free service-type account.

During troubleshooting, the original account record was forcibly deleted while the Swarm configuration still referenced that account. The web interface subsequently displayed a configuration error.

A Perforce login test also reported that the account's password had expired. This identified an additional authentication issue, although it was not established as the sole cause of the outage.

The account configuration and authentication issues were investigated and corrected. The Swarm web interface and expected functionality were subsequently verified as working.

**Final outcome:** The incident is resolved and closed.

## 2. Objective

- Reduce Perforce license consumption where possible.
- Determine which Perforce account Swarm uses.
- Investigate the Swarm configuration and authentication failure.
- Preserve existing Swarm configuration and pending changelist data.
- Restore the Swarm web interface without unnecessary reinstallation or destructive changes.

## 3. Environment and Sanitization

The following identifiers have been generalized.

| Item | Sanitized identifier |
|---|---|
| Swarm application server | `[SWARM_SERVER]` |
| Helix Core server | `[HELIX_CORE_SERVER]` |
| Perforce endpoint | `[HELIX_CORE_ENDPOINT]` |
| Swarm integration account | `[SWARM_ACCOUNT]` |
| Swarm configuration file | `/opt/perforce/swarm/data/config.php` |
| Swarm configuration cache | `/opt/perforce/swarm/data/cache/module-config-cache.php` |

No passwords, authentication tickets, private credentials, internal IP addresses, or customer-specific source-code details are included.

## 4. Timeline and Troubleshooting

### Step 1 — Investigated Perforce licensing

**Objective:** Determine whether the account used by Swarm was consuming a paid license.

Command:

```bash
p4 user -o [SWARM_ACCOUNT]
```

The intended interpretation was:

- `Type: standard`: standard user account, generally consuming a licensed seat.
- `Type: service`: service account intended for background processes and generally not consuming a standard user license.

**Finding:** The account was believed to be a standard account, prompting the attempt to reduce license consumption.

### Step 2 — Deleted the original account

Command executed:

```bash
p4 -p [HELIX_CORE_ENDPOINT] -u [ADMIN_ACCOUNT] \
  user -d -f [SWARM_ACCOUNT]
```

Reported output:

```text
User [SWARM_ACCOUNT] deleted.
```

**Result:** The deletion succeeded.

The intention was to recreate the account with the service type. However, the Swarm configuration continued to reference the original account name. The account deletion was followed by the Swarm web-interface failure.

### Step 3 — Verified the Swarm configuration file

Command:

```bash
sudo ls -l /opt/perforce/swarm/data/config.php
```

Reported result:

```text
-rw-r----- 1 www-data www-data 811 [TIMESTAMP] /opt/perforce/swarm/data/config.php
```

The file existed and was owned by the web-server account.

The relevant configuration was inspected without displaying credentials:

```bash
sudo grep -nE "'(port|user)'[[:space:]]*=>" \
  /opt/perforce/swarm/data/config.php
```

Sanitized output:

```text
13: 'port' => '[HELIX_CORE_ENDPOINT]',
14: 'user' => '[SWARM_ACCOUNT]',
23: 'port' => 25
```

**Finding:** Swarm was still configured to use the original integration account name.

### Step 4 — Verified the configuration cache

Command:

```bash
sudo ls -l /opt/perforce/swarm/data/cache/module-config-cache.php
```

Reported result:

```text
-rw-r--r-- 1 www-data www-data 276515 [TIMESTAMP] /opt/perforce/swarm/data/cache/module-config-cache.php
```

**Finding:** The configuration cache existed.

A stale cache was considered as a possible cause. The main configuration file was preserved.

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

This indicated an authentication issue in the tested CLI environment. It did not independently establish which credentials the Swarm web application was using or prove that password expiration was the sole cause.

### Step 6 — Checked the Helix Core server

Command:

```bash
p4 -p [HELIX_CORE_ENDPOINT] -u [ADMIN_ACCOUNT] info
```

Reported results included:

- Perforce CLI connected to the Helix Core server.
- The server returned normal information, including server version and root-directory details.
- The administrative account could authenticate successfully in the tested session.

**Finding:** Basic Helix Core connectivity was working.

### Step 7 — Checked whether the original account still existed

Command:

```bash
p4 -p [HELIX_CORE_ENDPOINT] -u [ADMIN_ACCOUNT] users \
  | grep -w '[SWARM_ACCOUNT]'
```

**Reported result:** No matching output.

**Finding:** The original account was not returned by the user-list query, consistent with the successful deletion.

### Step 8 — Investigated pending changelists

Command:

```bash
p4 -p [HELIX_CORE_ENDPOINT] -u [ADMIN_ACCOUNT] \
  changes -u [SWARM_ACCOUNT] -s pending
```

**Reported result:** Twelve pending changelists associated with the original account remained visible.

A detailed changelist description was obtained using:

```bash
p4 -p [HELIX_CORE_ENDPOINT] -u [ADMIN_ACCOUNT] \
  describe -S [CHANGE_NUMBER]
```

The output included shelved file entries and diff content.

**Finding:** Pending changelist metadata and shelved content remained accessible during the investigation.

### Step 9 — Attempted to inspect PHP on the wrong server

A PHP command was attempted on the Helix Core server:

```bash
sudo php -r '...'
```

Reported output:

```text
sudo: php: command not found
```

**Result:** Failed.

**Explanation:** The command was executed on the Helix Core server, where PHP was unavailable. The Swarm configuration inspection needed to be performed on the Swarm application server.

This failure did not indicate a fault in the Swarm PHP installation.

### Step 10 — Corrected and verified Swarm

The Swarm account and authentication configuration were investigated and corrected. The environment was tested again after the corrective actions.

**Result:** The Swarm web interface and expected functionality were confirmed to be working.

## 5. Error Observed in the Swarm Web Interface

The web interface displayed a message indicating that Swarm had detected a configuration error.

The error page identified three possible troubleshooting areas:

1. The Swarm configuration referenced invalid credentials or an unavailable account.
2. The configuration cache might be stale.
3. The configured account might lack the required permissions or have an invalid authentication ticket.

The error page also advised that, for sufficiently high Helix Core security levels, Swarm may require a valid long-lived ticket instead of a password.

**Assessment:** The error was consistent with the account and authentication issues identified during troubleshooting. The service was subsequently restored and verified.

## 6. Attempts and Results

| Test or action | Result | Interpretation |
|---|---|---|
| Inspect account specification | Completed | Investigated account type and licensing objective |
| Delete original account | Successful | Original account record removed |
| Inspect `config.php` | Successful | Configuration still referenced the original account name |
| Inspect cache file | Successful | Cache existed; validity was not initially established |
| Test account login status | Failed with password-expiration message | Authentication issue identified |
| Test Helix Core with administrative account | Successful | Basic server connectivity confirmed |
| Search user list for original account | No matching entry | Account absent from user listing |
| List pending changelists | Successful | Twelve pending changelists remained visible |
| Inspect a shelved changelist | Successful | Shelved file entries and diff content remained accessible |
| Run PHP inspection on Helix Core server | Failed: PHP unavailable | Command executed on the wrong server |
| Correct Swarm configuration and authentication | Successful | Swarm functionality restored |
| Verify Swarm web interface | Successful | Expected functionality confirmed |

## 7. Root-Cause Assessment

### Leading cause

The most likely initiating event was the forced deletion of the original Swarm integration account while the Swarm configuration continued to reference that account.

This introduced an inconsistency between the account expected by the application and the account records available in Helix Core.

### Contributing authentication issue

A subsequent login test reported a password-expiration condition. This was an additional authentication issue identified during the investigation.

### Other possibility investigated

A stale configuration cache was considered as a possible contributing factor. It was not independently established as the primary cause.

### Final assessment

The evidence points to an account lifecycle and authentication configuration problem following the deletion. The corrective actions restored the Swarm web interface, and the expected functionality was verified.

The precise contribution of each individual issue was not independently established.

## 8. Corrective Actions and Prevention

1. **Account configuration:** Investigated and corrected the Swarm account configuration and authentication issue.
2. **Authentication:** Verified the final authentication configuration.
3. **Application verification:** Tested the Swarm web interface after the corrective actions.
4. **Data preservation:** Checked pending changelists and shelved content during the investigation.
5. **Licensing review:** Reviewed the final account configuration against the license-reduction objective.
6. **Documentation:** Recorded the troubleshooting history, command results, and outcome without including secrets.
7. **Prevention:** Future changes to Swarm integration accounts should verify supported account types and required permissions before deleting or replacing an account.

## 10. Final Status and Closure

**Status: CLOSED — RESOLVED**

**Closure date:** October 29, 2026

The Perforce Swarm configuration and authentication incident has been resolved. The Swarm web interface is operational, and the expected functionality has been verified.

The investigation identified the original account deletion, the configuration's continued reference to that account, and a password-expiration condition during authentication testing. Corrective actions were completed, and the environment was tested successfully.

No outstanding incident actions were reported at closure.

**Lessons learned:** Before changing or deleting a Swarm integration account, confirm the supported account type, required permissions, authentication method, and licensing implications. Always validate application functionality after making account or configuration changes.
