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
# ----------------------------------------------------------------------------------------
