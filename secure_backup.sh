#!/bin/bash

#  backup script
#
#
#  Created by carbonyle on 15.06.15.
#


#prepare gpg

pkill gpg-agent >> /dev/null
export SSH_AUTH_SOCK=~/.gnupg/S.gpg-agent.ssh >> /dev/null
gpg-connect-agent "getinfo ssh_socket_name" /bye >> /dev/null
gpg-agent --use-standard-socket --daemon >> /dev/null
clear

#backup

if [ -f /Users/carbonyle/Backup/"$(date '+%d.%b.%Y').tar.gz.gpg" ];
then
   echo "Backup already performed, try later" && exit 1
else

    read -r -p "Do you want to backup something else? (Y/n) " morebackup

        if [[ $morebackup =~ ^([yY])$ ]]

        then

        read -r -p "Specify path to backup" pathtobackup
        tar -zcf /Users/carbonyle/Backup/"$(date '+%d.%b.%Y').tar.gz" /Users/carbonyle/Documents/Job $pathtobackup

        else

        tar -zcf /Users/carbonyle/Backup/"$(date '+%d.%b.%Y').tar.gz" /Users/carbonyle/Documents/Job

        fi

fi

#test

touch /Users/carbonyle/Backup/"$(date '+%d.%b.%Y').log"
tar -ztvvf /Users/carbonyle/Backup/"$(date '+%d.%b.%Y').tar.gz" >> /Users/carbonyle/Backup/"$(date '+%d.%b.%Y').log"
clear

#encrypt

gpg -r carbonyle -e /Users/carbonyle/Backup/"$(date '+%d.%b.%Y').tar.gz"
rm /Users/carbonyle/Backup/"$(date '+%d.%b.%Y').tar.gz"

#generate md5

if [ -f /Users/carbonyle/Backup/md5.log ];
then
   md5 /Users/carbonyle/Backup/"$(date '+%d.%b.%Y').tar.gz.gpg" >> /Users/carbonyle/Backup/md5.log
else
   touch /Users/carbonyle/Backup/md5.log && md5 /Users/carbonyle/Backup/"$(date '+%d.%b.%Y').tar.gz.gpg" >> /Users/carbonyle/Backup/md5.log
fi

#sync to server

read -r -p "Upload to [P]rism or to [c]arbonyle.net? " response

if [[ $response =~ ^([cC])$ ]]
then
/Users/carbonyle/Desktop/rsync_3.1.2dev -avhzP -e "ssh -p 4321" /Users/carbonyle/Backup carbonyle@carbonyle.net:/home/carbonyle/Documents/

else
/Users/carbonyle/Desktop/rsync_3.1.2dev -avhzP -e "ssh -p 4321" /Users/carbonyle/Backup carbonyle@192.168.1.116:/home/carbonyle/Documents/

fi

#ssh to server, run check script, and quit

ssh -t carbonyle 'rm /home/carbonyle/Documents/Backup/check.log && /home/carbonyle/Documents/Backup/check && cat /home/carbonyle/Documents/Backup/check.log && exit'

#cat local md5

cat /Users/carbonyle/Backup/md5.log
