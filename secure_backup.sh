#!/bin/bash

#  backup script
#
#
#  Created by Gaëtan Cherbuin on 15.06.15
#

#prepare gpg

if system_profiler SPUSBDataType | grep -q Yubikey;
then

pkill gpg-agent
export SSH_AUTH_SOCK=~/.gnupg/S.gpg-agent.ssh
export PINENTRY_USER_DATA="USE_CURSES=1"
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

tar -zcf ~/Backup/"$(date '+%d.%m.%Y').tar.gz" ~/Documents/
fi

#test

if tar tf ~/Backup/"$(date '+%d.%m.%Y').tar.gz" &> /dev/null;
then
        echo "archive integrity check passed"

else    echo "corrupted archive" && exit 1
fi

#encrypt & sign

gpg -r $USER --hidden-recipient $USER --throw-keyids -e ~/Backup/"$(date '+%d.%m.%Y').tar.gz"
gpg -sb ~/Backup/"$(date '+%d.%m.%Y').tar.gz.gpg"
rm ~/Backup/"$(date '+%d.%m.%Y').tar.gz"

#yubikey fix

pkill gpg-agent
export SSH_AUTH_SOCK=~/.gnupg/S.gpg-agent.ssh
export PINENTRY_USER_DATA="USE_CURSES=1"
gpg-connect-agent "getinfo ssh_socket_name" /bye
gpg-agent --use-standard-socket --daemon
clear

#sync to server

read -p "$(echo -e 'Upload to [P]rism or to [c]arbonyle.net? Type [L] for local file only \n\b')" response

if [[ $response =~ ^([cC])$ ]]
then
~/git/rsync_3.1.2dev -avhzP -e "ssh -F /Users/gaetan/.ssh/config" ~/Backup carbonyle:~/Documents/ && echo "Remote backup operation finished"
elif [[ $response =~ ^([pP])$ ]]
then
~/git/rsync_3.1.2dev -avhzP -e "ssh -F /Users/gaetan/.ssh/config" ~/Backup prism:~/Documents/ && echo "Remote backup operation finished, Welcome HOME"
elif [[ $response =~ ^([lL])$ ]]
then
echo "Local backup finished, this backup will be uploaded on your next remote backup operation"
else
echo "Invalid choice" && exit 1
fi

#test "$(tail -n 1 ~/Backup/sha-256.log | head -c 64)" == "$(ssh -t carbonyle 'shasum -a 256 ~/Documents/Backup/"$(date '+%d.%m.%Y').tar.gz.gpg" | tail -n 1 | head -c 64')" && echo "Backup successful" || echo "Local hash doesn't match remote, backup is corrupted."
