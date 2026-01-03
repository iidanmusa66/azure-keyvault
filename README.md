# Azure Key Vault with Dynamic RBAC

## Overview
This project demonstrates secure secrets management using **Infrastructure as Code (IaC)**. It deploys an Azure Key Vault and programmatically generates a random, globally unique name.

Crucially, it uses **dynamic identity retrieval** to automatically assign "God Mode" access policies to the deployer, preventing lockout scenarios during automated builds.

## Architecture
* **Azure Key Vault:** Standard SKU for secrets management.
* **Random Provider:** Generates unique naming conventions (`vault-zebra-xyz`) to satisfy Azure global DNS requirements.
* **Data Sources:** Fetches the current client configuration (Tenant ID/Object ID) dynamically at runtime.

## Technologies
* Terraform
* Azure RBAC & Access Policies
* HCL (HashiCorp Configuration Language)

## How to Deploy
1.  `terraform init`
2.  `terraform apply`
3.  Verify secret `SuperSecretPassword` in the Azure Portal.
