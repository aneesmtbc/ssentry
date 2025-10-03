# Troubleshooting Guide

## Common Issues and Solutions

### 1. SSH Connection Failed

**Problem**: Cannot connect to 10.20.1.2

**Solutions**:
```bash
# Test basic connectivity
ping 10.20.1.2

# Test SSH with verbose output
ssh -v user1@10.20.1.2

# Check if SSH key is added
ssh-add -l

# Copy SSH key to target
ssh-copy-id user1@10.20.1.2
```

### 2. Ansible Not Found

**Problem**: `ansible-playbook: command not found`

**Solution**:
```bash
# Install Ansible
pip3 install -r requirements.txt

# Or install system-wide
sudo apt install ansible  # Ubuntu/Debian
sudo yum install ansible  # CentOS/RHEL
```

### 3. SonarQube Won't Start

**Problem**: SonarQube service fails to start

**Check logs**:
```bash
ssh user1@10.20.1.2
sudo tail -f /opt/sonarqube/logs/sonar.log
sudo tail -f /opt/sonarqube/logs/es.log
```

**Common causes**:

a) **Insufficient memory**:
```bash
# Check available memory
free -h

# SonarQube requires at least 2GB RAM
# Elasticsearch (bundled) needs additional memory
```

b) **Port already in use**:
```bash
# Check if port 9000 is in use
sudo netstat -tlnp | grep 9000

# Stop conflicting service or change SonarQube port
```

c) **Java not found**:
```bash
# Check Java installation
java -version

# Install Java if missing
sudo apt install default-jdk
```

### 4. Sentry Containers Not Starting

**Problem**: Sentry Docker containers fail to start

**Check status**:
```bash
ssh user1@10.20.1.2
cd /opt/sentry
docker-compose ps
docker-compose logs
```

**Common causes**:

a) **Docker not running**:
```bash
# Check Docker status
sudo systemctl status docker

# Start Docker
sudo systemctl start docker
```

b) **Insufficient disk space**:
```bash
# Check disk space
df -h

# Clean Docker resources
docker system prune -a
```

c) **Port conflicts**:
```bash
# Check if port 9001 is in use
sudo netstat -tlnp | grep 9001
```

### 5. PostgreSQL Connection Failed

**Problem**: SonarQube cannot connect to PostgreSQL

**Check PostgreSQL**:
```bash
ssh user1@10.20.1.2
sudo systemctl status postgresql

# Check PostgreSQL logs
sudo tail -f /var/log/postgresql/postgresql-*.log

# Test database connection
sudo -u postgres psql -c "\l"
```

**Verify SonarQube database**:
```bash
sudo -u postgres psql
\c sonarqube
\dt
\q
```

### 6. Redis Connection Issues

**Problem**: Sentry cannot connect to Redis

**Check Redis**:
```bash
ssh user1@10.20.1.2
sudo systemctl status redis-server

# Test Redis connection
redis-cli ping
```

### 7. Web UI Not Accessible

**Problem**: Cannot access http://10.20.1.2:9000 or http://10.20.1.2:9001

**Check firewall**:
```bash
ssh user1@10.20.1.2

# Check UFW status (Ubuntu)
sudo ufw status

# Allow ports if needed
sudo ufw allow 9000/tcp
sudo ufw allow 9001/tcp

# Check iptables
sudo iptables -L -n
```

**Check if services are listening**:
```bash
# Check listening ports
sudo netstat -tlnp | grep -E "9000|9001"

# Or use ss
sudo ss -tlnp | grep -E "9000|9001"
```

### 8. Ansible Playbook Fails

**Problem**: Ansible playbook execution fails

**Run with verbose output**:
```bash
ansible-playbook -i inventory.yml playbook.yml -v
# Or even more verbose
ansible-playbook -i inventory.yml playbook.yml -vvv
```

**Common issues**:

a) **Sudo password required**:
```bash
# Add --ask-become-pass flag
ansible-playbook -i inventory.yml playbook.yml --ask-become-pass
```

b) **Python not found on target**:
```bash
# Specify Python interpreter in inventory.yml
ansible_python_interpreter: /usr/bin/python3
```

### 9. Services Running but Slow

**Problem**: Services are very slow to respond

**Check system resources**:
```bash
ssh user1@10.20.1.2

# Check CPU and memory
top
htop  # if installed

# Check disk I/O
iostat -x 1

# Check if swap is being used
free -h
```

**Solutions**:
- Increase RAM allocation
- Add swap space
- Optimize Java heap settings for SonarQube

### 10. Password/Credential Issues

**Problem**: Cannot login with default credentials

**SonarQube**:
- Default: admin/admin
- If changed and forgotten, reset via database:
```bash
ssh user1@10.20.1.2
sudo -u postgres psql sonarqube
UPDATE users SET crypted_password='$2a$12$uCkkXmhW5ThVK8mpBvnXOOJRLd64LJeHTeCkSuB3lfaR2N0AYBaSi', salt=null WHERE login='admin';
\q
# Password is now: admin
```

**Sentry**:
- Get initial credentials from logs:
```bash
ssh user1@10.20.1.2
cd /opt/sentry
docker-compose logs web | grep -i "admin\|password\|user"
```

## Getting More Help

### View Logs

**SonarQube**:
```bash
ssh user1@10.20.1.2
sudo tail -f /opt/sonarqube/logs/sonar.log
sudo tail -f /opt/sonarqube/logs/web.log
sudo tail -f /opt/sonarqube/logs/ce.log
sudo tail -f /opt/sonarqube/logs/es.log
```

**Sentry**:
```bash
ssh user1@10.20.1.2
cd /opt/sentry
docker-compose logs -f
docker-compose logs -f web
docker-compose logs -f worker
```

### Restart Services

**SonarQube**:
```bash
ssh user1@10.20.1.2
sudo systemctl restart sonarqube
sudo systemctl status sonarqube
```

**Sentry**:
```bash
ssh user1@10.20.1.2
cd /opt/sentry
docker-compose restart
docker-compose ps
```

### Reinstall from Scratch

If all else fails:
```bash
# Uninstall (see README.md Uninstallation section)
# Then run install.sh again
./install.sh
```

## Still Having Issues?

1. Run the verification script: `./verify.sh`
2. Check the official documentation:
   - [SonarQube Docs](https://docs.sonarqube.org/)
   - [Sentry Docs](https://docs.sentry.io/)
3. Check system requirements in README.md
4. Review Ansible playbook logs for specific error messages
