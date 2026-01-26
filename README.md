# GCP GCE Terraform Project

This project automates the deployment of a cost-optimized Linux VM on Google Cloud Platform using Terraform. It features service account impersonation, Shared VPC integration, and automated Nginx setup via startup scripts.

## 🏗 Project Architecture

- **Security**: Uses Service Account Impersonation (no local keys).
- **Network**: Deploys into a Shared VPC (Private IP only by default).
- **Cost**: Uses `e2-micro` instances with `SPOT` provisioning.
- **State**: Remote state management via GCS.

---

## 🚀 Quick Start Guide

### 1. Environment Preparation
Configure your local `gcloud` environment to match the target project.

```bash
# 1. Switch to your project profile
gcloud config configurations activate <GCLOUD_PROFILE_NAME>

# 2. Login to Application Default Credentials (ADC)
gcloud auth application-default login
```

### 2. Cloud Setup (One-Time)
Enable mandatory APIs and configure IAM permissions.

#### Enable APIs
```bash
gcloud services enable \
    iamcredentials.googleapis.com \
    serviceusage.googleapis.com \
    cloudresourcemanager.googleapis.com \
    --project <TARGET_PROJECT_ID>
```

#### Grant Impersonation Access
Allow your user identity to "become" the Terraform service account.
```bash
gcloud iam service-accounts add-iam-policy-binding <TF_SERVICE_ACCOUNT_EMAIL> \
    --member="user:$(gcloud config get-value account)" \
    --role="roles/iam.serviceAccountTokenCreator"
```

### 3. Local Configuration
The project uses `.gitignore` to protect sensitive values. Follow these steps to configure your local environment:

1. **Initialize Variables**:
   ```bash
   cp gce/terraform.tfvars.example gce/terraform.tfvars
   # Edit gce/terraform.tfvars with your actual values
   ```
2. **Configure Backend**:
   Create `gce/backend.conf` with your state bucket:
   ```hcl
   bucket = "<STATE_BUCKET_NAME>"
   ```

### 4. Deployment
```bash
cd gce

# Initialize with remote state configuration
terraform init -backend-config=backend.conf

# Review and Apply
terraform plan
terraform apply
```

---

## ✅ Verification & Access

Since the VM is deployed without a public IP, use one of the following methods to verify the installation.

### Method 1: Local Browser (IAP Port Forwarding)
The most convenient way to see the Nginx "Client Demo" page in your local browser.
1. Run the tunnel command:
   ```bash
   gcloud compute ssh <INSTANCE_NAME> \
       --project <TARGET_PROJECT_ID> \
       --zone <ZONE> \
       --tunnel-through-iap \
       -- -L 8080:localhost:80
   ```
2. Open your browser and visit: `http://localhost:8080`

### Method 2: SSH & Local Curl (Direct)
Verify the web server directly from within the VM.
1. SSH into the instance:
   ```bash
   gcloud compute ssh <INSTANCE_NAME> \
       --project <TARGET_PROJECT_ID> \
       --zone <ZONE> \
       --tunnel-through-iap
   ```
2. Run curl:
   ```bash
   curl localhost
   ```

### Method 3: Internal VPC Test
Test connectivity from another VM within the same Shared VPC.
1. Get the private IP: `terraform output private_ip`
2. From another VM in the VPC, run:
   ```bash
   curl <PRIVATE_IP>
   ```

---

## 🛠 Required IAM Roles

### Terraform Service Account
The service account specified in `terraform_service_account` requires:

| Role                             | Scope                 | Purpose                      |
| :------------------------------- | :-------------------- | :--------------------------- |
| `roles/compute.instanceAdmin.v1` | `<TARGET_PROJECT_ID>` | Create/Manage VM instances   |
| `roles/compute.networkUser`      | `<HOST_PROJECT_ID>`   | Access Shared VPC subnets    |
| `roles/storage.objectAdmin`      | `<STATE_BUCKET_NAME>` | Manage Terraform state files |

---

## 📂 Project Structure

```text
.
├── README.md               # This guide
├── .gitignore              # Prevents committing secrets/state
└── gce/                    # Terraform project directory
    ├── providers.tf        # GCP Provider & Impersonation config
    ├── variables.tf        # Variable definitions
    ├── terraform.tfvars    # [LOCAL ONLY] Your secret values
    ├── backend.conf        # [LOCAL ONLY] State bucket config
    ├── vm-instance.tf      # GCE Instance & Startup Script logic
    ├── outputs.tf          # Instance details (Private IP, etc.)
    └── main.tf             # Entry point placeholder
```

---

## 🔍 Troubleshooting

- **403 Permission Denied**: Ensure `iamcredentials.googleapis.com` is enabled and you have the `Token Creator` role.
- **412 Precondition Failed**: Likely an Org Policy blocking External IPs. The current code defaults to Private IP only.
- **IAP Connection**: To SSH into the private VM:
  ```bash
  gcloud compute ssh <INSTANCE_NAME> --tunnel-through-iap
  ```
