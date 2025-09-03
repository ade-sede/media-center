- Install Scaleway CLI: `curl -s https://raw.githubusercontent.com/scaleway/scaleway-cli/master/scripts/get.sh | sh`
- Configure authentication: `scw init`
- Set project ID environment variable: `export PROJECT_ID=XXXXX`
- Setup an a service API key for the project / organisation and keep both the access key and the secret key on hand

## Create object storage

Create a Scaleway bucket for JuiceFS distributed storage:

```bash
scw object bucket create name=<bucket-name> region=fr-par
```

## Create server & Infect it with NixOS

Create a server with sufficient resources for media streaming:

```bash
# 2 vCPU, 4GB RAM
scw instance server create \
  type=PLAY2-NANO \
  image=ubuntu_jammy \
  name=media-center \
  root-volume=block:25GB \
  zone=fr-par-2 \
  ip=ipv6 \
  project-id=$PROJECT_ID \
  cloud-init=@nixos-infect-cloud-init.yaml
```

## Get server IP and monitor installation

```bash
# Get the server IP and ID
scw instance server list zone=fr-par-2 project-id=$PROJECT_ID

# Set server IP and ID as variables for subsequent commands
export SERVER_IP=<server-ip>
export SERVER_ID=$(scw instance server list zone=fr-par-2 project-id=$PROJECT_ID -o json | jq -r '.[0].id')

# Poll for progression every minute

# Command will fail if nixos is not yet installed
ssh root@$SERVER_IP "nixos-version"

# Monitor NixOS installation progress (if still installing)
ssh root@$SERVER_IP "tail -f /tmp/infect.log"

# Remove the backup of the initial ubuntu install
ssh root@$SERVER_IP "rm -rf /old-root"
```

## Deploy our NixOS configuration

### 1. Copy hardware configuration from remote server to local machine

```bash
scp root@$SERVER_IP:/etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
```

### 2. From the local machine, commit hardware config to repository

```bash
git add hardware-configuration.nix
git commit -m "Add media-center server hardware config"
git push
```

### 3. Clone repository on remote server

```bash
ssh root@$SERVER_IP "git clone https://github.com/ade-sede/media-center.git /root/nixos"
```

### 4. Configure secrets

In `flake.nix`, on the remote

### 5. Deploy NixOS configuration

```bash
ssh root@$SERVER_IP "cd /root/nixos && nixos-rebuild switch --flake .#media-center"
```

**Note**: The SSL certificate generation will fail if the domain names are not setup yet. That's fine, you can simply rebuild later after making sure the domain name points toward the server.

## Update user passwords

After deployment, update the default passwords for security:

```bash
# SSH into the server and change passwords for each user
ssh ade-sede@$SERVER_IP  # default password: changeme
passwd ade-sede

ssh pancho@$SERVER_IP    # default password: changeme
passwd pancho
```

## Setup passwordless SSH access

Copy your SSH key to enable passwordless login:

```bash
# Set your preferred username
export USERNAME=ade-sede

# Copy SSH key for passwordless access
ssh-copy-id $USERNAME@$SERVER_IP
```
