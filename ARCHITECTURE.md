# Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  Control Machine                         │
│                  (Your Computer)                         │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Installation Components:                        │   │
│  │  - install.sh (entry point)                      │   │
│  │  - Ansible playbook                              │   │
│  │  - inventory.yml (target config)                 │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                           │
                           │ SSH (user1)
                           ▼
┌─────────────────────────────────────────────────────────┐
│              Target Server (10.20.1.2)                   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │            SonarQube Stack                       │   │
│  │  ┌────────────────────────────────────────────┐ │   │
│  │  │  SonarQube (Port 9000)                     │ │   │
│  │  │  - Web UI                                  │ │   │
│  │  │  - Code Analysis Engine                    │ │   │
│  │  │  - Elasticsearch (embedded)                │ │   │
│  │  └────────────────────────────────────────────┘ │   │
│  │            │                                     │   │
│  │            ▼                                     │   │
│  │  ┌────────────────────────────────────────────┐ │   │
│  │  │  PostgreSQL Database                       │ │   │
│  │  │  - sonarqube database                      │ │   │
│  │  └────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │            Sentry Stack (Docker)                 │   │
│  │  ┌────────────────────────────────────────────┐ │   │
│  │  │  Sentry Web (Port 9001)                    │ │   │
│  │  │  - Web UI                                  │ │   │
│  │  │  - API Endpoints                           │ │   │
│  │  └────────────────────────────────────────────┘ │   │
│  │            │                                     │   │
│  │            ▼                                     │   │
│  │  ┌────────────────────────────────────────────┐ │   │
│  │  │  Sentry Workers (Docker)                   │ │   │
│  │  │  - Background processing                   │ │   │
│  │  │  - Event processing                        │ │   │
│  │  └────────────────────────────────────────────┘ │   │
│  │            │                                     │   │
│  │            ▼                                     │   │
│  │  ┌────────────────────────────────────────────┐ │   │
│  │  │  PostgreSQL (Docker)                       │ │   │
│  │  │  - Sentry database                         │ │   │
│  │  └────────────────────────────────────────────┘ │   │
│  │            │                                     │   │
│  │            ▼                                     │   │
│  │  ┌────────────────────────────────────────────┐ │   │
│  │  │  Redis (Host)                              │ │   │
│  │  │  - Queue management                        │ │   │
│  │  │  - Caching                                 │ │   │
│  │  └────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## Component Details

### SonarQube (Port 9000)
- **Purpose**: Continuous code quality inspection
- **Installation**: Native systemd service
- **Location**: `/opt/sonarqube`
- **Database**: PostgreSQL (host)
- **Features**:
  - Static code analysis
  - Code smell detection
  - Security vulnerability scanning
  - Code coverage reporting
  - Technical debt management

### Sentry (Port 9001)
- **Purpose**: Application monitoring and error tracking
- **Installation**: Docker containers via docker-compose
- **Location**: `/opt/sentry`
- **Database**: PostgreSQL (containerized)
- **Queue**: Redis (host)
- **Features**:
  - Error tracking
  - Performance monitoring
  - Release tracking
  - Issue management
  - Real-time alerts

## Network Ports

| Service | Port | Protocol | Purpose |
|---------|------|----------|---------|
| SonarQube Web | 9000 | HTTP | Web UI and API |
| Sentry Web | 9001 | HTTP | Web UI and API |
| PostgreSQL | 5432 | TCP | Database (internal) |
| Redis | 6379 | TCP | Queue/Cache (internal) |

## Data Flow

### SonarQube Analysis Flow
```
Developer → SonarQube Scanner → SonarQube Server (9000)
                                        ↓
                                  PostgreSQL DB
                                        ↓
                                  Analysis Results
                                        ↓
                                  Web Dashboard
```

### Sentry Error Tracking Flow
```
Application Error → Sentry SDK → Sentry Web (9001)
                                        ↓
                                    Redis Queue
                                        ↓
                                  Sentry Workers
                                        ↓
                                  PostgreSQL DB
                                        ↓
                                  Issue Dashboard
```

## Installation Process

```
1. install.sh
   ├─> Check prerequisites
   ├─> Install Ansible
   └─> Run ansible-playbook
       
2. Ansible Playbook
   ├─> Update system packages
   ├─> Install dependencies
   │   ├─> Java (for SonarQube)
   │   ├─> PostgreSQL
   │   ├─> Redis
   │   ├─> Docker & Docker Compose
   │   └─> Python packages
   │
   ├─> Install SonarQube
   │   ├─> Create sonarqube user
   │   ├─> Download and extract SonarQube
   │   ├─> Configure PostgreSQL database
   │   ├─> Configure sonar.properties
   │   ├─> Create systemd service
   │   └─> Start service
   │
   └─> Install Sentry
       ├─> Clone sentry/self-hosted
       ├─> Configure environment
       ├─> Run install.sh
       └─> Start docker-compose
```

## File Structure on Target Server

```
/opt/
├── sonarqube/
│   ├── bin/           # Start/stop scripts
│   ├── conf/          # Configuration files
│   ├── data/          # Elasticsearch data
│   ├── extensions/    # Plugins
│   ├── lib/           # Libraries
│   ├── logs/          # Log files
│   └── web/           # Web application
│
└── sentry/
    ├── docker-compose.yml
    ├── .env
    ├── sentry/
    ├── nginx/
    └── volumes/       # Persistent data
```

## Service Management

### SonarQube
- **Service**: `sonarqube.service`
- **User**: `sonarqube`
- **Control**: `systemctl {start|stop|restart|status} sonarqube`

### Sentry
- **Container Manager**: Docker Compose
- **Control**: `docker-compose {up|down|restart|ps|logs}`
- **Working Directory**: `/opt/sentry`

## Resource Requirements

### Minimum Requirements
- **RAM**: 4GB
- **CPU**: 2 cores
- **Disk**: 20GB free space
- **OS**: Ubuntu 20.04+ or compatible

### Recommended Requirements
- **RAM**: 8GB+
- **CPU**: 4+ cores
- **Disk**: 50GB+ SSD
- **OS**: Ubuntu 22.04 LTS

## Security Considerations

1. **Default Passwords**: Change immediately after installation
2. **Firewall**: Only expose necessary ports
3. **SSL/TLS**: Use reverse proxy (nginx) for HTTPS
4. **Database**: Secure PostgreSQL with strong passwords
5. **Updates**: Regularly update both services
6. **Backups**: Implement backup strategy for databases

## Monitoring and Maintenance

### Health Checks
- Run `verify.sh` to check service status
- Monitor logs regularly
- Check disk space and memory usage

### Regular Tasks
- Update SonarQube and Sentry
- Backup databases
- Clean old data
- Monitor resource usage
- Review security advisories

## Scaling Considerations

### Horizontal Scaling
- SonarQube: Add compute engine nodes
- Sentry: Scale worker containers

### Vertical Scaling
- Increase RAM allocation
- Add CPU cores
- Upgrade to SSD storage

## Disaster Recovery

### Backup Strategy
1. PostgreSQL databases (both services)
2. SonarQube configuration files
3. Sentry configuration and volumes
4. Docker images (optional)

### Recovery Process
1. Reinstall base system
2. Run installation script
3. Restore databases
4. Restore configuration files
5. Restart services
