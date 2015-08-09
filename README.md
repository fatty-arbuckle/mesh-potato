# mesh-potato
A Raspberry Pi mesh network built on Arch Linux.

### Assumptions

- Your running Arch Linux.
- Using a Raspberry Pi B+

### Applying the Base Image

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
        Type n, then p for primary, 1 for the first partition on the drive, press ENTER to accept the default first sector, then type +100M for the last sector.
        Type t, then c to set the first partition to type W95 FAT32 (LBA).
        Type n, then p for primary, 2 for the second partition on the drive, and then press ENTER twice to accept the default first and last sector.
        Write the partition table and exit by typing w.

3. Create and mount the FAT filesystem:

        mkfs.vfat /dev/sdX1
        mkdir boot
        mount /dev/sdX1 boot

4. Create and mount the ext4 filesystem:

        mkfs.ext4 /dev/sdX2
        mkdir root
        mount /dev/sdX2 root

5. Download and extract the root filesystem (as root, not via sudo):

        wget http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
        bsdtar -xpf ArchLinuxARM-rpi-latest.tar.gz -C root
        sync

6. Move boot files to the first partition:

        mv root/boot/* boot

7. Unmount the two partitions:

        umount boot root


### Booting the Pi

1. Insert the SD card into the Pi, connect ethernet, and apply 5V power.

2. Find the link local address of the Pi

        ping6 ff00::01%eth0
        PING ff02::01%enp0s20u3(ff02::1) 56 data bytes
        64 bytes from fe80::9eeb:e8ff:fe20:4920: icmp_seq=1 ttl=64 time=0.038 ms
        64 bytes from fe80::ba27:ebff:fe19:db4: icmp_seq=1 ttl=64 time=0.865 ms (DUP!)
        64 bytes from fe80::9eeb:e8ff:fe20:4920: icmp_seq=2 ttl=64 time=0.031 ms
        64 bytes from fe80::ba27:ebff:fe19:db4: icmp_seq=2 ttl=64 time=0.711 ms (DUP!)

3. SSH to the IP address found above. The default root password is 'root'.

        ssh -6 root@fe80::ba27:ebff:fe19:db4%enp0s20u3
        root@fe80::ba27:ebff:fe19:db4%enp0s20u3's password: 
        Welcome to Arch Linux ARM
        
             Website: http://archlinuxarm.org
               Forum: http://archlinuxarm.org/forum
                 IRC: #archlinux-arm on irc.Freenode.net
       
        [root@alarmpi ~]# 

### Setting Up the Mesh Network

1. `iw dev wlan0 interface add mesh0 type mp`

2. `ifconfig mesh0 up`

3. `iw dev mesh0 join meshpotato`

