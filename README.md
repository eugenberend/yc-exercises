<details>
    <summary>Play terraform in YC</summary>

Install yandex cloud CLI:

```bash
curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
```

Initialize cloud:

```bash
yc init
```

> Assume that you created a directory already. If not, [do](https://cloud.yandex.ru/docs/resource-manager/quickstart) this.

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

Run initialization of Terraform

```bash
terraform init
```

Create your own tvfars file

```bash
cp terraform.tfvars.example terraform.tfvars
```

Set your own cloud/folder ID's in that file. You can get these ID's just typing `yc config list`. Don't forget to generate key pair for SSH access.

Apply infra.

```bash
terraform plan
# If no errors present, then run:
terraform apply
yes
```

Terraform ouputs a public IP address of instance. Use it to ssh on host:

```bash
ssh -i ~/.ssh/<username> <username>@<ip address>
```

Ensure that hostname was changed accordingly to the `hostname` argument in the instance resource.

Do not forget to destroy everything:

```bash
terraform destroy -auto-approve
```

</details>
