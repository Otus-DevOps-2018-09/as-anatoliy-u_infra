#!/usr/bin/python

# Usage:
# gcloud compute instances list \
#   --format=json \
#   | ./gcloud-inventory-parser.py

import sys, json;
inventory = { 'all': { 'hosts': {}, 'children': {} } };

instances = json.load(sys.stdin);
for instance in instances:
  host_name = instance['name'];
  host_ip = instance['networkInterfaces'][0]['accessConfigs'][0]['natIP'];
  tags = instance['tags']['items'];

  host = { 'ansible_host': host_ip };
  inventory['all']['hosts'][host_name] = host;

  for tag in tags:
    if tag != host_name:
      if tag not in inventory['all']['children']:
        inventory['all']['children'][tag] = { 'hosts': {} }

      inventory['all']['children'][tag]['hosts'][host_name] = None;

print json.dumps(inventory, indent=2);
