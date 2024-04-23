#!/usr/bin/env bash

TF_PROJECT_NAME=$1

mkdir $TF_PROJECT_NAME

tffiles=('variables' 'versions' 'main' 'outputs'); for file in "${tffiles[@]}" ; do touch "$TF_PROJECT_NAME/$file".tf; done
# for example
cat << EOF >> "$TF_PROJECT_NAME/variables.tf"
variable "hcloud_token" {
  sensitive = true
  default = "$TF_VAR_hcloud_token"
}
EOF