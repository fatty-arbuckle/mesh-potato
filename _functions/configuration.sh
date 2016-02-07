#!/usr/bin/env bash

### Configuration
#####################################################################

OUTPUT_DIR=./output

SSL_CA_C=CA
SSL_CA_ST=Yukon
SSL_CA_L=Mesh-Potato
SSL_CA_CN=ca.mesh-potato
SSL_CA_DAYS=3650

AVAHI_DOMAIN='local'

### DO NOT EDIT BELOW HERE
#####################################################################

PROJECT_FILES=./_files

# Environment variables and their defaults
LOG_LEVEL="${LOG_LEVEL:-6}" # 7 = debug -> 0 = emergency

# Commandline options. This defines the usage page, and is used to parse cli
# opts & defaults from. The parsing is unforgiving so be precise in your syntax
read -r -d '' usage <<-'EOF'
  -t    [arg] Specify the device to create the new image on.  Required."
  -i    [arg] Specify the Arch Linux RPi image to use."
  -h    [arg] Specify the host name of the new node."
  -p    [arg] Specify public SSH key to use to connect to the Pi."
  -c    [arg] Specify the certificate authority to use when creating MQTT certificates."
  -k    [arg] Specify the key that goes with the CA certificate (see -ca above)"
  -y          Automatically answer yes to all prompts.  (Do not prompt for questions.)"
EOF
