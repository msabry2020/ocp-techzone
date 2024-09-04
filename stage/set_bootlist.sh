#!/bin/bash

function set_bootlist
{
    host=$1

    ssh core@$host uname -a 2> /dev/null | grep -q ppc64le
    (($?!=0)) && echo "Warning: Architecture not ppc64le on $host" && exit 0

    ssh core@$host systemctl is-active multipathd 1> /dev/null
    (($?!=0)) && echo "Warning: Multipathing not active on $host" && exit 0
    
    disk=$(ssh core@$host sudo bootlist -m normal -o | grep -E "^sd" | head -n1)
    [[ -z $disk ]] && echo "Error: Can not identify a boot block device for $host" && exit 1

    mpath_list="$(ssh core@$host sudo multipath -l)"
    mpath_name=$(echo "$mpath_list" | tr -d '|' | awk -v BLOCK=$disk 'BEGIN {DMAP=""}; / dm-/ {DMAP=$0; next}; ($3 == BLOCK) {print DMAP; exit 0}' | tr ' ' '\n' | awk '/^dm-/ {print "/dev/"$1; exit 0}')
    [[ -z $mpath_name ]] && echo "Error: Can not identify multipath device managing $disk for $host" && exit 1

    mpath_device="$(ssh core@$host sudo multipath -l $mpath_name)"
    boot_list=$(echo "$mpath_device" | tr -d '|' | awk '/ sd/ {print $2" "$3}' | sort | head -n5 | cut -d ' ' -f 2 | tr '\n' ' ')
    [[ -z $boot_list ]] && echo "Error: Can not identify block devices managed by $mpath_name for $host" && exit 1

    ssh core@$host sudo bootlist -m normal -o $boot_list 1> /dev/null
    (($?!=0)) && echo "Error: Problem setting boot list to $boot_list for $host" && exit 1
    echo "Set $host boot list to $boot_list"

    sorted_list=$(echo $boot_list | tr ' ' '\n' | sort | tr '\n' ' ')
    current_list=$(ssh core@$host sudo bootlist -m normal -o | grep -E "^sd" | sort | tr '\n' ' ')
    [[ $current_list != $sorted_list ]] && echo "Error: Bootlist may not be set as expected on $host" && exit 1
}

for node in $(/usr/local/bin/oc get nodes | awk '!/NAME/ {print $1}') ; do
    set_bootlist $node
done
exit 0
