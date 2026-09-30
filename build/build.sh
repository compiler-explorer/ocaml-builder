#!/bin/bash

set -ex

FULL_VERSION=$1
VERSION=${FULL_VERSION%-flambda}

if echo ${VERSION} | grep 'trunk'; then
    echo Not supported at present
    exit 1
fi

FULLNAME=ocaml-${FULL_VERSION}
OUTPUT=/root/${FULLNAME}.tar.xz
S3OUTPUT=
if [[ $2 =~ ^s3:// ]]; then
    S3OUTPUT=$2
else
    if [[ -d "${2}" ]]; then
        OUTPUT=$2/${FULLNAME}.tar.xz
    else
        OUTPUT=${2-$OUTPUT}
    fi
fi

echo "ce-build-output:${OUTPUT}"

# Ocaml likes to put shebang lines of the form #!/path/to/ocamlrun which is set during build.
# We can't reolcate ocaml after the build, so we build it here in its presumed final destination location
STAGING_DIR=/opt/compiler-explorer/ocaml-${FULL_VERSION}
rm -rf ${STAGING_DIR}
mkdir -p ${STAGING_DIR}

curl -L https://github.com/ocaml/ocaml/archive/${VERSION}.tar.gz | tar zxf -
cd ocaml-${VERSION}
if [[ -f configure.ac ]]; then
    FLAMBDA_FLAG=--enable-flambda
    JOBS=$(nproc)
else
    # Before 4.08 OCaml had a hand-written configure (only takes -flambda) and its Makefiles aren't parallel-safe
    FLAMBDA_FLAG=-flambda
    JOBS=1
fi
FLAGS=
if [[ "${FULL_VERSION}" != "${VERSION}" ]]; then
    FLAGS=${FLAMBDA_FLAG}
fi
./configure ${FLAGS} -prefix ${STAGING_DIR}
make -j${JOBS} world.opt
make -j${JOBS} install

export XZ_DEFAULTS="-T 0"
tar Jcf ${OUTPUT} --transform "s,^./,./ocaml-${FULL_VERSION}/," -C ${STAGING_DIR} .

if [[ -n "${S3OUTPUT}" ]]; then
    aws s3 cp --storage-class REDUCED_REDUNDANCY "${OUTPUT}" "${S3OUTPUT}"
fi

echo "ce-build-status:OK"
