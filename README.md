<details>
    <summary>Terraform in YC</summary>

Install yandex cloud CLI:

```bash
curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
```

Initialize cloud:

```bash
yc init
```

> Assuming that you've created a directory already. If not, do [this](https://cloud.yandex.ru/docs/resource-manager/quickstart).

Create service account:

```bash
SVC_ACCT="berendyaev-terraform"
FOLDER_ID="REPLACE_TO_YOUR_OWN"
yc iam service-account create --name $SVC_ACCT --folder-id $FOLDER_ID
```

Assign role:

```bash
ACCT_ID=$(yc iam service-account get "berendyaev-terraform" | \
                        grep ^id | \
                        awk '{print $2}')
yc resource-manager folder add-access-binding --id $FOLDER_ID \
    --role editor \
    --service-account-id $ACCT_ID
```

Create IAM token:

```bash
mkdir ~/.yandex
yc iam key create --service-account-id $ACCT_ID --output ~/.yandex/key.json
```

Change current directory to ./terraform

```bash
cd ./terraform
```

Run Terraform initialization

```bash
terraform init
```

Create your own tvfars file

```bash
cp terraform.tfvars.example terraform.tfvars
```

Set your own cloud/folder ID in that file. You can get these ID with `yc config list`. Don't forget to generate SSH keys.

Apply infra.

```bash
terraform plan
# If no error present run:
terraform apply
yes
```

Terraform ouputs public IP address of the instance. Use it to ssh to the host:

```bash
ssh -i ~/.ssh/<username> <username>@<ip address>
```

Ensure that hostname has been changed according to the `hostname` argument in the instance resource.

Do not forget to destroy everything:

```bash
terraform destroy -auto-approve
```

</details>

<details>
    <summary>Docker-machine in YC</summary>

Install go

```bash
sudo add-apt-repository ppa:longsleep/golang-backports
sudo apt update
sudo apt install golang-go
```

Install docker-machine plugin

```bash
go get -u github.com/yandex-cloud/docker-machine-driver-yandex
```

The plugin has been installed in `$HOME/go/bin`. Make sure this path is in your `PATH` environment variable.

Set your YC folder ID and SA key path (see Terraform section):

```bash
FOLDER_ID="SET_YOUR_OWN_ID"
SA_KEY_PATH="/SET/YOUR/OWN/PATH"
```

Create Docker host

```bash
docker-machine create \
    --driver yandex \
    --yandex-image-family "ubuntu-1804-lts" \
    --yandex-platform-id "standard-v1" \
    --yandex-folder-id $FOLDER_ID \
    --yandex-sa-key-file $SA_KEY_PATH \
    docker-host
```

Connect to docker-host docker engine:

```bash
eval $(docker-machine env docker-host)
```

Run `docker run hello-world` to make sure that everything is working fine.


</details>
