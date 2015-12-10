#/bin/sh

# Default OpenConda installation directory
OPENCONDA_PREFIX="${HOME}/openconda"

# Variables templated during generation of the installer
OPENCONDA_VERSION="__OPENCONDA_VERSION__"
OPENCONDA_ARCH="__OPENCONDA_ARCH__"
OPENCONDA_RELEASE="__OPENCONDA_RELEASE__"
OPENCONDA_PACKAGES="__OPENCONDA_PACKAGES__"

echo "OpenConda ${OPENCONDA_RELEASE}"
echo "Version:      ${OPENCONDA_VERSION}"
echo "Architecture: ${OPENCONDA_ARCH}"
echo "Prefix:       ${OPENCONDA_PREFIX}"

# Check for proper architecture
if [ "$(uname -m)" != "${OPENCONDA_ARCH}" ]
then
    echo ""
    echo "This release of OpenConda was built for the ${OPENCONDA_ARCH}"
    echo "architecture. Your architecture ($(uname -m)) does not match."
    exit 1
fi

# Create main prefix directory
mkdir -p "${OPENCONDA_PREFIX}"

# Extract all packages in a temporary directory
TMP_EXTRACT_DIR=$(mktemp -d)
ARCHIVE_OFFSET=$(awk '/^__ARCHIVE__/ {print NR + 1; exit 0; }' $0)
tail -n+$ARCHIVE_OFFSET $0 | tar xzf - -C "${TMP_EXTRACT_DIR}"
cd "${TMP_EXTRACT_DIR}"

# Extract all packages in the $PREFIX/pkgs directory
mkdir -p "${OPENCONDA_PREFIX}/pkgs"
for PACKAGE in ${OPENCONDA_PACKAGES}
do
    echo "Extracting ${PACKAGE} ..."
    mkdir -p "${OPENCONDA_PREFIX}/pkgs/$(basename ${PACKAGE})"
    tar xjf "${PACKAGE}" -C "${OPENCONDA_PREFIX}/pkgs/$(basename ${PACKAGE})"
    rm -rf "${PACKAGE}"
done

# Remove temporary extraction directory
cd - > /dev/null
rm -rf "${TMP_EXTRACT_DIR}"

# Use conda script to install all packages in the environment

exit 0

__ARCHIVE__
