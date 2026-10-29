# Incident Report: Perforce Swarm Authentication Failure

**Incident date:** October 29, 2026  
**Environment:** Helix Core / Perforce Swarm  
**Severity:** Service disruption — Swarm web interface unavailable  
**Status:** Open — root cause suspected; recovery not yet verified

## 1. Executive Summary

The Perforce Swarm web interface began displaying a configuration or authentication error during an attempt to reduce Perforce license consumption.

The original Swarm integration account was believed to be a standard Perforce user, which consumes a licensed seat. The intended change was to replace it with a free service-type account.

During troubleshooting, the original account record was forcibly deleted. Swarm's configuration file still referenced that account, and the web interface subsequently displayed an error indicating that its configuration or authentication was invalid.

A login test also reported that the account's password had expired. This was an additional authentication issue identified during troubleshooting, but it has not been established as the sole cause of the outage.

**Current conclusion:** The account deletion and the mismatch between Swarm's configured account and the available Perforce account record are the leading suspected causes. The exact root cause remains unconfirmed because Swarm authentication has not yet been successfully restored and verified.

## 2. Objective

- Reduce Perforce license consumption where possible.
- Determine which Perforce account Swarm uses.
- Investigate the Swarm configuration and authentication failure.
- Preserve existing Swarm configuration and pending changelist data.
- Restore the Swarm web interface without unnecessary reinstallation or destructive changes.

## 3. Environment and Sanitization

The following identifiers have been generalized:

| Item | Sanitized identifier |
|---|---|
| Swarm application server | `[SWARM_SERVER]` |
| Helix Core server | `[HELIX_CORE_SERVER]` |
| Perforce endpoint | `[HELIX_CORE_ENDPOINT]` |
| Swarm integration account | `[SWARM_ACCOUNT]` |
| Swarm configuration file | `/opt/perforce/swarm/data/config.php` |
| Swarm configuration cache | `/opt/perforce/swarm/data/cache/module-config-cache.php` |

No passwords, authentication tickets, private credentials, or customer-specific source-code details are included.

## 4. Timeline and Troubleshooting

### Step 1 — Investigated Perforce licensing

**Objective:** Determine whether the account used by Swarm was consuming a paid license.

The account record was inspected using:

```bash
p4 user -o [SWARM_ACCOUNT]
```

The intended interpretation was:

- `Type: standard`: standard user account, generally consuming a licensed seat when accessing the server.
- `Type: service`: service account intended for background processes and generally not consuming a standard user license.

**Finding:** The account was believed to be a standard account, and converting the integration to a service account was the original objective.

**Important limitation:** The complete original output establishing the account type was not retained in the available incident notes. Therefore, the initial account type should be confirmed from an appropriate backup or historical record if required for an audit.

### Step 2 — Deleted the original account

The following command was executed:

```bash
p4 -p [HELIX_CORE_ENDPOINT] -u [ADMIN_ACCOUNT] user -d -f [SWARM_ACCOUNT]
```

Reported output:

```text
User [SWARM_ACCOUNT] deleted.
```

The deletion succeeded.

The intention was to recreate the account with the service type. However, deleting an account and recreating it as a service account is not sufficient to ensure compatibility with Swarm's administrative requirements.

**Impact:** Swarm's configuration still referenced the original account name. The account deletion was followed by the Swarm web-interface failure.

### Step 3 — Verified the Swarm configuration file

On the Swarm application server:

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

**Conclusion:** This established a configuration dependency on that account name. It did not, by itself, prove that the configuration file was otherwise invalid.

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

A stale cache was considered as another possible cause. The cache was not confirmed to be the root cause, and deleting it alone was not demonstrated to resolve the incident.

The main configuration file, `config.php`, was preserved.

### Step 5 — Tested Perforce authentication

The following test was run from the Swarm server:

```bash
p4 -p [HELIX_CORE_ENDPOINT] -u [SWARM_ACCOUNT] login -s
```

Reported output:

```text
Your password has expired, please change your password.
```

**Finding:** The authentication test encountered a password-expiration condition.

**Interpretation:** This is evidence of an authentication problem in the tested CLI environment. It does not independently establish which credentials the Swarm web application is using, nor does it prove that password expiration is the only cause of the outage.

The test should be repeated after confirming that the correct account exists and is of the intended type.

### Step 6 — Checked the Helix Core server

The following command was used to verify server connectivity and basic server information:

```bash
p4 -p [HELIX_CORE_ENDPOINT] -u [ADMIN_ACCOUNT] info
```

Reported results included:

- Perforce CLI connected to the Helix Core server.
- The server returned normal information, including server version and root-directory details.
- The administrative account could authenticate successfully in the tested session.

**Finding:** Basic Helix Core connectivity was working during the test.

**Limitation:** Successful `p4 info` using an administrative account does not prove that Swarm's configured account can authenticate or that Swarm's PHP application can communicate successfully.

### Step 7 — Checked whether the original account still existed

Command:

```bash
p4 -p [HELIX_CORE_ENDPOINT] -u [ADMIN_ACCOUNT] users \
  | grep -w '[SWARM_ACCOUNT]'
```

Reported result: no matching output.

**Finding:** The original account was not returned by the user-list query.

This was consistent with the successful deletion reported earlier. A user specification template returned by `p4 user -o` should not be treated as proof that the account record exists.

### Step 8 — Investigated pending changelists

Command:

```bash
p4 -p [HELIX_CORE_ENDPOINT] -u [ADMIN_ACCOUNT] \
  changes -u [SWARM_ACCOUNT] -s pending
```

**Reported result:** Twelve pending changelists associated with the original account remained visible.

The changelists contained references to shelved files. A detailed description was also obtained with:

```bash
p4 -p [HELIX_CORE_ENDPOINT] -u [ADMIN_ACCOUNT] \
  describe -S [CHANGE_NUMBER]
```

The output included shelved file entries and diff content.

**Finding:** Pending changelist metadata and shelved content remained accessible during the investigation.

**Risk:** These results do not establish that the shelved work has been independently backed up or that every associated Swarm review remains functional. The pending changelists must not be deleted until the required shelved content and review data have been safely preserved and verified.

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

**Explanation:** The command was executed on the Helix Core server, where PHP was not available. The Swarm configuration inspection must be performed on the Swarm application server, where PHP and the Swarm installation are located.

This failure does not indicate that Swarm's PHP installation is broken.

## 5. Error Observed in the Swarm Web Interface

The web interface displayed a message indicating that Swarm had detected a configuration error.

The error page identified three possible troubleshooting areas:

1. The Swarm configuration may reference invalid credentials or an unavailable account.
2. The configuration cache may be stale.
3. The configured account may lack the required permissions or have an invalid authentication ticket.

It also advised that, for servers using a sufficiently high Helix Core security level, Swarm may require a valid long-lived ticket instead of a password.

**Assessment:** The web error is consistent with the account and authentication issues identified during the investigation. It does not identify a single definitive root cause.

## 6. Attempts and Results

| Test or action | Result | Interpretation |
|---|---|---|
| Inspect account specification | Account believed to be a standard user | License-saving objective identified |
| Delete original account | Successful | Original account record removed |
| Inspect `config.php` | Successful | Configuration still referenced the original account name |
| Inspect cache file | Successful | Cache existed; validity not established |
| Test account login status | Failed with password-expiration message | Authentication issue identified |
| Test Helix Core with administrative account | Successful | Basic server connectivity confirmed |
| Search user list for original account | No matching entry | Account absent from user listing |
| List pending changelists | Successful | Twelve pending changelists remained visible |
| Inspect a shelved changelist | Successful | Shelved file entries and diff content remained accessible |
| Run PHP inspection on Helix Core server | Failed: PHP unavailable | Wrong server for this check |
| Restore Swarm functionality | Not yet verified | Incident remains open |

## 7. Root-Cause Assessment

### Leading suspected cause

The most likely initiating event was the forced deletion of the original Swarm integration account while the Swarm configuration continued to reference that account.

This introduced an inconsistency between the account expected by the application and the account records available in Helix Core.

### Contributing issue

A subsequent login test reported a password-expiration condition. The account's authentication state and the credentials or ticket actually used by the Swarm application therefore require further verification.

### Additional possibility

The Swarm configuration cache may contain stale information, but no test has demonstrated that the cache is the primary cause.

### Root cause status

**Suspected, not conclusively proven.**

The evidence points to an account lifecycle and authentication problem following the deletion. A successful login using the exact account and authentication method configured in Swarm, followed by a successful web-interface test, is required to confirm recovery.

## 8. Corrective Actions Recommended

1. **Do not delete any additional accounts or pending changelists.** Preserve the current state until the recovery path is confirmed.
2. **Verify the current account record and type** using an appropriately privileged Perforce session.
3. **Confirm the supported account type for the Swarm administrative account.** Do not assume a service-type account can replace a standard administrative account.
4. **Use a dedicated Swarm administrative account if required.** Configure Swarm to use a supported account with the required permissions. Confirm the licensing implications before implementation.
5. **Verify the configured authentication method.** Check whether the application uses a password or a long-lived ticket, and validate the relevant credential securely without putting it into the report or shell history.
6. **Inspect the Swarm application logs** for the exact authentication or configuration error.
7. **Clear the configuration cache only after confirming the configuration and credentials.** Preserve the main configuration file and follow the applicable Swarm documentation.
8. **Test the web interface** and verify that reviews, changelist details, and other expected functions load.
9. **Preserve pending changelists and shelved files.** Confirm an independent backup before any cleanup or ownership changes.
10. **Review license usage** after recovery to verify whether the intended licensing reduction was achieved.

## 9. Verification Required Before Closure

The incident should remain open until all of the following are confirmed:

- [ ] The configured Swarm account exists and has a supported account type.
- [ ] The account has the permissions required by Swarm.
- [ ] The configured authentication method works.
- [ ] Swarm no longer displays the configuration error.
- [ ] The web interface can load the expected reviews and changelist details.
- [ ] Pending changelists and shelved content remain preserved.
- [ ] License usage has been checked after the final account configuration.
- [ ] The final configuration and recovery steps have been documented without recording secrets.

## 10. Final Status

The investigation established that the original integration account was deleted, the Swarm configuration still referenced its name, the authentication test encountered a password-expiration condition, and twelve pending changelists remained visible with shelved content accessible.

Basic Helix Core connectivity was confirmed using an administrative account. However, the Swarm web interface has not yet been confirmed operational.

**Final assessment:** The account deletion and resulting authentication/configuration mismatch are the leading suspected cause. Recovery and license optimization remain outstanding, and no claim of successful restoration or verified license savings should be made until the final tests pass.
