
# mesh-potato

## Applying the Base Image

### Assumptions

- Your SD card is attached to your host and you have the device name (i.e., /dev/sdb)

    You can find the device name by running `dmesg` after inserting your SD card:

        [21302.406801] usb 1-1: new high-speed USB device number 4 using xhci_hcd
        [21303.101935] usb-storage 1-1:1.0: USB Mass Storage device detected
        [21303.102031] scsi host2: usb-storage 1-1:1.0
        [21303.102154] usbcore: registered new interface driver usb-storage
        [21303.103957] usbcore: registered new interface driver uas
        [21304.103865] scsi 2:0:0:0: Direct-Access     SanDisk  Cruzer Glide     1.26 PQ: 0 ANSI: 6
        [21304.105631] sd 2:0:0:0: [sdb] 125031680 512-byte logical blocks: (64.0 GB/59.6 GiB)
        [21304.107659] sd 2:0:0:0: [sdb] Write Protect is off
        [21304.107663] sd 2:0:0:0: [sdb] Mode Sense: 43 00 00 00
        [21304.107942] sd 2:0:0:0: [sdb] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
        [21304.134265]  sdb: sdb1
        [21304.135471] sd 2:0:0:0: [sdb] Attached SCSI disk
        [21350.696145] snd_hda_intel 0000:00:1b.0: IRQ timing workaround is activated for card #1. Suggest a bigger bdl_pos_adj.

- You have an Arch Linux ARM tar.gz file to copy onto the SD card

    You can download the latest Arch Linux ARM files for Raspberry Pi [here](http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz)

- Have a LAN interface up with an ipv6 address

    You can list your interfaces' addresses using the `ip addr show` command

        $ ip addr show
        1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default 
            link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
            inet 127.0.0.1/8 scope host lo
               valid_lft forever preferred_lft forever
            inet6 ::1/128 scope host 
               valid_lft forever preferred_lft forever
        2: wlp2s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
            link/ether 34:02:86:60:e0:55 brd ff:ff:ff:ff:ff:ff
            inet 172.27.5.72/21 brd 172.27.7.255 scope global wlp2s0
               valid_lft forever preferred_lft forever
            inet6 fe80::3602:86ff:fe60:e055/64 scope link 
               valid_lft forever preferred_lft forever
        3: enp0s20u3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
            link/ether 9c:eb:e8:20:49:20 brd ff:ff:ff:ff:ff:ff

    You can bring the LAN interface up with the following command,

        $ sudo ip link set enp0s20u3 up


### Scripted Setup

- You may apply the Arch Linux ARM image by running the `image_sdcard` script.

    image_sdcard --target <device>
    
        -t, --target <device>   specify the device to create the new image on.
                                WARNING: this will be destructive to the device!
    
        -i, --image <?.tar.gz>  specify the Arch Linux RPi image to use.


### Manual Instructions

The `image_sdcard` automates all of the following instructions. These instructions where derived from
[archlinux|ARM website](http://archlinuxarm.org/platforms/armv6/raspberry-pi).

#### Start fdisk to partition the SD card:

Run `fdisk` to create two partitions: the boot partition--512M of type W95 FAT32 (LBA), and the root
partition of type Linux on the rest of the disk.

1. fdisk /dev/sdb

        $ sudo fdisk /dev/sdb 
        
        Welcome to fdisk (util-linux 2.26.2).
        Changes will remain in memory only, until you decide to write them.
        Be careful before using the write command.
        
        
        Command (m for help): o
        Created a new DOS disklabel with disk identifier 0x69f548aa.
        
        Command (m for help): p
        Disk /dev/sdb: 14.9 GiB, 15931539456 bytes, 31116288 sectors
        Units: sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes
        Disklabel type: dos
        Disk identifier: 0x69f548aa
        
        Command (m for help): n
        Partition type
           p   primary (0 primary, 0 extended, 4 free)
           e   extended (container for logical partitions)
        Select (default p): p
        Partition number (1-4, default 1): 1
        First sector (2048-31116287, default 2048): 
        Last sector, +sectors or +size{K,M,G,T,P} (2048-31116287, default 31116287): +512M
        
        Created a new partition 1 of type 'Linux' and of size 512 MiB.
        
        Command (m for help): t
        Selected partition 1
        Partition type (type L to list all types): c
        Changed type of partition 'Linux' to 'W95 FAT32 (LBA)'.
        
        Command (m for help): n
        Partition type
           p   primary (1 primary, 0 extended, 3 free)
           e   extended (container for logical partitions)
        Select (default p): p
        Partition number (2-4, default 2): 2
        First sector (1050624-31116287, default 1050624): 
        Last sector, +sectors or +size{K,M,G,T,P} (1050624-31116287, default 31116287): 
        
        Created a new partition 2 of type 'Linux' and of size 14.3 GiB.
        
        Command (m for help): p
        Disk /dev/sdb: 14.9 GiB, 15931539456 bytes, 31116288 sectors
        Units: sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes
        Disklabel type: dos
        Disk identifier: 0x69f548aa
        
        Device     Boot   Start      End  Sectors  Size Id Type
        /dev/sdb1          2048  1050623  1048576  512M  c W95 FAT32 (LBA)
        /dev/sdb2       1050624 31116287 30065664 14.3G 83 Linux
        
        Command (m for help): w
        The partition table has been altered.
        Calling ioctl() to re-read partition table.
        Syncing disks.

#### Create and Mount the Filesystem:

1. Make the FAT filesystem on the first partition

        $ sudo mkfs.vfat /dev/sdb1 
        mkfs.fat 3.0.28 (2015-05-16)

2. Mount the first partition

        $ mkdir boot
        $ sudo mount /dev/sdb1 boot
        
3. Make the ext4 filesystem on the second partition

        $ sudo mkfs.ext4 /dev/sdb2 
        mke2fs 1.42.12 (29-Aug-2014)
        Creating filesystem with 3758208 4k blocks and 940240 inodes
        Filesystem UUID: 6d9275b2-6a5e-4216-8637-8ec8ac4f1d3d
        Superblock backups stored on blocks: 
        	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208

        Allocating group tables: done                            
        Writing inode tables: done                            
        Creating journal (32768 blocks): done
        Writing superblocks and filesystem accounting information: done   
        
5. Mount the second partition

        $ mkdir root
        $ sudo mount /dev/sdb2 root

#### Extract the root filesystem (as root, not via sudo):

1. Unpack the Arch Linux ARM onto the SD card

        $ sudo bsdtar -xpf ../meshpotato/base_image/ArchLinuxARM-rpi-latest.tar.gz -C root
        $ sync

2. Move the boot files to the proper place

        $ sudo mv root/boot/* boot/

#### Apply Changes

1. Set the hostname for the Pi

        $ echo "mesh-potato-somename" > ./tmp/image/root/etc/hostname

2. Set the pacman mirrorlist to point the host's server

        $ ip addr show
        1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default 
            link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
            inet 127.0.0.1/8 scope host lo
               valid_lft forever preferred_lft forever
            inet6 ::1/128 scope host 
               valid_lft forever preferred_lft forever
        4: enp0s20u3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
            link/ether 9c:eb:e8:20:49:20 brd ff:ff:ff:ff:ff:ff
            inet6 fe80::9eeb:e8ff:fe20:4920/64 scope link 
               valid_lft forever preferred_lft forever

        $ cat << EOF > ./tmp/image/root/etc/pacman.d/mirrorlist
        #
        # Arch Linux ARM repository mirrorlist
        #
         
        ### Local mesh-potato server
        Server = http://[fe80::9eeb:e8ff:fe20:4920%eth0]:8686/\$arch/\$repo
         
        EOF

#### Finishing

1. Unmount the SD card

        $ sudo umount boot root
