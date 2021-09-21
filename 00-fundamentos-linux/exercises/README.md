# Ejercicios

## Ejercicios CLI

### 1. Crea mediante comandos de bash la siguiente jerarquía de ficheros y directorios.

```
foo/
├─ dummy/
│  ├─ file1.txt
│  ├─ file2.txt
├─ empty/
```

Donde `file1.txt` debe contener el siguiente texto:

```
Me encanta la bash!!
```

Y `file2.txt` debe permanecer vacío.

### 2. Mediante comandos de bash, vuelca el contenido de file1.txt a file2.txt y mueve file2.txt a la carpeta empty.

El resultado de los comandos ejecutados sobre la jerarquía anterior deben dar el siguiente resultado.

```
foo/
├─ dummy/
│  ├─ file1.txt
├─ empty/
  ├─ file2.txt
```

Donde `file1.txt` y `file2.txt` deben contener el siguiente texto:

```
Me encanta la bash!!
```

### 3. Crear un script de bash que agrupe los pasos de los ejercicios anteriores y además permita establecer el texto de file1.txt alimentándose como parámetro al invocarlo.

Si se le pasa un texto vacío al invocar el script, el texto de los ficheros, el texto por defecto será:

```
Que me gusta la bash!!!!
```

### 4. Opcional - Crea un script de bash que descargue el conetenido de una página web a un fichero.

Una vez descargado el fichero, que busque en el mismo una palabra dada (esta se pasará por parametro) y muestre por pantalla el núemro de linea donde aparece.
