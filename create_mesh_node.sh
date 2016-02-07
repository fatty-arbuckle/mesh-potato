#!/usr/bin/env bash

source _functions/configuration.sh

### Set up functions
#####################################################################

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"

source ${__dir}/_functions/format.sh
source ${__dir}/_functions/help.sh
source ${__dir}/_functions/logging.sh
source ${__dir}/_functions/parse_cmdline.sh
source ${__dir}/_functions/validate_options.sh
source ${__dir}/_functions/imaging.sh
source ${__dir}/_functions/image_config.sh

function cleanup_before_exit () {
  unmount
  info "Cleaning up. Done"
}

trap cleanup_before_exit EXIT

### Command line processing
#####################################################################

parse_cmdline "$@"
validate_options

# Exit on error. Append ||true if you expect an error.
set -o errexit
set -o nounset
set -o pipefail

### Runtime
#####################################################################

TARGET=${arg_t}
HOSTNAME=${arg_h}
IMAGE=${arg_i}
SSH_KEY=${arg_p}
CA_CRT=${arg_c}
CA_KEY=${arg_k}
IMAGE_ROOT=${OUTPUT_DIR}/mnt/image

if [ "${arg_y}" != "1" ]
  then

  echo
  echo "!!! ERASING ALL DATA ON ${TARGET} !!!"
  echo

  while true; do
      read -p "Do you wish erase all of the data on ${TARGET}? " yn
      case $yn in
          [Yy]* )
              break
              ;;
          [Nn]* )
              info "Did not want to erase ${TARGET}. Exitting..."
              exit
              ;;
          * )
              echo "Please answer yes or no."
              ;;
      esac
  done
fi

notice "        TARGET:  ${TARGET}"
notice "      HOSTNAME:  ${HOSTNAME}"
notice "         IMAGE:  ${IMAGE}"
notice "SSH_PUBLIC_KEY:  ${SSH_KEY}"
notice "        CA_KEY:  ${CA_KEY}"
notice "        CA_CRT:  ${CA_CRT}"

notice "    IMAGE_ROOT:  ${IMAGE_ROOT}"

unmount

info "Creating base image"

partion_disk
create_filesystem
copy_image_to_disk

info "Configuring the image"

ROOT=$1
PI_HOSTNAME=$2
HOST_PUBLIC_KEY=$3

set_hostname
create_mesh_network_scripts
setup_host_ssh_public_key_access
set_root_password
copy_required_packages
setup_first_boot
update_issue
update_motd
update_fake_time
enable_dhcpcd_ipv4ll
deploy_mosquitto
create_node_certificate

#unmount

info "Done.  You may remove '${TARGET}'"
