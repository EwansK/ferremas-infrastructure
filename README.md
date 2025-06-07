# Ferremas Infrastructure

Infrastructure and deployment configuration for the Ferremas e-commerce platform.

## Architecture

- **API Gateway**: Routes requests to microservices
- **Product Service**: Manages product data
- **Frontend**: Next.js web application
- **Database**: PostgreSQL (AWS RDS)

## Services

| Service | Repository | Docker Image | Port |
|---------|------------|--------------|------|
| API Gateway | ferremas-api-gateway | ferremas-api-gateway | 4000 |
| Product Service | ferremas-product-service | ferremas-product-service | 4001 |
| Frontend | ferremas-frontend | ferremas-frontend | 3000 |

## Deployment

### AWS EC2 Setup

1. Launch Ubuntu EC2 instance
2. Run setup script:
```bash
curl -sSL https://raw.githubusercontent.com/YOUR_USERNAME/ferremas-infrastructure/main/setup-ec2.sh | bash
```

3. Configure environment variables:
```bash
cd /home/ubuntu/ferremas-infrastructure
sudo nano .env
```

4. Start services:
```bash
sudo systemctl start ferremas.service
```

### Manual Deployment

```bash
docker-compose -f docker-compose.prod.yml up -d
```

## Environment Variables

- `DOCKER_HUB_USERNAME` - Docker Hub username
- `PGHOST` - PostgreSQL host
- `PGUSER` - PostgreSQL username  
- `PGPASSWORD` - PostgreSQL password
- `PGDATABASE` - PostgreSQL database name
- `PGPORT` - PostgreSQL port
- `NEXT_PUBLIC_API_URL` - Frontend API URL

## CI/CD

Each service repository triggers automatic deployment when pushed to main branch:

1. Service builds and pushes Docker image
2. Infrastructure repository receives webhook
3. EC2 instance pulls latest images and redeploys

## Monitoring

- Health checks: `http://your-ec2-ip:4001/health`
- Logs: `docker-compose -f docker-compose.prod.yml logs -f`
- Status: `sudo systemctl status ferremas.service`