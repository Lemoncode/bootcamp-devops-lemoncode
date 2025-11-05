# Modulo 4 - Cloud

Este módulo cubre los servicios de cloud computing de los principales proveedores (Azure, AWS) con énfasis en orquestación de contenedores y gestión de infraestructura.

## Contenido del módulo

### 📘 [00-aks](./00-aks/) - Azure Kubernetes Service

Introducción a AKS (Azure Kubernetes Service), el servicio de orquestación de contenedores de Microsoft Azure.

- **01-mi-primer-aks**: Primeros pasos con AKS, despliegue de aplicaciones con manifiestos Kubernetes
- **02-azure-container-registry**: Uso de ACR (Azure Container Registry) para almacenar y gestionar imágenes de contenedor
- **03-cluster-autoscaler**: Configuración de escalado automático de clústeres
- **04-keda**: Event-driven autoscaling con KEDA (Kubernetes Event Driven Autoscaling)
- **05-cost-analysis**: Análisis y optimización de costos en Azure
- **05-microsoft-copilot-en-azure**: Integración de Microsoft Copilot en Azure

### 📗 [01-eks](./01-eks/) - Elastic Kubernetes Service (AWS)

Gestión completa de clústeres Kubernetes en AWS mediante EKS.

- **00-install-tools**: Instalación de herramientas necesarias
- **01-create-aws-user**: Creación y configuración de usuarios AWS
- **02-launching-cluster-eks**: Lanzamiento y configuración de clústeres EKS
- **03-deploy-k8s-dashboard**: Despliegue del dashboard de Kubernetes
- **04-deploy-solution**: Despliegue de soluciones con múltiples servicios (age-service, name-service, frontend)
- **05-helm**: Introducción a Helm y despliegue de aplicaciones con charts
- **06-autoscalling-our-applications**: Escalado automático horizontal (HPA) y de clúster
- **07-exposing-service**: Exposición de servicios mediante Ingress y Load Balancers
- **08-cdk8s**: Generación de manifiestos Kubernetes con cdk8s

### 📙 [aws](./aws/) - Amazon Web Services - IaaS

Infraestructura como servicio en AWS, desde conceptos básicos hasta configuraciones avanzadas.

- **01-introduction**: Introducción a AWS y conceptos fundamentales
- **02-create-user**: Creación de usuarios y grupos IAM
- **03-user-key-access**: Gestión de acceso y claves de usuarios
- **04-aws-cli-set-up**: Configuración de AWS CLI
- **05-ec2-deploy**: Lanzamiento y despliegue en instancias EC2
- **06-configuring-security-groups**: Configuración de grupos de seguridad y reglas de firewall
- **07-ec2-access**: Acceso a instancias EC2 (troubleshooting y acceso a aplicaciones)
- **08-managing-ips**: Gestión de direcciones IP (bastion servers, EIP)
- **09-elb**: Load balancing elástico con ELB

### 📕 [azure](./azure/) - Microsoft Azure - IaaS & PaaS

Servicios de Azure para infraestructura y plataforma.

#### IaaS (Infrastructure as a Service)
- **00-vnet**: Configuración de redes virtuales
- **01-db-vm**: Máquinas virtuales con bases de datos
- **02-api-vm**: Máquinas virtuales para APIs
- **03-frontend-vm**: Máquinas virtuales para frontend
- **04-load-balancer**: Balanceadores de carga
- **scripts**: Scripts de automatización

#### PaaS (Platform as a Service)
- **01-sql-database**: Azure SQL Database
- **02-app-service**: Azure App Service
- **03-static-web-apps**: Azure Static Web Apps
