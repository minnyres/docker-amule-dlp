#!/bin/sh

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

if [ -n "$WEBPASSWD" ]
then
    echo "Change the password for amule web interface."
    passwd=$(echo -n $WEBPASSWD | md5sum | cut -d ' ' -f 1)
    sed -i "s/^Password=.*/Password=$passwd/" $config
fi

if [ "$RECURSIVE_SHARE" == "yes" ]
then
    find /downloads -type d -not -empty \
    | uniq \
    | grep -v lost+found \
    | grep -v .Trash \
    | sort -ur > /config/shareddir.dat
else
    echo > /config/shareddir.dat
fi

if [ -n "$TIMEZONE" ]
then
    ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
fi

addgroup -g $GID amule
adduser amule -u $UID -G amule -D -s /bin/sh
chown -R $UID:$GID /config /downloads /temp

su - amule -c 'amuled --config-dir=/config --log-stdout'
