#!/bin/bash

# Verification script to check if SonarQube and Sentry are running properly

set -e

TARGET_IP="10.20.1.2"
TARGET_USER="user1"
SONARQUBE_PORT="9000"
SENTRY_PORT="9001"

echo "=========================================="
echo "Service Verification Script"
echo "=========================================="
echo ""

# Check SSH connectivity
echo "1. Checking SSH connectivity..."
if ssh -o ConnectTimeout=5 -o BatchMode=yes ${TARGET_USER}@${TARGET_IP} exit 2>/dev/null; then
    echo "   ✓ SSH connection successful"
else
    echo "   ✗ Cannot connect via SSH"
    exit 1
fi

# Check SonarQube service
echo ""
echo "2. Checking SonarQube service..."
SONAR_STATUS=$(ssh ${TARGET_USER}@${TARGET_IP} "systemctl is-active sonarqube" 2>/dev/null || echo "inactive")
if [ "$SONAR_STATUS" = "active" ]; then
    echo "   ✓ SonarQube service is running"
else
    echo "   ✗ SonarQube service is not running (status: $SONAR_STATUS)"
fi

# Check SonarQube HTTP endpoint
echo ""
echo "3. Checking SonarQube HTTP endpoint..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://${TARGET_IP}:${SONARQUBE_PORT} 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
    echo "   ✓ SonarQube is accessible at http://${TARGET_IP}:${SONARQUBE_PORT}"
    echo "   HTTP Status: $HTTP_CODE"
else
    echo "   ✗ SonarQube is not accessible (HTTP $HTTP_CODE)"
fi

# Check Sentry Docker containers
echo ""
echo "4. Checking Sentry Docker containers..."
SENTRY_CONTAINERS=$(ssh ${TARGET_USER}@${TARGET_IP} "cd /opt/sentry && docker-compose ps --services --filter 'status=running' 2>/dev/null | wc -l" 2>/dev/null || echo "0")
if [ "$SENTRY_CONTAINERS" -gt 0 ]; then
    echo "   ✓ Sentry has $SENTRY_CONTAINERS running containers"
else
    echo "   ✗ No Sentry containers are running"
fi

# Check Sentry HTTP endpoint
echo ""
echo "5. Checking Sentry HTTP endpoint..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://${TARGET_IP}:${SENTRY_PORT} 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
    echo "   ✓ Sentry is accessible at http://${TARGET_IP}:${SENTRY_PORT}"
    echo "   HTTP Status: $HTTP_CODE"
else
    echo "   ✗ Sentry is not accessible (HTTP $HTTP_CODE)"
fi

# Check PostgreSQL
echo ""
echo "6. Checking PostgreSQL..."
PG_STATUS=$(ssh ${TARGET_USER}@${TARGET_IP} "systemctl is-active postgresql" 2>/dev/null || echo "inactive")
if [ "$PG_STATUS" = "active" ]; then
    echo "   ✓ PostgreSQL is running"
else
    echo "   ✗ PostgreSQL is not running (status: $PG_STATUS)"
fi

# Check Redis
echo ""
echo "7. Checking Redis..."
REDIS_STATUS=$(ssh ${TARGET_USER}@${TARGET_IP} "systemctl is-active redis-server" 2>/dev/null || echo "inactive")
if [ "$REDIS_STATUS" = "active" ]; then
    echo "   ✓ Redis is running"
else
    echo "   ✗ Redis is not running (status: $REDIS_STATUS)"
fi

# Summary
echo ""
echo "=========================================="
echo "Verification Complete"
echo "=========================================="
echo ""
echo "Services Status:"
echo "  SonarQube: http://${TARGET_IP}:${SONARQUBE_PORT}"
echo "  Sentry:    http://${TARGET_IP}:${SENTRY_PORT}"
echo ""
echo "To view detailed logs:"
echo "  SonarQube: ssh ${TARGET_USER}@${TARGET_IP} 'sudo tail -f /opt/sonarqube/logs/sonar.log'"
echo "  Sentry:    ssh ${TARGET_USER}@${TARGET_IP} 'cd /opt/sentry && docker-compose logs -f'"
