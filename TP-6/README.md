# TP6 : Stockage et sauvegarde

## Partie 1 : Préparation de la machine `backup.tp6.linux`

### I. Ajout de disque

**🌞 Ajouter un disque dur de 5Go à la VM `backup.tp6.linux`**

```bash
[tomfox@backup ~]$ lsblk | grep sdb
sdb           8:16   0    5G  0 disk
```

### II. Partitioning

**🌞 Partitionner le disque à l'aide de LVM**

```bash
[tomfox@backup ~]$ sudo pvcreate /dev/sdb
[sudo] password for tomfox: 
  Physical volume "/dev/sdb" successfully created.
[tomfox@backup ~]$ sudo pvs
  PV         VG Fmt  Attr PSize  PFree
  /dev/sda2  rl lvm2 a--  <7.00g    0 
  /dev/sdb      lvm2 ---   5.00g 5.00g
[tomfox@backup ~]$ sudo pvdisplay  
[...]
  "/dev/sdb" is a new physical volume of "5.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb
  VG Name               
  PV Size               5.00 GiB
  Allocatable           NO
  PE Size               0   
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               MVjIIR-pWYt-hx9c-qCNf-7Jav-ossn-xYHZtK
[tomfox@backup ~]$ sudo vgcreate backup /dev/sdb
  Volume group "backup" successfully created
[tomfox@backup ~]$ sudo lvcreate -l 100%FREE backup -n lv_backup
  Logical volume "lv_backup" created.
[tomfox@backup ~]$ sudo lvdisplay
  --- Logical volume ---
  LV Path                /dev/backup/lv_backup
  LV Name                lv_backup
  VG Name                backup
  LV UUID                Sd3fhf-B7if-2iKk-dfRs-CGDS-9Aa1-B4p61T
  LV Write Access        read/write
  LV Creation host, time backup.tp6.linux, 2021-11-30 11:17:04 +0100
  LV Status              available
  # open                 0
  LV Size                <5.00 GiB
  Current LE             1279
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:2
```

**🌞 Formater la partition**

```bash
[tomfox@backup ~]$ sudo mkfs -t ext4 /dev/backup/lv_backup
mke2fs 1.45.6 (20-Mar-2020)
Creating filesystem with 1309696 4k blocks and 327680 inodes
Filesystem UUID: 71423fc2-8249-457b-ba84-64560341c062
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done 
```

**🌞 Monter la partition**

```bash
[tomfox@backup ~]$ sudo mkdir /mnt/backup
[tomfox@backup ~]$ sudo mount /dev/backup/lv_backup /mnt/backup
[tomfox@backup ~]$ df -h | grep backup
/dev/mapper/backup-lv_backup  4.9G   20M  4.6G   1% /mnt/backup
```



