#!/bin/bash
# Returns google cloud instances
# as ansible inventory json
gcloud compute instances list \
  --format=json \
  | ./gcloud-inventory-parser.py
