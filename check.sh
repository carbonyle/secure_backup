
#!/bin/bash
FILES="/home/carbonyle/Documents/Backup/*.tar.gz.gpg"

if [ -f /home/carbonyle/Documents/Backup/check.log ];
then
        for f in $FILES 
        do
                shasum -a 256 "$f" >> /home/carbonyle/Documents/Backup/check.log
        done
else
touch /home/carbonyle/Documents/Backup/check.log &&
        for f in $FILES 
        do
                shasum -a 256 "$f" >> /home/carbonyle/Documents/Backup/check.log
        done
fi

