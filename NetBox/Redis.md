# Redis Installation and Configuration for NetBox

This guide documents the installation and verification of Redis on Ubuntu Server 24.04 for a NetBox deployment.

## 1. Overview

Redis is an in-memory data store used by NetBox for:

- **Caching:** Improves application performance by temporarily storing frequently accessed data.
- **Task processing:** Supports background task queues and job processing.

For this deployment, Redis runs locally on the same Ubuntu server as NetBox and PostgreSQL.

## 2. Prerequisites

- Ubuntu Server 24.04 LTS
- SSH or console access
- A Linux account with `sudo` privileges
- Updated Ubuntu package index

Update the package index:

```bash
sudo apt update
```

## 3. Install Redis

Install Redis using Ubuntu's package manager:

```bash
sudo apt install redis-server -y
```

This installs Redis and configures its system service.

## 4. Verify Redis Installation

Check the installed Redis version:

```bash
redis-server -v
```

Example output:

```text
Redis server v=7.x.x
```

Check Redis connectivity:

```bash
redis-cli ping
```

Expected response:

```text
PONG
```

A `PONG` response confirms that the Redis server is responding to commands.

## 5. Verify the Redis Service

Check the Redis system service:

```bash
sudo systemctl status redis-server
```

Expected status:

```text
Active: active (running)
```

The service should also indicate that Redis is ready to accept connections.

## 6. Verify the Redis Network Binding

Inspect the service status or Redis configuration to confirm that Redis listens on localhost.

Example:

```text
127.0.0.1:6379
```

- `127.0.0.1` is the local loopback address.
- `6379` is Redis's default TCP port.

For a single-server NetBox deployment, keeping Redis bound to localhost prevents unnecessary remote access.

Do not expose Redis port `6379` to untrusted networks or the public internet.

## 7. Installation Results

| Component | Result |
|---|---|
| Operating system | Ubuntu Server 24.04 LTS |
| Redis version | 7.0.15 |
| Redis connectivity | PONG |
| Redis service | Active (running) |
| Network binding | 127.0.0.1:6379 |

All installation and verification checks completed successfully.

## 8. Security Considerations

- Keep Redis accessible only through localhost unless remote access is specifically required.
- Do not expose TCP port `6379` to the public internet.
- Restrict administrative access to approved users.
- Protect Redis configuration files.
- Include Redis and NetBox configuration in the deployment backup and recovery plan.
- Never publish credentials or internal infrastructure details on GitHub.

## 9. Next Steps

Continue the NetBox deployment:

1. Install the required Python dependencies.
2. Download the official NetBox source code.
3. Select a stable NetBox release.
4. Create a dedicated Linux service account.
5. Configure NetBox to connect to PostgreSQL and Redis.

## References

- [Redis Documentation](https://redis.io/docs/latest/)
- [Ubuntu Server Documentation](https://ubuntu.com/server/docs)
- [NetBox Installation Guide](https://netbox.readthedocs.io/en/stable/installation/)
