
## Prerequisites

These are the prerequisites required to provison another environment.
For each item, I have listed where in each file the entries are detailed.

1. S3 bucket for Terraform backend
* Under infrastructure/<<environment>> is a file called 'backend.tf'
Within this file is the S3 bucket name for the terraform backend 
* Enable versioning for this S3 bucket 

* NOTE: See also 01-prereq folder, if you want to automate

2. DynamoDB table for Terraform backend
* Under infrastructure/<<environment>> is a file called 'backend.tf'
Within this file is the S3 bucket name for the terraform backend

* NOTE: See also 01-prereq folder, if you want to automate

3. S3 bucket, IAM S3 Account and AWS Secret for PLG stack
* Under terraform-modules/rke2-install/templates is a file called 'userdata_server.sh'
within this file is the S3 bucket name and Secrets Manager Secret name
which is used by the plg_stack deploy. The bucket and secret name need to be 
created before the deploy. A new IAM S3 user will need to be created with a policy
that grants read/write access to the PLG S3 bucket. The IAM keys should be added
to the AWS Secret Manager. 

4. IAM userids
* The following IAM userids will need to be requested.  This is based on initial 8 stacks
* customer-srv-account-acorn-<<env>>-sv
* customer-srv-account-aspace-<<env>_sv
* customer-srv-account-curiosity-<<env>_sv
* customer-srv-account-fig-<<env>_sv
* customer-srv-account-fts-<<env>>_sv
* customer-srv-account-hdforms-<<env>>_sv
* customer-srv-account-hgl-<<env>>_sv
* customer-srv-account-jobmonitor-<env>>_sv
* customer-srv-account-lcingest-<<env>_sv

5. EFS mount
Whilst we will be migrating to other Persistent Volumes, we will still require an EFS mount in the env.
This is detailed as "efs_mount" in a file main.tf        

6. Rancher SSL Certificate
Create Two AWS Secrets in AWS Secrets Manager: <<env>-ssl-cert and <<env>>-ssl-key.
AWS Secret type: Other type of secret
Key/value pairs: Plaintext
The <<env>>-ssl-cert is a concatenated Certificate + Intermediate(s)/Root only      

        