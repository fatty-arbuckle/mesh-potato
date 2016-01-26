if [ -z ${imaging_loaded} ]
then

  imaging_loaded="loaded"
  echo "> loading imaging_loaded.sh"

  source settings.sh


  function unmount() {
    echo "===> Attempting to unmount '${TARGET}'"
    umount ${IMAGE_ROOT}/root ${IMAGE_ROOT}/boot
    return $?
  }

  function partion_disk() {
    echo "===> Partitioning the disk"

    echo "o
n
p
1

+512M
t
c
n
p
2


p
w
" | fdisk ${TARGET}
    return $?
  }

  function create_filesystem() {
    echo "===> Making the filesystems on '${TARGET}'"

    test mkfs.vfat ${TARGET_BOOT}
    test mkdir -p ${IMAGE_ROOT}/boot
    test mount ${TARGET_BOOT} ${IMAGE_ROOT}/boot

    echo "y" | test mkfs.ext4 -q ${TARGET_ROOT}
    test mkdir -p ${IMAGE_ROOT}/root
    test mount ${TARGET_ROOT} ${IMAGE_ROOT}/root
    return $?
  }

  function copy_image_to_disk() {
    echo "===> Copying '${BASE_IMAGE}' to '${TARGET}'"

    test bsdtar -xpf ${BASE_IMAGE} -C ${IMAGE_ROOT}/root
    test sync

    test mv ${IMAGE_ROOT}/root/boot/* ${IMAGE_ROOT}/boot/
    return $?
  }

fi
