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

exec python -m build --outdir ${INPUT_PACKAGES_DIR}
