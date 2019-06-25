FROM i386/debian:stretch-slim

# Update
RUN apt-get -y update

# Install requirements
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
    python3 \
    python3-pip \
    binutils \
    zlib1g \
    libffi6 \
    libstdc++6 \
    libncurses5 \
    libcurl3-gnutls \
    wget \
    bzip2 \
    unzip \
    git \
    && pip3 install --upgrade pip

# Clean
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create user
ENV USER hlserver
RUN useradd $USER

# Create HOME dir
ENV HOME /home/$USER
RUN mkdir $HOME

# Create SERVER dir
ENV SERVER $HOME/steamcmd
RUN mkdir $SERVER; mkdir $SERVER/tf2; mkdir $SERVER/tf2/tf

# Get steamcmd
RUN wget -O - http://media.steampowered.com/client/steamcmd_linux.tar.gz | tar -C $SERVER -xvz
ADD tf2_ds.txt update.sh tf.sh $SERVER/
RUN chmod 744 $SERVER/update.sh
RUN $SERVER/update.sh

# MetaMod
RUN wget -O - https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git970-linux.tar.gz | tar -C $SERVER/tf2/tf/ -xvz
# Sourcemod
RUN wget -O - https://sm.alliedmods.net/smdrop/1.9/sourcemod-1.9.0-git6281-linux.tar.gz | tar -C $SERVER/tf2/tf/ -xvz

# SteamWorks
RUN wget -O - https://users.alliedmods.net/~kyles/builds/SteamWorks/SteamWorks-git131-linux.tar.gz | tar -C $SERVER/tf2/tf/ -xvz
# Updater
RUN wget -O $SERVER/tf2/tf/addons/sourcemod/plugins/updater.smx https://bitbucket.org/GoD_Tony/updater/downloads/updater.smx
# Accelerator
RUN wget -O temp.zip https://builds.limetech.io/files/accelerator-2.3.3-git92-e01565f-linux.zip; \
    unzip temp.zip -d $SERVER/tf2/tf/; \
    rm temp.zip
# groundfix
RUN wget -O temp.zip https://github.com/laurirasanen/groundfix/releases/download/v3.1.3/plugin-and-dhooks.zip; \
    unzip temp.zip -d $SERVER/tf2/tf/addons/; \
    rm temp.zip

# Source.Python
RUN wget -O temp.zip http://downloads.sourcepython.com/release/690/source-python-tf2-June-02-2019.zip; \
    unzip temp.zip -d $SERVER/tf2/tf/; \
    rm temp.zip

# jtimer
RUN wget -O temp.zip https://github.com/occasionally-cool/jtimer/archive/develop.zip; \
    unzip temp.zip 'jtimer-develop/*'; \
    rm temp.zip; \
    cp -r jtimer-develop/* $SERVER/tf2/tf/; \
    rm -rf jtimer-develop; \
    cd $SERVER/tf2/tf/addons/source-python/plugins/jtimer; \
    python3 ./setup.py

# Config
ADD server.cfg $SERVER/tf2/tf/cfg/

# Expose ports
EXPOSE 27015/udp
EXPOSE 27015/tcp

# Set permissions
RUN chown -R $USER:$USER $HOME
RUN chmod 744 $SERVER/tf.sh $SERVER/steamcmd.sh $SERVER/tf2/srcds_run $SERVER/tf2/srcds_linux

# Start server as USER
USER $USER
ENTRYPOINT ["/home/hlserver/steamcmd/tf.sh"]
CMD ["+sv_pure", "0", "+map", "itemtest", "+maxplayers", "24"]
