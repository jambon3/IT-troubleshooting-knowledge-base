# NetBox 4.7.6 — Installation and Configuration on Ubuntu Server 24.04

## 1. Project Overview

This guide documents the installation and configuration of NetBox 4.7.6 on Ubuntu Server 24.04 LTS running as a virtual machine.

The deployment uses:

- Ubuntu Server 24.04 LTS
- NetBox 4.7.6
- PostgreSQL 16
- Redis 7
- Python 3.12
- Gunicorn 27
- Nginx
- VMware vSphere / ESXi
- Git-based NetBox installation

### Architecture

```text
             Administrator Workstation
                       |
                       | HTTP / HTTPS
                       |
                       v
                 Nginx (Port 80/443)
                       |
                       | Reverse Proxy
                       |
                       v
                Gunicorn (8001)
                       |
                       v
                 NetBox / Django
                       |
              +--------+--------+
              |                 |
              v                 v
          PostgreSQL          Redis
          Database        Cache / Queue
                                |
                                v
                         NetBox RQ Worker
```

### Example server settings

Replace these example values with the appropriate settings for your environment.

| Setting | Example |
|---|---|
| Server hostname | netbox01 |
| Server IP | 192.0.2.50 |
| Linux account | netbox |
| Installation directory | /opt/netbox |
| PostgreSQL database | netbox |
| PostgreSQL user | netbox |
| Gunicorn port | 8001 |
| NetBox version | 4.7.6 |

---

# 2. Prepare Ubuntu Server

## 2.1 Install Ubuntu Server

Install Ubuntu Server 24.04 LTS on a virtual machine.

Recommended initial configuration:

- Configure a hostname.
- Configure a static IP address.
- Configure DNS and the default gateway.
- Install OpenSSH Server.
- Create an initial Linux administrator account.
- Use an appropriately sized virtual disk.

The Linux administrator account is separate from the NetBox application account.

## 2.2 Verify the Ubuntu installation

```bash
lsb_release -a
```

Check the IP configuration:

```bash
ip addr
```

Check available disk space:

```bash
df -h
```

Check hostname:

```bash
hostnamectl
```

## 2.3 Expand the LVM filesystem (if required)

If additional virtual disk capacity has been assigned, verify the available physical volumes and logical volumes.

```bash
lsblk
```

```bash
sudo pvs
sudo vgs
sudo lvs
```

If the virtual disk has already been expanded and the volume group has free space, extend the root logical volume:

```bash
sudo lvextend -l +100%FREE -r /dev/ubuntu-vg/ubuntu-lv
```

Verify:

```bash
df -h
```

**Important:** Confirm the correct logical volume and available space before running the extension command. The example device path may differ on another installation.

## 2.4 Update Ubuntu

```bash
sudo apt update
```

```bash
sudo apt upgrade -y
```

---

# 3. Install PostgreSQL

NetBox uses PostgreSQL as its primary database.

## 3.1 Install PostgreSQL

```bash
sudo apt install postgresql postgresql-contrib -y
```

Verify the service:

```bash
sudo systemctl status postgresql
```

Check the PostgreSQL version:

```bash
psql --version
```

Check the database cluster:

```bash
pg_lsclusters
```

## 3.2 Create the NetBox database and user

Open the PostgreSQL console:

```bash
sudo -u postgres psql
```

Create the database:

```sql
CREATE DATABASE netbox;
```

Create the database user:

```sql
CREATE USER netbox;
```

Set a password interactively:

```sql
\password netbox
```

Assign ownership:

```sql
ALTER DATABASE netbox OWNER TO netbox;
```

Connect to the database:

```sql
\connect netbox
```

Grant schema permissions:

```sql
GRANT CREATE ON SCHEMA public TO netbox;
```

Exit PostgreSQL:

```sql
\q
```

**Security:** Use a unique, strong database password. Never publish the password in GitHub documentation.

## 3.3 Verify PostgreSQL

```bash
sudo -u postgres psql -c "\l"
```

Check that the NetBox database exists.

NetBox 4.7 uses PostgreSQL extensions including `ltree`. The database owner must have sufficient privileges for NetBox to install the required extension.

---

# 4. Install Redis

Redis is used by NetBox for caching and background task queues.

## 4.1 Install Redis

```bash
sudo apt install redis-server -y
```

## 4.2 Verify Redis

```bash
redis-server --version
```

Check the service:

```bash
sudo systemctl status redis-server
```

Test connectivity:

```bash
redis-cli ping
```

Expected response:

```text
PONG
```

For this deployment, Redis runs locally on:

```text
127.0.0.1:6379
```

Keep Redis restricted to localhost unless a specific secured remote configuration is required.

---

# 5. Install NetBox Dependencies

Install Python, development libraries, Git and compilation tools.

```bash
sudo apt install -y \
python3 \
python3-pip \
python3-venv \
python3-dev \
build-essential \
libxml2-dev \
libxslt1-dev \
libffi-dev \
libpq-dev \
libssl-dev \
zlib1g-dev \
git
```

Verify Python:

```bash
python3 --version
```

Verify Git:

```bash
git --version
```

---

# 6. Download NetBox

## 6.1 Create the installation directory

```bash
sudo mkdir -p /opt/netbox
```

## 6.2 Clone the official repository

```bash
sudo git clone https://github.com/netbox-community/netbox.git /opt/netbox
```

## 6.3 Fetch available releases

```bash
cd /opt/netbox
```

```bash
sudo git fetch --tags
```

## 6.4 Check out NetBox 4.7.6

```bash
sudo git checkout v4.7.6
```

Verify the version:

```bash
sudo git describe --tags --exact-match
```

Expected:

```text
v4.7.6
```

---

# 7. Create the NetBox Linux Service Account

NetBox should run under its own dedicated Linux account rather than the administrator account.

Create the account:

```bash
sudo adduser --system --group netbox
```

Verify:

```bash
id netbox
```

Set the main directory permissions:

```bash
sudo chown root:netbox /opt/netbox
sudo chmod 755 /opt/netbox
```

Set ownership of directories used for uploaded media, reports and scripts:

```bash
sudo chown -R netbox:netbox \
/opt/netbox/netbox/media \
/opt/netbox/netbox/reports \
/opt/netbox/netbox/scripts
```

The application source remains protected from unnecessary modifications by the service account.

---

# 8. Create the Python Virtual Environment

A Python virtual environment isolates NetBox's dependencies from Ubuntu's system Python packages.

Create it:

```bash
sudo python3 -m venv /opt/netbox/venv
```

Assign ownership:

```bash
sudo chown -R netbox:netbox /opt/netbox/venv
```

Upgrade pip:

```bash
sudo /opt/netbox/venv/bin/python -m pip install --upgrade pip
```

Verify:

```bash
sudo /opt/netbox/venv/bin/python --version
```

---

# 9. Run the NetBox Installation Script

Navigate to the installation directory:

```bash
cd /opt/netbox
```

Run:

```bash
sudo /opt/netbox/upgrade.sh
```

This script prepares the NetBox Python environment and installs the application dependencies.

Allow the process to finish before continuing.

---

# 10. Configure NetBox

## 10.1 Create the configuration file

Copy the example configuration:

```bash
sudo cp /opt/netbox/netbox/netbox/configuration_example.py \
/opt/netbox/netbox/netbox/configuration.py
```

Open it:

```bash
sudo nano /opt/netbox/netbox/netbox/configuration.py
```

## 10.2 Configure allowed hosts

Find `ALLOWED_HOSTS` and configure the server's IP address and hostname.

Example:

```python
ALLOWED_HOSTS = [
    '192.0.2.50',
    'netbox01'
]
```

Use the actual IP and hostname of your server.

## 10.3 Configure PostgreSQL

Find the `DATABASES` section.

Example:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'netbox',
        'USER': 'netbox',
        'PASSWORD': 'REPLACE_WITH_DATABASE_PASSWORD',
        'HOST': 'localhost',
        'PORT': '',
        'CONN_MAX_AGE': 300,
    }
}
```

Replace the password placeholder with the database password created earlier.

## 10.4 Configure Redis

Configure both the task queue and cache connections.

Example:

```python
REDIS = {
    'tasks': {
        'HOST': 'localhost',
        'PORT': 6379,
        'USERNAME': '',
        'PASSWORD': '',
        'DATABASE': 0,
        'SSL': False,
    },
    'caching': {
        'HOST': 'localhost',
        'PORT': 6379,
        'USERNAME': '',
        'PASSWORD': '',
        'DATABASE': 1,
        'SSL': False,
    }
}
```

Redis uses separate database numbers for task processing and caching.

## 10.5 Configure API token peppers

NetBox requires API token pepper configuration.

Example structure:

```python
API_TOKEN_PEPPERS = {
    1: 'REPLACE_WITH_A_NEW_RANDOM_SECRET'
}
```

Generate a strong random value locally.

Do not use the example text as a real secret.

Protect this value carefully. Changing or losing an existing pepper can affect previously issued API tokens.

## 10.6 Generate the Django SECRET_KEY

NetBox requires a Django secret key.

Use the supplied generator:

```bash
sudo /opt/netbox/venv/bin/python \
/opt/netbox/netbox/generate_secret_key.py
```

Copy the generated value locally and configure it in `configuration.py`:

```python
SECRET_KEY = 'REPLACE_WITH_GENERATED_SECRET'
```

Do not publish this value.

## 10.7 Protect the configuration file

Set ownership:

```bash
sudo chown root:netbox \
/opt/netbox/netbox/netbox/configuration.py
```

Set permissions:

```bash
sudo chmod 640 \
/opt/netbox/netbox/netbox/configuration.py
```

This allows root to manage the file while the NetBox service group can read it.

---

# 11. Validate the NetBox Configuration

Run Django's configuration checks:

```bash
sudo -u netbox /opt/netbox/venv/bin/python \
/opt/netbox/netbox/manage.py check
```

A successful check should report:

```text
System check identified no issues
```

Some optional static-directory warnings may appear if documentation assets have not been installed. Investigate these separately.

---

# 12. Apply Database Migrations

Run:

```bash
sudo -u netbox /opt/netbox/venv/bin/python \
/opt/netbox/netbox/manage.py migrate
```

This creates and updates the database schema required by NetBox.

Wait for all migrations to finish successfully.

---

# 13. Create the NetBox Administrator

Create the first superuser:

```bash
sudo -u netbox /opt/netbox/venv/bin/python \
/opt/netbox/netbox/manage.py createsuperuser
```

Follow the interactive prompts:

```text
Username:
Email address:
Password:
Password (again):
```

Use a strong password.

This creates the NetBox application administrator. It is not the same account as the Ubuntu Linux administrator.

---

# 14. Collect Static Files

NetBox's interface depends on CSS, JavaScript, images and other static assets.

Run:

```bash
sudo -u netbox /opt/netbox/venv/bin/python \
/opt/netbox/netbox/manage.py collectstatic --no-input
```

The expected output reports how many static files were copied.

## 14.1 Static directory permissions

If you receive:

```text
PermissionError: [Errno 13] Permission denied:
'/opt/netbox/netbox/static'
```

Inspect the directory:

```bash
ls -ld /opt/netbox
ls -ld /opt/netbox/netbox
ls -ld /opt/netbox/netbox/static
```

If the static output directory does not exist, create it with appropriate permissions:

```bash
sudo install -d -o netbox -g netbox -m 755 \
/opt/netbox/netbox/static
```

Run collection again:

```bash
sudo -u netbox /opt/netbox/venv/bin/python \
/opt/netbox/netbox/manage.py collectstatic --no-input
```

Verify a static file:

```bash
ls -l /opt/netbox/netbox/static/setmode.js
```

The file should exist and be readable.

---

# 15. Configure Gunicorn

Gunicorn is the WSGI application server that runs the NetBox Django application.

## 15.1 Copy the official Gunicorn configuration

```bash
sudo cp /opt/netbox/contrib/gunicorn.py /opt/netbox/gunicorn.py
```

Verify:

```bash
sudo cat /opt/netbox/gunicorn.py
```

## 15.2 Understand the Gunicorn settings

Example settings:

```python
bind = '127.0.0.1:8001'

workers = 5

threads = 3

timeout = 120

max_requests = 5000

max_requests_jitter = 500
```

Explanation:

| Setting | Purpose |
|---|---|
| bind | IP and port where Gunicorn listens |
| workers | Number of worker processes |
| threads | Threads per worker |
| timeout | Maximum request processing time |
| max_requests | Requests before worker recycling |
| max_requests_jitter | Random variation in recycling |

The example uses localhost because Nginx will communicate with Gunicorn internally.

Do not expose Gunicorn directly to the corporate network.

## 15.3 Disable the optional Gunicorn control socket

In this deployment, Gunicorn 27 attempted to create its control socket under the system account's `/nonexistent` home directory.

The installed Gunicorn supports:

```text
--no-control-socket
```

The option can be supplied through the systemd service command if required.

Verify the installed version's supported options:

```bash
/opt/netbox/venv/bin/gunicorn --help
```

---

# 16. Configure systemd Services

NetBox requires a web service and a background worker.

The official service templates are located in:

```text
/opt/netbox/contrib/
```

## 16.1 Install the NetBox web service

```bash
sudo cp /opt/netbox/contrib/netbox.service \
/etc/systemd/system/netbox.service
```

Inspect:

```bash
sudo cat /etc/systemd/system/netbox.service
```

The official template includes:

```ini
[Unit]
Description=NetBox WSGI Service
Documentation=https://netboxlabs.com/docs/netbox/
After=network-online.target
Wants=network-online.target

[Service]
Type=simple

User=netbox
Group=netbox
PIDFile=/var/tmp/netbox.pid
WorkingDirectory=/opt/netbox

ExecStart=/opt/netbox/venv/bin/gunicorn --pid /var/tmp/netbox.pid --pythonpath /opt/netbox/netbox --config /opt/netbox/gunicorn.py netbox.wsgi

Restart=on-failure
RestartSec=30
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

If your Gunicorn configuration requires disabling its control socket, add the supported `--no-control-socket` option to the `ExecStart` command.

## 16.2 Install the background worker

```bash
sudo cp /opt/netbox/contrib/netbox-rq.service \
/etc/systemd/system/netbox-rq.service
```

Inspect:

```bash
sudo cat /etc/systemd/system/netbox-rq.service
```

The worker executes:

```ini
ExecStart=/opt/netbox/venv/bin/python3 /opt/netbox/netbox/manage.py rqworker high default low
```

The worker processes background tasks from Redis.

## 16.3 Reload systemd

```bash
sudo systemctl daemon-reload
```

## 16.4 Enable and start NetBox

```bash
sudo systemctl enable --now netbox netbox-rq
```

## 16.5 Verify services

```bash
sudo systemctl status netbox netbox-rq --no-pager
```

Both should report:

```text
Active: active (running)
```

Check Gunicorn logs:

```bash
sudo journalctl -u netbox -n 30 --no-pager
```

---

# 17. Configure Nginx

Nginx acts as a reverse proxy between the browser and Gunicorn.

It also serves NetBox's static files.

## 17.1 Install Nginx

```bash
sudo apt install nginx -y
```

Verify:

```bash
sudo systemctl status nginx --no-pager
```

## 17.2 Inspect the official NetBox Nginx template

```bash
sudo cat /opt/netbox/contrib/nginx.conf
```

The official template includes HTTPS settings and certificate paths.

For initial internal testing, configure HTTP first and introduce HTTPS afterward.

## 17.3 Create the NetBox Nginx configuration

```bash
sudo nano /etc/nginx/sites-available/netbox
```

Example:

```nginx
server {
    listen 80;

    server_name 192.0.2.50 netbox01;

    client_max_body_size 25m;

    location /static/ {
        alias /opt/netbox/netbox/static/;
    }

    location / {
        proxy_pass http://127.0.0.1:8001;

        proxy_set_header X-Forwarded-Host $http_host;

        proxy_set_header X-Real-IP $remote_addr;

        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Replace the example IP and hostname with the correct values.

### Explanation

| Directive | Purpose |
|---|---|
| listen 80 | Listen for HTTP connections |
| server_name | Match the requested hostname |
| client_max_body_size | Maximum upload size |
| location /static/ | Serve NetBox static files |
| alias | Static file directory |
| proxy_pass | Forward application requests to Gunicorn |
| X-Real-IP | Pass the client's IP address |
| X-Forwarded-Proto | Pass the original HTTP/HTTPS scheme |

## 17.4 Enable the Nginx site

```bash
sudo ln -s /etc/nginx/sites-available/netbox \
/etc/nginx/sites-enabled/netbox
```

Remove the default site:

```bash
sudo rm /etc/nginx/sites-enabled/default
```

## 17.5 Validate Nginx

```bash
sudo nginx -t
```

Expected:

```text
syntax is ok
test is successful
```

Reload Nginx:

```bash
sudo systemctl reload nginx
```

---

# 18. Test the NetBox Deployment

## 18.1 Test Gunicorn through Nginx

From the Ubuntu server:

```bash
curl -I http://192.0.2.50/
```

A response such as:

```text
HTTP/1.1 302 Found
Location: /login/?next=/
```

is expected when NetBox redirects an unauthenticated user to the login page.

Note: Testing `http://127.0.0.1/` may return HTTP 400 if `127.0.0.1` is not included in `ALLOWED_HOSTS`. Test using the configured server IP or hostname.

## 18.2 Access NetBox from a workstation

Open:

```text
http://192.0.2.50
```

Log in using the NetBox superuser credentials created earlier.

---

# 19. Troubleshooting Static Media

A common warning is:

```text
Static Media Failure

The following static media file failed to load:
setmode.js
```

This indicates that NetBox cannot successfully load one of its interface assets.

## 19.1 Verify the file exists

```bash
ls -l /opt/netbox/netbox/static/setmode.js
```

## 19.2 Verify file collection

```bash
sudo -u netbox /opt/netbox/venv/bin/python \
/opt/netbox/netbox/manage.py collectstatic --no-input
```

## 19.3 Verify Nginx can serve the file

```bash
curl -I http://192.0.2.50/static/setmode.js
```

Expected:

```text
HTTP/1.1 200 OK
Content-Type: application/javascript
```

A successful HTTP 200 confirms that Nginx can serve the file.

## 19.4 Browser troubleshooting

If NetBox still displays a static-media warning despite an HTTP 200 response:

1. Open the NetBox page in Chrome or Edge.
2. Press `F12`.
3. Select the Network tab.
4. Refresh the page.
5. Locate `setmode.js`.
6. Inspect its HTTP status and response.
7. Check the Console tab for JavaScript errors.

Also try:

```text
Ctrl + Shift + R
```

This forces the browser to reload cached assets.

A successful `curl` test does not necessarily prove the browser loaded the file correctly. Check the browser's actual request before changing server configuration.

---

# 20. Remaining Production Configuration

The basic web application is running, but additional configuration is recommended before production use.

## 20.1 HTTPS

Configure TLS certificates and update the Nginx configuration to:

- Listen on port 443.
- Use a valid certificate and private key.
- Redirect HTTP to HTTPS.
- Set the appropriate trusted proxy and secure cookie settings.
- Validate certificate renewal.

Do not expose an administrative application over unencrypted HTTP outside a trusted test environment.

## 20.2 NetBox Housekeeping

Inspect the supplied housekeeping service and timer files:

```bash
ls -l /opt/netbox/contrib/
```

Check the installed release's official housekeeping configuration and enable the supplied timer if applicable.

Housekeeping performs scheduled maintenance tasks.

## 20.3 Firewall

Restrict access to the management network.

Typical access requirements:

| Port | Service | Access |
|---|---|---|
| 22 | SSH | Authorized administrators |
| 80 | HTTP | Internal network / HTTPS redirect |
| 443 | HTTPS | Authorized users |
| 5432 | PostgreSQL | Localhost only |
| 6379 | Redis | Localhost only |
| 8001 | Gunicorn | Localhost only |

## 20.4 Backups

Establish backups for:

- PostgreSQL database
- NetBox configuration
- Uploaded media
- Custom plugins
- Any custom scripts or reports
- TLS certificate material, where appropriate

Test restoration periodically.

## 20.5 Maintenance

For upgrades:

1. Review the official NetBox release notes.
2. Back up the database and configuration.
3. Fetch the desired release.
4. Follow the official upgrade procedure.
5. Run the upgrade script.
6. Collect static files.
7. Restart the required services.
8. Validate the application and background worker.

---

# 21. Deployment Verification Checklist

Use this checklist to validate the installation.

- [x] Ubuntu Server installed
- [x] Static IP configured
- [x] SSH access configured
- [x] LVM filesystem expanded
- [x] PostgreSQL installed
- [x] NetBox database created
- [x] Redis installed
- [x] Python dependencies installed
- [x] NetBox 4.7.6 downloaded
- [x] Dedicated NetBox Linux account created
- [x] Python virtual environment created
- [x] NetBox upgrade script executed
- [x] NetBox configuration created
- [x] Database connection configured
- [x] Redis configured
- [x] Django secret key generated
- [x] API token pepper configured
- [x] Database migrations completed
- [x] NetBox administrator created
- [x] Gunicorn configured
- [x] NetBox systemd service installed
- [x] Background worker service installed
- [x] Gunicorn running
- [x] NetBox background worker running
- [x] Nginx installed
- [x] Nginx reverse proxy configured
- [x] Nginx configuration validated
- [x] Static files collected
- [x] Static JavaScript file served successfully over HTTP
- [ ] Browser static-media warning fully resolved
- [ ] Housekeeping timer verified and enabled
- [ ] HTTPS configured
- [ ] Firewall restrictions reviewed
- [ ] Backup and restore process tested
- [ ] Production readiness validated

---

# 22. Useful Administration Commands

### Check NetBox

```bash
sudo systemctl status netbox
```

### Check background worker

```bash
sudo systemctl status netbox-rq
```

### Check Nginx

```bash
sudo systemctl status nginx
```

### Check PostgreSQL

```bash
sudo systemctl status postgresql
```

### Check Redis

```bash
sudo systemctl status redis-server
```

### Restart NetBox

```bash
sudo systemctl restart netbox
```

### Restart background worker

```bash
sudo systemctl restart netbox-rq
```

### Reload Nginx

```bash
sudo systemctl reload nginx
```

### Inspect NetBox logs

```bash
sudo journalctl -u netbox -n 50 --no-pager
```

### Inspect worker logs

```bash
sudo journalctl -u netbox-rq -n 50 --no-pager
```

### Inspect Nginx logs

```bash
sudo tail -f /var/log/nginx/error.log
```

---

# 23. Official References

- NetBox documentation: https://netboxlabs.com/docs/netbox/
- NetBox installation guide: https://netboxlabs.com/docs/netbox/installation/
- NetBox GitHub repository: https://github.com/netbox-community/netbox
- Ubuntu Server documentation: https://documentation.ubuntu.com/server/
- PostgreSQL documentation: https://www.postgresql.org/docs/
- Redis documentation: https://redis.io/docs/
- Gunicorn documentation: https://docs.gunicorn.org/
- Nginx documentation: https://nginx.org/en/docs/

---

**Project:** NetBox Network Documentation Platform

**Platform:** Ubuntu Server 24.04 LTS

**Application version:** NetBox 4.7.6

**Installation method:** Official Git repository and Python virtual environment

**Deployment status:** Core application and services running; browser static-media validation and production hardening remain.
