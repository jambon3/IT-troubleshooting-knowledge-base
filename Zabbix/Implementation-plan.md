# Zabbix Deployment Proposal and Build Specification

## Overview

This document outlines the proposed deployment of a Zabbix monitoring platform for a VMware vSphere environment. The solution will provide centralized monitoring, email alerting, performance reporting, historical trend analysis, and capacity planning.

## Current Environment

### VMware Infrastructure

- 2 ESXi Hosts
- Approximately 14 Virtual Machines
- VMware vCenter 7.0.1
- Minimal anticipated growth

### Monitoring Requirements

- Email alerting
- VMware infrastructure monitoring
- Historical performance monitoring
- Capacity planning
- 30-day history retention

---

# Proposed Server Specifications

## Virtual Machine

### Server Name

```text
ZABBIX01
```

### Operating System

```text
Ubuntu Server 24.04 LTS
```

### Resources

```text
CPU: 2 vCPU
Memory: 8 GB RAM
Storage: 150 GB SSD
```

### Software Stack

```text
Zabbix LTS
PostgreSQL 16
TimescaleDB
Nginx
PHP 8.3
```

---

# Why This Configuration?

The proposed specifications provide sufficient resources for the current environment while allowing room for future expansion.

Benefits include:

- VMware Host Monitoring
- VMware Virtual Machine Monitoring
- vCenter Monitoring
- Email Alerting
- Historical Performance Graphs
- Capacity Planning
- Infrastructure Trend Analysis
- Future Growth Beyond Current Requirements

The solution is intentionally sized to avoid overprovisioning while maintaining scalability.

---

# Monitoring Scope

## ESXi Host Monitoring

Monitor:

```text
CPU Utilization
Memory Utilization
Storage Utilization
Network Utilization
Host Availability
Hardware Health Status
```

## Virtual Machine Monitoring

Monitor:

```text
CPU Usage
Memory Usage
Disk Consumption
Network Activity
Power State
Availability Status
```

## Datastore Monitoring

Monitor:

```text
Capacity Usage
Free Space
Storage Growth
Threshold Alerts
```

## vCenter Monitoring

Monitor:

```text
vCenter Availability
Service Health
Performance Statistics
Inventory Discovery
System Events
```

---

# Historical Performance Data

Historical data collection is strongly recommended.

## Benefits

### Capacity Planning

Examples:

```text
How quickly is datastore storage growing?
When will additional storage be required?
Which virtual machines consume the most resources?
```

### Troubleshooting

Examples:

```text
When did performance degradation begin?
Was CPU utilization elevated before an outage?
Was memory usage increasing prior to a failure?
```

### Trend Analysis

Examples:

```text
CPU trends over time
Memory trends over time
Storage growth trends
Network utilization trends
```

Historical graphs often provide more value than alerts alone because they help identify patterns and support proactive infrastructure planning.

---

# Data Retention

## History Data

```text
30 Days
```

## Trend Data

```text
365 Days
```

This approach provides long-term reporting capabilities while maintaining a manageable database size.

---

# VMware Integration Requirements

## Service Account

Create a dedicated monitoring account with:

```text
Read-Only Permissions
Permission Propagation Enabled
```

Administrative permissions are not required.

---

# Network Requirements

## Required Ports

```text
TCP 443   - Zabbix Server to vCenter
TCP 10051 - Zabbix Server
TCP 10050 - Zabbix Agent (Optional)
TCP 25    - SMTP
TCP 587   - SMTP Submission
```

---

# High-Level Implementation Plan

## Phase 1 - Server Deployment

- Deploy Ubuntu Server 24.04 LTS
- Apply operating system updates
- Configure hostname
- Configure static IP address
- Configure DNS
- Configure NTP

---

## Phase 2 - Database Installation

- Install PostgreSQL 16
- Install TimescaleDB
- Create the Zabbix database
- Configure retention settings

---

## Phase 3 - Zabbix Installation

- Install Zabbix Server
- Install Zabbix Frontend
- Install Zabbix Agent
- Configure database connectivity
- Configure web interface

---

## Phase 4 - VMware Integration

- Create VMware monitoring account
- Configure VMware API connectivity
- Connect Zabbix to vCenter
- Apply VMware templates
- Validate data collection

---

## Phase 5 - Alerting Configuration

- Configure SMTP server settings
- Configure email notifications
- Create alert actions
- Define monitoring thresholds

Example alerts:

```text
Host Unavailable
High CPU Usage
High Memory Usage
Low Datastore Space
VM Powered Off
```

---

## Phase 6 - Validation

- Verify VMware discovery
- Validate host monitoring
- Validate VM monitoring
- Test email alerts
- Confirm data collection
- Verify historical graph generation

---

# Expected Outcomes

After implementation, the platform will provide:

- ✅ ESXi Host Monitoring
- ✅ Virtual Machine Monitoring
- ✅ VMware vCenter Monitoring
- ✅ Email Alerting
- ✅ Historical Performance Graphs
- ✅ Capacity Planning Metrics
- ✅ Long-Term Trend Analysis
- ✅ Centralized Monitoring Dashboard
- ✅ Scalable Foundation for Future Growth

---

# Final Recommendation

## Build Specification

```text
Server Name: ZABBIX01

Operating System:
- Ubuntu Server 24.04 LTS

Resources:
- 2 vCPU
- 8 GB RAM
- 150 GB SSD

Software:
- Zabbix LTS
- PostgreSQL 16
- TimescaleDB
- Nginx
- PHP 8.3

Retention:
- History Data: 30 Days
- Trend Data: 365 Days

Monitoring Scope:
- VMware ESXi Hosts
- VMware Virtual Machines
- VMware vCenter

Capabilities:
- Email Alerting
- Historical Performance Reporting
- Capacity Planning
- Trend Analysis
```

## Conclusion

This configuration is appropriately sized for the current environment of 2 ESXi hosts and approximately 14 virtual machines. It provides all required monitoring functionality while maintaining sufficient capacity for future growth and long-term performance analysis.
