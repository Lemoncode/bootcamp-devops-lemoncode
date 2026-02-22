# Terraform Workspaces using local backend

## Create `main.tf`

```ini
# 1. Define the Backend (Local is the default, but we can be explicit)
terraform {
  backend "local" {}
}

# 2. Use the workspace name to define local variables
locals {
  env_name = terraform.workspace
}

# 3. Create a resource that changes based on the workspace
resource "local_file" "example" {
  filename = "config-${local.env_name}.txt"
  content  = "This file belongs to the ${local.env_name} environment."
}

# 4. Output the workspace name for verification
output "current_workspace" {
  value = terraform.workspace
}
```

## Steps 

We can now initialize:

```bash
terraform init
```

By default, Terraform creates the backend as local, and associates this backend state, with the `default` workspace

### Create a `dev` Workspace

```bash
terraform workspace new dev
terraform apply -auto-approve
```

After this operation, a new file is created `config-dev.txt`. Notice that a new directory has also being created `terraform.tfstate.d`. Terraform isolates each environment's state by using this `terraform.tfstate.d` directory.

We can list the workspaces:

```bash
terraform workspace list
```

We can see that now we have two *worspaces* and Terraform sets the current working copy to the last one that we have created.

```
  default
* dev
```

We can have a look into the current state:

```bash
terraform state list
```

We can see the following state list

```
local_file.example
```

Lets have a look on the only element that is on our state

```bash
terraform state show local_file.example
```

```ini
# local_file.example:
resource "local_file" "example" {
    content              = "This file belongs to the dev environment."
    content_base64sha256 = "G+x9zXyvpcCmuQN8zOFayevpvCwwrz7WSS4BfjmBMuQ="
    content_base64sha512 = "Hz5YdAdvYx2WkiRJzQk4zxCOg3PuVPdLDYR3u1XhE+X4pIa2KiJDMwQiv7f7R/WJ6EslmQHhauab67GTdu4Zcw=="
    content_md5          = "8a6b7053db3338624f833edf55b329da"
    content_sha1         = "823a7b987174b8c8c5b95d7ad64e714c5c373439"
    content_sha256       = "1bec7dcd7cafa5c0a6b9037ccce15ac9ebe9bc2c30af3ed6492e017e398132e4"
    content_sha512       = "1f3e5874076f631d96922449cd0938cf108e8373ee54f74b0d8477bb55e113e5f8a486b62a2243330422bfb7fb47f589e84b259901e16ae69bebb19376ee1973"
    directory_permission = "0777"
    file_permission      = "0777"
    filename             = "config-dev.txt"
    id                   = "823a7b987174b8c8c5b95d7ad64e714c5c373439"
}
```

### Create a `prod` Workspace

```bash
terraform workspace new prod
terraform apply -auto-approve
```

A file named `config-prod.txt` is created. Terraform "forgets" about the dev file because the state is now isolated.

```bash
terraform state list
terraform state show local_file.example
```

```ini
# local_file.example:
resource "local_file" "example" {
    content              = "This file belongs to the prod environment."
    content_base64sha256 = "eB0Fwg1xvbxfAncbd8XEhXc8pkHc1XzKzyfcUdvFaoI="
    content_base64sha512 = "q3JC2Jx6P71YTO16OrWtCV9izyWH6uvH1gCqNfpCcIlZWxk7+gns6ABKOX9oBmhBnAg4AmIeCKpg7uss7ugzVA=="
    content_md5          = "12db46ff732f3f389a7a6416f8741c95"
    content_sha1         = "95ae7e53129520423efed8399f50941cb404230b"
    content_sha256       = "781d05c20d71bdbc5f02771b77c5c485773ca641dcd57ccacf27dc51dbc56a82"
    content_sha512       = "ab7242d89c7a3fbd584ced7a3ab5ad095f62cf2587eaebc7d600aa35fa427089595b193bfa09ece8004a397f680668419c083802621e08aa60eeeb2ceee83354"
    directory_permission = "0777"
    file_permission      = "0777"
    filename             = "config-prod.txt"
    id                   = "95ae7e53129520423efed8399f50941cb404230b"
}
```

### List and Switch Workspaces

```bash
# List all workspaces (the '*' shows the active one)
terraform workspace list

# Switch back to dev
terraform workspace select dev
```

There is not any restriction to run on `default`, is just another workspace

```bash
terraform workspace select dev
```

```bash
terraform apply -auto-approve
```

## How local State is Organized

```
.
├── main.tf
├── terraform.tfstate          # State for the 'default' workspace
└── terraform.tfstate.d/       # Directory for all other workspaces
    ├── dev/
    │   └── terraform.tfstate  # State for the 'dev' workspace
    └── prod/
        └── terraform.tfstate  # State for the 'prod' workspace
```

> WORKSPACE: One configuration -> multiple states

Workspace is ideally to work on a feature branch conncept, where temporally changes over an environment are made on this branch, and then we remove the branch and the associated workspace. But since we are on the same directory, managing multiple environments is really taugh.