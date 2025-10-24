# Usar imagen base oficial de PHP con Apache
FROM php:8.2-apache

# Establecer el directorio de trabajo
WORKDIR /var/www/html

# Instalar extensiones PHP necesarias
RUN apt-get update && apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Habilitar módulo de reescritura (mod_rewrite) de Apache
RUN a2enmod rewrite

# Copiar archivos de la API
COPY api.php .

# Configurar Apache para servir desde el directorio correcto
RUN echo '<Directory /var/www/html>\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' > /etc/apache2/conf-available/html.conf && \
a2enconf html

# Exponer puerto 80
EXPOSE 80

# Comando por defecto
CMD ["apache2-foreground"]
