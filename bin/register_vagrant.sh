#!/usr/bin/env bash
set -o nounset # Treat unset variables as an error and immediately exit
set -o errexit # If a command fails exit the whole script

if [ "${DEBUG:-false}" = "true" ]; then
  set -x # Run the entire script in debug mode
fi

usage() {
    echo "usage: $(basename $0) <box_name> <box_suffix> <version>"
    echo
    echo "Requires the following environment variables to be set:"
    echo "  VAGRANT_ORG"
}

args() {
    if [ $# -lt 3 ]; then
        usage
        exit 1
    fi

    BOX_NAME=$1
    BOX_SUFFIX=$2
    VERSION=$3
}

get_short_description() {
    if [[ "${BOX_NAME}" =~ i386 ]]; then
        BIT_STRING="32-bit"
    else
        BIT_STRING="64-bit"
    fi
    DOCKER_STRING=
    if [[ "${BOX_NAME}" =~ docker ]]; then
        DOCKER_STRING=" with Docker preinstalled"
    fi
    EDITION_STRING=
    if [[ "${BOX_NAME}" =~ desktop ]]; then
        EDITION_STRING=" Desktop"
    else
        EDITION_STRING=" Server"
    fi
    RAW_VERSION=${BOX_NAME#tkl}
    RAW_VERSION=${RAW_VERSION%-i386}
    RAW_VERSION=${RAW_VERSION%-docker}
    RAW_VERSION=${RAW_VERSION%-desktop}
    PRETTY_VERSION=${RAW_VERSION:0:2}.${RAW_VERSION:2}

    VIRTUALBOX_VERSION=$(virtualbox --help | head -n 1 | awk '{print $NF}')
    PARALLELS_VERSION=$(prlctl --version | awk '{print $3}')
    VMWARE_VERSION=10.0.5
    SHORT_DESCRIPTION="Turnkey Linux ${PRETTY_VERSION} (${BIT_STRING})${DOCKER_STRING}"
}

create_description() {
    if [[ "${BOX_NAME}" =~ i386 ]]; then
        BIT_STRING="32-bit"
    else
        BIT_STRING="64-bit"
    fi
    DOCKER_STRING=
    if [[ "${BOX_NAME}" =~ docker ]]; then
        DOCKER_STRING=" with Docker preinstalled"
    fi
    EDITION_STRING=
    if [[ "${BOX_NAME}" =~ desktop ]]; then
        EDITION_STRING=" Desktop"
    else
        EDITION_STRING=" Server"
    fi
    RAW_VERSION=${BOX_NAME#debian}
    RAW_VERSION=${RAW_VERSION%-i386}
    RAW_VERSION=${RAW_VERSION%-docker}
    RAW_VERSION=${RAW_VERSION%-desktop}
    PRETTY_VERSION=${RAW_VERSION:0:1}.${RAW_VERSION:1}
    if [[ "${PRETTY_VERSION:0:3}" == "6.0" ]]; then
        PRETTY_VERSION=${RAW_VERSION:0:1}.${RAW_VERSION:1:1}.${RAW_VERSION:2:2}
    fi
    case ${PRETTY_VERSION:0:1} in
    6)
        PRETTY_VERSION="Squeeze ${PRETTY_VERSION}"
        ;;
    7)
        PRETTY_VERSION="Wheezy ${PRETTY_VERSION}"
        ;;
    8)
        PRETTY_VERSION="Jessie ${PRETTY_VERSION}"
        ;;
    esac

    VIRTUALBOX_VERSION=$(virtualbox --help | head -n 1 | awk '{print $NF}')
    PARALLELS_VERSION=$(prlctl --version | awk '{print $3}')
    VMWARE_VERSION=10.0.5

    VMWARE_BOX_FILE=box/vmware/${BOX_NAME}${BOX_SUFFIX}
    VIRTUALBOX_BOX_FILE=box/virtualbox/${BOX_NAME}${BOX_SUFFIX}
    PARALLELS_BOX_FILE=box/parallels/${BOX_NAME}${BOX_SUFFIX}
    DESCRIPTION="Debian ${PRETTY_VERSION} (${BIT_STRING})${DOCKER_STRING}

"
    if [[ -e ${VMWARE_BOX_FILE} ]]; then
        FILESIZE=$(du -k -h "${VMWARE_BOX_FILE}" | cut -f1)
        DESCRIPTION=${DESCRIPTION}"VMWare ${FILESIZE}B/"
    fi
    if [[ -e ${VIRTUALBOX_BOX_FILE} ]]; then
        FILESIZE=$(du -k -h "${VIRTUALBOX_BOX_FILE}" | cut -f1)
        DESCRIPTION=${DESCRIPTION}"VirtualBox ${FILESIZE}B/"
    fi
    if [[ -e ${PARALLELS_BOX_FILE} ]]; then
        FILESIZE=$(du -k -h "${PARALLELS_BOX_FILE}" | cut -f1)
        DESCRIPTION=${DESCRIPTION}"Parallels ${FILESIZE}B/"
    fi
    DESCRIPTION=${DESCRIPTION%?}

    if [[ -e ${VMWARE_BOX_FILE} ]]; then
        DESCRIPTION="${DESCRIPTION}

VMware Tools ${VMWARE_VERSION}"
    fi
    if [[ -e ${VIRTUALBOX_BOX_FILE} ]]; then
        DESCRIPTION="${DESCRIPTION}

VirtualBox Guest Additions ${VIRTUALBOX_VERSION}"
    fi
    if [[ -e ${PARALLELS_BOX_FILE} ]]; then
        DESCRIPTION="${DESCRIPTION}

Parallels Tools ${PARALLELS_VERSION}"
    fi
}

create_metadata() {
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    METADATA_JSON=$(
      jq -n "{
        name: \"${VAGRANT_ORG}/${BOX_NAME}${BOX_SUFFIX%-[[:digit:]]*}\",
        versions: [{
          version: \"${VERSION}\",
          providers: [{
            name: \"${PROVIDER}\",
            url: \"${SCRIPT_DIR}/../${VIRTUALBOX_BOX_FILE}\"
          }]
        }]
      }"
    )
}

publish_provider() {
    METADATA_FILE=box/${BOX_NAME}${BOX_SUFFIX%-*}.json
    echo $METADATA_JSON > $METADATA_FILE
    vagrant box add $METADATA_FILE
}


vagrant_publish() {
    VIRTUALBOX_BOX_FILE=box/virtualbox/${BOX_NAME}${BOX_SUFFIX}

    if [[ -e ${VIRTUALBOX_BOX_FILE} ]]; then
        PROVIDER=virtualbox
        create_metadata
        publish_provider
    fi
}

main() {
    args "$@"

    vagrant_publish    
}

main "$@"
