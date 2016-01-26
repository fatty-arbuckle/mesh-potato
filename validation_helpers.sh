if [ -z ${validation_loaded} ]
then

  validation_loaded="loaded"
  echo "> loading validation_helpers.sh"



  function validate_root_privilege() {
    if [ "$EUID" -ne 0 ]
    then
      echo
      echo "*** Please run ${ME} as root"
      echo

      return 1
    fi

    return 0
  }



  function validate_target() {
    if [ -z "${1}" ]
    then
        echo
        echo "*** The --target option cannot be empty"
        help
        return 1
    fi

    if [ ! -b "${1}" ]
    then
        echo
        echo "*** '${1}' must be a block device"
        echo
        return 1
    fi

    return 0
  }



  function validate_base_image() {
    if [ -z "${1}" ]
    then
        BASE_IMAGE=${OUTPUT_DIR}/downloads/ArchLinuxARM-rpi-latest.tar.gz
        if [ ! -f ${BASE_IMAGE} ]
        then
            echo "===> Downloading latest Arch Linux ARM image"
            mkdir -p ${OUTPUT_DIR}/downloads
            wget http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz -O ${BASE_IMAGE}
        fi
    fi

    if [ ! -f "${BASE_IMAGE}" ]
    then
        echo
        echo "*** '${BASE_IMAGE}' must exist and be a valid file"
        echo
        return 1
    fi

    return 0
  }



  function validate_hostname() {
    if [ -z "$1" ]
    then
      RANDHOSTSTRING=`< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-8}`
      PI_HOSTNAME="mesh-potato-${RANDHOSTSTRING}"
    fi
    return 0
  }

fi
