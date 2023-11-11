#!/bin/bash

# Define functions for colored output.
print_green() {
    printf "\e[32m$1\e[0m\n"
}

print_red() {
    printf "\e[31m$1\e[0m\n"
}

# Check if user is already logged into Azure.
az_account=$(az account show --output json 2>/dev/null)

if [ $? -ne 0 ]; then
    # Log in to Azure if not already logged in.
    print_green "Logging into Azure..."
    az login --output json

    # Check for errors after Azure login.
    if [ $? -ne 0 ]; then
        print_red "Error logging into Azure. Exiting..."
        exit 1
    fi
else
    print_green "Already logged into Azure."
fi

# Retrieve the subscription ID
subscription_id=$(echo $az_account | jq -r '.id')
if [ -z "$subscription_id" ]; then
    print_red "Unable to find subscription ID. Exiting..."
    exit 1
fi

print_green "Using subscription ID: $subscription_id"

# Change directory to where the role_binding.tf file is stored.
cd ../azure-aks/role_binding || { print_red "Directory not found. Exiting..."; exit 1; }

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_red "Terraform could not be found. Please install it to proceed."
    exit 1
fi

# Import resource group into Terraform state
resource_group_name="coder-resources"  # replace with your actual resource group name if different
terraform import azurerm_resource_group.coder /subscriptions/$subscription_id/resourceGroups/$resource_group_name

# Initialize Terraform
print_green "Initializing Terraform..."
terraform init

# Check for errors after Terraform initialization.
if [ $? -ne 0 ]; then
    print_red "Error initializing Terraform. Exiting..."
    exit 1
fi

# Apply the Terraform configuration for role_binding.tf
print_green "Applying the role binding configuration..."
terraform apply -auto-approve

# Check for errors after Terraform apply.
if [ $? -ne 0 ]; then
    print_red "Error during Terraform apply. Exiting..."
    exit 1
fi

print_green "Role binding configuration applied successfully!"
