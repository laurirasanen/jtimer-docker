#!/bin/bash

SERVER = "~/steamcmd"

cd $SERVER
./tf2/srcds_run -game tf -autoupdate -steam_dir $SERVER -steamcmd_script $SERVER/tf2_ds.txt $@