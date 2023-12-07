# Balanceadores de carga

Ahora que ya tienes una aplicación totalmente funcional, vamos a ver cómo podemos escalarla para que pueda soportar más carga. Para ello, vamos a utilizar un balanceador de carga. Un balanceador de carga es un dispositivo que distribuye el tráfico de red o las solicitudes de trabajo entre varios servidores. Los balanceadores de carga se utilizan para aumentar la capacidad de procesamiento de una aplicación web y optimizar su rendimiento, ya que distribuyen el tráfico de red de forma eficiente entre varios servidores.

En Azure, existen dos tipos de balanceadores de carga:

- Balanceador de carga público: distribuye el tráfico de red entrante a las máquinas virtuales de Azure. Este balanceador de carga se puede utilizar para equilibrar el tráfico de red a máquinas virtuales que se encuentran en la misma red virtual o en redes virtuales distintas. También se puede utilizar para equilibrar el tráfico de red a máquinas virtuales en distintas regiones de Azure.

- Balanceador de carga interno: distribuye el tráfico de red entrante a las máquinas virtuales dentro de una red virtual. Este balanceador de carga se puede utilizar para equilibrar el tráfico de red a máquinas virtuales que se encuentran en la misma red virtual.

En este caso, vamos a utilizar un balanceador de carga público para poder acceder a nuestra aplicación desde Internet. Para ello, vamos a crear un balanceador de carga público y vamos a asociarle una regla de balanceo de carga para que pueda distribuir el tráfico de red entre las máquinas virtuales que tenemos en nuestra red virtual.