# Football Data Hub

> Real-time football data API hosted on Azure — a DevOps portfolio project focused on low-cost infrastructure, security, and observability.

## Overview

This project simulates a real-world cloud infrastructure for a small to medium-sized application serving 300–500 users. The goal is to demonstrate that it is possible to build a secure, observable, and automated infrastructure without relying on expensive managed cloud services.

Built as a career transition portfolio piece from IT Support Engineering to Cloud/DevOps Engineering.

## Architecture

- **3 Ubuntu VMs** on Azure (Spain Central) running Docker Compose
- **Azure Load Balancer Standard** distributing traffic between VM-1 and VM-2
- **Azure Bastion** for secure administrative SSH access (no public IPs on VMs)
- **NAT Gateway** for outbound internet access from private VMs
- **4 subnets** with network segmentation (Bastion, App, Monitoring, Management)
- **NSG** with least-privilege firewall rules

## Stack

| Layer | Technology |
|-------|-----------|
| Cloud | Azure (Spain Central) |
| IaC | Terraform (modular) |
| Language | Python 3.10 + FastAPI |
| Cache | Redis (primary + replica) |
| Containers | Docker + Docker Compose |
| Monitoring | Prometheus + Grafana |
| CI/CD | GitHub Actions |
| Secure Access | Azure Bastion (Standard SKU) |
| Backup | Azure Backup GRS → France Central |

## VM Distribution

| VM | Private IP | Components |
|----|-----------|------------|
| VM-1 | 10.0.1.4 | API FastAPI + Redis primary |
| VM-2 | 10.0.1.5 | API FastAPI + Redis replica |
| VM-3 | 10.0.2.4 | Prometheus + Grafana |

## API Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /health` | Health check for Azure Load Balancer |
| `GET /liga-espanha/tabela` | La Liga standings |
| `GET /liga-espanha/jogos` | La Liga matches |
| `GET /liga-uk/tabela` | Premier League standings |
| `GET /liga-uk/jogos` | Premier League matches |

Data source: [Football-Data.org](https://www.football-data.org) (free tier, 10 req/min rate limit). Redis cache with TTL reduces external API calls.

## Running Locally

For local development and testing without Azure infrastructure.

```bash
# Clone the repository
git clone https://github.com/sivonei/football-data-hub.git
cd football-data-hub

# Start the development environment
./dev.sh
```

The script activates the Python virtual environment, runs tests, and starts the API server.
Access the Swagger documentation at `http://localhost:8000/docs`.

**Environment variables required** (create `api/.env`):

```bash
FOOTBALL_API_KEY=your_key_here
REDIS_HOST=localhost
REDIS_PORT=6379
```

Get a free API key at [football-data.org/client/register](https://www.football-data.org/client/register).

## Running on Azure

For full infrastructure deployment on Azure with Terraform.

**Prerequisites:**
- Azure CLI installed and logged in (`az login`)
- Terraform 1.5+ installed
- SSH key pair available at `~/.ssh/eve`

**1. Provision infrastructure:**

```bash
cd infra
terraform init
terraform apply
```

Terraform will output the Bastion IP and SSH commands for each VM.

**2. Connect to VMs via Azure Bastion:**

```bash
az network bastion ssh \
  --name football-data-hub-bastion \
  --resource-group football-data-hub-rg \
  --target-ip-address 10.0.1.4 \
  --auth-type ssh-key \
  --username azureuser \
  --ssh-key ~/.ssh/eve
```

**3. Deploy the application on each VM:**

```bash
# On VM-1 and VM-2
docker-compose -f docker/vm1-compose.yml up -d

# On VM-3
docker-compose -f docker/vm3-compose.yml up -d
```

**4. Access Grafana via SSH tunnel:**

```bash
ssh -L 3000:10.0.2.4:3000 azureuser@<bastion-ip> -i ~/.ssh/eve
# Then open http://localhost:3000
```

**5. Destroy infrastructure when done:**

```bash
terraform destroy
```

Cost per 2-hour working session is approximately €1-2.


## Security Model

- VMs have **no public IPs** — all administrative access goes through Azure Bastion
- SSH is restricted to the Bastion subnet (`10.0.0.0/26`) via NSG rules
- Grafana (port 3000) is only accessible internally within the VNet
- Outbound internet access via NAT Gateway (outbound only, never inbound)
- Sensitive files excluded from Git: `.env`, `terraform.tfvars`, `terraform.tfstate`

## Cost Philosophy

This project intentionally avoids expensive managed services. Estimated monthly cost when running:

| Resource | Estimated Cost |
|----------|---------------|
| 3x Standard_D2s_v3 VMs | ~$235/month |
| Azure Bastion Standard | ~$140/month |
| NAT Gateway | ~$35/month |
| Azure Backup GRS | ~$14/month |
| Load Balancer Standard | ~$20/month |
| **Total** | **~$444/month** |

In practice, infrastructure is destroyed after each session. Cost per 2-hour working session is approximately €1–2.

## Backup Strategy

- **Service:** Azure Backup with GRS replicating to France Central
- **Schedule:** Every 4 hours between 10:00–22:00
- **Retention:** 7 days
- **RPO:** 4 hours
- **RTO:** 5 hours

## Project Structure
```bash
football-data-hub/
├── api/                    # FastAPI application
│   ├── app/
│   │   ├── main.py
│   │   ├── routes/         # Endpoints by league
│   │   └── services/       # External API + Redis cache
│   ├── tests/
│   ├── Dockerfile
│   └── requirements.txt
├── infra/                  # Terraform
│   ├── main.tf
│   ├── modules/
│   │   ├── network/        # VNet, Subnets, NSG, Bastion, NAT
│   │   └── compute/        # 3 VMs
├── docker/                 # Docker Compose per VM
├── frontend/               # Bootstrap HTML frontend
├── docs/                   # Architecture diagrams
└── .github/workflows/      # CI/CD pipeline

```


## CI/CD

GitHub Actions runs on every push to `main`:
1. Checkout code
2. Setup Python 3.10
3. Install dependencies
4. Run pytest (6 tests)

Deploy pipeline (coming soon): build Docker image → push to ACR → deploy via Bastion SSH.

## Decisions

See [DECISIONS.md](DECISIONS.md) for technical decisions and their rationale.

## License

MIT

