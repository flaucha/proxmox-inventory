#!/bin/bash
#### CORRER CON SUDO ####

qm list | sed -e 's/\s\+/,/g' | sed 's/^,//' | sed 's/,$//' > ~/qmlist
input=~/qmlist
cat ~/qmlist > tmp_inv.csv
sed '1{s/$/,CORES,SOCKETS,NET0,NET1,COMMENTS/}' tmp_inv.csv > inv_dinamico.csv
while IFS= read -r line
do
  VMid=$(sed 's@^[^0-9]*\([0-9]\+\).*@\1@' <<< $line)
  echo "$VMid"
  if [[ $VMid =~ ^[-+]?[0-9]+$ ]];
  then
     cores=$(grep cores /etc/pve/qemu-server/"$VMid".conf | awk '{print $2}')
     sed -ie "s/^$VMid,.*$/&,$cores/g" inv_dinamico.csv
     sockets=$(grep sockets /etc/pve/qemu-server/"$VMid".conf | awk '{print $2}')
     sed -ie "s/^$VMid,.*$/&,$sockets/g" inv_dinamico.csv
     net0=$(grep net0 /etc/pve/qemu-server/"$VMid".conf | awk '{print $2}')
     addnet0=$(echo "$net0" | tr ',' ' ')
     sed -ie "s/^$VMid,.*$/&,$addnet0/g" inv_dinamico.csv
     net1=$(grep net1 /etc/pve/qemu-server/"$VMid".conf | awk '{print $2}')
     addnet1=$(echo "$net1" | tr ',' ' ')
     sed -ie "s/^$VMid,.*$/&,$addnet1/g" inv_dinamico.csv
     comments=$(grep ^# /etc/pve/qemu-server/"$VMid".conf | tr '#' ' ')
     addcomments=$(echo $comments | tr ',' ' ' | tr '/' '-')
     echo $addcomments
     sed -ie "s/^$VMid,.*$/&,$addcomments/g" inv_dinamico.csv


  fi
done < "$input"

