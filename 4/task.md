# Generate a self-signed SSL certificate using openssl and enable HTTPS for one of yourvirtual hosts.

## Step 1:
Enable SSL module:
```bash
sudo a2enmod ssl
```
Enable rewrite module:
```bash
sudo a2enmod rewrite
```
Check if module is enabled:
```bash
sudo apache2ctl -M | grep ssl
```
![step1](images/step1.png)

## Step 2:
Create directories:
```bash
sudo mkdir -p /etc/ssl/private
sudo mkdir -p /etc/ssl/certs
```
Set Permissions:
```bash
sudo chmod 700 /etc/ssl/private
```

## Step 3:
Generate private key and certificate:
```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/site1.local.key \
    -out /etc/ssl/certs/site1.local.crt
```

![step2](images/step2.png)

## Step 4:
Verify Certificate Creation:
```bash
sudo ls -la /etc/ssl/private/site1.local.key
sudo ls -la /etc/ssl/certs/site1.local.crt
```
Set Permissions:
```bash
sudo chmod 600 /etc/ssl/private/site1.local.key
sudo chmod 644 /etc/ssl/certs/site1.local.crt
```
Set Ownership:
```bash
sudo chown root:root /etc/ssl/private/site1.local.key
sudo chown root:root /etc/ssl/certs/site1.local.crt
```
Verify Files:
```bash
sudo openssl x509 -in /etc/ssl/certs/site1.local.crt -text -noout | head -10
sudo openssl rsa -in /etc/ssl/private/site1.local.key -check -noout
```
![step3](images/step3.png)

## Step 4:
Create HTTPS Virtual Host Configuration:
```bash
sudo tee /etc/apache2/sites-available/site1.local-ssl.conf > /dev/null << 'EOF'
<VirtualHost *:443>
    ServerName site1.local
    DocumentRoot /var/www/site1.local
    
    # SSL Configuration
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/site1.local.crt
    SSLCertificateKeyFile /etc/ssl/private/site1.local.key
    
    # Security headers
    Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
    Header always set X-Frame-Options DENY
    Header always set X-Content-Type-Options nosniff
    
    # Logs
    ErrorLog ${APACHE_LOG_DIR}/site1.local_ssl_error.log
    CustomLog ${APACHE_LOG_DIR}/site1.local_ssl_access.log combined
    
    <Directory /var/www/site1.local>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
```
Create HTTP to HTTPS Redirection:
```bash
sudo tee /etc/apache2/sites-available/site1.local.conf > /dev/null << 'EOF'
<VirtualHost *:80>
    ServerName site1.local
    DocumentRoot /var/www/site1.local
    
    # Redirect all HTTP traffic to HTTPS
    Redirect permanent / https://site1.local/
    
    # Logs
    ErrorLog ${APACHE_LOG_DIR}/site1.local_error.log
    CustomLog ${APACHE_LOG_DIR}/site1.local_access.log combined
</VirtualHost>
EOF
```

## Step 5:
Enable Headers module and HTTPS Site:

For security headers:
```bash
sudo a2enmod headers
```
Enable SSL site:
```bash
sudo a2ensite site1.local-ssl.conf
```
To keep HTTP site enabled for redirect:
```bash
sudo a2ensite site1.local.conf
```

## Step 6:
Configure SSL Settings:
```bash
sudo tee /etc/apache2/conf-available/ssl-params.conf > /dev/null << 'EOF'
# Modern SSL configuration
SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH
SSLProtocol All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
SSLHonorCipherOrder On
SSLCompression off
SSLUseStapling on
SSLStaplingResponderTimeout 5
SSLStaplingReturnResponderErrors off
SSLSessionTickets Off
EOF
```
Enable SSL parameters:
```bash
sudo a2enconf ssl-params
```

## Step 7:
Enable ports:
```bash
grep -n "Listen 443" /etc/apache2/ports.conf
```
If not found, add with:
```bash
echo "Listen 443 ssl" | sudo tee -a /etc/apache2/ports.conf
```

## Step 8:
Test Apache configuration:
```bash
sudo apache2ctl configtest
```
If ok, restart:
```bash
sudo systemctl restart apache2
```
Check status:
```bash
sudo systemctl status apache2
```