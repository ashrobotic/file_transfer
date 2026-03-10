# Automatic File Transfer (Ubuntu ↔ Windows) using SCP

This project provides a **Shell script that monitors a directory in Ubuntu and automatically transfers newly created files to a Windows machine using SCP**.

It uses:

* `inotify` for real-time file monitoring
* `scp` for secure file transfer
* `OpenSSH` on Windows

---

# Architecture

```
Ubuntu (File Monitoring)
        │
        │  SCP
        ▼
Windows (OpenSSH Server)
```

When a new `.txt` file is created in the monitored folder, it is automatically transferred to the Windows machine.

---

# 1. Windows Setup

## Enable ICMP (Optional – for ping)

Open:

**Start → Windows Defender Firewall with Advanced Security**

Navigate to:

**Inbound Rules**

Find the rule:

```
File and Printer Sharing (Echo Request - ICMPv4-In)
```

Right-click the rule → **Enable Rule**

---

# 2. Install OpenSSH on Windows

Open **PowerShell as Administrator**

Check if SSH is installed:

```
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
```

Expected output:

```
OpenSSH.Client~~~~0.0.1.0   Installed
OpenSSH.Server~~~~0.0.1.0   Installed
```

If not installed, run:

```
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```

Start the SSH service:

```
Start-Service sshd
```

Enable automatic startup:

```
Set-Service -Name sshd -StartupType Automatic
```

Verify installation:

```
ssh -V
```

---

# 3. Find Windows Username

Open **Command Prompt** and run:

```
whoami
```

Example output:

```
robo
```

---

# 4. SCP File Transfer Examples

## Ubuntu → Windows

```
scp ~/file_path/fil_name robo@192.168.0.199:"C:/Users/robo/Desktop/"
```

## Windows → Ubuntu

```
scp C:\Users\robo\Desktop\file_name user@192.168.0.151:/home/path_to_move/
```

---

# 5. Ubuntu Setup

Install file monitoring tool:

```
sudo apt install inotify-tools
```

Optional: automate password login using `sshpass`.

Set password variable:

```
export WIN_PASS="2026"
```

Example transfer using password:

```
sshpass -p "$WIN_PASS" scp ~/file_name dell@192.168.x.xxx:"C:/Users/robo/Desktop/"
```

---

# 6. Automatic File Monitoring Script

Example script: **scp_file.sh**

```
#!/bin/bash

WATCH_DIR="$HOME/robo_records"
WINDOWS_USER="robo"
WINDOWS_IP="192.168.x.xxx"
WINDOWS_PATH="C:/Users/robo/Desktop/"

echo "Monitoring $WATCH_DIR for new txt files..."

inotifywait -m -e create --format '%f' "$WATCH_DIR" | while read FILE
do
    if [[ "$FILE" == *.txt ]]; then
        echo "New file detected: $FILE"
        
        scp "$WATCH_DIR/$FILE" ${WINDOWS_USER}@${WINDOWS_IP}:"${WINDOWS_PATH}"
        
        if [ $? -eq 0 ]; then
            echo "File transferred successfully"
        else
            echo "Transfer failed"
        fi
    fi
done
```

---

# 7. Run the Script

Make the script executable:

```
chmod +x scp_file.sh
```

Run it:

```
./scp_file.sh
```

Example output:

```
Monitoring /home/user/patient_records for new txt files...
New file detected: test.txt
File transferred successfully
```

---

# Features

* Real-time directory monitoring
* Automatic file transfer
* Secure SCP communication
* Simple shell-based implementation
* Works between Ubuntu and Windows

---

# Requirements

## Ubuntu

* `inotify-tools`
* `scp`
* `sshpass` (optional)

## Windows

* OpenSSH Server

---

# Use Cases

* Automated file backup
* IoT data collection
* Robotics system logging
* Edge device to workstation data transfer

---

# Author

Ash Robotics
