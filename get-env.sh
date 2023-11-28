#!/bin/bash

# Get secrets from AWS Secrets Manager
(aws secretsmanager get-secret-value --secret-id monitoring --region=us-west-2 | jq '.SecretString' -r | jq '.monitoring' -r | jq '.' -r) > config.json

#echo $SECRETS > services.json
#exit

