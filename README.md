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

-----

8.1. Adding multiple SSH keys to GCP Compute Engine metadata with Terraform
Using resource "google_compute_project_metadata_item" with key = "ssh-keys"
will overwrite all previously added SSH keys in project,
including those that were added manually
So, here is working example to add multiple SSH keys:
```
resource "google_compute_project_metadata_item" "default" {
  key = "ssh-keys"
  value = "appuser1:${file(var.public_key_path)}appuser2:${file(var.public_key_path)}"
}
```

8.2. Problem with describing similar compute instances as separate resources is code duplication
Instead we can use `count = {...}` to create multiple instances

# Here is how to output IPs of instances with count > 1
```
output "app_ips" {
  value = "${join(", ",google_compute_instance.app.*.network_interface.0.access_config.0.assigned_nat_ip)}"
}
```

8.3. Sample SSH config to access Reddit App
```
Host reddit-app-01
  HostName <reddit-app-host-name>
  User appuser
  IdentityFile ~/.ssh/appuser
```

-----

9. Terraform-2
Добавил уже существующий ресурс `firewall_ssh` в Terraform
При выполнении `terraform apply` получил сообщение об ошибке, что такой ресурс уже существует
Импортировал уже существующий ресурс `firewall_ssh` командой `terrform import`
Создал описание двух VM - для основного приложени и базы данных
Перенес конфигурацию в модули, дополнительно создал модуль `vpc`
Настройки модулей вынес в переменные
Проверил работу модуля `vpc` с различными значениями переменной `source_ranges`: все адреса, мой IP, чужой IP
Создал два варианта развертывания инфраструктуры в каталогах `stage` и `prod` -- в первом открыт доступ к приложениию для всех IP, во втором -- только для моего IP
Добавил модуль storage-bucket для хранения state-файлов terraform в облаке
Проверил работу проекта при переносе в другую папку, где отсутствует файл `terraform.tfstate`, terraform при этом корректно работает
При попытке одновременно запустить `terraform apply` (или `destroy`) получил сообщение об ошибке:
```bash
Error: Error locking state: Error acquiring the state lock: writing "gs://backend-stage/terraform/state/default.tflock" failed: googleapi: Error 412: Precondition Failed, conditionNotMet

Terraform acquires a state lock to protect the state from being written by multiple users at the same time. Please resolve the issue above and try again. For most commands, you can disable locking with the "-lock=false" flag, but this is not recommended.
```

Доработал конфигурации `stage` и `prod` чтобы они могли выполняться
одновременно и не мешать друг другу
Добавил provisioners в модули для настройки базы и приложения.
При этом следует учесть, что настройки mongodb по-умолчанию не разрашают доступ c внешних адресов. Для доступа необходимо править `/etc/mongod.conf` и рестартовать сервис (либо, как вариант исправить базовый образ reddit-db-base)
Для `puma` добавил переменную окружения `DATABASE_URL` с помощью Terraform Template Provider `template_file` (либо, как вариант, можно передавать это значение аргументом для deploy-скрипта):
```bash
[Service]
Environment="DATABASE_URL=${database_url}"
```
Пока не реализовал задание "Опционально можете реализовать отключение provisioner в зависимости от значения переменной". Насколько я виж
у, в terraform нет "conditional flow" или другого стандартного спосо
бо для этого, как вариант можно попробовать использовать count=1|0 в
 зависимости от переданной переменной

Пример использования:
```bash
cd terraform/
cp terraform.tfvars.example terraform.tfvars
# update terraform.tfvars

cd stage/ # (или prod/)
cp terraform.tfvars.example terraform.tfvars
# update terraform.tfvars
terraform plan -var-file=../terraform.tfvars
terraform apply -var-file=../terraform.tfvars

### Sample outputs:
#
# app_external_ip = 35.241.182.XXX
# db_internal_ip = 10.132.0.2

После этого можно зайти по адресу
http://<app_external_ip>:9292
и увидеть web-интерфейс приложения
