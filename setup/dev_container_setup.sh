#!/bin/bash

# Define a function to print green text to the terminal.
print_green() {
    printf "\e[32m$1\e[0m\n"
}

# Define a function to print red text to the terminal.
print_red() {
    printf "\e[31m$1\e[0m\n"
}

#installing python libs
print_green "installing python libs ..."
# sudo apt-get install libcairo2-dev
# pip install -r requirements.txt
# pip install azure-eventhub
# pip install flask



# Check if user is already logged into Azure.
az_account=$(az account show 2>/dev/null)

if [ $? -ne 0 ]; then
    # Log in to Azure if not already logged in.
    print_green "Logging into Azure..."
    az login

    # Check for errors after Azure login.
    if [ $? -ne 0 ]; then
        print_red "Error logging into Azure. Exiting..."
        exit 1
    fi
else
    print_green "Already logged into Azure."
fi

# Check if the azure-aks directory exists
if [ -d "./azure-aks" ]; then
    # If it exists, change to that directory and print a success message
    cd ./azure-aks
    print_green "Successfully changed directory to ../azure-aks"
else
    # If it does not exist, print an error message and advise to run from the root directory
    print_red "Error: ../azure-aks directory does not exist. Please ensure the install script is run from the root directory."
    # Exit the script with a non-zero status
    exit 1
fi

# Initialize Terraform in the current directory.
print_green "Initializing Terraform..."
terraform init

# Check for errors after Terraform initialization.
if [ $? -ne 0 ]; then
    print_red "Error initializing Terraform. Exiting..."
    exit 1
fi

# Display the Terraform plan.
print_green "Displaying Terraform plan..."
terraform plan

# Check for errors after Terraform plan.
if [ $? -ne 0 ]; then
    print_red "Error during Terraform plan. Exiting..."
    exit 1
fi

# Apply the Terraform plan.
print_green "Applying Terraform plan..."
terraform apply

# Check for errors after Terraform apply.
if [ $? -ne 0 ]; then
    print_red "Error during Terraform apply. Exiting..."
    exit 1
fi



# print_green "Installing kubectl..."

# # curl -LO "https://dl.k8s.io/release/v1.20.0/bin/linux/amd64/kubectl"
# # chmod +x ./kubectl


print_green "Script finished successfully!"

