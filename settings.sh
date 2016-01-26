
if [ -z ${settings_loaded} ]
then

settings_loaded="loaded"
echo "> loading settings.sh"


OUTPUT_DIR=./target

## Domain to use for the local network
export AVAHI_DOMAIN='local'

### Certificate settings
#export SSL_CERT_COUNTRY='US'
#export SSL_CERT_STATE='ID'
#export SSL_CERT_LOCATION='Boise'
#export SSL_CERT_ORG='Roscoe Potato Farm'
#export SSL_CERT_ORG_UNIT='Mesh-Potato'
#export SSL_CERT_COMMON_NAME="root.${AVAHI_DOMAIN}"

SSH_ID_DIR=${OUTPUT_DIR}/access
MQTT_CA_DIR=${OUTPUT_DIR}/mqtt

mesh_potato_ca_key=${MQTT_CA_DIR}/mesh-potato-ca.key
mesh_potato_ca_crt=${MQTT_CA_DIR}/mesh-potato-ca.crt

fi
