# assessment-design

project/
├── terraform/
│   ├── main.tf                # Main Terraform configuration
│   ├── variables.tf           # Variables definitions
│   ├── terraform.tfvars       # Variable values (git-ignored for security)
│   ├── outputs.tf             # Outputs definitions (if required)
│   ├── versions.tf            # Provider and Terraform version constraints
├── .github/
│   └── workflows/
│       └── tactions.yml       # GitHub Actions workflow for Terraform automation
├── README.md                  # Project documentation and instructions
├── .gitignore                 # Ignore sensitive or unnecessary files



## Prerequisites
- Terraform >= 1.5.0
- GCP Project with necessary IAM roles
- GitHub repository with secrets for Terraform

## Setup and Usage
1. Clone the repository:
   ```bash
   git clone <repository_url>
   cd project/terraform
