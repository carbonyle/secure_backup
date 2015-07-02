#!/bin/bash

#  backup script
#
#
#  Created by Gaëtan Cherbuin on 15.06.15.
#

#prepare gpg

if system_profiler SPUSBDataType | grep -q Yubikey;
then
pkill gpg-agent
gpg-agent --use-standard-socket --daemon 
clear

else
echo "Insert Yubikey & run again" && exit 1
fi

#backup

if [ -f ~/Backup/"$(date '+%d.%m.%Y').tar.gz.gpg" ];
then
   echo "Backup already performed, try later" && exit 1
else

tar -zcf ~/Backup/"$(date '+%d.%m.%Y').tar.gz" ~/Documents
fi

#test

if tar tf ~/Backup/"$(date '+%d.%m.%Y').tar.gz" &> /dev/null;
then
        echo "archive integrity check passed"

else    echo "corrupted archive" && exit 1
fi

#encrypt & sign

gpg -r gaetan -e ~/Backup/"$(date '+%d.%m.%Y').tar.gz"
gpg -sb ~/Backup/"$(date '+%d.%m.%Y').tar.gz.gpg"
rm ~/Backup/"$(date '+%d.%m.%Y').tar.gz"

#yubikey fix

pkill gpg-agent
export SSH_AUTH_SOCK=~/.gnupg/S.gpg-agent.ssh
gpg-connect-agent "getinfo ssh_socket_name" /bye
gpg-agent --use-standard-socket --daemon
clear

#sync to server

read -r -p "Upload to [P]rism or to [c]arbonyle.net? " response

if [[ $response =~ ^([cC])$ ]]
then
~/Desktop/rsync_3.1.2dev -avhzP -e "ssh -p 4321" ~/Backup carbonyle@carbonyle.net:/home/carbonyle/Documents/
elif [[ $response =~ ^([pP])$ ]]
then
~/Desktop/rsync_3.1.2dev -avhzP -e "ssh -p 4321" ~/Backup carbonyle@192.168.1.116:/home/carbonyle/Documents/
else
echo "Invalid choice" && exit 1
fi
