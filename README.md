# otherIAC-rancher
otherIAC RKE Rancher 

This is a IAC repo for the RKE/Rancher install onto an AWS instance

## Table of Contents

- [Prerequisites](#prerequisites)
  [Step-by-Step Deployment Guide](#step-by-step-deployment-guide)

## Prerequisites
Before proceeding with the deployment of the RKE2 cluster, ensure you have the following prerequisites in place:

1. Terraform: An open-source infrastructure as code software tool. It allows users to define and provision data center infrastructure using a declarative configuration language. [Download and install Terraform](https://www.terraform.io/downloads.html) on your local machine.

2. AWS CLI: A unified tool to manage AWS services. It is configured with administrative capabilities provided by AWS IAM.

3. AWS Secrets Manager Access: The passwords for ArgoCD and Rancher are stored here. Your AWS IAM account must have `secretsmanager:GetSecretValue` permissions to access these passwords.

4  S3 Bucket Access: An S3 bucket is required to store RKE2 node tokens used when new nodes join the cluster. The S3 bucket should be in the same region where you will be deploying the AWS resources.

## Step-by-Step Deployment Guide

To provision the infrastructure using this Terraform module, follow these steps:

1. **Initialize Prereqs**
Navigate to 01-prereq and then initialize the prereqs for the Terraform state

2. **Terraform**
Navigate to your environment directory (e.g., `infrastructure/sandbox2`), then initialize your Terraform working directory by running: terraform init
This command initializes a new or existing Terraform working directory by creating initial files, loading any remote state, downloading modules, etc.

3. **Plan Your Infrastructure**
Before applying changes, it's advisable to create an execution plan to reach the desired state of your infrastructure: terraform plan
The `terraform plan` command creates an execution plan. By default, creating a plan requires no extra options.

4. **Apply the Infrastructure Changes**
If the execution plan corresponds to your expectations, you can apply the changes: terraform apply
The `terraform apply` command executes the actions proposed in a Terraform plan.