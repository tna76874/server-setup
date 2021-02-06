# Server config

Prepare your config files and edit public keys and other variables:

```
./install.sh
nano vars.yml
```

Run the playbook to set up users and firewall.

```bash
sudo ansible-playbook main.yml
```

Install docker:

```bash
sudo ansible-playbook main.yml -t docker
```

Install nginx:

```bash
sudo ansible-playbook main.yml -t nginx
```

Install nextcloud:

```bash
sudo ansible-playbook main.yml -t nextcloud
```

Secure the server (do not allow password ssh auth):

```bash
sudo ansible-playbook main.yml -t security
```

