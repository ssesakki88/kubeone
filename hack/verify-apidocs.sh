#!/usr/bin/env bash

# Copyright 2021 The KubeOne Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -eu -o pipefail

cd $(dirname "${BASH_SOURCE}")/..

DIFFROOT="docs/api_reference"
TMP_DIFFROOT="_tmp/docs/api_reference"
_tmp="_tmp"

cleanup() {
  rm -rf "${_tmp}"
}
trap "cleanup" EXIT SIGINT

cleanup

mkdir --parents "${TMP_DIFFROOT}"
cp --archive "${DIFFROOT}"/* "${TMP_DIFFROOT}"

./hack/update-apidocs.sh
echo "diffing ${DIFFROOT} against freshly generated apidocs"
ret=0
diff --ignore-matching-lines='^date =.*' -Naupr "${DIFFROOT}" "${TMP_DIFFROOT}" || ret=$?
cp -a "${TMP_DIFFROOT}"/* "${DIFFROOT}"
if [[ $ret -eq 0 ]]; then
  echo "${DIFFROOT} up to date."
else
  echo "${DIFFROOT} is out of date. Please run hack/update-apidocs.sh"
  exit 1
fi
