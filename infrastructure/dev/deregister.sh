#!/bin/bash

# Fetch instance IDs using AWS CLI with tag filtering
instance_ids=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=*rke2_dev_*" \
  --query 'Reservations[].Instances[].InstanceId' \
  --output text)

# Loop through the instance IDs and run commands on each instance
for instance_id in $instance_ids; do
    # Unregister with subscription-manager
    aws ssm send-command --document-name "AWS-RunShellScript" \
        --parameters "commands=['subscription-manager unregister']" \
        --instance-ids "$instance_id"

    # Run unlink_nessus.sh script
    aws ssm send-command --document-name "AWS-RunShellScript" \
        --parameters "commands=['/root/unlink_nessus.sh']" \
        --instance-ids "$instance_id"
done

echo " --> Clearing down ALBs"
cd alb
terraform destroy --auto-approve
sleep 5
cd ..

echo " --> Clearing down App DNSes"
cd app-dnses
terraform destroy --auto-approve
sleep 5
cd ..

echo " --> Clearing down Apps "
cd app-dnses
terraform destroy --auto-approve
sleep 5
cd ..

echo " --> Clearing down Infrastructure"
# Destroy infrastructure using Terraform
terraform destroy --auto-approve
