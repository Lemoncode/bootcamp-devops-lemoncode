# Introducción

## Infraestructura como código

> Proveer infraestructura a través del software para conseguir despliegues consistentes y predecibles.

## Conceptos fundamentales

* Definido en Código
* Almacenamiento en control de versiones
* Declarativo o imperativo
* Idempotente y consistente
* Push o Pull

## Declarativo vs Imperativo

```ini
# Make me a campero
get mollete
get ham
get cheese
get tomato
get lettuce
get mayonnaise

put ham in mollete
put cheese on ham
put lettuce on cheese
put tomato on lettuce
```

```ini
# Make me a campero
get mollete
get ham
get cheese
get tomato
get lettuce
get mayonnaise

put ham in mollete
put cheese on ham
put lettuce on cheese
put tomato on lettuce
put mayonaise on tomato
```

```ini
# Make me a campero
food campero "classic-campero" {
  ingridients = [
    "ham", "cheese", "tomato", "lettuce", "mayonnaise"
  ]
}
```
put mayonaise on tomato
```

```ini
# Make me a campero
food campero "classic-campero" {
  ingridients = [
    "ham", "cheese", "tomato", "lettuce", "mayonnaise"
  ]
}
```

> Terraform es un ejemplo de aproximación declarativa para desarrollar Infraestructure as Code.

## Idempotente y Consistente

* Mi amigo: Hazme un Campero
* Mi respuesta Toma tu Campero

En un mundo **idempotente**, si **mi amigo pregunta de nuevo** por el `campero`

* Mi amigo: Hazme un Campero
* Mi respuesta Toma tu Campero

No te voy a hacer otro porque ya tienes uno.

> Terrafom intenta ser idempotente en el sentido de que si n has cambiado nada en tu código y lo aplicas de nuevo al mismo entorno, nada cambiará en el entorno porque tu código coincide con la realidad de la infraestructura que existe.

## Push or Pull

* ¿Pushing o Pulling al entorno?
* Terraform es de tipo PUSH

## Beneficios de la Infraestructura como Código

* Despliegues automatizados
* Proceso repetible
* Entornos consistentes
* Componentes reusables
* Arquitectura documentada