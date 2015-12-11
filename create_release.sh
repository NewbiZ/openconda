#!/bin/sh

# OpenConda configuration
OPENCONDA_ARCH=$(uname -m)
OPENCONDA_VERSION="1.0"
OPENCONDA_RELEASE="openconda-${OPENCONDA_VERSION}-${OPENCONDA_ARCH}"

# Dependencies configuration
OPENCONDA_PACKAGES="
    /home/avallee/workspace/openconda/packages/ncurses-6.0-0.tar.bz2
    /home/avallee/workspace/openconda/packages/openssl-1.0.2e-0.tar.bz2
    /home/avallee/workspace/openconda/packages/patchelf-0.8-0.tar.bz2
    /home/avallee/workspace/openconda/packages/python-2.7.11-0.tar.bz2
    /home/avallee/workspace/openconda/packages/readline-6.3.0-0.tar.bz2
    /home/avallee/workspace/openconda/packages/sqlite-3.9.2-0.tar.bz2
    /home/avallee/workspace/openconda/packages/zlib-1.2.8-0.tar.bz2
    /home/avallee/workspace/openconda/packages/conda-3.18.8-py27_0.tar.bz2
    /home/avallee/workspace/openconda/packages/conda-env-2.4.5-py27_0.tar.bz2
    /home/avallee/workspace/openconda/packages/pip-7.1.2-py27_0.tar.bz2
    /home/avallee/workspace/openconda/packages/setuptools-18.5-py27_0.tar.bz2
    /home/avallee/workspace/openconda/packages/wheel-0.26.0-py27_1.tar.bz2
    /home/avallee/workspace/openconda/packages/pyyaml-3.11-py27_1.tar.bz2
    /home/avallee/workspace/openconda/packages/requests-2.8.1-py27_0.tar.bz2
    /home/avallee/workspace/openconda/packages/pycosat-0.6.1-py27_0.tar.bz2
    /home/avallee/workspace/openconda/packages/jinja2-2.8-py27_0.tar.bz2"

# Retrieve files from different locations and copy them to
# a local directory
# Usage:
#   get_file http://website.org/package.tar.gz /tmp
#   get_file /my/package.tar.gz /tmp
function get_file {
    case $1 in
        http://*)
            wget "$1" -P "$2"
            ;;
        /*)
            cp "$1" "$2"
            ;;
        *)
            echo "Cannot retrieve package $1."
            exit 1
            ;;
    esac
}

# http://packages.org/zlib-1.2.8-0.tar.bz2 -> zlib-1.2.8-0.tar.bz2
function package_filename {
    basename $1
}

# http://packages.org/zlib-1.2.8-0.tar.bz2 -> zlib-1.2.8-0
function package_filename_noext {
    FILENAME=$(package_filename $1)
    echo ${FILENAME%.*.*}
}

# http://packages.org/zlib-1.2.8-0.tar.bz2 -> 0
function package_buildnumber {
    FILENAME=$(package_filename_noext $1)
    echo ${FILENAME##*-}
}

# http://packages.org/zlib-1.2.8-0.tar.bz2 -> 1.2.8
function package_version {
    FILENAME=$(package_filename_noext $1)
    FILENAME=${FILENAME%-*}
    echo ${FILENAME##*-}
}

# http://packages.org/zlib-1.2.8-0.tar.bz2 -> zlib
function package_name {
    FILENAME=$(package_filename_noext $1)
    FILENAME=${FILENAME%-*}
    echo ${FILENAME%-*}
}

TMP_DOWNLOAD_DIR="$(mktemp -d)"

PACKAGE_ARCHIVES=""
for PACKAGE in $OPENCONDA_PACKAGES
do
    PACKAGE_NAME=$(package_name $PACKAGE)
    PACKAGE_VERSION=$(package_version $PACKAGE)
    echo "Retrieving ${PACKAGE_NAME} version ${PACKAGE_VERSION}"
    get_file "${PACKAGE}" "${TMP_DOWNLOAD_DIR}"
    PACKAGE_ARCHIVES="$PACKAGE_ARCHIVES $(package_filename $PACKAGE)"
done

echo "Creating blob archive ${OPENCONDA_RELEASE}.tar.gz"
cd "${TMP_DOWNLOAD_DIR}"
tar czf "${OPENCONDA_RELEASE}.tar.gz" ${PACKAGE_ARCHIVES}
cd - > /dev/null

echo "Generating installer in dist/${OPENCONDA_RELEASE}.sh"
mkdir -p dist
cp installer-template.sh "dist/${OPENCONDA_RELEASE}.sh"
sed -i "s/__OPENCONDA_VERSION__/${OPENCONDA_VERSION}/g" "dist/${OPENCONDA_RELEASE}.sh"
sed -i "s/__OPENCONDA_ARCH__/${OPENCONDA_ARCH}/g" "dist/${OPENCONDA_RELEASE}.sh"
sed -i "s/__OPENCONDA_PACKAGES__/${PACKAGE_ARCHIVES}/g" "dist/${OPENCONDA_RELEASE}.sh"
sed -i "s/__OPENCONDA_RELEASE__/${OPENCONDA_RELEASE}/g" "dist/${OPENCONDA_RELEASE}.sh"
cat "${TMP_DOWNLOAD_DIR}/${OPENCONDA_RELEASE}.tar.gz" >> "dist/${OPENCONDA_RELEASE}.sh"

rm -rf "${TMP_DOWNLOAD_DIR}"
