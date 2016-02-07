function set_hostname() {
  info "setting the hostname to ${HOSTNAME}"
  echo ${HOSTNAME} > ${IMAGE_ROOT}/root/etc/hostname
}

function create_mesh_network_scripts() {
  info "creating mesh network setup scripts"
  mkdir -p ${IMAGE_ROOT}/root/root/.mesh-potato
  cp ${PROJECT_FILES}/enable_mesh ${IMAGE_ROOT}/root/root/.mesh-potato/
  chmod 755 ${IMAGE_ROOT}/root/root/.mesh-potato/
  cp ${PROJECT_FILES}/mesh-potato.service ${IMAGE_ROOT}/root/etc/systemd/system/
}

function setup_host_ssh_public_key_access() {
    info "adding host's SSH public key"
    mkdir ${IMAGE_ROOT}/root/root/.ssh
    cp ${SSH_KEY} ${IMAGE_ROOT}/root/root/.ssh/authorized_keys
}

function set_root_password() {
    info "setting the root password"
    local hash=`${PROJECT_FILES}/new_pw_hash | sed 's/[\\\/&]/\\&/g'`
    sed -i '/^root.*/ c\root:'"${hash}"':16619::::::' ${IMAGE_ROOT}/root/etc/shadow
}

function copy_required_packages() {
  info "copying the required packages to ${TARGET}"

  local package_dir=${OUTPUT_DIR}/downloads/packages
  mkdir -p ${IMAGE_ROOT}/root/root/.mesh-potato/required_packages
  cp ${package_dir}/* ${IMAGE_ROOT}/root/root/.mesh-potato/required_packages
}

function setup_first_boot() {
  info "copying the first_boot script to ${TARGET}"
  cp ${PROJECT_FILES}/first_boot ${IMAGE_ROOT}/root/root/.mesh-potato/first_boot
  sed -i '/^AVAHI_DOMAIN=.*/ c\AVAHI_DOMAIN='"${AVAHI_DOMAIN}" ${IMAGE_ROOT}/root/root/.mesh-potato/first_boot
  cp ${PROJECT_FILES}/first_boot.service ${IMAGE_ROOT}/root/etc/systemd/system/multi-user.target.wants/first_boot.service
  ln -s ${IMAGE_ROOT}/root/etc/systemd/system/multi-user.target.wants/first_boot.service ${IMAGE_ROOT}/root/etc/systemd/system/first_boot.service
}

function update_issue() {
  info "updating the issue string to include include the mesh0 address"
	echo "Arch Linux \r (\l)" > ${IMAGE_ROOT}/root/etc/issue
	echo "mesh0 \4{mesh0}" >> ${IMAGE_ROOT}/root/etc/issue
}

function update_motd() {
  info "updating the motd"
    echo  > ${IMAGE_ROOT}/root/etc/motd
    echo "o     o               8         .oPYo.          o           o         " >> ${IMAGE_ROOT}/root/etc/motd
    echo "8b   d8               8         8    8          8           8         " >> ${IMAGE_ROOT}/root/etc/motd
    echo "8\`b d'8 .oPYo. .oPYo. 8oPYo.   o8YooP' .oPYo.  o8P .oPYo.  o8P .oPYo. " >> ${IMAGE_ROOT}/root/etc/motd
    echo "8 \`o' 8 8oooo8 Yb..   8    8    8      8    8   8  .oooo8   8  8    8 " >> ${IMAGE_ROOT}/root/etc/motd
    echo "8     8 8.       'Yb. 8    8    8      8    8   8  8    8   8  8    8 " >> ${IMAGE_ROOT}/root/etc/motd
    echo "8     8 \`Yooo' \`YooP' 8    8    8      \`YooP'   8  \`YooP8   8  \`YooP' " >> ${IMAGE_ROOT}/root/etc/motd
    echo "..::::..:.....::.....:..:::..:::..::::::.....:::..::.....:::..::.....:" >> ${IMAGE_ROOT}/root/etc/motd
    echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::" >> ${IMAGE_ROOT}/root/etc/motd
    echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::" >> ${IMAGE_ROOT}/root/etc/motd
    echo >> ${IMAGE_ROOT}/root/etc/motd
}

function update_fake_time() {
    info "setting the (fake) system time to the current time"
    date "+%Y%m%d%H%M" --utc > ${IMAGE_ROOT}/root/root/.mesh-potato/.install_time
}

function enable_dhcpcd_ipv4ll() {
    info "enabling ipv4ll"
    sed -i '/^noipv4ll.*/ c\#noipv4ll' ${IMAGE_ROOT}/root/etc/dhcpcd.conf
}

function deploy_mosquitto() {
    info "copying local mosquitto build to the Pi"

    mkdir -p ${IMAGE_ROOT}/root/root/.mesh-potato/required_packages
    cp ${PROJECT_FILES}/local-packages/* ${IMAGE_ROOT}/root/root/.mesh-potato/required_packages

    mkdir -p ${IMAGE_ROOT}/root/root/.mesh-potato/mosquitto
    cp ${PROJECT_FILES}/mosquitto.conf ${IMAGE_ROOT}/root/root/.mesh-potato/mosquitto/mosquitto.conf
    mkdir -p ${IMAGE_ROOT}/root/root/.mesh-potato/mosquitto/ssl
    cp ${mesh_potato_ca_crt} ${IMAGE_ROOT}/root/root/.mesh-potato/mosquitto/ssl

    info "creating mosquitto user on the Pi"
    echo "mosquitto:x:225:225:moquitto::/usr/bin/nologin" >> ${IMAGE_ROOT}/root/etc/passwd
    echo "mosquitto:x:225" >> ${IMAGE_ROOT}/root/etc/group

    #info "setting LD_LIBARARY_PATH for libmosquitto"
    #echo "export LD_LIBRARY_PATH=/usr/local/lib/" >> ${IMAGE_ROOT}//root/.bash_profile
}

function create_node_certificate() {
    echo "creating mosquitto certificates for ${HOSTNAME}"

    local key=${IMAGE_ROOT}/root/root/.mesh-potato/mosquitto/ssl/${HOSTNAME}.key
    local crt=${IMAGE_ROOT}/root/root/.mesh-potato/mosquitto/ssl/${HOSTNAME}.crt
    local csr=${OUTPUT_DIR}/authority/requests/${HOSTNAME}.csr

    mkdir -p ${OUTPUT_DIR}/authority/requests

    openssl genrsa \
              -out ${key} \
              1024

    ## TODO fix this decl
    local SUBJ=/C=US/ST=Massachusetts/L=Server/CN=${HOSTNAME}.local
    openssl req \
              -out ${csr} \
              -key ${key} \
              -subj ${SUBJ} \
              -new

    openssl x509 \
              -req \
              -in ${csr} \
              -CA ${mesh_potato_ca_crt} \
              -CAkey ${mesh_potato_ca_key} \
              -CAcreateserial \
              -CAserial ${OUTPUT_DIR}/authority/serial \
              -out ${crt} \
              -days 3650

    openssl x509 -in ${crt} -noout -text

    echo "certfile /root/.mesh-potato/mosquitto/ssl/${HOSTNAME}.crt" >> ${IMAGE_ROOT}/root/root/.mesh-potato/mosquitto/mosquitto.conf
    echo "keyfile /root/.mesh-potato/mosquitto/ssl/${HOSTNAME}.key" >> ${IMAGE_ROOT}/root/root/.mesh-potato/mosquitto/mosquitto.conf


    mkdir -p ${OUTPUT_DIR}/authority/requests/copies
    cp ${key} ${OUTPUT_DIR}/authority/requests/copies
    cp ${crt} ${OUTPUT_DIR}/authority/requests/copies
  }
