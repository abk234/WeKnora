#!/bin/bash
# Simplified startup script for WeKnora
# This script starts all services with proper environment checks

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   WeKnora - Startup Script            ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo -e "${YELLOW}Creating .env from .env.example...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ .env file created${NC}"
    echo -e "${YELLOW}Please review and update .env file if needed${NC}"
    echo ""
fi

# Source environment variables
source .env

# Display configuration
echo -e "${BLUE}Configuration:${NC}"
echo "  • Frontend Port: ${FRONTEND_PORT:-80}"
echo "  • Backend Port: ${APP_PORT:-8080}"
echo "  • DocReader Port: ${DOCREADER_PORT:-50051}"
echo "  • Database: ${DB_DRIVER:-postgres}"
echo "  • Storage: ${STORAGE_TYPE:-local}"
echo "  • Ollama: ${OLLAMA_BASE_URL}"
echo ""

# Ask for confirmation
read -p "Start WeKnora with these settings? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Startup cancelled${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Starting WeKnora services...${NC}"
echo ""

# Use the comprehensive start_all.sh script
./scripts/start_all.sh

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   WeKnora Started Successfully!        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Access your application:${NC}"
echo -e "  • Web UI:     ${GREEN}http://localhost:${FRONTEND_PORT:-80}${NC}"
echo -e "  • API:        ${GREEN}http://localhost:${APP_PORT:-8080}${NC}"
echo -e "  • API Health: ${GREEN}http://localhost:${APP_PORT:-8080}/health${NC}"
echo ""
echo -e "${YELLOW}Tips:${NC}"
echo "  • To stop: ./stop.sh or ./scripts/start_all.sh --stop"
echo "  • To view logs: docker compose logs -f"
echo "  • To check status: docker compose ps"
echo ""
