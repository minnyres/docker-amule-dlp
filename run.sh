#!/bin/bash

config="/config/amule.conf"

if [ -f "$config" ]
then
    echo "Use existing aMule configuration file."
else
    echo "No aMule configuration file found, use the default one."
    cp /amule.conf $config
fi

echo "Use the theme $WEBUI for amule webserver."
sed -i "s/.*Template=.*/Template=$WEBUI/" $config

if [ -n "$ECPASSWD" ]
then
    echo "Change the password for remote connection."
    passwd=$(echo -n $ECPASSWD | md5sum | cut -d ' ' -f 1)
    sed -i "s/.*ECPassword=.*/ECPassword=$passwd/" $config
fi

groupadd -g $GID amule
useradd amule -u $UID -g $GID -m -s /bin/bash
chown -R amule:amule /config /downloads /temp

su - amule -c 'amuled --config-dir=/config --log-stdout'