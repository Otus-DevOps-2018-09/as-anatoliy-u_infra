#!/bin/bash

cp /tmp/puma.service /etc/systemd/system/puma.service
systemctl daemon-reload
systemctl enable puma.service
systemctl start puma.service
