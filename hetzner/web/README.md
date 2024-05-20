# terminal 1
cd itedu/hetzner/web
chmod +x ./build.sh

# terminal 2
cd itedu/hetzner/web
set -o allexport; source .env; set +o allexport
ssh ${CLOUD_SSH_USERNAME}@${CLOUD_IP} -i ~/.ssh/${CLOUD_SSH_KEY}.key
