# NetBox Installation and Configuration Guide

## Ubuntu Server 24.04 LTS — NetBox 4.7.6

**Deployment method:** Git source installation  
**Database:** PostgreSQL 16  
**Cache and task queue:** Redis 7  
**Python:** 3.12  
**Web application:** Django / NetBox

---

# 1. Deployment Overview

This guide documents the installation and configuration of NetBox on Ubuntu Server 24.04 LTS.

NetBox is an infrastructure resource modelling and documentation platform used to manage:

- IP address management (IPAM)
- Network devices
- VLANs and prefixes
- Sites and locations
- Racks and equipment
- Virtual machines
- Interfaces and connections
- Circuits and providers
- Infrastructure documentation

## 1.1 Software requirements

| Component | Installed version |
|---|---|
| Ubuntu Server | 24.04.4 LTS |
| NetBox | 4.7.6 |
| Python | 3.12.3 |
| PostgreSQL | 16.15 |
| Redis | 7.0.15 |
| Git | 2.43.0 |

## 1.2 Architecture

```text
                Administrator
                      |
                      |
                 Web Browser
                      |
                      |
               NetBox Web UI
                      |
                      |
             NetBox Django App
                      |
             +--------+--------+
             |                 |
             |                 |
        PostgreSQL           Redis
        Database          Cache / Tasks
```

---

# 2. Prepare Ubuntu Server

Update the package repositories:

```bash
sudo apt update
```

Install the required system packages:

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

Verify the installed versions:

```bash
python3 --version
git --version
```

---

# 3. Configure PostgreSQL

PostgreSQL is NetBox's primary database.

## 3.1 Install PostgreSQL

```bash
sudo apt install postgresql postgresql-contrib -y
```

Verify the installation:

```bash
psql --version
```

Check the PostgreSQL cluster:

```bash
sudo pg_lsclusters
```

Expected status:

```text
Status: online
```

## 3.2 Create the NetBox database

Open the PostgreSQL shell:

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

Set the password interactively:

```sql
\password netbox
```

Assign database ownership:

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

Exit:

```sql
\q
```

**Security:** Store the PostgreSQL password securely. Never commit it to GitHub.

---

# 4. Configure Redis

Redis provides caching and background task queue functionality.

## 4.1 Install Redis

```bash
sudo apt install redis-server -y
```

Verify the version:

```bash
redis-server -v
```

Test Redis:

```bash
redis-cli ping
```

Expected response:

```text
PONG
```

Check the service:

```bash
sudo systemctl status redis-server
```

The service should be active.

For this deployment, Redis is accessed locally on:

```text
127.0.0.1:6379
```

Redis is not configured with authentication in this installation. Keep it restricted to localhost unless you deliberately implement a secured remote configuration.

---

# 5. Download NetBox

## 5.1 Create the installation directory

```bash
sudo mkdir -p /opt/netbox
```

## 5.2 Clone the official repository

```bash
sudo git clone https://github.com/netbox-community/netbox.git /opt/netbox
```

## 5.3 Select the NetBox release

```bash
cd /opt/netbox
```

Fetch available tags:

```bash
sudo git fetch --tags
```

Select the release:

```bash
sudo git checkout v4.7.6
```

Verify the selected version:

```bash
sudo git describe --tags --exact-match
```

Expected:

```text
v4.7.6
```

---

# 6. Create the NetBox Service Account

NetBox should run under a dedicated Linux service account rather than the administrator's personal account.

Create the account:

```bash
sudo adduser --system --group netbox
```

Verify:

```bash
id netbox
```

## 6.1 Configure installation permissions

Set the installation directory ownership:

```bash
sudo chown root:netbox /opt/netbox
sudo chmod 755 /opt/netbox
```

Assign ownership of NetBox's writable directories:

```bash
sudo chown -R netbox:netbox \
/opt/netbox/netbox/media \
/opt/netbox/netbox/reports \
/opt/netbox/netbox/scripts
```

---

# 7. Create the Python Virtual Environment

A Python virtual environment isolates NetBox dependencies from Ubuntu's system Python packages.

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

Verify Python:

```bash
/opt/netbox/venv/bin/python --version
```

---

# 8. Install NetBox Dependencies

Run the official installation/upgrade script:

```bash
cd /opt/netbox
sudo /opt/netbox/upgrade.sh
```

This prepares the NetBox Python environment and installs the required application dependencies.

Wait for the script to complete before continuing.

---

# 9. Create the NetBox Configuration File

Copy the example configuration:

```bash
sudo cp \
/opt/netbox/netbox/netbox/configuration_example.py \
/opt/netbox/netbox/netbox/configuration.py
```

Verify:

```bash
ls -l /opt/netbox/netbox/netbox/configuration.py
```

The main configuration file is:

```text
/opt/netbox/netbox/netbox/configuration.py
```

---

# 10. Configure NetBox

Edit the configuration:

```bash
sudo nano /opt/netbox/netbox/netbox/configuration.py
```

## 10.1 Allowed hosts

Configure the IP address and hostname used to access NetBox.

Example:

```python
ALLOWED_HOSTS = [
    '192.0.2.50',
    'netbox.example.internal',
]
```

Replace these example values with the actual server IP and DNS hostname.

## 10.2 API token peppers

API token peppers are cryptographic secrets used to protect NetBox API tokens.

Generate a random secret locally:

```bash
sudo -u netbox /opt/netbox/venv/bin/python \
/opt/netbox/netbox/generate_secret_key.py
```

Configure:

```python
API_TOKEN_PEPPERS = {
    1: r'REPLACE_WITH_GENERATED_SECRET',
}
```

The dictionary key `1` identifies the pepper version.

Do not expose the generated value or commit it to GitHub.

## 10.3 PostgreSQL configuration

Configure the database connection:

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

The database name and username are both `netbox`.

The password must match the PostgreSQL password configured earlier.

## 10.4 Redis configuration

NetBox uses two logical Redis databases.

### Task queue

```python
REDIS = {
    'tasks': {
        'HOST': 'localhost',
        'PORT': 6379,
        'USERNAME': '',
        'PASSWORD': '',
        'DATABASE': 0,
    },
```

### Caching

```python
    'caching': {
        'HOST': 'localhost',
        'PORT': 6379,
        'USERNAME': '',
        'PASSWORD': '',
        'DATABASE': 1,
        'SSL': False,
    },
}
```

Redis database 0 is used for tasks.

Redis database 1 is used for caching.

Both connections use the local Redis service.

## 10.5 Django SECRET_KEY

Generate a random key:

```bash
sudo -u netbox /opt/netbox/venv/bin/python \
/opt/netbox/netbox/generate_secret_key.py
```

Configure:

```python
SECRET_KEY = 'REPLACE_WITH_GENERATED_SECRET'
```

Keep this secret private. Do not reuse it as a database password or API token pepper.

---

# 11. Secure the Configuration File

After editing and saving:

```bash
sudo chown root:netbox \
/opt/netbox/netbox/netbox/configuration.py
```

Set permissions:

```bash
sudo chmod 640 \
/opt/netbox/netbox/netbox/configuration.py
```

This allows the NetBox service group to read the configuration without granting access to other users.

---

# 12. Validate the Configuration

Run:

```bash
sudo -u netbox /opt/netbox/venv/bin/python \
/opt/netbox/netbox/manage.py check
```

The installation produced this warning:

```text
(staticfiles.W004) The directory
'/opt/netbox/netbox/project-static/docs'
does not exist.
```

The configuration check completed with one static-files warning and no fatal configuration error.

Investigate the warning during the static asset and documentation review.

---

# 13. Run Database Migrations

Create the database tables and apply the required migrations:

```bash
sudo -u netbox /opt/netbox/venv/bin/python \
/opt/netbox/netbox/manage.py migrate
```

The migrations completed successfully.

---

# 14. Create the NetBox Administrator

Create the first NetBox administrator account:

```bash
sudo -u netbox /opt/netbox/venv/bin/python \
/opt/netbox/netbox/manage.py createsuperuser
```

Provide:

- Username
- Email address
- Strong password
- Password confirmation

This creates an application-level administrator account.

It is separate from Ubuntu, Active Directory and Microsoft Entra ID accounts.

---

# 15. Collect Static Files

NetBox needs its CSS, JavaScript, images and other static assets collected for the web interface.

Run:

```bash
sudo -u netbox /opt/netbox/venv/bin/python \
/opt/netbox/netbox/manage.py collectstatic --no-input
```

Verify that the command completes successfully.

---

# 16. Remaining Configuration and Deployment

The installation and initial application configuration are complete. The following tasks are still required before NetBox is available as a properly deployed web application.

## 16.1 Configure Gunicorn

Gunicorn is the WSGI application server that runs the NetBox Django application.

Remaining tasks:

- Configure the Gunicorn service.
- Configure the appropriate Unix socket.
- Set service ownership and permissions.
- Enable the service at boot.
- Verify that Gunicorn starts successfully.

## 16.2 Configure NetBox background workers

NetBox requires background workers to process queued jobs.

Remaining tasks:

- Configure the NetBox RQ worker service.
- Configure the NetBox housekeeping service.
- Enable both services.
- Verify their status.

## 16.3 Configure Nginx

Nginx will act as the reverse proxy in front of Gunicorn.

Remaining tasks:

- Install Nginx.
- Configure the NetBox virtual host.
- Configure the upstream Gunicorn socket.
- Configure static and media file handling.
- Test the Nginx configuration.
- Enable the Nginx service.

## 16.4 Configure HTTPS

Before production use:

- Obtain an appropriate TLS certificate.
- Configure HTTPS in Nginx.
- Redirect HTTP to HTTPS.
- Verify certificate validity.
- Restrict access to the NetBox interface.

## 16.5 Configure DNS

Create an internal DNS record for the NetBox server.

Example:

```text
netbox.example.internal
```

Make sure the record resolves to the correct server IP.

## 16.6 Configure firewall rules

Restrict network access to the required services.

Recommended approach:

| Port | Purpose | Access |
|---|---|---|
| 22 | SSH | Administrative network |
| 80 | HTTP | Redirect to HTTPS |
| 443 | HTTPS | Authorized users |
| 5432 | PostgreSQL | Localhost only |
| 6379 | Redis | Localhost only |

Do not expose PostgreSQL or Redis directly to the corporate network.

## 16.7 Configure backups

A NetBox backup strategy should include:

- PostgreSQL database backups.
- NetBox media files.
- NetBox configuration file.
- Any required custom plugins and related files.
- Documented restoration procedures.

Store backups separately from the NetBox VM and periodically test restoration.

## 16.8 Configure monitoring and maintenance

Recommended operational tasks:

- Monitor CPU, memory and disk usage.
- Monitor PostgreSQL and Redis.
- Monitor Gunicorn and Nginx.
- Review NetBox application logs.
- Monitor backup success.
- Establish a NetBox upgrade procedure.
- Document configuration changes.

---

# 17. Final Deployment Checklist

### Completed

- [x] Ubuntu Server installed.
- [x] System packages installed.
- [x] PostgreSQL installed.
- [x] PostgreSQL database created.
- [x] PostgreSQL user created.
- [x] Redis installed.
- [x] Redis connectivity verified.
- [x] NetBox Git repository cloned.
- [x] NetBox release selected.
- [x] NetBox service account created.
- [x] Directory permissions configured.
- [x] Python virtual environment created.
- [x] NetBox dependencies installed.
- [x] NetBox configuration file created.
- [x] Allowed hosts configured.
- [x] API token pepper configured.
- [x] PostgreSQL connection configured.
- [x] Redis connections configured.
- [x] Django SECRET_KEY configured.
- [x] Configuration file permissions restricted.
- [x] Django configuration check completed.
- [x] Database migrations completed.
- [x] NetBox administrator created.
- [x] Static file collection command issued.

### Remaining

- [ ] Verify static file collection output.
- [ ] Configure Gunicorn.
- [ ] Configure NetBox RQ workers.
- [ ] Configure housekeeping.
- [ ] Configure Nginx.
- [ ] Configure internal DNS.
- [ ] Configure HTTPS.
- [ ] Configure firewall restrictions.
- [ ] Verify browser access.
- [ ] Test NetBox administrator login.
- [ ] Configure backups and restoration.
- [ ] Configure monitoring.
- [ ] Document operational maintenance.

---

# 18. Useful Commands

Check PostgreSQL:

```bash
sudo systemctl status postgresql
```

Check Redis:

```bash
sudo systemctl status redis-server
```

Test Redis:

```bash
redis-cli ping
```

Check NetBox application configuration:

```bash
sudo -u netbox /opt/netbox/venv/bin/python \
/opt/netbox/netbox/manage.py check
```

Check database migrations:

```bash
sudo -u netbox /opt/netbox/venv/bin/python \
/opt/netbox/netbox/manage.py showmigrations
```

Check NetBox version:

```bash
cd /opt/netbox
git describe --tags --exact-match
```

---

# 19. Official Documentation

- NetBox documentation: https://netbox.readthedocs.io/
- NetBox GitHub repository: https://github.com/netbox-community/netbox
- NetBox installation guide: https://netbox.readthedocs.io/en/stable/installation/
- PostgreSQL documentation: https://www.postgresql.org/docs/
- Redis documentation: https://redis.io/docs/
- Ubuntu Server documentation: https://documentation.ubuntu.com/server/

---

**Project status:** NetBox application installed and initially configured. Remaining work is focused on application services, reverse proxy, HTTPS, network access, backups and operational readiness.

**Security reminder:** Never commit `configuration.py`, generated secrets, database passwords, or administrator credentials to a public GitHub repository.
