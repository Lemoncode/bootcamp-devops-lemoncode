## Instalando Terraform

La instalación de Terraform es un simple ejecutable que añadiremos a nuestro path. Podemos usar los gestores de paquetes de nuestro sistema operativo para instalarlo.

## Instalación Manual

Este paso es común a todos los sistemas operativos.

Descargar el paquete adecuado para nuestro sistema operativo en [este enlace](https://www.terraform.io/downloads).

### Instalación Manual Mac o Linux

Una vez descargado lo descomprimimos, y lo movemos al directorio de ejectutables.

```bash
mv ~/Downloads/terraform /usr/local/bin/
```

Para confirmar la instalación, simplemente ejecutar:

```bash
terraform -help
```

### Instalación Manual Windows

Una vez descargado lo descomprimimos y lo ubicamos en una carpeta fácilmente reconocible por ejemplo `C:\terraform`. 

Para editar el `PATH`, seguiremos los siguientes pasos:

1. Ir a `Control panel` --> `System` --> `System settings` --> `Environment Variables`
2. Buscar `PATH`
3. Pulsar `edit` y modificarlo de forma adecuada
4. Asegurar que hemos incluido `;` --> `c:\path;c:\path2`

## Referencias

[Terraform Downloads](https://www.terraform.io/downloads)
[Where can I set up path xxxx.exe on Windows?](https://stackoverflow.com/questions/1618280/where-can-i-set-path-to-make-exe-on-windows)