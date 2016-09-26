#!/usr/bin/env bash

MYPY_VERSION="0.4.3"

echo "*****************************"
echo "building mypy ${MYPY_VERSION}"
echo "*****************************"
echo

if [ -f "/etc/pexrc" ]
then
    echo "Found /etc/pexrc, this may interfere with creation of the pex.  Please remove and retry."
    exit 1
fi

case $(uname -s) in
  *Linux*) PLATFORM="linux";
           ARCH=`uname -p`;
           SHASUM="sha1sum";;
  *Darwin*) PLATFORM="mac";
            ARCH=`sw_vers -productVersion | cut -f1,2 -d.`;
            SHASUM="shasum";;
  *) echo "invalid platform!"; exit 1;;
esac

DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
DIRPATH=$(pwd -P)
MYPY_DEST_DIR="${DIRPATH}/build-support/scripts/mypy/${MYPY_VERSION}"
mkdir -p ${MYPY_DEST_DIR}

BUILD_DIR="mypy_build.${DATE}"
python3 -m venv ${BUILD_DIR}

. ${BUILD_DIR}/bin/activate
curl https://bootstrap.pypa.io/get-pip.py | ${BUILD_DIR}/bin/python

${BUILD_DIR}/bin/pip3 install requests
${BUILD_DIR}/bin/pip3 install pex

${BUILD_DIR}/bin/pex mypy-lang \
            --not-zip-safe \
            --no-use-wheel \
            --always-write-cache \
            --python=python3 \
            -e mypy \
            -o ${MYPY_DEST_DIR}/mypy \
            --python=python3 \
            --platform ${PLATFORM}-${ARCH}

echo ${BUILD_DIR}/bin/pex mypy-lang \
            --python=python3 \
            -e mypy \
            -o ${MYPY_DEST_DIR}/mypy \
            --python=python3 \
            --platform ${PLATFORM}-${ARCH}
rm -rf ${BUILD_DIR}

