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
