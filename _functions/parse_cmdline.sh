#!/usr/bin/env bash

source ${__dir}/_functions/configuration.sh

function parse_cmdline {

  # Translate usage string -> getopts arguments, and set $arg_<flag> defaults
  while read line; do
    opt="$(echo "${line}" |awk '{print $1}' |sed -e 's#^-##')"

    if ! echo "${line}" |egrep '\[.*\]' >/dev/null 2>&1; then
      init="0" # it's a flag. init with 0
    else
      opt="${opt}:" # add : if opt has arg
      init=""  # it has an arg. init with ""
    fi
    opts="${opts}${opt}"

    varname="arg_${opt:0:1}"
    if ! echo "${line}" |egrep '\. Default=' >/dev/null 2>&1; then
      eval "${varname}=\"${init}\""
    else
      match="$(echo "${line}" |sed 's#^.*Default=\(\)#\1#g')"
      eval "${varname}=\"${match}\""
    fi
  done <<< "${usage}"

  # Reset in case getopts has been used previously in the shell.
  OPTIND=1

  # Overwrite $arg_<flag> defaults with the actual CLI options
  while getopts "${opts}" opt; do
    line="$(echo "${usage}" |grep "\-${opt}")"

    [ "${opt}" = "?" ] && help "Invalid use of script: ${@} "
    varname="arg_${opt:0:1}"
    default="${!varname}"

    value="${OPTARG}"
    if [ -z "${OPTARG}" ] && [ "${default}" = "0" ]; then
      value="1"
    fi

    eval "${varname}=\"${value}\""
    debug "cli arg ${varname} = ($default) -> ${!varname}"
  done

  shift $((OPTIND-1))

  [ "$1" = "--" ] && shift

  # debug mode
  if [ "${arg_d}" = "1" ]; then
    set -o xtrace
    LOG_LEVEL="7"
  fi

  # help mode
  if [ "${arg_h}" = "1" ]; then
    # Help exists with code 1
    help "Help using ${0}"
  fi
}
