# Cerrando recursos S3

## Pre requisitos

> Si has destruidfo el entorno recrealo

```bash
cd lab/lc_web_app/
terraform plan -out d3.tfplan
terraform apply "d3.tfplan"
```

## Pasos

### Paso 1. 

Actualizamos `loadbalancer.tf`

```diff
## aws_elb_service_account
+data "aws_elb_service_account" "root" {}

## aws_lb
```

### Paso 2. Generamos la policy que necesitamos

Si seguimos el siguiente [enlace](https://awspolicygen.s3.amazonaws.com/policygen.html), encontraremos una web donde pordemos generar politicas de seguridad.

Vamos a crear aquí las distintas políticas de seguridad que necesitamos, empezamos por los permisos para `aws_elb_service_account`

1. Seleccionamos `S3 Bucket Policy`
2. Introducimpos como `Principal` - `AWS`
3. Seleccionamos la acción de `PutObject`
4. Introducimos como Amazon Resource Name `arn:aws:s3:::${BucketName}/${KeyName}` 
5. Click en `Add Statement`

Debemos añadir el servicio en si mismo también `delivery.logs.amazonaws.com`

1. Introducimos como `Principal` - `Service`
2. Seleccionamos la acción de `PutObject`
3. Introducimos como Amazon Resource Name `arn:aws:s3:::${BucketName}/${KeyName}`
4. `Add Conditions` 
   1. `Condition` - `StringEquals`
   2. `Key` - `s3:x-amz-acl`
   3. `Value` - `bucket-owner-full-control`
   4. Click en `Add Condition`
5. Click en `Add Statement`

Por último el servicio necesita acceso al ACL del Bucket

1. Introducimos como `Principal` - `Service`
2. Seleccionamos la acción de `PutObject`
3. Introducimos como Amazon Resource Name `arn:aws:s3:::${BucketName}/${KeyName}`
4. Click en `Add Statement`

Ya estamos listos para generar la `Policy`, hacemos click en `Generate Policy`, obtenemos

```json
{
  "Id": "Policy1639995384326",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1639993445416",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${BucketName}/${KeyName}",
      "Principal": {
        "AWS": [
          "AWS"
        ]
      }
    },
    {
      "Sid": "Stmt1639994327284",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${BucketName}/${KeyName}",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      },
      "Principal": {
        "AWS": [
          "Service"
        ]
      }
    },
    {
      "Sid": "Stmt1639994660593",
      "Action": [
        "s3:GetBucketAcl"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${BucketName}/${KeyName}",
      "Principal": {
        "AWS": [
          "Service"
        ]
      }
    }
  ]
}
```

Ahora a partir de este esqueleto vamos a generar, el json que necesitamos

```diff
{
- "Id": "Policy1639995384326",
  "Version": "2012-10-17",
  "Statement": [
    {
-     "Sid": "Stmt1639993445416",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
-     "Resource": "arn:aws:s3:::${BucketName}/${KeyName}",
+     "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*",
-     "Principal": {
-       "AWS": [
-         "AWS"
-       ]
-     }
+     "Principal": {
+       "AWS": "${data.aws_elb_service_account.root.arn}"
+     }
    },
    {
-     "Sid": "Stmt1639994327284",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
-     "Resource": "arn:aws:s3:::${BucketName}/${KeyName}",
+     "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      },
-     "Principal": {
-       "AWS": [
-         "Service"
-       ]
-     }
+     "Principal": {
+       "Service": "delivery.logs.amazonaws.com"
+     }
    },
    {
-     "Sid": "Stmt1639994660593",
      "Action": [
        "s3:GetBucketAcl"
      ],
      "Effect": "Allow",
-     "Resource": "arn:aws:s3:::${BucketName}/${KeyName}",
+     "Resource": "arn:aws:s3:::${local.s3_bucket_name}",
-     "Principal": {
-       "AWS": [
-         "Service"
-       ]
-     }
+     "Principal": {
+       "Service": "delivery.logs.amazonaws.com"
+     }
    }
  ]
}
```

The final `json` looks like:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*",
      "Principal": {
        "AWS": "${data.aws_elb_service_account.root.arn}"
      }
    },
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      },
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      }
    },
    {
      "Action": [
        "s3:GetBucketAcl"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      }
    }
  ]
}
```

### Paso 3. Generamos el Bucket

Actualizamos `s3.tf`

```tf
# aws_s3_bucket
resource "aws_s3_bucket" "web_bucket" {
  bucket        = local.s3_bucket_name
  acl           = "private"
  force_destroy = true

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*",
      "Principal": {
        "AWS": "${data.aws_elb_service_account.root.arn}"
      }
    },
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      },
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      }
    },
    {
      "Action": [
        "s3:GetBucketAcl"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      }
    }
  ]
}
  POLICY

  tags = local.common_tags
}

# aws_s3_bucket_object

# aws_iam_role

# aws_iam_role_policy

# aws_iam_instance_profile

```

* Tomamos el nombre del bucket de local
* Establecemos `acl` como privado
* Establecemos `force_destroy` para que Terraform lo elimine en el `destroy`
* Policy
  * En el statement para la `bucket policy`, queremos permitir al balenceador de carga y al `delivery service logs` acceso al bucket de S3. Esto lo hacemos utilizando `Allow`, y vamos a referenciar como principal, nuestra cuenta de servicio `Elastic Load Balancer` desde `data source`. Recordar que esto lo hemos declarado en `loadbalancer.tf`, como la entrada `data "aws_elb_service_account" "root" {}`, este es el `data source` que necesitará referenciar la `service account` usada por el `Elastic Load Balancer` en nuestra región.

  ```json
  "Principal": {
    "AWS": "${data.aws_elb_service_account.root.arn}"
  },
  ``` 

  * Para la `action`, usamos `s3:PutObject`, y para el recurso le pasamos el nombre del bucket y el path, **alb-logs**. Esto da permisos `Elastic Load Balancer` para escribir en el path.

  ```json
  "Action": "s3:PutObject",
  "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*"
  ```

  * Vamos a darle los mismos permisos al servicio `delivery.logs.amazonaws.com`, y además `s3:GetBucketAcl`


### Paso 4. Alimentamos los objectos del Bucket 

Actualizamos `s3.tf`

```tf
# ....
# aws_s3_bucket_object
resource "aws_s3_bucket_object" "website" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "/website/index.html"
  source = "./website/index.html"

  tags = local.common_tags
}

resource "aws_s3_bucket_object" "graphic" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "/website/fruits.png"
  source = "./website/fruits.png"

  tags = local.common_tags
}

# aws_iam_role
# ....
```

### Paso 5. Crear el Role y asignarlo

Actualizamos `s3.tf`

```tf
# aws_iam_role
resource "aws_iam_role" "allow_nginx_s3" {
  name = "allow_nginx_s3"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
  EOF
}
```

Este es el role que será utilizado por nuestras instancias

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
```

Ahora podemos asignar la `policy` al `role`

> EJERCICIO. Crear una `policy` que permita todas las acciones sobre S3.

```tf
# aws_iam_role_policy
resource "aws_iam_role_policy" "allow_s3_all" {
  name = "allow_s3_all"
  role = aws_iam_role.allow_nginx_s3.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${local.s3_bucket_name}",
        "arn:aws:s3:::${local.s3_bucket_name}/*"
      ]
    }
  ]
}
  EOF
}
```

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${local.s3_bucket_name}",
        "arn:aws:s3:::${local.s3_bucket_name}/*"
      ]
    }
  ]
}
```

Por útimo creamos el [perfil de instamcia](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html)

```tf
# aws_iam_instance_profile
resource "aws_iam_instance_profile" "nginx_profile" {
  name = "nginx_profile"
  role = aws_iam_role.allow_nginx_s3.name

  tags = local.common_tags
}

```

Necesitamos un `instance profile` para pasar el `role` a una instancia EC2

## Clean Up

```bash
terraform destroy
```