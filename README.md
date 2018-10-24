# as-anatoliy-u_infra
as-anatoliy-u Infra repository

5.1. Connect to someinternalhost using ssh "jump host":
ssh -J appuser@bastion app@<someinternalhost-internal-ip-addr>

5.2. Connect to someinternalhost using just "ssh someinternalhost" command:
Edit ~/.ssh/config
### Bastion host. Directly reachable
Host bastion
  HostName <bastion public name or IP address>
  User appuser

### Internal host without public address,
### accessed through bastion with ProxyJump
Host someinternalhost
  HostName <VM internal address, reachable from bastion>
  User appuser
  ProxyJump bastion

5.3. Setup pritunl on Ubuntu 18.04 LTS
see https://github.com/pritunl/pritunl#ubuntu-bionic
bastion_IP = 35.210.252.191
someinternalhost_IP = 10.132.0.3

5.4. Install HTTPS certificate for Pritunl
Just set "Lets Encrypt Domain" in "Settings" to <bastion_ip_addr>.sslip.io

-----

6.1. Reddit App test
testapp_IP = 35.204.134.233
testapp_port = 9292

6.2. Reddit App - startup script
```bash
### startup-script.sh

#!/bin/bash
APPUSER=appuser
COMPLETED=/tmp/setup-completed

if [ -f $COMPLETED ]; then
  exit 0
fi

# install ruby
apt update && apt install -y ruby-full ruby-bundler build-essential

# install mongodb
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list' && \
apt update && \
apt install -y mongodb-org && \
systemctl start mongod && \
systemctl enable mongod

# deploy
cd /home/$APPUSER/
git clone -b monolith https://github.com/express42/reddit.git && \
cd reddit && \
bundle install && \
puma -d

touch $COMPLETED
```

6.3. Reddit App - create instance with `gcloud` command
```bash
gcloud compute instances create \
  reddit-app \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=startup-script.sh
```

6.4. Reddit App - create firewall rule for #puma-server
```bash
gcloud compute firewall-rules create \
  default-puma-server \
  --allow tcp:9292 \
  --target-tags puma-server \
  --description "Allow incoming traffic for #puma-server on tcp:9292"
```

-----

7.1. Create Reddit base image with packer
```
packer validate \
  -var-file=variables.json \
  ./ubuntu16.json

packer build \
  -var-file=variables.json \
  ./ubuntu16.json
```

7.2. Create "baked" reddit image
```
packer validate \
  -var-file=immutable-variables.json \
  ./immutable.json

packer build \
  -var-file=immutable-variables.json \
  ./immutable.json
```

7.3. Create reddit VM instance from baked image
```
### config-scripts/create-redditvm.sh
gcloud compute instances create \
  reddit-app-from-baked \
  --image-family reddit-full \
  --tags puma-server \
  --boot-disk-size=10GB \
  --machine-type=g1-small \
  --restart-on-failure
```
