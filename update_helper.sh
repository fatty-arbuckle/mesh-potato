if [ -z ${update_image_loaded} ]
then

  update_image_loaded="loaded"
  echo "> loading update_image_loaded.sh"

  source settings.sh

function update_image_fn {
  echo "===> Setting up the image"

  ROOT=$1
  PI_HOSTNAME=$2
  HOST_PUBLIC_KEY=$3

	set_hostname
	#set_pacman_mirrotlist
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
	#create_mosquitto_certificate
  create_node_certificate ${PI_HOSTNAME}

  return 0
}

### ##############################################
###
### setup functions

function test {
    local the_cmd="$@"
    echo "    ---> ${the_cmd}"
    eval "${the_cmd}"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "error with $1" >&2
    fi
    return $status
}

function set_hostname() {
    echo "    ...setting the hostname to ${PI_HOSTNAME}"
    echo ${PI_HOSTNAME} > ${ROOT}/etc/hostname
}

function set_pacman_mirrotlist() {
    eval "ipconfig mesh0"
    local status=$?
    if [ $status -eq 0 ]; then
        HOST_MESH0_IPV6=`ip addr show mesh0 | grep inet6 | awk '{print $2}' | awk -F/ '{print $1}'`
        echo "    ...setting the pacman mirrotlist to ${HOST_MESH0_IPV6}"
        cat << EOF > ${ROOT}/etc/pacman.d/mirrorlist
#
# Arch Linux ARM repository mirrorlist
# Generated on ${ME} mesh-potato script
#

### Local mesh-potato server
Server = http://[${HOST_MESH0_IPV6}%eth0]:8686/\$arch/\$repo

EOF
    fi
}

function create_mesh_network_scripts() {
    echo "    ...creating mesh network setup scripts"
    test mkdir -p ${ROOT}/root/.mesh-potato
    test cp enable_mesh ${ROOT}/root/.mesh-potato/
    test chmod 755 ${ROOT}/root/.mesh-potato/
    test cp mesh-potato.service ${ROOT}/etc/systemd/system/
}

function setup_host_ssh_public_key_access() {
    echo "    ...adding host's SSH public key"
    test mkdir ${ROOT}/root/.ssh
    test cp ${HOST_PUBLIC_KEY} ${ROOT}/root/.ssh/authorized_keys
}

function set_root_password() {
    echo "    ...setting the root password on the Pi"
    local hash=`./new_pw_hash | sed 's/[\\\/&]/\\&/g'`
    sed -i '/^root.*/ c\root:'"${hash}"':16619::::::' ${ROOT}/etc/shadow
}

function copy_required_packages() {
    while read PACKAGE
    do
        if [ ! -f "${OUTPUT_DIR}/packages/`basename ${PACKAGE}`" ]
        then
            echo "    ...downloading ${PACKAGE}"
            wget ${PACKAGE} -P ${OUTPUT_DIR}/packages
            wget ${PACKAGE}.sig -P ${OUTPUT_DIR}/packages
        else
            echo "    ...already have ${PACKAGE}"
        fi
    done < required_packages.txt

    echo "    ...copying the required packages to the Pi"
    test mkdir -p ${ROOT}/root/.mesh-potato/required_packages
    test cp ${OUTPUT_DIR}/packages/* ${ROOT}/root/.mesh-potato/required_packages
}

function setup_first_boot() {
    echo "    ...copying the first_boot script to the Pi"
    test cp first_boot ${ROOT}/root/.mesh-potato/first_boot
    sed -i '/^AVAHI_DOMAIN=.*/ c\AVAHI_DOMAIN='"${AVAHI_DOMAIN}" ${ROOT}/root/.mesh-potato/first_boot
    test cp first_boot.service ${ROOT}/etc/systemd/system/multi-user.target.wants/first_boot.service
    test ln -s ${ROOT}/etc/systemd/system/multi-user.target.wants/first_boot.service ${ROOT}/etc/systemd/system/first_boot.service
}

function update_issue() {
	echo "Arch Linux \r (\l)" > ${ROOT}/etc/issue
	echo "mesh0 \4{mesh0}" >> ${ROOT}/etc/issue
}

function update_motd() {
    echo  > ${ROOT}/etc/motd
    echo "o     o               8         .oPYo.          o           o         " >> ${ROOT}/etc/motd
    echo "8b   d8               8         8    8          8           8         " >> ${ROOT}/etc/motd
    echo "8\`b d'8 .oPYo. .oPYo. 8oPYo.   o8YooP' .oPYo.  o8P .oPYo.  o8P .oPYo. " >> ${ROOT}/etc/motd
    echo "8 \`o' 8 8oooo8 Yb..   8    8    8      8    8   8  .oooo8   8  8    8 " >> ${ROOT}/etc/motd
    echo "8     8 8.       'Yb. 8    8    8      8    8   8  8    8   8  8    8 " >> ${ROOT}/etc/motd
    echo "8     8 \`Yooo' \`YooP' 8    8    8      \`YooP'   8  \`YooP8   8  \`YooP' " >> ${ROOT}/etc/motd
    echo "..::::..:.....::.....:..:::..:::..::::::.....:::..::.....:::..::.....:" >> ${ROOT}/etc/motd
    echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::" >> ${ROOT}/etc/motd
    echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::" >> ${ROOT}/etc/motd
    echo >> ${ROOT}/etc/motd

}

function update_fake_time() {
    echo "    ...setting the (fake) time on the Pi to the current time"
    date "+%Y%m%d%H%M" > ${ROOT}/root/.mesh-potato/.install_time
}

function enable_dhcpcd_ipv4ll() {
    echo "    ...enabling ipv4ll for on the Pi"
    sed -i '/^noipv4ll.*/ c\#noipv4ll' ${ROOT}/etc/dhcpcd.conf
}

function deploy_mosquitto() {
    echo "    ...copying local mosquitto build to the Pi"
    test cp -r mosquitto/* ${ROOT}/
    test mkdir -p ${ROOT}/usr/local/etc/mosquitto
    test cp mesh-potato-mosquitto.conf ${ROOT}/usr/local/etc/mosquitto/mosquitto.conf
    test mkdir -p ${ROOT}/root/.mesh-potato/mosquitto/ssl
    test cp ${mesh_potato_ca_crt} ${ROOT}/root/.mesh-potato/mosquitto/ssl

    echo "    ...creating mosquitto user on the Pi"
    echo "mosquitto:x:225:225:moquitto::/usr/bin/nologin" >> ${ROOT}/etc/passwd
    echo "mosquitto:x:225" >> ${ROOT}/etc/group

    echo "    ...setting LD_LIBARARY_PATH for libmosquitto"
    echo "export LD_LIBRARY_PATH=/usr/local/lib/" >> ${ROOT}/root/.bash_profile
}

function create_mosquitto_certificate() {
    SSL_CERT_COMMON_NAME="${PI_HOSTNAME}.${AVAHI_DOMAIN}"
    echo "    ...creating mosquitto certificates for ${SSL_CERT_COMMON_NAME}"

    PI_KEY=${ROOT}/root/.mesh-potato/mosquitto/ssl/local_key.pem
    PI_CERT=${ROOT}/root/.mesh-potato/mosquitto/ssl/local_cert.pem
    PI_CSR=${OUTPUT_DIR}/requests/${PI_HOSTNAME}_csr.pem

    mkdir -p ${OUTPUT_DIR}/requests

    subject="/C=${SSL_CERT_COUNTRY}/ST=${SSL_CERT_STATE}/L=${SSL_CERT_LOCATION}/O=${SSL_CERT_ORG}/OU=${SSL_CERT_ORG_UNIT}/CN=${SSL_CERT_COMMON_NAME}"
    openssl req -nodes -newkey rsa:2048 -keyout ${PI_KEY} -out ${PI_CSR} -subj "${subject}"
    openssl x509 -req -days 365 -in ${PI_CSR} -CA ${mesh_potato_ca_crt} -CAkey ${mesh_potato_ca_key} -set_serial 00001 -out ${PI_CERT}
    test openssl x509 -in ${PI_CERT} -noout -text
}

fi
