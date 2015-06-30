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
export SSH_AUTH_SOCK=~/.gnupg/S.gpg-agent.ssh
gpg-connect-agent "getinfo ssh_socket_name" /bye
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

tar -zcf ~/Backup/"$(date '+%d.%m.%Y').tar.gz" ~/Documents/Job ~/Library/Application\ Support/Pcsxr/ ~/Library/Application\ Support/OpenEmu/Save\ States/ ~/Documents/GTA\ San\ Andreas\ User\ Files/
fi

#test

if tar tf ~/Backup/"$(date '+%d.%m.%Y').tar.gz" &> /dev/null;
then
        echo "archive integrity check passed"

else    echo "corrupted archive" && exit
fi

#encrypt

gpg -r gaetan -e ~/Backup/"$(date '+%d.%m.%Y').tar.gz"
rm ~/Backup/"$(date '+%d.%m.%Y').tar.gz"

#generate sha-256

if [ -f ~/Backup/sha-256.log ];
then
   shasum -a 256 ~/Backup/"$(date '+%d.%m.%Y').tar.gz.gpg" >> ~/Backup/sha-256.log
else
   touch ~/Backup/sha-256.log && shasum -a 256 ~/Backup/"$(date '+%d.%m.%Y').tar.gz.gpg" >> ~/Backup/sha-256.log
fi

#sync to server

read -r -p "Upload to [P]rism or to [c]arbonyle.net? " response

if [[ $response =~ ^([cC])$ ]];
then
~/Desktop/rsync_3.1.2dev -avhzP -e "ssh -p 4321" ~/Backup carbonyle@carbonyle.net:/home/carbonyle/Documents/

else
~/Desktop/rsync_3.1.2dev -avhzP -e "ssh -p 4321" ~/Backup carbonyle@192.168.1.116:/home/carbonyle/Documents/

fi

clear

#test if local sha-256 hash matches remote and print status

test "$(tail -n 1 ~/Backup/sha-256.log | head -c 64)" == "$(ssh -t carbonyle 'shasum -a 256 ~/Documents/Backup/"$(date '+%d.%m.%Y').tar.gz.gpg" | tail -n 1 | head -c 64')" && echo "Backup successful" || echo "Local hash doesn't match remote, backup is corrupted."


