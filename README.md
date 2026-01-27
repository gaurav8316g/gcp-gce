# GCP GCE Terraform Project

This project automates the deployment of cost-optimized Linux and Windows VMs on Google Cloud Platform using Terraform. It features service account impersonation, Shared VPC integration, and automated setup.

## 🏗 Project Architecture

- **Security**: Uses Service Account Impersonation (no local keys).
- **Network**: Deploys into a Shared VPC (Private IP only by default).
- **Cost**: Uses `e2-micro` (Linux) and `e2-medium` (Windows) instances with `SPOT` provisioning.
- **State**: Remote state management via GCS.
- **Flexibility**: Toggle VM creation using boolean flags.

---

## 🚀 Quick Start Guide

### 1. Environment Preparation
Configure your local `gcloud` environment.

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

#### Configure Firewall for IAP (Host Project)
Required to allow SSH (22), HTTP (80), and RDP (3389) traffic via IAP.
```bash
gcloud compute firewall-rules create allow-iap-ingress-all \
    --project <HOST_PROJECT_ID> \
    --network <VPC_NAME> \
    --direction INGRESS \
    --action ALLOW \
    --source-ranges 35.235.240.0/20 \
    --rules tcp:22,tcp:80,tcp:3389 \
    --description "Allow IAP ingress for SSH, HTTP, and RDP"
```

### 3. Local Configuration
The project uses `.gitignore` to protect sensitive values.

1. **Initialize Variables**:
   ```bash
   cp gce/terraform.tfvars.example gce/terraform.tfvars
   # Edit gce/terraform.tfvars with your actual values (e.g., set create_windows_vm = true)
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

### Linux VM (Method 1: Local Browser via IAP)
1. Run the tunnel command:
   ```bash
   gcloud compute ssh <LINUX_INSTANCE_NAME> \
       --project <TARGET_PROJECT_ID> \
       --zone <ZONE> \
       --tunnel-through-iap \
       -- -L 8080:localhost:80
   ```
2. Visit: `http://localhost:8080`

### Windows VM (Method 2: RDP via IAP)

#### 1. Generate Windows Password
Windows instances do not have a default password. You must generate one:
```bash
gcloud compute reset-windows-password <WINDOWS_INSTANCE_NAME> \
    --project <TARGET_PROJECT_ID> \
    --zone <ZONE> \
    --user admin
```
*Note: Save the password returned by this command.*

#### 2. Start IAP Tunnel
Run this in your local terminal to bridge RDP traffic:
```bash
gcloud compute start-iap-tunnel <WINDOWS_INSTANCE_NAME> 3389 \
    --project <TARGET_PROJECT_ID> \
    --zone <ZONE> \
    --local-host-port=localhost:3389
```
*Keep this terminal window open during your session.*

#### 3. Connect via RDP Client
- **From macOS**: 
  1. Install **Microsoft Remote Desktop** from the App Store.
  2. Add a new PC with PC name: `localhost:3389`.
  3. Use Username: `admin` and the generated password.
- **From Windows**: 
  1. Use the built-in **Remote Desktop Connection** (mstsc).
  2. Connect to `localhost:3389`.
  3. Alternatively, use [IAP Desktop](https://github.com/GoogleCloudPlatform/iap-desktop) for an automated experience.

---

## 🛠 Required IAM Roles

| Role                               | Scope                 | Purpose                      |
| :--------------------------------- | :-------------------- | :--------------------------- |
| `roles/compute.instanceAdmin.v1`   | `<TARGET_PROJECT_ID>` | Create/Manage VM instances   |
| `roles/compute.networkUser`        | `<HOST_PROJECT_ID>`   | Access Shared VPC subnets    |
| `roles/storage.objectAdmin`        | `<STATE_BUCKET_NAME>` | Manage Terraform state files |
| `roles/iap.tunnelResourceAccessor` | `<TARGET_PROJECT_ID>` | Use IAP TCP forwarding       |

---

## 📂 Project Structure

```text
.
├── README.md               # This guide
├── .gitignore              # Prevents committing secrets/state/lock
└── gce/                    # Terraform project directory
    ├── providers.tf        # GCP Provider & Impersonation config
    ├── variables.tf        # Variable definitions (incl. create_linux/windows_vm)
    ├── terraform.tfvars    # [LOCAL ONLY] Your secret values
    ├── terraform.tfvars.example # Template for variables
    ├── backend.conf        # [LOCAL ONLY] State bucket config
    ├── vm-instance.tf      # Linux Instance & Nginx Startup Script
    ├── windows-vm.tf       # Windows Server Instance
    ├── outputs.tf          # Instance details (Private IPs)
    └── main.tf             # Entry point placeholder
```

---

## 🔍 Troubleshooting

- **403 Permission Denied**: Ensure `iamcredentials.googleapis.com` is enabled and you have the `Token Creator` role on the service account.
- **4003 Failed to Connect**: Ensure the **Host Project** has a firewall rule allowing `35.235.240.0/20` on ports `22, 80, 3389`.
- **IAP Tunnel Performance**: Install `NumPy` locally to increase TCP upload bandwidth for RDP.
