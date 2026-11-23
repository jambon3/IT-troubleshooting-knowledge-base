# Create a Bootable Sergei Strelec USB Using Rufus

## Overview

This guide explains how to download **Sergei Strelec WinPE 11-10 (x64) English Version 2026.09.08** and create a bootable USB drive using Rufus.

Sergei Strelec is a Windows Preinstallation Environment (WinPE) toolkit used for:

- Windows troubleshooting and recovery
- HDD and SSD diagnostics
- Disk partition management
- Backup and recovery
- Data recovery
- Windows installation
- System maintenance

## Requirements

| Component | Requirement |
|---|---|
| USB Flash Drive | 16 GB recommended |
| Operating System | Windows |
| ISO Image | Sergei Strelec WinPE x64 |
| USB Creation Tool | Rufus |
| USB Interface | USB 3.0 recommended |

## Step 1 – Download Sergei Strelec

Download the English x64 version from:

**[Sergei Strelec – WinPE 11-10 x64 English Version 2026.09.08](https://sergeistrelec.name/winpe-10-8-sergei-strelec-english/288-winpe-11-10-sergei-strelec-x64-20260908-english-version.html)**

1. Open the download page.
2. Select one of the available download mirrors.
3. Download the archive.
4. Extract the downloaded archive using 7-Zip or WinRAR.
5. If prompted for an archive password, use the password specified on the download page.
6. Locate the `.iso` file.

**Important:** Select the extracted ISO file, not the compressed ZIP or RAR archive.

## Step 2 – Download Rufus

Download Rufus from its official website:

https://rufus.ie/

1. Download the latest version.
2. Run `rufus.exe` as Administrator.
3. Insert your USB flash drive.

## Step 3 – Configure Rufus

Open Rufus and configure the following settings:

| Setting | Recommended Configuration |
|---|---|
| Device | Your USB Flash Drive |
| Boot Selection | Disk or ISO Image |
| Image Selection | Sergei Strelec `.iso` |
| Partition Scheme | GPT (UEFI systems) |
| Target System | UEFI (non-CSM) |
| File System | Use Rufus defaults; NTFS if required |

**Note:** If your target computer uses Legacy BIOS, select MBR instead of GPT.

### Creating the Bootable USB

1. Click **SELECT**.
2. Browse to the extracted Sergei Strelec ISO.
3. Select the ISO file.
4. Verify that the correct USB device is selected.
5. Click **START**.
6. If Rufus asks between ISO Image mode and DD Image mode, try ISO Image mode first.
7. Confirm the formatting warning.
8. Wait until Rufus displays **READY**.

**Warning:** This operation erases all existing data on the selected USB drive. Verify the device before proceeding.

## Step 4 – Boot From USB

Once Rufus has completed:

1. Safely eject the USB drive.
2. Insert it into the target computer.
3. Restart the computer.
4. Open the BIOS/UEFI boot menu.
5. Select the USB drive.
6. Select the Sergei Strelec WinPE environment.

### Common Boot Menu Keys

| Manufacturer | Boot Menu Key |
|---|---|
| Dell | F12 |
| HP | F9 |
| Lenovo | F12 |
| ASUS | ESC |
| Acer | F12 |
| MSI | F11 |

## Step 5 – Troubleshooting

### Rufus Error: Image Is Either Non-Bootable or Uses an Unsupported Boot Method

Possible causes:

- Incorrect ISO file selected.
- Incomplete or corrupted download.
- Compressed archive selected instead of extracted ISO.
- ISO boot structure not recognized by Rufus.

Recommended actions:

1. Verify that the ISO was completely extracted.
2. Download the ISO again if necessary.
3. Verify the ISO checksum if one is published.
4. Check the Sergei Strelec archive for its recommended USB creation methods.
5. Alternatively, use Ventoy.

### Alternative: Use Ventoy

If Rufus cannot recognize the ISO, Ventoy is an alternative.

Official website:

https://www.ventoy.net/

1. Download and extract Ventoy.
2. Run `Ventoy2Disk.exe` as Administrator.
3. Select your USB drive.
4. Click **Install**.
5. Copy the Sergei Strelec ISO directly onto the USB drive.
6. Boot the computer from USB.
7. Select Sergei Strelec from the Ventoy menu.

The Sergei Strelec release documentation also identifies Ventoy as a supported way to boot the ISO.

## Useful Resources

- [Sergei Strelec Official Website](https://sergeistrelec.name/)
- [Rufus Official Website](https://rufus.ie/)
- [Ventoy Official Website](https://www.ventoy.net/)

## Conclusion

Sergei Strelec WinPE is a useful addition to an IT administrator's troubleshooting toolkit.

Rufus can be used to create a bootable USB when it recognizes the ISO correctly. If Rufus rejects the image, Ventoy provides an alternative method.

Always test the USB on a non-production computer before relying on it for system recovery.
