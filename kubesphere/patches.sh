#!/usr/bin/env bash

CD=$(cd "$(dirname "$0")" || exit && pwd)
cd "$CD" || exit
. "$CD"/versions.sh

f_path="ks-config.yml"
k8s_row_num=$(awk -v pattern="kubernetes:" '$0 ~ pattern {print NR+1}' "$f_path")
ks_row_num=$(awk -v pattern="name: ks-installer" '$0 ~ pattern {print NR+3}' "$f_path")
if [[ "$OSTYPE" == "darwin"* ]]; then
  # shellcheck disable=SC2154
  sed -i '' "s/, password: \".*\"/, password: \"$password\"/g" "$f_path"
  # shellcheck disable=SC2154
  sed -i '' "${k8s_row_num}s/version: v.*/version: v$k8s_ver/" "$f_path"
  # shellcheck disable=SC2154
  sed -i '' "${ks_row_num}s/version: v.*/version: v$ks_ver/" "$f_path"
else
  sed -i "s/, password: \".*\"/, password: \"$password\"/g" "$f_path"
  sed -i "${k8s_row_num}s/version: v.*/version: v$k8s_ver/" "$f_path"
  sed -i "${ks_row_num}s/version: v.*/version: v$ks_ver/" "$f_path"
fi