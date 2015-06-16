# secure_backup

It's a script I use on my MBP to backup important directories. It work fine for my needs and is adapted to my configuration. I do not pretend it to be perfect

This script it a attempt of implementing secure backup in term of file integrity and content privacy. 

After creation of the tar.gz archive, its integrity is tested and reported to a log file.
The file is then encrypted using GPG, a md5 hash is computed then uploaded to my server. 

On server side another script (check.sh) is used to calculate the md5 hash of the transfered file and you can then manualy compared transfered and received hashes

nb: it's dirty and probably only usefull for me but it make good use of my Yubikey NEO (smartcard for GPG and SSH Auth)


Install:

- Client side: cp, chmod+x & run secure_backup.sh
- Server side: scp, chmod+x

You'll first need to adapt it to your config. Note that secure_backup.sh is made for OS X (md5 instead of md5sum, ...) unlike check.sh which is Llinux compatible (Debian)
