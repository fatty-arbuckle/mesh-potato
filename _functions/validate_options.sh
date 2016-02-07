#!/usr/bin/env bash

source ${__dir}/_functions/configuration.sh

function validate_root_privilege() {
  [ "$EUID" -ne 0 ]     && emergency "Must be run with root privilege"
}

function validate_target() {
  [ -z "${arg_t}" ]     && help      "Setting a target with -target is required"
  [ ! -b "${arg_t}" ]   && help      "'${arg_t}' must be a block device"
}

function validate_hostname() {
  if [ -z "${arg_h}" ]
    then
    RANDHOSTSTRING=`< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-8}`
    arg_h="mesh-potato-${RANDHOSTSTRING}"
    info "Setting hostname to ${arg_h}"
  fi
}

function validate_image() {
  if [ -z "${arg_i}" ]
    then
    downloaded_image=${OUTPUT_DIR}/downloads/ArchLinuxARM-rpi-latest.tar.gz
    if [ ! -f ${downloaded_image} ]
    then
        info "Downloading latest Arch Linux ARM image to ${downloaded_image}"
        mkdir -p ${OUTPUT_DIR}/downloads
        wget http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz -O ${downloaded_image}
    fi
    arg_i=${downloaded_image}
  fi

  [ ! -f "${arg_i}" ]    && emergency "'${arg_i}' must exist and be a valid file"
}

function validate_ssh_key() {
  if [ ! -f "${arg_p}" ]
    then
    ssh_key=${OUTPUT_DIR}/ssh/host_id.pub
    if [ ! -f "${ssh_key}" ]
      then
      info "Creating SSH identity accessing nodes in ${ssh_key}"
      mkdir -p ${OUTPUT_DIR}/ssh
      ssh-keygen -b 2048 -N "" -C "mesh-potato host access" -f ${OUTPUT_DIR}/ssh/host_id
    fi
    arg_p=${ssh_key}
  fi

  [ ! -f "${arg_p}" ]    && emergency "'${arg_p}' must exist and be a valid file"
}

function validate_certificate_authority {
  if [ ! -f "${arg_c}" ] || [ ! -f "${arg_k}" ]
    then
    mesh_potato_ca_key=${OUTPUT_DIR}/authority/mesh-potato-ca.key
    mesh_potato_ca_crt=${OUTPUT_DIR}/authority/mesh-potato-ca.crt
    if [ ! -f ${mesh_potato_ca_key} ] && [ ! -f ${mesh_potato_ca_crt} ]
      then
      mkdir -p `dirname ${mesh_potato_ca_key}`

      info "Creating certificate authority in ${mesh_potato_ca_crt}"

      local SUBJ=/C=${SSL_CA_C}/ST=${SSL_CA_ST}/L=${SSL_CA_L}/CN=${SSL_CA_CN}
      openssl req \
                -nodes \
                -new \
                -x509 \
                -subj ${SUBJ} \
                -days SSL_CA_DAYS \
                -keyout ${mesh_potato_ca_key} \
                -out ${mesh_potato_ca_crt}

      openssl x509 -in ${mesh_potato_ca_crt} -noout -text
    fi
    arg_k=${mesh_potato_ca_key}
    arg_c=${mesh_potato_ca_crt}
  fi

  [ ! -f "${arg_c}" ]    && emergency "'${arg_c}' must exist and be a valid file"
  [ ! -f "${arg_k}" ]    && emergency "'${arg_k}' must exist and be a valid file"
}

function validate_required_packages() {
  local package_dir=${OUTPUT_DIR}/downloads/packages
  while read PACKAGE
  do
    if [ ! -f "${package_dir}/`basename ${PACKAGE}`" ]
    then
      info "downloading ${PACKAGE}"
      wget ${PACKAGE} -P ${package_dir}
      wget ${PACKAGE}.sig -P ${package_dir}
    else
      info "already have ${PACKAGE}"
    fi
  done < ${PROJECT_FILES}/required_packages.txt
}

function validate_options {
  [ -z "${LOG_LEVEL}" ] && emergency "Cannot continue without LOG_LEVEL. "
  validate_root_privilege
  validate_target
  validate_hostname
  validate_image
  validate_ssh_key
  validate_certificate_authority
  validate_required_packages
}
