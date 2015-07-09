# secure_backup

This script is a attempt of implementing secure backup in term of file integrity and content privacy. 

After creation of the tar.gz archive, its integrity is tested. The file is then encrypted using GPG, a separate signature file is created, files are sent over SSH.

Install:

- Copy, chmod+x & run

This script assumes that 

- You have a Yubikey NEO with a properly configured GPG applet for public key auth.
- SSHD is configured for public-key auth. (use gpgkey2ssh to generate a ssh compatible public-key derived from your GPG auth key)
- Local ssh connection settings are in ~/.ssh/config
- You modify it according to your configuration
