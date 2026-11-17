# Storage Fundamentals: Sectors and Clusters

## Overview

Understanding sectors and clusters is a fundamental skill

Every file ultimately resides on physical disk sectors, while operating systems typically manage storage using clusters.

---

# Storage Hierarchy

```text
Physical Disk
    ↓
Sector
    ↓
Cluster
    ↓
File
```

Example:

```text
Disk
├─ Sector 1
├─ Sector 2
├─ Sector 3
├─ Sector 4
```

Windows groups sectors into clusters and stores files within those clusters.

---

# What is a Sector?

A **sector** is the smallest physical storage unit on a disk.

## Typical Sector Sizes

| Drive Type | Sector Size |
|------------|-------------|
| Legacy HDD | 512 Bytes |
| Modern HDD/SSD | 4096 Bytes (4 KB) |

### Example

```text
Disk
├─ Sector 1 (512 B)
├─ Sector 2 (512 B)
├─ Sector 3 (512 B)
├─ Sector 4 (512 B)
```

The disk hardware reads and writes data at the sector level.

---

# What is a Cluster?

A **cluster** is a group of one or more sectors.

The filesystem (NTFS) allocates storage using clusters rather than individual sectors.

## Example

```text
Sector Size = 512 B

1 Cluster = 8 Sectors

8 × 512 = 4096 B (4 KB)
```

Result:

```text
Cluster = 4 KB
```

---

# Relationship Between Sectors and Clusters

```text
Sectors
   ↓
Form Clusters
   ↓
Clusters Store Files
```

Example:

| Sector Size | Sectors per Cluster | Cluster Size |
|------------|--------------------|--------------|
| 512 B | 8 | 4 KB |
| 4 KB | 1 | 4 KB |
| 4 KB | 16 | 64 KB |

A cluster is simply a collection of sectors.

---

# File Storage Example

Assume:

```text
Cluster Size = 4 KB
```

Create a file:

```text
report.txt = 100 Bytes
```

Storage consumed:

```text
Actual File Size = 100 Bytes
Disk Usage = 4 KB
```

Why?

Because NTFS allocates an entire cluster.

---

# Size vs Size on Disk

Windows properties may show:

```text
Size = 1 KB
Size on Disk = 4 KB
```

The file only contains 1 KB of data, but a full cluster was allocated.

---

# Small Clusters

## Example

```text
Sector Size = 4 KB
Cluster Size = 4 KB
```

### Advantages

- Less wasted space
- Better for many small files
- Common for operating system drives

### Disadvantages

- More filesystem overhead
- More allocation records
- Potentially more fragmentation

### Best Used For

- Windows operating systems
- File servers
- User documents
- General-purpose storage

---

# Large Clusters

## Example

```text
Sector Size = 4 KB
Cluster Size = 64 KB
```

This means:

```text
1 Cluster = 16 Sectors
```

### Advantages

- Better for large files
- Reduced filesystem overhead
- Faster allocation
- Less fragmentation

### Disadvantages

- Wastes space with small files

### Example

```text
File Size = 1 KB
Cluster Size = 64 KB
```

Result:

```text
Disk Usage = 64 KB
```

Even though only 1 KB of data exists.

---

# Comparing Large and Small Clusters

| Feature | Small Cluster (4 KB) | Large Cluster (64 KB) |
|----------|----------|-----------|
| Space Efficiency | Better | Worse |
| Small File Storage | Better | Worse |
| Large File Storage | Good | Better |
| Fragmentation | Higher | Lower |
| Filesystem Overhead | Higher | Lower |

---

# Does a Larger Cluster Change Sector Size?

No.

Example:

```text
Sector Size = 4 KB
Cluster Size = 64 KB
```

A cluster is simply:

```text
16 Sectors
```

The physical sector size never changes.

Think of it like this:

```text
Sector = Brick
Cluster = Wall Made of Bricks
```

Changing the wall size does not change the brick size.

---

# Bad Sectors

A bad sector is a physical location on a disk that can no longer reliably store data.

Common symptoms:

- Read errors
- Write errors
- Disk corruption
- SMART warnings

Administrators often use:

```cmd
chkdsk /r
```

to locate and isolate bad sectors.

---

# Checking Sector and Cluster Information

Run the following command in an elevated Command Prompt:

```cmd
fsutil fsinfo ntfsinfo C:
```

Example output:

```text
Bytes Per Sector  : 4096
Bytes Per Cluster : 65536
```

Which means:

```text
65536 ÷ 4096 = 16

1 Cluster = 16 Sectors
```

---

# VMware Example

Storage flow in VMware:

```text
Physical Disk
    ↓
Sectors
    ↓
Storage Array
    ↓
Datastore (VMFS)
    ↓
VMDK
    ↓
Guest OS Files
```

Even though administrators work with VMDKs and datastores, everything eventually resides on physical disk sectors.

---

# NetApp Example

Typical NetApp storage hierarchy:

```text
Physical Disks
    ↓
Sectors
    ↓
RAID Group
    ↓
Aggregate
    ↓
Volume
    ↓
LUN / SMB Share / NFS Export
```

NetApp abstracts the storage layout, but data still lives on physical sectors.

---

# Veeam Repository Example

Typical backup storage:

```text
Backup Job
    ↓
Repository
    ↓
VBK / VIB Files
```

Since backup files are usually large, administrators commonly use:

```text
64 KB Cluster Size
```

for better efficiency and performance.

---

# Common Cluster Sizes by Workload

| Workload | Typical Cluster Size |
|-----------|--------------------|
| Windows C: Drive | 4 KB |
| File Server | 4 KB |
| User Documents | 4 KB |
| SQL Server Data Volume | 64 KB |
| Veeam Repository | 64 KB |
| Large Media Files | 64 KB |

---


# Key Takeaways

- A sector is the smallest physical storage unit on a disk.
- A cluster is one or more sectors grouped together.
- Files are stored in clusters.
- Clusters reside on sectors.
- Large clusters improve performance for large files.
- Small clusters improve storage efficiency for small files.
- Sector size is determined by the storage hardware.
- Cluster size is determined by the filesystem.
- VMware, NetApp, and Veeam storage ultimately rely on physical sectors.
