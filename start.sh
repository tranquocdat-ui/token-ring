#!/bin/bash

# ============================================
# Tokenring Docker Deployment Script
# ============================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Tokenring Docker Deployment${NC}"
echo -e "${YELLOW}========================================${NC}"

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    print_error "Docker daemon is not running. Please start Docker service."
    exit 1
fi

# Menu
echo ""
echo "Select deployment option:"
echo "1. Build Docker image"
echo "2. Run all servers (docker-compose)"
echo "3. Run specific server"
echo "4. Stop all containers"
echo "5. View server logs"
echo "6. Clean up (remove containers and images)"
echo ""
read -p "Enter your choice (1-6): " CHOICE

case $CHOICE in
    1)
        print_info "Building Docker image..."
        docker build -t tokenring:latest .
        print_info "Build completed successfully!"
        ;;
    
    2)
        print_info "Starting all servers with docker-compose..."
        docker-compose up -d
        print_info "All servers started successfully!"
        echo ""
        docker-compose ps
        ;;
    
    3)
        read -p "Enter server number (1-5): " SERVER_NUM
        if [[ ! $SERVER_NUM =~ ^[1-5]$ ]]; then
            print_error "Please enter a number between 1 and 5"
            exit 1
        fi
        
        CONTAINER_NAME="tokenring-server$SERVER_NUM"
        print_info "Starting Server $SERVER_NUM..."
        
        # Build image if not exists
        if ! docker image inspect tokenring:latest &> /dev/null; then
            print_info "Image not found. Building..."
            docker build -t tokenring:latest .
        fi
        
        # Run individual server
        docker run -d \
            --name "$CONTAINER_NAME" \
            -e SERVER_NUM=$SERVER_NUM \
            -p "500${SERVER_NUM}:5000" \
            tokenring:latest
        
        print_info "Server $SERVER_NUM started successfully!"
        ;;
    
    4)
        print_info "Stopping all containers..."
        docker-compose down 2>/dev/null || docker stop $(docker ps -q 2>/dev/null) 2>/dev/null || true
        print_info "All containers stopped."
        ;;
    
    5)
        read -p "Enter server number (1-5) or 'all' for all servers: " SERVER_CHOICE
        if [ "$SERVER_CHOICE" = "all" ]; then
            print_info "Showing logs for all servers..."
            docker-compose logs -f
        elif [[ $SERVER_CHOICE =~ ^[1-5]$ ]]; then
            CONTAINER_NAME="tokenring-server$SERVER_CHOICE"
            print_info "Showing logs for $CONTAINER_NAME..."
            docker logs -f "$CONTAINER_NAME"
        else
            print_error "Invalid choice"
            exit 1
        fi
        ;;
    
    6)
        print_warning "This will remove all containers and images related to tokenring..."
        read -p "Are you sure? (yes/no): " CONFIRM
        if [ "$CONFIRM" = "yes" ]; then
            print_info "Cleaning up..."
            docker-compose down -v 2>/dev/null || true
            docker image rm tokenring:latest 2>/dev/null || true
            print_info "Cleanup completed."
        else
            print_info "Cleanup cancelled."
        fi
        ;;
    
    *)
        print_error "Invalid choice. Please enter a number between 1 and 6."
        exit 1
        ;;
esac
