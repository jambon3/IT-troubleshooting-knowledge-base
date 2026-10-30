# Perforce Swarm — SMTP Email Notification Troubleshooting

**Incident ID:** APP-EMAIL-001  
**Category:** Application / Linux / SMTP / Microsoft 365  
**Status:** CLOSED — RESOLVED  
**Platform:** Perforce Helix Swarm  
**Operating System:** Linux  
**Application Directory:** `/opt/perforce/swarm`  
**Log File:** `/opt/perforce/swarm/data/log`  
**Documentation:** Sanitized for a public GitHub technical portfolio

---

## 1. Executive Summary

Perforce Swarm was not delivering email notifications when users created or participated in code reviews.

The investigation identified an SMTP connectivity problem. Swarm was successfully generating notification events and identifying recipients, but it could not establish a connection to its configured SMTP destination.

The primary error identified in the application logs was:

```text
Unable to connect to tcp://localhost:25
(Connection refused)
```

The investigation established that Swarm was attempting to connect to `localhost` on TCP port 25, where no local SMTP service was accepting connections.

The troubleshooting process included:

- Analyzing Swarm application logs.
- Investigating notification generation and recipient resolution.
- Checking the Linux SMTP service.
- Inspecting TCP port 25.
- Investigating Swarm mail configuration.
- Testing connectivity to Microsoft 365 Exchange Online Protection.
- Reviewing application configuration permissions.
- Investigating Perforce backend connectivity.

The SMTP connectivity problem was addressed, and the Swarm application and its expected functionality were subsequently restored.

**Final outcome:** Email notification functionality was restored, and the incident was closed.

## 2. Sanitized Environment Details

All infrastructure identifiers below are fictional examples.

| Component | Example |
|---|---|
| Application | Perforce Helix Swarm |
| Application server | SWARM-SERVER-01 |
| Operating system | Linux |
| Application directory | `/opt/perforce/swarm` |
| Application log | `/opt/perforce/swarm/data/log` |
| Web server | Apache |
| Application runtime | PHP |
| Source control | Perforce Helix Core |
| Original SMTP destination | localhost |
| Original SMTP port | 25 |
| Intended SMTP relay | example-com.mail.protection.outlook.com |
| SMTP relay port | 25 |
| Sender address | notifications@example.com |
| Example recipient | developer@example.com |

## 3. Root Cause Analysis

**Root cause: Swarm was configured to use a local SMTP endpoint that was not accepting connections.**

The application attempted to establish an SMTP connection to:

```text
localhost:25
```

However, no local SMTP service was listening on the expected port.

The connection therefore failed before Swarm could establish an SMTP session.

### Confirmed findings

- Swarm was generating notification events.
- Recipient identification was functioning.
- The application attempted to use `localhost:25`.
- The local SMTP connection returned `Connection refused`.
- Postfix was not found during the investigation.
- Microsoft 365 Exchange Online Protection was investigated as the intended external SMTP relay.
- TCP connectivity to the external relay was successfully tested.

The issue was related to SMTP delivery rather than code review creation or the Perforce backend.

## 4. Troubleshooting and Resolution

### Step 1 — Locate the Swarm installation

**Objective:** Identify the application directory and log locations.

Commands:

```bash
cd /opt/perforce/swarm
pwd
ls -lah
```

**Result:**

The application was located under:

```text
/opt/perforce/swarm
```

The application log was identified at:

```text
/opt/perforce/swarm/data/log
```

### Step 2 — Analyze Swarm application logs

**Objective:** Identify errors related to email notifications.

Command:

```bash
sudo grep -i -n -E \
"localhost:25|connection refused|smtp|mail|email" \
/opt/perforce/swarm/data/log | tail -100
```

**Result:**

The logs showed that Swarm was processing notification events and identifying recipients.

However, the SMTP connection failed with:

```text
Unable to connect to tcp://localhost:25
(Connection refused)
```

**Finding:** Notification generation was working, but SMTP delivery was failing.

### Step 3 — Verify code review notification generation

**Objective:** Determine whether code review creation or recipient identification was causing the issue.

The investigation included reviewing test code reviews.

Sanitized examples:

```text
Review ID: 8146
Review ID: 8215
```

**Result:**

- Code reviews were being created.
- Notification processing was occurring.
- Recipient information was being resolved.
- The failure occurred during SMTP dispatch.

An incorrect/default sender identity was also identified during the investigation:

```text
notifications@SWARM-SERVER-01
```

This was investigated as part of the mail configuration troubleshooting.

### Step 4 — Investigate the local SMTP service

**Objective:** Determine whether a local mail transfer agent was available.

Commands:

```bash
sudo systemctl status postfix
```

```bash
dpkg -l | grep -i postfix
```

```bash
sudo ss -ltnp | grep ':25'
```

**Result:**

Postfix was not found during the investigation, and no local SMTP service was accepting connections on TCP port 25.

**Finding:** The application was configured to use a local SMTP endpoint that was unavailable.

### Step 5 — Investigate Microsoft 365 SMTP relay

**Objective:** Identify and test the intended corporate SMTP relay.

Sanitized example:

```text
example-com.mail.protection.outlook.com
```

The intended SMTP parameters were:

| Parameter | Value |
|---|---|
| SMTP hostname | example-com.mail.protection.outlook.com |
| Port | TCP 25 |
| Protocol | SMTP |
| Sender | notifications@example.com |

Connectivity test:

```bash
nc -vz example-com.mail.protection.outlook.com 25
```

**Result:**

The TCP connectivity test succeeded.

This confirmed that the server could reach the external SMTP relay on port 25.

A successful TCP connection alone does not guarantee that an email will be accepted or delivered, so application-level testing was also necessary.

### Step 6 — Investigate Swarm mail configuration

**Objective:** Identify the incorrect SMTP destination and sender configuration.

The original mail configuration referenced:

```text
localhost:25
```

The intended configuration was to use the corporate Microsoft 365 SMTP relay.

The investigation also identified a file permission issue.

The relevant application configuration file was owned by:

```text
www-data
```

Its permissions were:

```text
-rw-r-----
```

An initial PHP validation attempt failed because the configuration file could not be accessed with the current permissions.

The correct validation approach was to use elevated privileges:

```bash
sudo php -l /path/to/swarm/config.php
```

Expected successful result:

```text
No syntax errors detected in /path/to/swarm/config.php
```

The SMTP destination and sender identity were addressed during the corrective work.

### Step 7 — Investigate Perforce backend connectivity

**Objective:** Rule out the Perforce Helix Core backend as the primary cause.

The investigation included reviewing the application's Perforce connection and service account authentication.

**Result:**

Code review creation and notification recipient resolution were functioning.

The evidence continued to point to SMTP connectivity as the primary problem.

### Step 8 — Verify recovery and close the incident

**Objective:** Confirm that the application was operational following corrective action.

**Result:**

- Swarm web interface operational.
- Code review functionality restored.
- Expected application functions operational.
- SMTP connectivity issue addressed.
- Email notification functionality restored.
- Production application available.

**Final status: CLOSED — RESOLVED.**

## 5. Consolidated Troubleshooting Commands

The following commands provide a reusable diagnostic reference.

### Inspect application logs

```bash
sudo tail -100 /opt/perforce/swarm/data/log
```

```bash
sudo grep -i -n -E \
"smtp|mail|email|localhost:25|connection refused" \
/opt/perforce/swarm/data/log
```

### Check the local SMTP service

```bash
sudo systemctl status postfix
```

```bash
dpkg -l | grep -i postfix
```

```bash
sudo ss -ltnp | grep ':25'
```

### Test external SMTP connectivity

```bash
nc -vz example-com.mail.protection.outlook.com 25
```

### Validate PHP configuration syntax

```bash
sudo php -l /path/to/swarm/config.php
```

### Inspect application file permissions

```bash
ls -lah /opt/perforce/swarm/data
```

These commands should be executed using appropriately authorized administrative access.

## 6. Final Findings

| Investigation | Finding |
|---|---|
| Swarm application | Operational |
| Code review creation | Working |
| Notification generation | Working |
| Recipient identification | Working |
| Original SMTP destination | localhost |
| Local SMTP port | 25 |
| Local SMTP service | Not available |
| SMTP connection | Connection refused |
| Microsoft 365 relay | Identified |
| External TCP connectivity | Successful |
| Application configuration | Investigated and corrected |
| Email notification functionality | Restored |
| Incident status | CLOSED — RESOLVED |

## 7. Lessons Learned

1. **Application logs are essential:** They helped isolate the failure to the SMTP delivery process.
2. **Understand localhost:** It refers to the local server, not an external mail service.
3. **Check listening services:** A refused connection on port 25 warrants investigation of local SMTP services.
4. **Test network connectivity:** Validate external SMTP reachability separately from application functionality.
5. **Understand Linux permissions:** Application configuration files may require elevated privileges for inspection and validation.
6. **Separate application and infrastructure failures:** Successful notification generation does not guarantee successful email delivery.
7. **Preserve production functionality:** Troubleshooting should avoid unnecessary disruption to the source-control environment.

## 8. Final Assessment

This incident demonstrated practical troubleshooting across several infrastructure layers:

- Linux system administration.
- Apache and PHP application troubleshooting.
- Perforce Helix Swarm.
- SMTP and TCP connectivity.
- Microsoft 365 Exchange Online Protection.
- Application configuration and file permissions.
- Log analysis and service dependency investigation.

The investigation identified an unavailable local SMTP endpoint as the cause of the email notification failure.

Corrective action restored the expected Swarm functionality and email notification service.

**FINAL STATUS: CLOSED — RESOLVED.**

---

## 9. References

- [Perforce Helix Swarm Documentation](https://help.perforce.com/helix-swarm/)
- [Microsoft Learn — Exchange Online](https://learn.microsoft.com/en-us/exchange/exchange-online)
- [Microsoft Learn — Exchange Online Mail Flow](https://learn.microsoft.com/en-us/exchange/mail-flow-best-practices/mail-flow-best-practices)
- [PHP Documentation](https://www.php.net/manual/en/)
- [Linux ss Manual](https://man7.org/linux/man-pages/man8/ss.8.html)

---

*Sanitization notice: All hostnames, email addresses, identifiers, and network details are fictional. No actual company infrastructure information should be published in a public repository.*
