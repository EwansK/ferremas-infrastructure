#!/bin/bash

# EC2 Setup Script for Ferremas Infrastructure (Amazon Linux)
# Run this script on your EC2 instance

set -e

echo "🚀 Setting up Ferremas infrastructure on Amazon Linux EC2..."

# Update system
sudo yum update -y

# Install Docker
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    sudo yum install -y docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ec2-user
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "📦 Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Install Git (usually pre-installed on Amazon Linux)
if ! command -v git &> /dev/null; then
    echo "📦 Installing Git..."
    sudo yum install -y git
fi

# Create project directory
echo "📁 Setting up project directory..."
cd /home/ec2-user
if [ ! -d "ferremas-infrastructure" ]; then
    git clone https://github.com/EwansK/ferremas-infrastructure.git
    cd ferremas-infrastructure
else
    cd ferremas-infrastructure
    git pull origin main
fi

# Create .env file template
if [ ! -f ".env" ]; then
    echo "📝 Creating .env template..."
    cat > .env << EOL
DOCKER_HUB_USERNAME=your-dockerhub-username
PGHOST=your-rds-endpoint.region.rds.amazonaws.com
PGUSER=your-db-username
PGPASSWORD=your-db-password
PGDATABASE=your-database-name
PGPORT=5432
NEXT_PUBLIC_API_URL=http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):4000
EOL
    echo "⚠️  Please edit .env file with your actual values!"
fi

# Setup systemd service for auto-start
sudo tee /etc/systemd/system/ferremas.service > /dev/null << EOL
[Unit]
Description=Ferremas E-commerce Platform
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ec2-user/ferremas-infrastructure
ExecStart=/usr/local/bin/docker-compose -f docker-compose.prod.yml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose.prod.yml down
User=ec2-user

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable ferremas.service

echo "✅ EC2 setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit /home/ec2-user/ferremas-infrastructure/.env with your database credentials"
echo "2. Run: sudo systemctl start ferremas.service"
echo "3. Check status: sudo systemctl status ferremas.service"
echo "4. View logs: docker-compose -f docker-compose.prod.yml logs -f"