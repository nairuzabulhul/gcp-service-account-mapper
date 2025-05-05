#!/bin/bash

# Define color variables
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
BOLD='\e[1m'
RESET='\e[0m'  # Reset color

# Ensure the user is authenticated
gcloud auth list --format="value(account)" >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}You need to authenticate first using 'gcloud auth login'${RESET}"
    exit 1
fi

# Prompt user for a project ID
echo -ne "${YELLOW}Enter the GCP Project ID (leave blank to use the default project): ${RESET}"
read PROJECT_ID

# If the user did not provide a project ID, use the default one
if [ -z "$PROJECT_ID" ]; then
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
fi

# Check if PROJECT_ID is still empty
if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}No project ID provided or set. Use 'gcloud config set project PROJECT_ID' to set one.${RESET}"
    exit 1
fi

echo -e "\n${GREEN}Fetching service accounts for project: ${BOLD}$PROJECT_ID${RESET}..."
echo -e "${BOLD}-----------------------------------------------${RESET}\n"

# Get all service accounts for the specified project
SERVICE_ACCOUNTS=$(gcloud iam service-accounts list --project="$PROJECT_ID" --format="value(email)")

if [ -z "$SERVICE_ACCOUNTS" ]; then
    echo -e "${RED}No service accounts found in project: $PROJECT_ID${RESET}"
    exit 0
fi

# Loop through each service account and list roles and permissions
for SA in $SERVICE_ACCOUNTS; do
    echo -e "${BLUE}Service Account: ${BOLD}$SA${RESET}"

    # Get IAM policies (Roles) and list them separately
    ROLES=$(gcloud projects get-iam-policy "$PROJECT_ID" \
        --flatten="bindings[].members" \
        --format="value(bindings.role)" \
        --filter="bindings.members:$SA")

    if [ -z "$ROLES" ]; then
        echo -e "${RED}Assigned Roles: None${RESET}"
    else
        echo -e "${GREEN}Assigned Roles:${RESET}"
        echo "$ROLES" | awk '{print "- " $0}'  # Print each role on a new line

        # Filter only custom roles (roles that start with "projects/PROJECT_ID/roles/")
        CUSTOM_ROLES=$(echo "$ROLES" | grep "^projects/$PROJECT_ID/roles/")

        if [ -n "$CUSTOM_ROLES" ]; then
            echo -e "\n${YELLOW}Fetching permissions for custom roles...${RESET}"
            
            for FULL_ROLE_PATH in $CUSTOM_ROLES; do
                # Extract just the role name
                ROLE_NAME=$(basename "$FULL_ROLE_PATH")

                echo -e "\n${BOLD}Custom Role: $ROLE_NAME${RESET}"
                PERMISSIONS=$(gcloud iam roles describe "$ROLE_NAME" --project="$PROJECT_ID" --format="value(includedPermissions)")
                
                if [ -z "$PERMISSIONS" ]; then
                    echo -e "${RED}No permissions found for this role.${RESET}"
                else
                    echo -e "${GREEN}Permissions:${RESET}"
                    echo "$PERMISSIONS" | tr ';' '\n' | tr ',' '\n' | awk '{print "- " $0}'  # Print each permission on a new line
                fi
            done
        fi
    fi

    echo -e "${BOLD}-----------------------------------------------${RESET}"
done

echo -e "${GREEN}DONE${RESET}"
