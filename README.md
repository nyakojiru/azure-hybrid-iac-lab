# azure-hybrid-iac-lab

Terraform that provisions a small **hybrid-cloud + identity** footprint on Azure —
the way I'd bootstrap a landing zone for a Windows/AD shop moving to the cloud.
Built to pair my 15+ yrs of tier-1 Windows Server / Active Directory / Entra ID
infrastructure with Infrastructure-as-Code, which is where enterprise infra is
heading in 2026 (platform engineering, IaC-first provisioning).

> Status: learning-in-public lab. It's real, `terraform validate`-clean Terraform;
> apply it against your own subscription. Not production-hardened — it's a proof
> that I provision cloud + identity with code, not clicks.

## What it builds

| Component | Why it's here |
|-----------|---------------|
| Resource group + tags | Landing-zone hygiene |
| VNet + subnet | The network an AKS / hybrid workload lands in |
| Log Analytics workspace | Observability wired in from day one |
| AKS cluster (system node pool, managed identity, Azure RBAC) | The cloud-native compute target |
| Entra ID (Azure AD) application + service principal | **Identity-as-code** — the bridge from my AD/Entra background to cloud auth |

The Entra app + AKS Azure-RBAC integration is the deliberate throughline: this
isn't a generic "spin up a cluster" demo — it's identity-first infra, which is my
actual edge.

## Layout

```
.
├── providers.tf      # azurerm + azuread providers, required versions
├── variables.tf      # inputs (location, prefix, node size, tags)
├── main.tf           # RG, VNet, Log Analytics, AKS, Entra app + SP
├── outputs.tf        # cluster name, kubeconfig command, app (client) id
├── terraform.tfvars.example
└── .gitignore
```

## Use

```bash
az login                                   # auth to your subscription
cp terraform.tfvars.example terraform.tfvars   # set prefix/location
terraform init
terraform fmt -check && terraform validate
terraform plan
terraform apply                            # creates real (billable) resources
# ... explore ...
terraform destroy                          # tear it all down
```

## Roadmap (the learning path this repo tracks)

- [x] Resource group + network + AKS via Terraform
- [x] Entra ID app registration as code (identity-first)
- [ ] Remote state in an Azure Storage backend
- [ ] Split into reusable modules (network / identity / aks)
- [ ] GitHub Actions: `fmt` + `validate` + `plan` on PR (GitOps)
- [ ] Deploy a sample workload + wire Entra Workload Identity

Pairs with my AZ-104 (in progress) and HashiCorp Terraform Associate study.
