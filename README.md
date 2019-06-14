# proxmox-inventory
Script to inventory VM's per node.

The script get qm list info, convert it to csv file, and match with .conf files in /etc/pve/qemu-server/[VMid].conf

It will run in any directory but needs sudo to use qm commands.
