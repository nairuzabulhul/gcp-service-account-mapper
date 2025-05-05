# GCP Service Account Auditor 🔍

Bash script is to enumerate GCP service accounts and their roles/permissions, especially focusing on custom roles within a specific Google Cloud Project.

## Features

- Lists all service accounts in a given GCP project
- Displays assigned IAM roles for each service account
- Identifies and expands custom roles to show included permissions

## Prerequisites

- [gcloud CLI](https://cloud.google.com/sdk/docs/install) installed and authenticated
- Sufficient permissions to list IAM roles and policies in the target project

## Usage
```bash
# Authenticate with gcloud if not already done
gcloud auth login

# Make the script executable and run it
chmod +x gcp-service-account-mapper.sh 
./gcp-iam-auditor.sh
