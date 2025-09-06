# Configure `ufw` or `iptables` to allow only HTTP(80), HTTPS(443), SSH(22), andMySQL(3306) from a specific IP range.

## Using `ufw`:

### Step 1:
check status:
```bash
sudo ufw status
```
Reset for a clean slate:
```bash
sudo ufw --force reset
```
Set default policies:
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

### Step 2:
Allow SSH from specific IP range:
```bash
sudo ufw allow from 102.91.93.119/24 to any port 22
```
Allow other services:

HTTP:
```bash
sudo ufw allow from 102.91.93.119/24 to any port 80
```
HTTPS:
```bash
sudo ufw allow from 102.91.93.119/24 to any port 443
```
MySQL:
```bash
sudo ufw allow from 102.91.93.119/24 to any port 3306
```
enable `ufw`:
```bash
sudo ufw enable
```
Verify with:
```bash
sudo ufw status numbered
```
![step](images/result.png)

## Using `iptables`:

### Step 1:
Check rules:
```bash
sudo iptables -L -n -v
```
Flush out existing rules if youre sure:
```bash
sudo iptables -F
sudo iptables -X
sudo iptables -Z
```