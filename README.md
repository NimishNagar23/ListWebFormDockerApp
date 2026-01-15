# Dockerized User Directory on AWS ECS

A full-stack web application deployed on AWS ECS Fargate using Terraform. The application features a FastAPI backend with PostgreSQL and S3 integration, and a static frontend served via Nginx.

## Architecture

- **Frontend**: API-driven HTML/CSS/JS served by Nginx.
- **Backend**: FastAPI (Python) for user management and image uploads.
- **Database**: AWS RDS (PostgreSQL).
- **Storage**: AWS S3 for profile images.
- **Infrastructure**: Provisioned via Terraform (VPC, Security Groups, ECR, ECS Fargate, ALB).

## Prerequisites

- AWS CLI configured with administrator access.
- Terraform (v1.0+)
- Docker
- Git

## Project Structure

```
├── backend/            # FastAPI Application
├── frontend/           # Static Website (HTML/JS/CSS)
├── terraform/          # Infrastructure as Code
│   ├── modules/        # Reusable Terraform Modules (VPC, ECS, etc.)
│   ├── main.tf         # Root Configuration
│   └── outputs.tf      # Infrastructure Outputs (ALB DNS, etc.)
├── docker-compose.yml  # Local development setup
└── README.md
```

## Local Development

1.  **Clone the repository**:
    ```bash
    git clone <repository-url>
    cd DockerProject
    ```

2.  **Create `.env` file**:
    ```env
    AWS_ACCESS_KEY_ID=your_key
    AWS_SECRET_ACCESS_KEY=your_secret
    AWS_REGION=us-east-1
    S3_BUCKET_NAME=your_bucket
    DATABASE_URL=postgresql://user:password@db:5432/userdb
    ```

3.  **Run with Docker Compose**:
    ```bash
    docker-compose up --build
    ```
    Access the app at `http://localhost:80`.

## AWS Deployment

### 1. Provision Infrastructure

Navigate to the terraform directory and apply the configuration:

```bash
cd terraform
terraform init
terraform apply
```

Note the `ecr_backend_url` and `ecr_frontend_url` from the outputs.

### 2. Build and Push Images

Authenticate with ECR:
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.us-east-1.amazonaws.com
```

Build and push the containers:

```bash
# Backend
docker build -t docker-project-backend ./backend
docker tag docker-project-backend:latest <ecr_backend_url>:latest
docker push <ecr_backend_url>:latest

# Frontend
docker build -t docker-project-frontend ./frontend
docker tag docker-project-frontend:latest <ecr_frontend_url>:latest
docker push <ecr_frontend_url>:latest
```

### 3. Finalize Deployment

If this is the first deployment, run `terraform apply` again or update the ECS service to ensure it picks up the new images.

```bash
aws ecs update-service --cluster docker-project-cluster --service docker-project-service --force-new-deployment
```

## Accessing the Application

After deployment, accessing the ALB DNS Name provided in the Terraform outputs:

```
http://docker-project-alb-xxxx.us-east-1.elb.amazonaws.com
```
