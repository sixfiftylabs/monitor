#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DESTINATION_DIR="/home/ubuntu/monitor"
echo $SCRIPT_DIR

IP_ADDRESS=$(aws ec2 describe-instances --filter --region=us-west-2 "Name=instance-id,Values=i-0499cd266c888d353" | jq -r '.Reservations[0].Instances[0].PublicIpAddress')

echo "Deploying to $IP_ADDRESS"
echo "Deploying to $DESTINATION_DIR"
read -r -p "Are you sure you wish to continue? [y/N] " response

case "$response" in
    [yY][eE][sS]|[yY]) 
        echo "Let's go!"
        ;;
    *)
        echo "Exiting"
        exit 1
        ;;
esac

#Kill the running process on the remote host
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/monitoring-west-2.pem ubuntu@$IP_ADDRESS "sudo systemctl stop monitor.service"

#Remove existing files on the remote host
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/monitoring-west-2.pem ubuntu@$IP_ADDRESS "rm -rf $DESTINATION_DIR"

#Create directories on the remote host
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/monitoring-west-2.pem ubuntu@$IP_ADDRESS "mkdir -p $DESTINATION_DIR"

# SCP files to the remote host
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/monitoring-west-2.pem $SCRIPT_DIR/* ubuntu@$IP_ADDRESS:$DESTINATION_DIR/

#Build on the remote host
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/monitoring-west-2.pem ubuntu@$IP_ADDRESS "cd $DESTINATION_DIR && go build"

#Deploy monitor.service
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/monitoring-west-2.pem ubuntu@$IP_ADDRESS "sudo cp $DESTINATION_DIR/monitor.service /etc/systemd/system"

#Restart systemd and enable monitor.service
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/monitoring-west-2.pem ubuntu@$IP_ADDRESS "sudo systemctl daemon-reload && sudo systemctl enable monitor.service"

#Start monitor.service
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/monitoring-west-2.pem ubuntu@$IP_ADDRESS "sudo systemctl start monitor.service"