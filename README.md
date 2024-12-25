# assessment-design
Under the project has the terraform folder. It has the file listed below

# 1.main below.tf          # Main Terraform configuration
# 2.variables.tf           # Variables definitions
# 3.terraform.tfvars       # Variable values (git-ignored for security)
# 4.outputs.tf             # Outputs definitions (if required)
# 5.versions.tf            # Provider and Terraform version constraints

instead of that blow files also included
# README.md                  # Project documentation and instructions
# .gitignore                 # Ignore sensitive or unnecessary files
========================================================================
========================================================================

### 4. Explain how you would automate the process using TFActions.

   Here's the Terraform code to achieve the described setup and an explanation of automating the process using TFActions.

##  Automating with TFActions
      
   TFActions simplifies running Terraform within GitHub Actions. Here’s how you would automate the process:

   Setup Repository: Store the Terraform code in a GitHub repository.
   
   there are two popular methods for authentication
   
# 1st method

   # 1 Create Secrets:
GOOGLE_CREDENTIALS: JSON key for the GCP service account.
GCP_PROJECT: Your GCP project ID.
GCP_REGION: The region for resources.

Create a Workflow File: Add the following YAML file to .github/workflows/terraform.yml
-----------------------------------------------------------------------------------------
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
        run: terraform plan -var=\"project_id=${{ secrets.GCP_PROJECT }}\" -var=\"region=${{ secrets.GCP_REGION }}\"

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve -var=\"project_id=${{ secrets.GCP_PROJECT }}\" -var=\"region=${{ secrets.GCP_REGION }}\"
# -------------------------------------------------------------------------


# 2nd method
Using Google Cloud Workload Identity Federation eliminates the need to manage and store long-lived service account keys. 
Here’s how you can integrate it with the Terraform automation process:

# Steps to Configure Workload Identity Federation with GitHub Actions

1. Create a Workload Identity Pool: Use the gcloud CLI or Terraform to create the workload identity pool:

gcloud iam workload-identity-pools create "github-pool" \
  --project="${GCP_PROJECT_ID}" \
  --location="global" \
  --display-name="GitHub Pool"

2. Create a Provider for the Pool: Link GitHub as the identity provider.

gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --project="${GCP_PROJECT_ID}" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub" \
  --issuer-uri="https://token.actions.githubusercontent.com"

3. Grant Permissions to Use the Workload Identity Pool: Bind the pool to your Google Cloud Service Account (GSA):

gcloud iam service-accounts add-iam-policy-binding "${GSA_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
  --project="${GCP_PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${GCP_PROJECT_ID}/locations/global/workloadIdentityPools/github-pool/attribute.repository/${GITHUB_REPOSITORY}"

4. Based on that create Terraform Workflow File: Modify .github/workflows/terraform.yml to use Workload Identity Federation:

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

# Main Points
1.Secrets Setup:
   Define GCP_PROJECT_ID and GSA_NAME in your repository secrets.
2.Authentication:
   The google-github-actions/auth action handles federated authentication without requiring a service account key.
3.Workload Identity Provider:
   Ensures GitHub Actions workflows can act as the identity and access resources securely.

# This approach enhances security and aligns with best practices by avoiding service account key files.





