# NetBox Server Deployment on VMware ESXi

## Project Overview

This project documents the deployment and initial configuration of an Ubuntu Server virtual machine on VMware ESXi, preparing the environment to host NetBox for infrastructure documentation and IP Address Management (IPAM).

The deployment covers virtual machine provisioning, Linux installation, network configuration, DHCP troubleshooting, static IP assignment, and SSH remote administration.

**Environment:** Sanitized demonstration based on real-world infrastructure administration experience.

## 1. VMware Virtual Machine Provisioning

Provisioned a new virtual machine using VMware vSphere.

| Component | Configuration |
|---|---|
| Hypervisor | VMware ESXi |
| Management | VMware vSphere |
| Guest OS | Ubuntu Server 24.04 LTS |
| CPU | 2 vCPUs |
| Memory | 8 GB |
| Storage | 40 GB virtual disk |
| Disk provisioning | Thin |
| Network adapter | VMXNET3 |
| Network | Designated server network |

## 2. Ubuntu Server Installation

Installed Ubuntu Server and configured the initial administrative account.

Installation decisions:

- Configured a dedicated server hostname.
- Created a local administrative account.
- Selected LVM for disk management.
- Enabled OpenSSH Server.
- Left the proxy configuration empty because no proxy was required during installation.
- Skipped optional featured server snaps.

A local administrative account was retained for recovery and maintenance.

## 3. Network Discovery and Troubleshooting

The server initially received an IPv4 address through DHCP.

The network interface and address were inspected using:

```bash
ip -br addr
```

The routing table was inspected using:

```bash
ip route
```

The primary network interface was identified as:

```text
ens192
```

### DHCP investigation

The initial DHCP address differed from the intended reserved address.

Troubleshooting steps included:

1. Inspecting the DHCP scope.
2. Reviewing the DHCP reservation.
3. Comparing the reservation's MAC address with the VMware virtual network adapter.
4. Identifying the DHCP server responding to the VM.
5. Investigating why the expected reservation was not being applied.

This demonstrated the difference between dynamic DHCP assignment, DHCP reservations, and manually configured static addressing.

## 4. SSH Remote Administration

OpenSSH Server was enabled during Ubuntu installation.

Service status was verified using:

```bash
sudo systemctl status ssh
```

Connectivity was tested from Windows PowerShell:

```powershell
Test-NetConnection SERVER_IP -Port 22
```

A remote connection was established using:

```powershell
ssh adminuser@SERVER_IP
```

SSH provided command-line administration without requiring continuous access to the VMware console.

## 5. Static IPv4 Configuration with Netplan

After investigating the DHCP reservation, the server was configured with a manually assigned IPv4 address.

Ubuntu uses Netplan to manage network configuration.

### Step 1 — Inspect the existing configuration

```bash
ls -l /etc/netplan/
```

```bash
sudo cat /etc/netplan/*.yaml
```

Original DHCP configuration:

```yaml
network:
  version: 2
  ethernets:
    ens192:
      dhcp4: true
```

### Step 2 — Back up the configuration

```bash
sudo cp /etc/netplan/50-cloud-init.yaml \
/etc/netplan/50-cloud-init.yaml.backup
```

### Step 3 — Configure a static address

The following example uses documentation-only network addresses.

```yaml
network:
  version: 2
  ethernets:
    ens192:
      dhcp4: false
      addresses:
        - 192.0.2.50/24
      routes:
        - to: default
          via: 192.0.2.1
      nameservers:
        addresses:
          - 192.0.2.7
          - 192.0.2.8
        search:
          - example.invalid
```

**Important:** The addresses above are illustrative only. Replace them with network values approved for the deployment environment. Confirm that the address is allocated and does not conflict with another device.

### Step 4 — Validate the configuration

```bash
sudo netplan generate
```

The configuration passed validation without errors.

### Step 5 — Apply the configuration

```bash
sudo netplan apply
```

The SSH connection may disconnect when the network address changes. Keep the VMware console available for recovery.

### Step 6 — Verify the new address

```bash
ip -br addr
```

The network interface displayed the intended static IPv4 address.

## 6. Connectivity Verification

From Windows PowerShell:

```powershell
ssh adminuser@SERVER_IP
```

Additional verification commands:

```bash
hostnamectl
```

```bash
ip route
```

```bash
resolvectl status
```

Remote SSH connectivity was successfully established using the new address.

## 7. Troubleshooting Reference

| Task | Command |
|---|---|
| Display IP addresses | `ip -br addr` |
| Display routing table | `ip route` |
| Inspect interfaces | `ip link` |
| List Netplan files | `ls -l /etc/netplan/` |
| Display Netplan configuration | `sudo cat /etc/netplan/*.yaml` |
| Validate Netplan | `sudo netplan generate` |
| Apply Netplan | `sudo netplan apply` |
| Check SSH service | `sudo systemctl status ssh` |
| Display hostname | `hostnamectl` |
| Check DNS configuration | `resolvectl status` |
| Test SSH port | `Test-NetConnection SERVER_IP -Port 22` |

## 8. Technical Skills Demonstrated

- VMware ESXi and vSphere administration.
- Ubuntu Server deployment.
- Linux system administration.
- Virtual network adapter configuration.
- DHCP reservation troubleshooting.
- Static IPv4 addressing.
- Netplan YAML configuration.
- DNS and default gateway configuration.
- OpenSSH remote administration.
- Windows PowerShell diagnostics.
- Network troubleshooting.

## 9. Future Project Milestones

- [ ] Apply Ubuntu security updates.
- [ ] Configure SSH key-based authentication.
- [ ] Restrict SSH access through firewall rules.
- [ ] Integrate Active Directory authentication, if required.
- [ ] Install and configure NetBox.
- [ ] Configure PostgreSQL.
- [ ] Configure Redis.
- [ ] Configure HTTPS and authentication.
- [ ] Implement automated backups.
- [ ] Document infrastructure inventory and network topology.

## Project Status

**Completed:** Ubuntu Server deployment, initial network troubleshooting, static IP configuration, and SSH remote access.

**Next phase:** NetBox installation and production security configuration.

## Security and Privacy Notice

This repository intentionally uses sanitized infrastructure information.

No production IP addresses, internal DNS records, MAC addresses, hostnames, credentials, configuration exports, or confidential company information should be committed to this repository.
