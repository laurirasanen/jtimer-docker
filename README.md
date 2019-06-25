# jtimer-docker

# Install
```bash
#!/bin/bash

# Update
apt update
DEBIAN_FRONTEND=noninteractive apt upgrade -y
DEBIAN_FRONTEND=noninteractive apt dist-upgrade -y

# Install docker
apt -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt update
apt-cache policy docker-ce
apt -y install docker-ce

# Clean
apt -y autoremove
apt clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Docker mounts
mkdir -p /srv/maps /srv/cfg
chmod -R 777 /srv

# Build image
docker build https://github.com/occasionally-cool/jtimer-docker.git -t jtimer-server
```

# Config
* Upload your maps to `/srv/maps/`
* Upload your config to `/srv/cfg/`

# Usage
Starting a container:  
```bash
docker run --name=tf2 --restart always -itd -p 27015:27015/udp -p 27015:27015/tcp -v /srv/maps:/home/hlserver/steamcmd/tf2/tf/maps -v /srv/cfg:/home/hlserver/steamcmd/tf2/tf/cfg jtimer-server +maxplayers 24 +map jump_soar_a4
```