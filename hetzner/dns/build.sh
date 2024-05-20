#!/usr/bin/env bash
# shellcheck disable=2155
# shellcheck disable=2153

function confirm() {
  local prompt response
  if [ "$1" ]; then prompt="$1"; else prompt="Are you sure"; fi
  prompt="$prompt [y/n] ?"
  while true; do
    read -r -p "$prompt " response
    case "$response" in
      [Yy]) return 0 ;;
      [Nn]) return 1 ;;
      *) ;;
    esac
  done
}

function main() {
  
  set -o allexport
  # shellcheck disable=SC1091
  source .environment
  set +o allexport

  if packer init . && packer build . ; then
    
    export CLOUD_IMAGE_ID=$(jq -r '.builds[-1].artifact_id' .manifest.json)

    if confirm "Deploy the infrastructure" ; then
      
      export TF_VAR_cloud_token="$CLOUD_TOKEN"
      export TF_VAR_dns_token="$DNS_TOKEN"
      export TF_VAR_project="$CLOUD_PROJECT"
      export TF_VAR_domain="$CLOUD_DOMAIN"
      export TF_VAR_server_type="$CLOUD_SERVER_TYPE"
      export TF_VAR_location="$CLOUD_LOCATION"
      export TF_VAR_datacenter="$CLOUD_DATACENTER"
      export TF_VAR_image="$CLOUD_IMAGE_ID"

      terraform init
      terraform apply     
      
      export CLOUD_SSH_KEY=$(terraform output -json | jq -r ".key.value")
      export CLOUD_NS1=$(terraform output -json | jq -r ".ns1.value")
      export CLOUD_NS2=$(terraform output -json | jq -r ".ns2.value")
      
      envsubst < .environment > .env
      
      terraform destroy
    fi

    # Delete packer image
    curl \
	    -X DELETE \
	    -H "Authorization: Bearer $CLOUD_TOKEN" \
	    "https://api.hetzner.cloud/v1/images/$CLOUD_IMAGE_ID"
  fi
}

main "$@"