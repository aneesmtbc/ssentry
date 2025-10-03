# Quick Start Guide

## One-Command Installation

```bash
./install.sh
```

That's it! The script will install both SonarQube and Sentry on **10.20.1.2** using user **user1**.

## Prerequisites

Before running, make sure:

1. You have SSH access to the target server:
   ```bash
   ssh user1@10.20.1.2
   ```

2. User `user1` has sudo privileges on 10.20.1.2

3. Your SSH key is set up:
   ```bash
   ssh-copy-id user1@10.20.1.2
   ```

## What Gets Installed

| Service | Port | URL | Default Credentials |
|---------|------|-----|---------------------|
| SonarQube | 9000 | http://10.20.1.2:9000 | admin / admin |
| Sentry | 9001 | http://10.20.1.2:9001 | Check logs* |

*To get Sentry credentials:
```bash
ssh user1@10.20.1.2
cd /opt/sentry
docker-compose logs web | grep -i admin
```

## After Installation

1. **Change default passwords immediately!**
2. Access SonarQube at http://10.20.1.2:9000
3. Access Sentry at http://10.20.1.2:9001

## Need Help?

See the full [README.md](README.md) for detailed documentation, troubleshooting, and customization options.
