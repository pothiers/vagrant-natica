#/bin/bash -e -x

# Partition, format, mount second disk

sudo fdisk /dev/sdb <<EOF
n
p
1


w
EOF
sudo mkfs.ext4 /dev/sdb1 > /dev/null
sudo mkdir /hd2
sudo mount /dev/sdb1 /hd2

sudo chmod ugo+wrX /hd2

