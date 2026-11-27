# PostgreSQL Installation and Database Configuration for NetBox

This guide documents the installation of PostgreSQL on Ubuntu Server 24.04 and the preparation of a dedicated database for NetBox.

> **Security note:** All examples are sanitized. Never publish real passwords, credentials, internal IP addresses, or company infrastructure details.

## 1. Prerequisites

- Ubuntu Server 24.04 LTS
- SSH or console access
- A Linux account with `sudo` privileges
- Sufficient disk space

Update the package index:

```bash
sudo apt update
```

## 2. Install PostgreSQL

Install PostgreSQL and its contributed extensions:

```bash
sudo apt install postgresql postgresql-contrib -y
```

PostgreSQL is installed directly on the Ubuntu server. NetBox will use this database to store network infrastructure information such as devices, IP addresses, VLANs, and prefixes.

## 3. Verify PostgreSQL Installation

Check the PostgreSQL database cluster:

```bash
sudo pg_lsclusters
```

Expected output (example):

```text
Ver  Cluster  Port  Status  Owner
16   main     5432  online  postgres
```

Check the installed version:

```bash
psql --version
```

Check the service:

```bash
sudo systemctl status postgresql
```

**Note:** Ubuntu's PostgreSQL service wrapper may report `active (exited)`. This can be normal. The important verification is that `pg_lsclusters` reports the database cluster as `online`.

## 4. Access the PostgreSQL Console

Ubuntu creates a PostgreSQL administrative account named `postgres`.

Open the PostgreSQL console:

```bash
sudo -u postgres psql
```

The prompt should change to:

```text
postgres=#
```

You are now executing PostgreSQL commands, not Linux shell commands.

## 5. Create the NetBox Database

Create a dedicated database:

```sql
CREATE DATABASE netbox;
```

Create a dedicated PostgreSQL user:

```sql
CREATE USER netbox;
```

Set the password interactively:

```sql
\password netbox
```

PostgreSQL will ask for the new password twice.

Assign ownership of the database:

```sql
ALTER DATABASE netbox OWNER TO netbox;
```

Connect to the database:

```sql
\connect netbox
```

Grant permission to create objects in the public schema:

```sql
GRANT CREATE ON SCHEMA public TO netbox;
```

Exit PostgreSQL:

```sql
\q
```

## 6. Verify the Database and User

Reopen the PostgreSQL console:

```bash
sudo -u postgres psql
```

List the databases:

```sql
\l
```

Inspect the NetBox user:

```sql
\du netbox
```

Exit:

```sql
\q
```

Verify that:

- The `netbox` database exists.
- The `netbox` role exists.
- The `netbox` role owns the database.
- The role has the required schema permissions.

## 7. Security Considerations

For a single-server deployment:

- Keep PostgreSQL accessible only locally unless remote database access is specifically required.
- Do not expose TCP port `5432` to the public internet.
- Use a dedicated application database account.
- Never use the PostgreSQL superuser account for NetBox.
- Store database credentials securely.
- Never commit passwords, secret keys, or private configuration files to GitHub.
- Include PostgreSQL in the server backup and recovery plan.

## 8. Next Steps

After PostgreSQL is configured and verified:

1. Install Redis.
2. Install the NetBox application.
3. Configure the database and Redis connections.
4. Run NetBox database migrations.
5. Configure Gunicorn and systemd.
6. Configure Nginx and HTTPS.
7. Implement access restrictions, monitoring, and backups.

## References

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Ubuntu Server Documentation](https://ubuntu.com/server/docs)
- [NetBox Installation Guide](https://netbox.readthedocs.io/en/stable/installation/)
