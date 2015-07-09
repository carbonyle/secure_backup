# secure_backup

This script is a attempt of implementing secure backup in term of file integrity and content privacy. 

After creation of the tar.gz archive, its integrity is tested. The file is then encrypted using GPG, a separate signature file is created, files are sent over SSH.

Install:

- Copy, chmod+x & run
