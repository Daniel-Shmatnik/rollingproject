# Flask AWS Monitor

A CI/CD pipeline that builds and deploys a Flask web application for monitoring AWS resources (EC2 instances, VPCs, Load Balancers, AMIs). The project uses Jenkins for automation, Docker for containerization, Docker Hub as the image registry, and Terraform for AWS infrastructure provisioning.

## Project Structure

```
├── python/              # Flask application
│   ├── app.py           # Main app — fetches and displays AWS resources
│   └── requirements.txt # Python dependencies (Flask, Boto3)
├── Terraform/           # Infrastructure as code
│   ├── main.tf          # EC2 instance, security group, SSH key
│   ├── variables.tf     # Configurable variables
│   ├── outputs.tf       # Output values (IP, SSH command, etc.)
│   └── provider.tf      # AWS and Terraform provider config
├── Dockerfile           # Container image definition
└── Jenkinsfile          # CI/CD pipeline definition
```

## How It Works

1. **Jenkins** clones the repo, runs linting (Flake8), security scanning (Bandit), builds a Docker image, scans it for vulnerabilities (Trivy), and pushes it to Docker Hub.
2. **Docker** packages the Flask app into a portable container.
3. **Terraform** provisions an EC2 instance on AWS to host the application.
4. **Flask app** connects to AWS via Boto3 and displays EC2 instances, VPCs, Load Balancers, and AMIs in a web dashboard.

## Prerequisites

- Docker
- Jenkins (running in a Docker container with Docker socket access)
- Terraform >= 1.0
- AWS account with configured credentials
- Docker Hub account

## Tester Notice — Variables You May Need to Change

If you are testing this project, some variables are specific to the original developer's environment. Below is every variable that may need to be swapped to match your own setup. 

| Variable                | File              | Default                          | What to Set                                          | Used By        |
|-------------------------|-------------------|----------------------------------|------------------------------------------------------|----------------|
| `dockerhub-username`    | Jenkins Creds     | —                                | Your Docker Hub username (Secret text)               | Jenkins        |
| `dockerhub-password`    | Jenkins Creds     | —                                | Your Docker Hub password or token (Secret text)      | Jenkins        |
| `IMAGE_NAME`            | Jenkinsfile       | `<username>/flask-aws-monitor`   | Auto-set from your Docker Hub username               | Jenkins        |
| Git repo URL            | Jenkinsfile       | `Daniel-Shmatnik/rollingproject` | Change to your fork if applicable                    | Jenkins        |
| `AWS_ACCESS_KEY_ID`     | Environment var   | Auto-fetched from env            | Your AWS access key                                  | Flask App      |
| `AWS_SECRET_ACCESS_KEY` | Environment var   | Auto-fetched from env            | Your AWS secret key                                  | Flask App      |
| `REGION`                | app.py            | `us-east-1`                      | Your preferred AWS region                            | Flask App      |
| `EXPOSE 5001`           | Dockerfile        | Port 5001                        | Change only if you modify the port in app.py         | Docker         |
| `aws_region`            | variables.tf      | `us-east-1`                      | Your AWS region                                      | Terraform only |
| `vpc_id`                | variables.tf      | `vpc-044604d0bfb707142`          | Your VPC ID, or uses developer default if not set    | Terraform only |
| `instance_type`         | variables.tf      | `t3.medium`                      | Change if you need a different size                  | Terraform only |
| `instance_name`         | variables.tf      | `builder`                        | Any name you prefer                                  | Terraform only |
| `subnet_id`             | variables.tf      | Auto-discovers public subnet     | Your subnet ID, or leave empty to auto-detect        | Terraform only |
| `my_ip`                 | variables.tf      | Auto-detected via checkip        | Your IP in CIDR (e.g. `1.2.3.4/32`), or leave empty  | Terraform only |
| `ssh_public_key_path`   | variables.tf      | Auto-generates new key pair      | Path to your public key, or leave empty              | Terraform only |

> **Note:** Variables marked **Terraform only** are not used by the Jenkins pipeline. They only apply if you separately run `terraform apply` to provision AWS infrastructure.

## Quick Start

```bash
# 1. Run the app locally with Docker
docker build -t flask-aws-monitor .
docker run -p 5001:5001 \
  -e AWS_ACCESS_KEY_ID=<your-key> \
  -e AWS_SECRET_ACCESS_KEY=<your-secret> \
  flask-aws-monitor

# 2. Deploy infrastructure with Terraform
cd Terraform
terraform init
terraform apply                              # uses default VPC, or:
terraform apply -var="vpc_id=<your-vpc-id>"  # specify your own

# 3. Access the dashboard
# http://localhost:5001 (local) or http://<ec2-public-ip>:5001 (deployed)
```

## CI/CD Pipeline Stages

1. **Clone Repository** — pulls the latest code from GitHub
2. **Parallel Checks** — runs Flake8 linting and Bandit security scanning simultaneously
3. **Build Docker Image** — builds and tags the container image
4. **Image Security Scan** — scans the Docker image with Trivy for HIGH and CRITICAL CVEs
5. **Push to Docker Hub** — authenticates and pushes the image
6. **Cleanup** — removes local images after the build

## Proof of Success

### Jenkins Pipeline Stages
All automated stages passing successfully:

![Jenkins Stage View](jenkins%20file%20stage%20review.png)

### Docker Hub Verification
The final image available in the Docker Hub registry:

![Docker Hub Image](dockerhub%20image%20confirmation.png)
