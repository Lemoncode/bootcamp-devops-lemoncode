# Segregated Folder per each environment

## Project structure

```
.
├── modules/
│   └── local_file/
│       ├── main.tf
│       └── variables.tf
└── environments/
    ├── dev/
    │   ├── main.tf          # Calls the module with 'dev' settings
    │   └── terraform.tfstate # Local state for dev
    └── prod/
        ├── main.tf          # Calls the module with 'prod' settings
        └── terraform.tfstate # Local state for prod
```

The reusable code is in `modules` folder and create separate directories for `dev` and `prod`.

## Example Implementation

### The Reusable Module

Create `lab-directories/modules/local_file/main.tf`

```ini
variable "env_name" { type = string }

resource "local_file" "example" {
  filename = "config-${var.env_name}.txt"
  content  = "Environment: ${var.env_name}"
}
```

### The Dev Environment

Create `lab-directories/environments/dev/main.tf`

```ini
module "app" {
  source   = "../../modules/local_file"
  env_name = "dev"
}
```

```bash
cd environments/dev
```

```bash
terraform init
terraform apply -auto-approve
```


### The Prod Environment

Create `lab-directories/environments/prod/local_file/main.tf`

```ini
module "app" {
  source   = "../../modules/local_file"
  env_name = "prod"
}
```

```bash
cd environments/prod
```

```bash
terraform init
terraform apply -auto-approve
```

Now each state is segregated by diretory.