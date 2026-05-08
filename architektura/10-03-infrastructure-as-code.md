# Infrastructure as Code (IaC)

## Czym jest IaC?

Infrastructure as Code to podejscie, w ktorym infrastruktura (serwery, sieci, bazy danych, load balancery) jest definiowana i zarzadzana za pomoca kodu. Zamiast klikalek w konsoli chmurowej, piszemy deklaratywny kod, ktory opisuje pozadany stan infrastruktury.

## Dlaczego IaC?

| Podejscie reczne | IaC |
|-------------------|-----|
| Klikalki w konsoli | Kod w repozytorium |
| Niepowtarzalne | Powtarzalne (ten sam wynik za kazdym razem) |
| Brak historii zmian | Git — kto, kiedy, dlaczego zmienil |
| Trudne do audytu | Code review dla infrastruktury |
| Konfiguracja na zywo | Plan → Review → Apply |
| Drift (reczne zmiany) | Drift detection |

## Terraform — podstawy

### HCL (HashiCorp Configuration Language)

```hcl
# main.tf — definicja infrastruktury
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "${var.project}-vpc" }
}

# Subnet
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = { Name = "${var.project}-public-${count.index + 1}" }
}
```

### Zmienne

```hcl
# variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "project" {
  description = "Nazwa projektu"
  type        = string
}

variable "environment" {
  description = "Srodowisko (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "instance_type" {
  description = "Typ instancji EC2"
  type        = string
  default     = "t3.micro"
}
```

```hcl
# terraform.tfvars (per srodowisko)
aws_region    = "eu-central-1"
project       = "my-app"
environment   = "prod"
instance_type = "t3.medium"
```

### Outputs

```hcl
# outputs.tf
output "vpc_id" {
  description = "ID VPC"
  value       = aws_vpc.main.id
}

output "load_balancer_dns" {
  description = "DNS load balancera"
  value       = aws_lb.main.dns_name
}

output "database_endpoint" {
  description = "Endpoint bazy danych"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}
```

### Komendy Terraform

```bash
# Inicjalizacja (pobierz providery, skonfiguruj backend)
terraform init

# Sprawdz co sie zmieni (dry run)
terraform plan -out=tfplan

# Zastosuj zmiany
terraform apply tfplan

# Pokaz aktualny stan
terraform show

# Zniszcz infrastrukture
terraform destroy

# Formatowanie kodu
terraform fmt -recursive

# Walidacja
terraform validate
```

## State Management

Terraform przechowuje stan infrastruktury w pliku `terraform.tfstate`. Stan mapuje zasoby w kodzie na rzeczywiste zasoby w chmurze.

### Remote State

```hcl
# Przechowuj stan w S3 (nie lokalnie!)
terraform {
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "services/my-app/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"  # locking
  }
}
```

### State Locking

```
Developer A: terraform apply
  → Lock state (DynamoDB)
  → Zmien infrastrukture
  → Update state
  → Unlock state

Developer B: terraform apply (w tym samym czasie)
  → Proba lock — ZABLOKOWANE
  → Czeka az A zakonczy
```

### Najwazniejsze zasady

1. **Nigdy nie edytuj state recznie** — zawsze przez Terraform
2. **Remote state** — S3/GCS/Azure Blob, nie lokalne pliki
3. **State locking** — DynamoDB/Consul, zapobiega rownoczesnym zmianom
4. **Encrypt state** — zawiera wrazliwe dane (hasla, klucze)
5. **State per srodowisko** — oddzielne pliki state dla dev/staging/prod

## Moduly Terraform

Moduly to reuzywalne bloki infrastruktury — jak funkcje w kodzie.

```hcl
# modules/ecs-service/main.tf
variable "name" { type = string }
variable "image" { type = string }
variable "cpu" { type = number, default = 256 }
variable "memory" { type = number, default = 512 }
variable "port" { type = number, default = 3000 }

resource "aws_ecs_task_definition" "main" {
  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory

  container_definitions = jsonencode([{
    name  = var.name
    image = var.image
    portMappings = [{ containerPort = var.port }]
  }])
}

resource "aws_ecs_service" "main" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
}

output "service_name" { value = aws_ecs_service.main.name }
```

```hcl
# Uzycie modulu
module "order_service" {
  source = "./modules/ecs-service"

  name    = "order-service"
  image   = "ghcr.io/org/order-service:1.2.3"
  cpu     = 512
  memory  = 1024
  port    = 3000
}

module "payment_service" {
  source = "./modules/ecs-service"

  name    = "payment-service"
  image   = "ghcr.io/org/payment-service:2.0.1"
  cpu     = 256
  memory  = 512
  port    = 3000
}
```

## Pulumi — IaC w jezyku programowania

Pulumi pozwala definiowac infrastrukture w TypeScript, Python, Go, C#. Pelna moc jezyka programowania — petle, warunki, funkcje.

```typescript
// index.ts — Pulumi w TypeScript
import * as aws from "@pulumi/aws";
import * as pulumi from "@pulumi/pulumi";

const config = new pulumi.Config();
const environment = config.require("environment");

// VPC
const vpc = new aws.ec2.Vpc("main-vpc", {
  cidrBlock: "10.0.0.0/16",
  enableDnsHostnames: true,
  tags: { Name: `${environment}-vpc` }
});

// Subnets — petla!
const azs = aws.getAvailabilityZones({ state: "available" });
const subnets = azs.then(zones =>
  zones.names.slice(0, 2).map((az, i) =>
    new aws.ec2.Subnet(`public-${i}`, {
      vpcId: vpc.id,
      cidrBlock: `10.0.${i + 1}.0/24`,
      availabilityZone: az,
      mapPublicIpOnLaunch: true
    })
  )
);

// ECS Fargate Service
const service = new aws.ecs.Service("my-app", {
  cluster: cluster.arn,
  taskDefinition: taskDef.arn,
  desiredCount: environment === "prod" ? 3 : 1,
  launchType: "FARGATE"
});

export const vpcId = vpc.id;
export const serviceUrl = lb.dnsName;
```

### Terraform vs Pulumi

| Cecha | Terraform | Pulumi |
|-------|-----------|--------|
| Jezyk | HCL (deklaratywny) | TypeScript, Python, Go, C# |
| State | terraform.tfstate | Pulumi Cloud lub self-managed |
| Krzywa uczenia | Nowa skladnia (HCL) | Znany jezyk programowania |
| Testowanie | terraform test (nowe) | Standardowe frameworki testowe |
| Adopcja | Bardzo wysoka | Rosnie |
| Moduly | Terraform Registry | Pakiety NPM/PyPI/NuGet |
| Plan/Preview | terraform plan | pulumi preview |

## GitOps z ArgoCD

GitOps to podejscie, w ktorym Git jest jedynym zrodlem prawdy dla infrastruktury i konfiguracji. ArgoCD monitoruje repozytorium i automatycznie synchronizuje klaster Kubernetes.

```
Developer → Git Push → Repo (manifesty K8s)
                           ↑
                     ArgoCD monitoruje
                           ↓
                    Kubernetes Cluster
                    (automatyczna synchronizacja)
```

### Konfiguracja ArgoCD

```yaml
# argocd-application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/org/k8s-manifests.git
    targetRevision: main
    path: apps/my-app/overlays/production
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true       # usun zasoby, ktorych nie ma w repo
      selfHeal: true    # napraw reczne zmiany na klastrze
    syncOptions:
      - CreateNamespace=true
```

### Przeplyw GitOps

```
1. Developer zmienia manifest K8s w repo
2. PR → Code Review → Merge do main
3. ArgoCD wykrywa zmiane (polling lub webhook)
4. ArgoCD porownuje stan w repo vs stan na klastrze
5. Jesli roznica — automatyczna synchronizacja
6. ArgoCD raportuje status (healthy/degraded/synced)
```

### Struktura repozytorium GitOps

```
k8s-manifests/
  apps/
    my-app/
      base/
        deployment.yaml
        service.yaml
        kustomization.yaml
      overlays/
        dev/
          kustomization.yaml
          patches/
            replicas.yaml
        staging/
          kustomization.yaml
        production/
          kustomization.yaml
          patches/
            replicas.yaml
            resources.yaml
```

## Dobre praktyki IaC

1. **Kod infrastruktury w repozytorium** — wersjonowanie, code review, historia
2. **Moduly** — reuzywalne bloki, DRY (Don't Repeat Yourself)
3. **Oddzielne state per srodowisko** — dev, staging, prod niezalezne
4. **Plan przed apply** — zawsze sprawdz co sie zmieni
5. **Immutable infrastructure** — nie modyfikuj serwerow, zastap nowymi
6. **Testuj infrastrukture** — terraform validate, terratest, checkov
7. **Drift detection** — wykrywaj reczne zmiany na infrastrukturze
8. **Secrets w secret manager** — nie w kodzie Terraform

## Kluczowe wnioski

1. **IaC = wersjonowanie infrastruktury** — powtarzalnosc, audyt, code review
2. **Terraform** to standard rynkowy — HCL, ogromny ekosystem providerow
3. **Remote state + locking** — obowiazkowe dla pracy zespolowej
4. **Moduly** to reuzywalne bloki — jak funkcje w kodzie
5. **Pulumi** daje pelna moc jezyka programowania — lepsze dla zlozonych scenariuszy
6. **GitOps z ArgoCD** — Git jako jedyne zrodlo prawdy, automatyczna synchronizacja
