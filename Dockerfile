FROM i386/debian:stretch-slim

# Update
RUN apt-get -y update

# Install requirements
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install \
    zlib1g \
    libffi6 \
    libstdc++6 \
    libncurses5 \
    libcurl3-gnutls \
    wget \
    bzip2 \
    unzip \
    git

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

# Get SourceMod
RUN wget -O - https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git970-linux.tar.gz | tar -C $SERVER/tf2/tf/ -xvz
RUN wget -O - https://sm.alliedmods.net/smdrop/1.9/sourcemod-1.9.0-git6281-linux.tar.gz | tar -C $SERVER/tf2/tf/ -xvz

# Get SourceMod plugins
RUN wget -O - https://users.alliedmods.net/~kyles/builds/SteamWorks/SteamWorks-git131-linux.tar.gz | tar -C $SERVER/tf2/tf/ -xvz
RUN wget -O $SERVER/tf2/tf/addons/sourcemod/plugins/updater.smx https://bitbucket.org/GoD_Tony/updater/downloads/updater.smx
RUN wget -O $SERVER/tf2/tf/temp.zip https://builds.limetech.io/files/accelerator-2.3.3-git92-e01565f-linux.zip; unzip $SERVER/tf2/tf/temp.zip; rm $SERVER/tf2/tf/temp.zip
RUN wget -O $SERVER/tf2/tf/addons/temp.zip https://github.com/laurirasanen/groundfix/releases/download/v3.1.3/plugin-and-dhooks.zip; unzip $SERVER/tf2/tf/addons/temp.zip; rm $SERVER/tf2/tf/addons/temp.zip

# Get Source.Python
RUN git clone https://github.com/Source-Python-Dev-Team/Source.Python/
RUN cp -r ./Source.Python/addons $SERVER/tf2/tf
RUN cp -r ./Source.Python/resource $SERVER/tf2/tf
RUN rm -rf ./Source.Python

# Get Source.Python plugins
RUN git clone https://github.com/occasionally-cool/jtimer
RUN cp -r ./jtimer/addons $SERVER/tf2/tf
RUN cp -r ./jtimer/resource $SERVER/tf2/tf
RUN cp -r ./jtimer/cfg $SERVER/tf2/tf
RUN rm -rf ./jtimer

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
