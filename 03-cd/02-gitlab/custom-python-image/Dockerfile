ARG base_version  
ARG base_image_name  
FROM $base_image_name:$base_version  
ARG python_version  
RUN apt update  
RUN apt install -y python${python_version} python3-pip python${python_version}-venv
