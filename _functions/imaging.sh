function unmount() {
  info "Attempting to unmount '${TARGET}'"
  umount ${IMAGE_ROOT}/root ${IMAGE_ROOT}/boot || true
}

function partion_disk() {
  info "Partitioning the disk"

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
}

function create_filesystem() {
  info "Making the filesystems on '${TARGET}'"

  local target_boot=${TARGET}1
  local target_root=${TARGET}2

  mkfs.vfat ${target_boot}
  mkdir -p ${IMAGE_ROOT}/boot
  mount ${target_boot} ${IMAGE_ROOT}/boot

  echo "y" | mkfs.ext4 -q ${target_root}
  mkdir -p ${IMAGE_ROOT}/root
  mount ${target_root} ${IMAGE_ROOT}/root
}

function copy_image_to_disk() {
  info "Copying '${IMAGE}' to '${TARGET}'"

  bsdtar -xpf ${IMAGE} -C ${IMAGE_ROOT}/root
  sync

  mv ${IMAGE_ROOT}/root/boot/* ${IMAGE_ROOT}/boot/
}
