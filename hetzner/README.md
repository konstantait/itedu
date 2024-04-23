## Terraform install 

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

sudo apt-get install terraform
````

## Manage Hetzner Cloud Servers

Sign in into the Hetzner Cloud Console choose a Project, go to Security -> API Tokens, and generate a new token

````
echo 'export TF_VAR_hcloud_token=<HETZNER-API-TOKEN>' >> ~/.bashrc 

curl -H "Authorization: Bearer $TF_VAR_hcloud_token" \
    'https://api.hetzner.cloud/v1/images'

curl -H "Authorization: Bearer $TF_VAR_hcloud_token" \
    'https://api.hetzner.cloud/v1/server_types'

cd hetzner

terraform init
terraform plan
terraform apply
terraform show
terraform destroy

cat inventory.ini

ssh root@<IP-FROM-INVENORY> -i ~/.ssh/<RE-CREATED-KEY>.key
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
