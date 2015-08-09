
### Applying the Base Image

#### Assumptions

- Your running Arch Linux on the host
- Using a Raspberry Pi B+

#### Scripted Setup

#### Manual Instructions

These instructions where derived from [archlinux|ARM website}(http://archlinuxarm.org/platforms/armv6/raspberry-pi).

1. Insert the SD Card and run `dmesg` to find the device name for the SD card,

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

2. Start fdisk to partition the SD card:

        fdisk /dev/sdX
        At the fdisk prompt, delete old partitions and create a new one:
        Type o. This will clear out any partitions on the drive.
        Type p to list partitions. There should be no partitions left.
        Type n, then p for primary, 1 for the first partition on the drive, press ENTER to accept the default first sector, then type +512M for the last sector.
        Type t, then c to set the first partition to type W95 FAT32 (LBA).
        Type n, then p for primary, 2 for the second partition on the drive, and then press ENTER twice to accept the default first and last sector.
        Write the partition table and exit by typing w.

        [phatty@arbuckle mesh-potato]$ sudo fdisk /dev/sdb 
        
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
        
        [phatty@arbuckle mesh-potato]$

3. Create and mount the FAT filesystem:

        mkfs.vfat /dev/sdX1
        mkdir boot
        mount /dev/sdX1 boot


        [phatty@arbuckle mesh-potato]$ sudo mkfs.vfat /dev/sdb1 
        mkfs.fat 3.0.28 (2015-05-16)
        [phatty@arbuckle mesh-potato]$ mkdir boot
        [phatty@arbuckle mesh-potato]$ sudo mount /de
        [phatty@arbuckle mesh-potato]$ sudo mount /dev/sdb1 boot
        [phatty@arbuckle mesh-potato]$ 
        


4. Create and mount the ext4 filesystem:

        mkfs.ext4 /dev/sdX2
        mkdir root
        mount /dev/sdX2 root

        [phatty@arbuckle mesh-potato]$ sudo mkfs.ext4 /dev/sdb2 
        mke2fs 1.42.12 (29-Aug-2014)
        Creating filesystem with 3758208 4k blocks and 940240 inodes
        Filesystem UUID: 6d9275b2-6a5e-4216-8637-8ec8ac4f1d3d
        Superblock backups stored on blocks: 
        	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208

        Allocating group tables: done                            
        Writing inode tables: done                            
        Creating journal (32768 blocks): done
        Writing superblocks and filesystem accounting information: done   
        
        
        [phatty@arbuckle mesh-potato]$ mkdir root
        [phatty@arbuckle mesh-potato]$ sudo mount /dev/sdb2 root


5. Download and extract the root filesystem (as root, not via sudo):

        wget http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
        bsdtar -xpf ArchLinuxARM-rpi-latest.tar.gz -C root
        sync

        [phatty@arbuckle mesh-potato]$ sudo bsdtar -xpf ../meshpotato/base_image/ArchLinuxARM-rpi-latest.tar.gz -C root
        [phatty@arbuckle mesh-potato]$ sync
        [phatty@arbuckle mesh-potato]$


6. Move boot files to the first partition:

        mv root/boot/* boot

        [phatty@arbuckle mesh-potato]$ sudo mv root/boot/* boot/

7. Unmount the two partitions:

        umount boot root

        [phatty@arbuckle mesh-potato]$ sudo umount boot root
        [phatty@arbuckle mesh-potato]$ 
