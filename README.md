# secure_backup

It's a script I use on my MBP to backup directories. It work fine for my needs and is adapted to my configuration. I do not pretend it to be perfect.

This script is a attempt of implementing secure backup in term of file integrity and content privacy. 

After creation of the tar.gz archive, its integrity is tested. The file is then encrypted using GPG, send over SSH, then a sha-256 hash is computed and compared to the local hash.

Install:

- Copy, chmod+x & run secure_backup.sh


Requirement:

- Yubikey NEO (configured as smartcard, use gpgkey2ssh to generate a public key for sshd)
- GPGTools
- Unix server for remote storage, sshd configured for public key auth

You'll need to adapt it to your config. 
