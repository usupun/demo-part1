# Description For Task 1

## Project Structure

Your Terraform project is organized as follows:

### Terraform Files
1. **`main.tf`**: Main Terraform configuration file.
2. **`variables.tf`**: Defines input variables for the project.
3. **`terraform.tfvars`**: Stores variable values (excluded from version control for security).
4. **`outputs.tf`**: Specifies outputs (if required).
5. **`versions.tf`**: Contains provider and Terraform version constraints.

### Additional Files
- **`README.md`**: Project documentation and instructions.
- **`.gitignore`**: Excludes sensitive or unnecessary files from version control.

---

## Automating with TFActions

TFActions simplifies running Terraform workflows within GitHub Actions. Here’s how you can automate the process:

### Step 1: Setup Repository
Store your Terraform code in a GitHub repository.

### Step 2: Authentication Methods
You can choose between two popular methods for authentication:

#### **1. Using Service Account Keys**

##### Create Secrets:
Add the following secrets to your repository:
- **`GOOGLE_CREDENTIALS`**: JSON key for the GCP service account.
- **`GCP_PROJECT`**: Your GCP project ID.
- **`GCP_REGION`**: The region for resources.

##### Workflow File:
Save the following YAML code as `.github/workflows/terraform.yml`:

```yaml
name: Terraform CI/CD

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  terraform:
    name: Terraform Plan and Apply
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0

      - name: Authenticate to GCP
        uses: google-github-actions/auth@v1
        with:
          credentials_json: ${{ secrets.GOOGLE_CREDENTIALS }}

      - name: Initialize Terraform
        run: terraform init

      - name: Terraform Plan
        run: terraform plan -var="project_id=${{ secrets.GCP_PROJECT }}" -var="region=${{ secrets.GCP_REGION }}"

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve -var="project_id=${{ secrets.GCP_PROJECT }}" -var="region=${{ secrets.GCP_REGION }}"
```

#### **2. Using Workload Identity Federation**

Eliminate the need to manage long-lived service account keys with this approach.

##### Steps to Configure Workload Identity Federation:

1. **Create a Workload Identity Pool:**
```bash
gcloud iam workload-identity-pools create "github-pool" \
  --project="${GCP_PROJECT_ID}" \
  --location="global" \
  --display-name="GitHub Pool"
```

2. **Create a Provider for the Pool:**
```bash
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --project="${GCP_PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub" \
  --issuer-uri="https://token.actions.githubusercontent.com"
```

3. **Grant Permissions to Use the Workload Identity Pool:**
```bash
gcloud iam service-accounts add-iam-policy-binding "${GSA_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
  --project="${GCP_PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${GCP_PROJECT_ID}/locations/global/workloadIdentityPools/github-pool/attribute.repository/${GITHUB_REPOSITORY}"
```

##### Workflow File:
Save the following YAML code as `.github/workflows/terraform.yml`:

```yaml
name: Terraform CI/CD with Workload Identity Federation

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  terraform:
    name: Terraform Plan and Apply
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Authenticate using Workload Identity Federation
        uses: google-github-actions/auth@v1
        with:
          workload_identity_provider: "projects/${{ secrets.GCP_PROJECT_ID }}/locations/global/workloadIdentityPools/github-pool/providers/github-provider"
          service_account: "${{ secrets.GSA_NAME }}@${{ secrets.GCP_PROJECT_ID }}.iam.gserviceaccount.com"

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0

      - name: Initialize Terraform
        run: terraform init

      - name: Terraform Plan
        run: terraform plan -var="project_id=${{ secrets.GCP_PROJECT_ID }}" -var="region=${{ secrets.GCP_REGION }}"

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve -var="project_id=${{ secrets.GCP_PROJECT_ID }}" -var="region=${{ secrets.GCP_REGION }}"
```

---

## Key Points

1. **Secrets Setup:**
   - Define `GCP_PROJECT_ID` and `GSA_NAME` in your repository secrets.

2. **Authentication:**
   - The `google-github-actions/auth` action handles federated authentication without requiring service account keys.

3. **Workload Identity Provider:**
   - Securely integrates GitHub Actions workflows with GCP resources.

By using TFActions and Workload Identity Federation, you enhance security and adhere to best practices for infrastructure automation.
Also well the service account should have allocate the necessary permissions.
