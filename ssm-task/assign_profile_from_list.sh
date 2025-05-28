#!/bin/bash

# === CONFIGURATION ===
PROFILE_NAME="ec2-ssm-profile"
REGION="us-east-1" 

# === LIST OF INSTANCE IDS ===
INSTANCES=(
  "i-0123456789abcdef0"
  "i-0abcdef1234567890"
  "i-0a1b2c3d4e5f6g7h8"
)

echo "Starting IAM instance profile assignment..."

for INSTANCE_ID in "${INSTANCES[@]}"; do
  echo "Checking $INSTANCE_ID"

  PROFILE_ATTACHED=$(aws ec2 describe-instances \
    --region "$REGION" \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[0].Instances[0].IamInstanceProfile" \
    --output text)

  if [[ "$PROFILE_ATTACHED" == "None" ]]; then
    echo "Attaching $PROFILE_NAME to $INSTANCE_ID..."

    aws ec2 associate-iam-instance-profile \
      --region "$REGION" \
      --instance-id "$INSTANCE_ID" \
      --iam-instance-profile Name="$PROFILE_NAME"

    if [[ $? -eq 0 ]]; then
      echo "Successfully attached to $INSTANCE_ID"
    else
      echo "Failed to attach profile to $INSTANCE_ID"
    fi
  else
    echo "$INSTANCE_ID already has a profile. Skipping."
  fi
done
