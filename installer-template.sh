#/bin/sh

OPENCONDA_VERSION="__OPENCONDA_VERSION__"
CONDA_VERSION="__CONDA_VERSION__"
VIRTUALENV_VERSION="__VIRTUALENV_VERSION__"
CONDA_ARCHIVE="__CONDA_ARCHIVE__"
VIRTUALENV_ARCHIVE="__VIRTUALENV_ARCHIVE__"
PREFIX="${HOME}/openconda"
ARCH="$(uname -m)"

echo "OpenConda ${OPENCONDA_VERSION} installer"

echo "OpenConda version: ${OPENCONDA_VERSION}"
echo "Conda version: ${CONDA_VERSION}"
echo "Prefix: ${PREFIX}"

# Check for python
python --version > /dev/null
if test "$?" != "0"
then
    echo "Cannot find a suitable python binary. Please install python"
    echo "or create a 'python' symlink pointing to your python version."
    echo "e.g.: ln -s /usr/local/bin/python2.7 /usr/local/bin/python"
    exit 1
fi

# Check for proper architecture
case "${ARCH}" in
    amd64|x86_64)
        echo "Platform: ${ARCH}"
        ;;
    *)
        echo "This release of OpenConda was built for 64bits platforms."
        echo "Your platform ($ARCH) is not supported."
        exit 1
        ;;
esac;

TMP_EXTRACT_DIR=$(mktemp -d)
ARCHIVE_OFFSET=$(awk '/^__ARCHIVE__/ {print NR + 1; exit 0; }' $0)
tail -n+$ARCHIVE_OFFSET $0 | tar xzvf - -C "${TMP_EXTRACT_DIR}"
cd "${TMP_EXTRACT_DIR}"
tar xzf "${VIRTUALENV_ARCHIVE}"
tar xjf "${CONDA_ARCHIVE}"
echo "Creating conda virtual in ${PREFIX}"
"${TMP_EXTRACT_DIR}/virtualenv-${VIRTUALENV_VERSION}/virtualenv.py" "${PREFIX}" > /dev/null
echo "Installing conda"
"${PREFIX}/bin/pip" install "${TMP_EXTRACT_DIR}/conda-${CONDA_VERSION}" > /dev/null
cd - > /dev/null
echo "${TMP_EXTRACT_DIR}"
rm -rf "${TMP_EXTRACT_DIR}"

exit 0

__ARCHIVE__
