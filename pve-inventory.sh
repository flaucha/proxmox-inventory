#!/bin/bash
#### RUN WITH SUDO ####
#GET LIST AND SORT WITH COMMAS
qm list | sed -e 's/\s\+/,/g' | sed 's/^,//' | sed 's/,$//' > ~/qmlist
input=~/qmlist
cat ~/qmlist > tmp_inv.csv
#ADD CUSTOM FIELDS TO DEFINITIVE FILE
sed '1{s/$/,CORES,SOCKETS,NET0,NET1,COMMENTS/}' tmp_inv.csv > inv_dinamico.csv
#READ INITIAL FILE
while IFS= read -r line
do
  #STRIPE VMID FROM THE LINE BEEING READ
  VMid=$(sed 's@^[^0-9]*\([0-9]\+\).*@\1@' <<< $line)
  #echo "$VMid"
  #DISCARD NOT NUMERIC LINES
  if [[ $VMid =~ ^[-+]?[0-9]+$ ]];
  then
     #GET CORES AND SOCKETS
     cores=$(grep cores /etc/pve/qemu-server/"$VMid".conf | awk '{print $2}')
     sed -ie "s/^$VMid,.*$/&,$cores/g" inv_dinamico.csv
     sockets=$(grep sockets /etc/pve/qemu-server/"$VMid".conf | awk '{print $2}')
     sed -ie "s/^$VMid,.*$/&,$sockets/g" inv_dinamico.csv
     #ADD NETWORKS, ONLY 2 ARE AUDITED. REMOVE COMMAS FROM LINES TO PREVENT ERRORS IN CSV
     net0=$(grep net0 /etc/pve/qemu-server/"$VMid".conf | awk '{print $2}')
     addnet0=$(echo "$net0" | tr ',' ' ')
     sed -ie "s/^$VMid,.*$/&,$addnet0/g" inv_dinamico.csv
     net1=$(grep net1 /etc/pve/qemu-server/"$VMid".conf | awk '{print $2}')
     addnet1=$(echo "$net1" | tr ',' ' ')
     sed -ie "s/^$VMid,.*$/&,$addnet1/g" inv_dinamico.csv
     #REMOVE COMMENTS HASHTAG, BACKSLASH AND COMMAS.
     comments=$(grep ^# /etc/pve/qemu-server/"$VMid".conf | tr '#' ' ')
     addcomments=$(echo $comments | tr ',' ' ' | tr '/' '-')
     echo $addcomments
     sed -ie "s/^$VMid,.*$/&,$addcomments/g" inv_dinamico.csv
  fi
done < "$input"
