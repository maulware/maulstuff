# Shamir Distributed Boot Unseal

This tool is placing scripts into initramfs and is contacting servers that contain parts of the actual unseal key.
The actual distribution of the key shares and ssh (public)keys is up to the implementor.
The system can either be deployed in a trusted or untrusted (e.g. internet/corporate) network.

TODO: Only tested on debian, ubuntu. Arch/manjaro require additional work (sssd AUR and stuff)

## Key destribution
The ssss-split tool does not support 128 ASCII characters and 256 hex digits. domagic script is provided to allow split of more and already prepares the shares for X servers. the 1_shares, 2_shares, ..., X_shares are the files that need to be put on the servers.
domagic has a self test to recombine the split key parts and check them.

## Client side Configuration
/etc/mboot data files that are always used. The initramfs script will take all files in /etc/mboot and place them into the initramfs.

### initramfs
/etc/initramfs-tools/initramfs.conf needs to be setup properly to have network configured.
hooks_mboot.sh needs to be placed in /etc/initramfs-tools/hooks/ and set as executable.
local-top_mpremount.sh needs to be placed in /etc/initramfs-tools/scripts/.

### userdata
This file is sourced if it exists by the boot script. mboot_t variable can be set there to allow arbitrary threshold. mboot_decrypt to override the used function for decryption of the disk (parameter is base64 encoded). Do not forget to include tools into initramfs (see hooks script). Alternative use perform_eval variable and set to true, this will take the combined data decoded and eval() instead. mboot_networking function to be executed for additional functions that you want to execute after initramfs configure_networking.

### ssh_config
The config file in /etc/mboot is put into the initramfs. The unseal script is connecting to all mboot_* hosts given in the ssh_config file.
```
# config example for all hosts
Host *
    User remoteExampleUser
    Port 2222
    UserKnownHostsFile /etc/mboot/known_hosts_example
    IdentitiesOnly yes
    IdentityFile /etc/mboot/boot_key
    ConnectTimeout 20

# individual mboot_* host configs for actual servers
Host mboot_examplehost1
    HostName 10.0.0.101
Host mboot_exmphst2
    HostName 192.0.0.200
Host mboot_srv3
    HostName 192.168.0.4
```

### known_hosts_example
```
# all trusted hosts required or alternatively use unsafe trust in ssh_config
mboot_examplehost1 ssh-ed25519 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
mboot_exmphst2     ssh-ed25519 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB
mboot_srv3         ssh-ed25519 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC
```

### boot_key
Generate key directly on the server via ```ssh-keygen -f /etc/mboot/ -t ed25519```

## Server side config
This is the configuration with parts of the actual secret. Only requirement on the server is that when the client is authenticating with his publickey that he receives the key part without any further interaction.
Example remoteExampleUser's .ssh/authorized_keys file
```
command="cat /keypartfolder/000-keysharefile" ssh-ed25519 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA000
command="cat /keypartfolder/010-keysharefile" ssh-ed25519 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA010
cert-authority ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILmLXfef0ASYrIdwpqp8Z4uhxBPak1qMUCtYLevD8Mtq example-CA
```
### Advanced
The last item in the authorized_keys file is an advanced use of ssh where the client has a boot_key-cert.pub file next to his boot_key.pub. A trusted entity has access to the cert-authority file, which was created via normal ssh-keygen.
THe cert-authority pubkey is the part that is placed on the server side, the client's key is signed using ssh-keygen.
Further information on [Digitalocean](https://www.digitalocean.com/community/tutorials/how-to-create-an-ssh-ca-to-validate-hosts-and-clients-with-ubuntu).

Warning: The boot_key-cert.pub is signed by the authority, not encrypted! The configured RemoteCommand in it can be read by the client, do not directly put the key part into the signed cert.
