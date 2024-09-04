#!/bin/bash
##############################################################################
# Modified version of create_disk_link.sh script provided by OCP4 Terraform
# provisioning templates.
##############################################################################

##############################################################################
# Insure a volume has come online. Sometimes it does not always come online
# right away, so loop several times trying
##############################################################################
count=0
sudo rescan-scsi-bus.sh -a -m -r
while [[ $(multipath -ll | grep -c mpath) -lt 2 ]] ; do
    [[ $count -gt 12 ]] && echo "Error: Extra disk not coming online!" && exit 1
    ((count=count+1))
    echo "Waiting for disk to come online"
    sleep 15
    sudo rescan-scsi-bus.sh -a -m -r
done

##############################################################################
# Create udev rule for it
##############################################################################
found=0
storage_device=""
storage_disk_name="disk/pv-storage-disk"
volume_sizes="100 500"
for device in $(ls -1 /dev/mapper/mpath*|egrep -v "[0-9]$"); do
    if [[ ! -b $device"1" ]]; then
        # Convert disk size to GB
        device_size=$(lsblk -b -dn -o SIZE $device | awk '{print $1/1073741824}')
	for volume_size in ${volume_sizes} ; do
            if [[ -z $storage_device && $device_size == ${volume_size} ]]; then
                storage_device=$device
                # This symbolic link is used in openshift config
                echo "ENV{DM_UUID}==\"$(sudo udevadm info --root --name="$storage_device" | sudo grep DM_UUID | sudo cut -f2 -d'=')\" SYMLINK+=\"$storage_disk_name\"" | sudo tee /etc/udev/rules.d/99-custom-ocp.rules;
                sudo udevadm control --reload-rules;
                sudo udevadm trigger --type=devices --action=change
	        found=1
                break
            fi
        done
	[[ ${found} == 1 ]] && break
    fi
done
[[ $found != 1 ]] && echo "Error: Did not find mpath!" && exit 1

##############################################################################
# Verify udev has created the link
##############################################################################
timeout 30 bash -c -- "
while [ ! -L /dev/$storage_disk_name ]; do
    echo 'Disk not ready, sleeping for 2s..';
    sleep 2;
done
"
[[ ! -L /dev/$storage_disk_name ]] && echo "Error: Can not find disk link!" && exit 1

##############################################################################
# Create file system, mount it at /export, and setup /etc/fstab
##############################################################################
sudo mkfs.ext4 -F /dev/$storage_disk_name
[[ ! -d /export ]] && mkdir -p /export && chmod -R 755 /export

mount | grep -q export
[[ $? != 0 ]] && sudo mount /dev/$storage_disk_name /export

grep -Eq "/dev/$storage_disk_name /export ext4 defaults 0 0" /etc/fstab
[[ $? != 0 ]] && echo "/dev/$storage_disk_name /export ext4 defaults 0 0" >> /etc/fstab

echo "test" > /export/test.dat
[[ $? != 0 ]] && echo "Error: Error writing to file system" && exit 1
rm -f /export/test.dat

##############################################################################
# Update initramfs with custom rule
##############################################################################
sudo dracut -f -v
exit 0
