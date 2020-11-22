# Deberes Parte 4

# Usando la imagen lemoncodersbc/showinfo:v1 haz lo siguiente:
#
# 1. Crea un deployment con 1 pod que use esa imagen
# 2. Crea un ConfigMap que tenga una clave llamada FOO con el valor "FooData"
# 3. Crea un Secreto generic que tenga una clave llamada BAR_SECRET con el valor "SuperSecretData"
# 4. Configura el deployment para que el pod use:
#     4.1 Una variable de entorno llamada FOO_VAR con el valor de la clave FOO del ConfigMap
#     4.2 Una variable de entorno llamada BAR_SECRET con el valor de la misma clave del secreto
#
# 5. Pon en marcha el deploy y verifica que el pod tiene las variables de entorno (a través del endpoint /info del pod. Puedes usar port-forward)
# 5. Modifica el ConfigMap y modifica el valor de la clave FOO paa que sea "NewFooData"
# 6. Qué pasa con el pod?
# 7. Escala el deployment a dos réplicas
# 8. Cual es la configuración del nuevo pod?
