# Bash Scripting

### Definición

Un BASH script no es más que un fichero en texto plano que contiene una serie de comandos. Estos comandos no son más que una mezcla de comandos que podemos ejecutar en una interfaz de comandos. Cualquier comando que puedas ejecutar en una terminal se pueden ejecutar dentro del script manteniendo su funcionamiento con normalidad.

Por convención tienen extensión `.sh` aunque si queremos podemos darle cualquier extensión o ninguna, ya que Linux es un sistema que no depende de extensiones.

Cuando ejecutamos un script (o programa) Linux carga el contenido del script y sus instrucciones en memoria por lo que se crea un proceso que representa la instancia de ese programa.

### Hello World

El script más básico es imprimir un mensaje por consola. Para ello creamos el fichero "helloworld.sh" con el siguiente contenido:

```bash
echo "Hello world!"
```

Para lanzarlo ejecutaremos el intérprete bash:

```shell
$ bash  -c ./helloworld.sh
Hello world!
```
