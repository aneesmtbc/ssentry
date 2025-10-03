# SSentry - SonarQube & Sentry Installation Automation

Automated installation and configuration of SonarQube and Sentry using Ansible.

## Overview

This repository provides automation scripts to install and configure:
- **SonarQube** - Continuous code quality inspection platform
- **Sentry** - Application monitoring and error tracking

## Target Configuration

- **Target IP**: 10.20.1.2
- **Target User**: user1
- **SonarQube Port**: 9000
- **Sentry Port**: 9001

## Prerequisites

Before running the installation, ensure you have:

1. **Control Machine** (where you run the scripts):
   - Python 3.6 or higher
   - pip3
   - SSH client

2. **Target Server** (10.20.1.2):
   - Ubuntu 20.04 or higher (or compatible Debian-based system)
   - Minimum 4GB RAM (8GB recommended)
   - Minimum 20GB free disk space
   - User `user1` with sudo privileges
   - SSH access enabled

3. **SSH Key Setup**:
   ```bash
   # Generate SSH key if you don't have one
   ssh-keygen -t rsa -b 4096
   
   # Copy SSH key to target server
   ssh-copy-id user1@10.20.1.2
   ```

## Quick Start

> **TL;DR?** See [QUICKSTART.md](QUICKSTART.md) for a one-page quick reference.

### Option 1: Using the Installation Script (Recommended)

```bash
# Clone the repository
git clone https://github.com/aneesmtbc/ssentry.git
cd ssentry

# Run the installation script
./install.sh
```

The script will:
- Check and install Ansible if needed
- Verify SSH connectivity
- Run the Ansible playbook
- Display access information

### Option 2: Manual Ansible Execution

```bash
# Install dependencies
pip3 install -r requirements.txt

# Run the playbook
ansible-playbook -i inventory.yml playbook.yml
```

## Configuration

### Inventory File (`inventory.yml`)

Configure target server details:
```yaml
all:
  hosts:
    sonar_sentry_server:
      ansible_host: 10.20.1.2
      ansible_user: user1
```

### Playbook Variables (`playbook.yml`)

Customize installation by modifying variables in the playbook:
- `sonarqube_version`: SonarQube version to install
- `sonarqube_port`: Port for SonarQube (default: 9000)
- `sentry_port`: Port for Sentry (default: 9001)
- `postgres_password`: PostgreSQL password (change this!)

## Post-Installation

### Verifying the Installation

Run the verification script to check if all services are running:

```bash
./verify.sh
```

This will check:
- SSH connectivity
- SonarQube service status and HTTP endpoint
- Sentry Docker containers and HTTP endpoint
- PostgreSQL and Redis services

### Accessing the Services

**SonarQube:**
- URL: http://10.20.1.2:9000
- Default credentials: `admin` / `admin`
- **Important**: Change password on first login

**Sentry:**
- URL: http://10.20.1.2:9001
- To get initial admin credentials:
  ```bash
  ssh user1@10.20.1.2
  cd /opt/sentry
  docker-compose logs web | grep -i admin
  ```

### Service Management

**SonarQube:**
```bash
# Check status
sudo systemctl status sonarqube

# Restart
sudo systemctl restart sonarqube

# View logs
sudo tail -f /opt/sonarqube/logs/sonar.log
```

**Sentry:**
```bash
# Check status
cd /opt/sentry
docker-compose ps

# Restart
docker-compose restart

# View logs
docker-compose logs -f
```

## Architecture

> **Want to understand the system design?** See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed architecture diagrams and component information.

The installation sets up:

1. **PostgreSQL** - Database for SonarQube
2. **Redis** - Required for Sentry
3. **SonarQube** - Running as systemd service
4. **Sentry** - Running in Docker containers via docker-compose

## Troubleshooting

> **Having issues?** See the comprehensive [TROUBLESHOOTING.md](TROUBLESHOOTING.md) guide for detailed solutions.

### SSH Connection Issues
```bash
# Test SSH connection
ssh user1@10.20.1.2

# Check SSH key
cat ~/.ssh/id_rsa.pub
```

### SonarQube Not Starting
```bash
# Check logs
sudo tail -f /opt/sonarqube/logs/sonar.log

# Check service status
sudo systemctl status sonarqube

# Check Java version
java -version
```

### Sentry Not Accessible
```bash
# Check Docker containers
ssh user1@10.20.1.2
cd /opt/sentry
docker-compose ps

# Check logs
docker-compose logs web
```

### Port Conflicts
If ports 9000 or 9001 are already in use, modify the ports in `playbook.yml` before running the installation.

## Security Considerations

⚠️ **Important Security Steps:**

1. **Change Default Passwords**: Immediately change all default passwords after installation
2. **Firewall**: Configure firewall to restrict access to ports 9000 and 9001
3. **HTTPS**: Set up reverse proxy (nginx/Apache) with SSL/TLS certificates
4. **Database**: Change PostgreSQL password from default
5. **Updates**: Regularly update SonarQube and Sentry to latest versions

## Customization

To customize the installation:

1. Edit `inventory.yml` to change target server
2. Edit `playbook.yml` to modify:
   - Software versions
   - Port numbers
   - Installation paths
   - Database credentials

## Uninstallation

To remove the installed services:

```bash
# Stop and remove Sentry
ssh user1@10.20.1.2
cd /opt/sentry
docker-compose down -v
sudo rm -rf /opt/sentry

# Stop and remove SonarQube
sudo systemctl stop sonarqube
sudo systemctl disable sonarqube
sudo rm -rf /opt/sonarqube
sudo rm /etc/systemd/system/sonarqube.service
sudo systemctl daemon-reload

# Remove databases (optional)
sudo -u postgres psql -c "DROP DATABASE sonarqube;"
sudo -u postgres psql -c "DROP USER sonarqube;"
```

## Support

For issues or questions:
- Check the troubleshooting section
- Review logs on the target server
- Refer to official documentation:
  - [SonarQube Documentation](https://docs.sonarqube.org/)
  - [Sentry Documentation](https://docs.sentry.io/)

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.