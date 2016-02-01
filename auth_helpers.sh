if [ -z ${auth_loaded} ]
then

  auth_loaded="loaded"
  echo "> loading auth_loaded.sh"

  source settings.sh
  unset OPENSSL_CONF

  function validate_ssh_host_key() {
    if [ ! -f "${1}" ]
    then
        HOST_PUBLIC_KEY=${SSH_ID_DIR}/host_id.pub
        if [ ! -f "$HOST_PUBLIC_KEY" ]
        then
            echo "===> Creating SSH key for accessing Pi"
            mkdir -p ${SSH_ID_DIR}
            ssh-keygen -b 2048 -N "" -C "mesh-potato host access" -f ${SSH_ID_DIR}/host_id
        fi
    fi
  }

  function validate_certificate_authority {
    if [ ! -f "${1}" ] || [ ! -f "${2}" ]
    then
      echo "===> using mesh-potato certificate authority"
      mesh_potato_ca_key=${MQTT_CA_DIR}/mesh-potato-ca.key
      mesh_potato_ca_crt=${MQTT_CA_DIR}/mesh-potato-ca.crt
    fi

    if [ ! -f ${mesh_potato_ca_key} ] && [ ! -f ${mesh_potato_ca_crt} ]
    then
      mkdir -p `dirname ${mesh_potato_ca_key}`

      #subject="/C=${SSL_CERT_COUNTRY}/ST=${SSL_CERT_STATE}/L=${SSL_CERT_LOCATION}/O=${SSL_CERT_ORG}/OU=${SSL_CERT_ORG_UNIT}/CN=${SSL_CERT_COMMON_NAME}"

      local SUBJ=/C=CA/ST=Yukon/L=Mesh-Potato/CN=ca.mesh.potato
      openssl req \
                -nodes \
                -new \
                -x509 \
                -subj ${SUBJ} \
                -days 3650 \
                -keyout ${mesh_potato_ca_key} \
                -out ${mesh_potato_ca_crt}

      openssl x509 -in ${mesh_potato_ca_crt} -noout -text
      ## TODO proper error handling
    fi
    return 0
  }

  function remove_certificate_authority() {
    rm -f ${mesh_potato_ca_crt}
    rm -f ${mesh_potato_ca_key}
  }









  function create_node_certificate() {
    echo "    ...creating mosquitto certificates for ${1}"

    local key=${ROOT}/root/.mesh-potato/mosquitto/ssl/${1}.key
    local crt=${ROOT}/root/.mesh-potato/mosquitto/ssl/${1}.crt
    local csr=${OUTPUT_DIR}/requests/${1}.csr

    mkdir -p ${OUTPUT_DIR}/requests

    openssl genrsa \
              -out ${key} \
              1024

    ## TODO fix this decl
    local SUBJ=/C=US/ST=Massachusetts/L=Server/CN=${1}.local
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
              -out ${crt} \
              -days 3650

    test openssl x509 -in ${crt} -noout -text

    mkdir -p ${OUTPUT_DIR}/requests/copies
    test cp ${key} ${OUTPUT_DIR}/requests/copies
    test cp ${crt} ${OUTPUT_DIR}/requests/copies
  }

  #create_certificate_authority
  #node_name=arbuckle
  #create_node_certificate ${node_name}

  #cat > mosquitto.conf << MOSQUITTO_CONF
  #bind_address ${node_name}
  #port 8883
  #cafile ${mesh_potato_ca_crt}
  #certfile ${node_name}.crt
  #keyfile ${node_name}.key
  #tls_version tlsv1
  #MOSQUITTO_CONF

  #echo
  #echo
  #echo "The server can be run with"
  #echo "    mosquitto -c mosquitto.conf"
  #echo
  #echo "The client with"
  #echo "    mosquitto_sub -h ${node_name} -p 8883 --cafile ${mesh_potato_ca_crt} --tls-version tlsv1 -d -t \\\$SYS/#"
  #echo
fi
