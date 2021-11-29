# ¿Qué es Jenkins?

> The leading open source automation server, Jenkins provides hundreds of plugins to support building, deploying and automating any project.

# ¿Qué es una Pipeline?

> _A continuous delivery (CD) pipeline_ is an automated expression of your process for getting software from version control right through to your users and customers. Every change to your software (committed in source control) goes through a complex process on its way to being released. This process involves building the software in a reliable and repeatable manner, as well as progressing the built software (called a "build") through multiple stages of testing and deployment.

# ¿Qué es una Jenkins Pipeline?

> Es un conjunto de plugins que soportan la implementación e integración de _continuous delivery pipelines_ en Jenkins

- `Pipeline` provee de un conjunto extensible de herramientas para modelar `simple-to-complex delivery pipelines` "cómo código" via [Pipeline domain-specific language (DSL) syntax]('https://www.jenkins.io/doc/book/pipeline/syntax/')

- La definición de una `Jenkins Pipeline` se escribe en un fichero de texto `Jenkinsfile`.

## Beneficios de Pipeline cómo código

- Crea una _Pipeline build process_ para todas las ramas y peticiones de integración (pull requests).
- Revisión de código e iteración sobre la Pipeline
- Posibilidad de auditar los cambios a lo largo de la historia de la Pipeline.
- Una única fuente de verdad sobre la Pipeline

# Declarative vs Scripted Pipeline syntax

- Un `Jenkinsfile` se puede escribir de dos maneras - **Declarative y Scripted**

- La `Declarative Pipeline` es más reciente y tiene cómo características:
  - provee características sintácticas más ricas que sintaxis de la `Scripted Pipeline`
  - está diseñada para escribir y leer la Pipeline fácilmente

# ¿Por qué Pipeline

- **Code:** Pipelines are implemented in code and typically checked into source control, giving teams the ability to edit, review, and iterate upon their delivery pipeline
- **Durable:** Pipelines can survive both planned and unplanned restarts of the Jenkins controller.
- **Pausable:** Pipelines can optionally stop and wait for human input or approval before continuing the Pipeline run.
- **Versatile:** Pipelines support complex real-world CD requirements, including the ability to fork/join, loop, and perform work in parallel.
- **Extensible:** The Pipeline plugin supports custom extensions to its DSL footnote:dsl:[] and multiple options for integration with other plugins.

# Pipeline concepts

## Pipeline

Una `Jenkins Pipeline` es un modelo definido por un usuario de una `CD pipeline`. El código de la `Pipeline` define todo el proceso de `build`, el cual suele incluir escenarios para construir una aplicación, testear y después distribuirla.

> _pipeline_ es un bloque fundamental dentro de _Declarative Pipeline syntax_

## Node

Un `node` es una máquina la cual es parte de un entorno Jenkins y es capaz de ejecutar un nodo.

> Un _node_ es parte de una _Scripted Pipeline syntax_

## Stage

- Un bloque `stage` define conceptualmente un subconjunto de tareas distintas ejecutadas a través de la Pipeline:
  - Build
  - Test
  - Deploy

## Step

- Una tarea única. Fundamentalmente, un `step` le dice a Jenkins que hacer en un punto particular en el tiempo.

# Pipeline syntax overview

## Declarative Pipeline fundamentals

```groovy
pipeline {
    agent any // [1]
    stages {
        stage('Build') { // [2]
            steps {
                // [3]
            }
        }
        stage('Test') {
            steps {
                //
            }
        }
        stage('Deploy') {
            steps {
                //
            }
        }
    }
}
```
