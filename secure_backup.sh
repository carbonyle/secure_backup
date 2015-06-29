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

if [ -f ~/Backup/"$(date '+%d.%b.%Y').tar.gz.gpg" ];
then
   echo "Backup already performed, try later" && exit 1
else

tar -zcf ~/Backup/"$(date '+%d.%b.%Y').tar.gz" ~/Documents ~/OtherFoldersToBackup

#test

touch ~/Backup/"$(date '+%d.%b.%Y').log"
tar -ztvvf ~/Backup/"$(date '+%d.%b.%Y').tar.gz" >> ~/Backup/"$(date '+%d.%b.%Y').log"
clear

#encrypt

gpg -r carbonyle -e ~/Backup/"$(date '+%d.%b.%Y').tar.gz"
rm ~/Backup/"$(date '+%d.%b.%Y').tar.gz"

#generate sha-256

if [ -f ~/Backup/sha-256.log ];
then
   shasum -a 256 ~/Backup/"$(date '+%d.%b.%Y').tar.gz.gpg" >> ~/Backup/sha-256.log
else
   touch ~/Backup/md5.log && shasum -a 256 ~/Backup/"$(date '+%d.%b.%Y').tar.gz.gpg" >> ~/Backup/sha-256.log
fi

#sync to server

read -r -p "Upload to [P]rism or to [c]arbonyle.net? " response

if [[ $response =~ ^([cC])$ ]];
then
~/Desktop/rsync_3.1.2dev -avhzP -e "ssh -p 4321" ~/Backup carbonyle@carbonyle.net:/home/carbonyle/Documents/

else
~/Desktop/rsync_3.1.2dev -avhzP -e "ssh -p 4321" ~/Backup carbonyle@LocalPath

fi

#ssh to server, run check script, and quit

ssh -t carbonyle 'rm /home/carbonyle/Documents/Backup/check.log && /home/carbonyle/Documents/Backup/check && cat /home/carbonyle/Documents/Backup/check.log && exit'

#cat local sha-256

cat ~/Backup/sha-256.log
