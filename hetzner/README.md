## Terraform, Paker & Hetzner Cloud CLI install 

````
sudo apt-get update
sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp.gpg > /dev/null

gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp.gpg \
    --fingerprint

echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update

sudo apt-get -y install jq terraform packer

wget https://github.com/hetznercloud/cli/releases/download/v1.43.1/hcloud-linux-amd64.tar.gz

tar -xvf hcloud-linux-*.tar.gz

sudo mv hcloud /usr/local/bin/

hcloud version

echo "source <(hcloud completion bash)" | tee -a ~/.bashrc

source ~/.bashrc
````

## Manage Hetzner Cloud Servers

Sign in into the Hetzner Cloud Console choose a Project, go to Security -> API Tokens, and generate a new token

````
echo "export HETZNER_CLOUD_API_TOKEN=<HETZNER_CLOUD_API_TOKEN>" >> ~/.bashrc
echo "export HETZNER_DNS_API_TOKEN=<HETZNER_DNS_API_TOKEN>" >> ~/.bashrc
echo 'export TF_CLI_ARGS_apply="-compact-warnings"' >> ~/.bashrc

curl -H "Authorization: Bearer $HETZNER_CLOUD_API_TOKEN" \
    'https://api.hetzner.cloud/v1/images' | jq .

curl -H "Authorization: Bearer $HETZNER_CLOUD_API_TOKEN" \
    'https://api.hetzner.cloud/v1/server_types' | jq .

curl -H "Authorization: Bearer $HETZNER_CLOUD_API_TOKEN" \
    'https://api.hetzner.cloud/v1/datacenters' | jq .

curl -H "Auth-API-Token: $HETZNER_DNS_API_TOKEN" \
     'https://dns.hetzner.com/api/v1/records' | jq .
````

## Adding locally hosted code to GitHub

Sign in into the GitHub, go to Setting -> Developer Settings -> Personal access tokens (classic), and generate a new token

````
echo 'export GITHUB_user=<GITHUB_USER>' >> ~/.bashrc
echo 'export GITHUB_token=<GITHUB_TOKEN>' >> ~/.bashrc

git config --global user.name '<GITHUB_USER>'
git config --global user.email '<GITHUB_EMAIL>'

git init -b main
git add .
git commit -m 'initial commit'
````

Create a new repository on GitHub.com. Do not initialize the new repository with README, license, or gitignore files. 

````
git remote show origin
git remote add origin https://$GITHUB_user:$GITHUB_token@github.com/$GITHUB_user/<CREATED-GITHUB_REPO>.git
git remote show origin
git push --set-upstream origin main
git push

git reflog
````