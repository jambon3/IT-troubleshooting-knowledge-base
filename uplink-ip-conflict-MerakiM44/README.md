***information are sanitized. 
# Cisco Meraki MR44 — Uplink IP Conflict Troubleshooting

**Incident ID:** NET-001  
**Category:** Networking / IP Address Conflict  
**Status:** Mitigation attempted — pending verification  
**Device:** Cisco Meraki MR44 access point  
**Documentation:** Sanitized for a public technical portfolio

## 1. Issue summary

A Cisco Meraki MR44 access point reported the warning:

> Uplink IP address in conflict with another device.

The investigation identified a duplicate IPv4 address: the access point received an address through DHCP that was also configured statically on a production server.

The investigation included checking DHCP leases, investigating alternative IP addresses, creating a DHCP reservation, and attempting to configure the access point with a different address.

The new address and the final resolution have not yet been conclusively verified.

## 2. Network details

All names, IP addresses, and MAC addresses below are fictional examples used for documentation.

| Component | Example details |
|---|---|
| Access point | Cisco Meraki MR44, `AP-LAB-01` |
| Access point MAC | `AA-BB-CC-DD-EE-FF` |
| Original access point IP | `10.20.30.92` via DHCP |
| Production server | `APP-SERVER-01` |
| Production server IP | `10.20.30.92` (static) |
| Default gateway | `10.20.30.29` |
| DHCP server | `DHCP-SERVER-01` (`10.20.30.27`) |
| DNS servers | `10.20.30.7`, `10.20.40.200` |
| Subnet | `10.20.30.0/24` |
| Example DHCP pool | `10.20.30.60–10.20.30.199` |
| Candidate replacement IP | `10.20.30.130` |

### Root cause

The access point's DHCP-assigned IP address conflicted with the production server's statically configured IP address.

Two devices on the same network should not use the same IPv4 address. This can cause connectivity problems and trigger duplicate-IP warnings.

## 3. Troubleshooting performed

### Step 1 — Identify the duplicate address

**Result:** Confirmed.

The MR44 received `10.20.30.92` through DHCP, while the production server was configured with the same address statically.

### Step 2 — Identify the DHCP server

**Result:** Confirmed.

The DHCP server was identified as a Windows DHCP Server, and the relevant scope was identified as `10.20.30.0/24`.

### Step 3 — Inspect the DHCP lease

**Result:** Inconclusive.

The original address was initially associated with the MR44's MAC address in the DHCP lease information. Later, the lease was no longer visible in the query results, although the Meraki Dashboard continued to display the original address.

The disappearance of a DHCP lease record did not establish that the IP conflict had been resolved.

### Step 4 — Investigate an alternative IP address

**Result:** The candidate was not selected.

A ping to another candidate address received a response, and an ARP lookup returned a MAC address consistent with a possible virtual machine.

The address was therefore not selected for the MR44.

### Step 5 — Investigate a second candidate IP

**Result:** No conclusive evidence that the address was unused.

The DHCP query returned no lease for `10.20.30.130`. A ping test from the DHCP server returned “Destination host unreachable,” and the local ARP query returned no entry.

These results did not prove that the address was unused. An offline device, a device on another network segment, or network filtering could affect the results.

### Step 6 — Create a DHCP reservation

**Result:** Reservation created and verified.

A reservation was created for the MR44's MAC address using the candidate IP `10.20.30.130`.

The reservation appeared in the DHCP configuration, but its state remained `InactiveReservation` during subsequent checks.

An inactive reservation means the DHCP server had not recorded an active lease for that reservation at the time of the check. It does not, by itself, establish whether the access point was using a static address.

### Step 7 — Check DHCP exclusions

**Result:** No exclusions were returned.

The DHCP exclusion query returned no entries for the scope.

This did not establish that every address in the subnet was available, because static assignments and devices not currently visible to DHCP could still be using addresses.

### Step 8 — Reboot the access point

**Result:** No confirmed address change.

The MR44 was rebooted through the Meraki Dashboard. The reservation remained inactive afterward.

### Step 9 — Attempt static IP configuration

**Result:** Pending verification.

The configuration form displayed static IP settings for the candidate address. However, the Dashboard's reported address and the failed connectivity test did not conclusively establish that the new configuration had taken effect.

The actual IP configuration, subnet mask, gateway reachability, and connectivity must be verified before the incident can be marked resolved.

## 4. PowerShell troubleshooting commands

Run the following commands in an appropriately authorized PowerShell session on a system with the Windows DHCP Server management tools installed.

Replace the example values with the correct values for the environment being investigated.

### A. Set investigation variables

```powershell
$DhcpServer = "DHCP-SERVER-01"
$ScopeId    = "10.20.30.0"
$TargetIP   = "10.20.30.130"
$ApMac      = "AA-BB-CC-DD-EE-FF"
```

### B. Check whether the candidate has a DHCP lease

```powershell
Get-DhcpServerv4Lease `
    -ComputerName $DhcpServer `
    -ScopeId $ScopeId |
    Where-Object {
        $_.IPAddress.IPAddressToString -eq $TargetIP
    } |
    Format-List *
```

**Purpose:** Checks whether the DHCP server currently has a lease record for the candidate address.

An empty result means no matching lease was returned. It does not prove the address is unused.

### C. Check existing DHCP reservations

```powershell
Get-DhcpServerv4Reservation `
    -ComputerName $DhcpServer `
    -ScopeId $ScopeId |
    Format-Table IPAddress, ClientId, Name, Description -AutoSize
```

To inspect only the candidate address:

```powershell
Get-DhcpServerv4Reservation `
    -ComputerName $DhcpServer `
    -ScopeId $ScopeId |
    Where-Object {
        $_.IPAddress.IPAddressToString -eq $TargetIP
    } |
    Format-List *
```

**Purpose:** Verifies whether a reservation already exists for the candidate IP.

### D. Check DHCP exclusion ranges

```powershell
Get-DhcpServerv4ExclusionRange `
    -ComputerName $DhcpServer `
    -ScopeId $ScopeId
```

**Purpose:** Lists the address ranges excluded from DHCP allocation in the selected scope.

### E. Test network reachability

Run this command from the DHCP server or another suitable machine on the same subnet:

```powershell
Test-Connection -ComputerName $TargetIP -Count 2
```

**Purpose:** Tests whether the candidate responds to ICMP echo requests.

A failed ping does not prove an IP address is unused.

### F. Inspect the local ARP/neighbor cache

```powershell
Get-NetNeighbor -AddressFamily IPv4 |
    Where-Object {
        $_.IPAddress -eq $TargetIP
    } |
    Format-Table IPAddress, LinkLayerAddress, State -AutoSize
```

**Purpose:** Checks whether the local system has a neighbor-cache entry for the candidate address.

No entry may simply mean that the system has not recently resolved that address. A stale entry may also need further investigation.

### G. Create a DHCP reservation

**Run this only after confirming that the address is appropriate for the access point, checking for conflicting assignments, and verifying the correct MAC address.**

```powershell
Add-DhcpServerv4Reservation `
    -ComputerName $DhcpServer `
    -ScopeId $ScopeId `
    -IPAddress $TargetIP `
    -ClientId $ApMac `
    -Name "Meraki-MR44-Lab" `
    -Description "Reserved IP for Meraki MR44"
```

To verify the reservation afterward:

```powershell
Get-DhcpServerv4Reservation `
    -ComputerName $DhcpServer `
    -ScopeId $ScopeId |
    Where-Object {
        $_.IPAddress.IPAddressToString -eq $TargetIP
    } |
    Format-List *
```

**Important:** Creating a reservation does not force an access point configured with a static IP to use that address. The access point must be configured appropriately, and its actual address must be verified.

## 5. Vendor documentation

Cisco Meraki's official documentation explains static IP assignment for Meraki access points:

[Static IP Assignment on a Cisco Meraki Access Point](https://documentation.meraki.com/Wireless/Operate_and_Maintain/How_Tos/Features_and_Integrations/Static_IP_Assignment_on_a_Cisco_Meraki_Access_Point)

Refer to the vendor instructions when applying or verifying the static IP configuration.

## 6. Outstanding verification

The following items remain before the incident can be considered resolved:

- [ ] Confirm the MR44's actual IP address in the Meraki Dashboard.
- [ ] Confirm that the configured subnet mask, gateway, and DNS settings are correct.
- [ ] Confirm that the replacement IP does not conflict with another device.
- [ ] Verify connectivity between the access point, gateway, and required management services.
- [ ] Confirm that the original duplicate-IP warning remains cleared.
- [ ] Confirm that the production server retains its original IP address and remains reachable.
- [ ] Determine whether any DHCP scope changes are necessary to protect statically assigned addresses from future conflicts.

## 7. Current status

**Mitigation attempted — pending verification.**

The duplicate-IP root cause was identified, and a DHCP reservation was created for an alternative address. However, the reservation's inactive state and the unconfirmed IP configuration mean the final resolution has not yet been demonstrated.

The incident should only be marked **Resolved** after the access point's active address and connectivity are verified and the conflict warning is confirmed cleared.

## 8. Lessons learned

- Investigate DHCP leases, reservations, exclusions, static assignments, and ARP information before selecting an alternative IP address.
- A failed ping or missing ARP entry is not proof that an address is free.
- DHCP reservations and static IP configurations are different mechanisms.
- Verify the device's actual network configuration rather than relying solely on an edit form.
- Document confirmed findings separately from assumptions and outstanding work.

*This report uses fictional example identifiers and addresses. Never publish real company hostnames, internal network details, device MAC addresses, credentials, certificates, or sensitive logs in a public repository.*
