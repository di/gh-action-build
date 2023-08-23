#! /bin/bash

# This code is derived from
# https://github.com/pypa/gh-action-pypi-publish/blob/unstable/v1/twine-upload.sh
#
# Copyright © 2019, Sviatoslav Sydorenko
# (wk+gh~pypa/gh-action-pypi-publish@sydorenko.org.ua) and contributors
# (https://github.com/pypa/gh-action-pypi-publish/graphs/contributors)

if [[ -n "${DEBUG}" ]]
then
    set -x
fi

set -Eeuo pipefail

function get-normalized-input() {
  local var_name=${1}
  python -c \
    '
from os import getenv
from sys import argv
envvar_name = f"INPUT_{argv[1].upper()}"
print(
  getenv(envvar_name) or getenv(envvar_name.replace("-", "_")) or "",
  end="",
)
    ' \
    "${var_name}"
}


# NOTE: These variables are needed to combat GitHub passing broken env vars
# NOTE: from the runner VM host runtime.
# Ref: https://github.com/pypa/gh-action-pypi-publish/issues/112
export HOME="/root"  # So that `python -m site` doesn't get confused
export PATH="/usr/bin:${PATH}"  # To find `id`
. /etc/profile  # Makes python and other executables findable
export PATH="$(python -m site --user-base)/bin:${PATH}"
export PYTHONPATH="$(python -m site --user-site):${PYTHONPATH}"

INPUT_PACKAGES_DIR="$(get-normalized-input 'packages-dir')"

python -m build --outdir ${INPUT_PACKAGES_DIR}

output=$(python /app/check_for_pure_wheels.py --outdir ${INPUT_PACKAGES_DIR})
if [ $? -ne 0 ]; then
    echo \
        ::warning file='# >>' PyPA build action'%3A' \
        Non-pure wheel built\
        '<< ':: \
        One or more wheels are not pure Python wheels. This may mean that your \
        not all platforms or architectures will be supported by your project. \
        You may want to perform additional, platform-specific builds.
fi

# Try to run docker-in-docker:
docker build -t hey -f /app/Dockerfile .
docker run hey -e INPUT_PACKAGES_DIR='${{ inputs.packages-dir }}' -e INPUT_VERBOSE='${{ inputs.verbose }}'
