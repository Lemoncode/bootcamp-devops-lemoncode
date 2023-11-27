ARG base_version
ARG base_image_name
FROM $base_image_name:$base_version
ARG python_version
RUN echo $python_version
RUN apt-get update
RUN apt-get install -y python$python_version python3-pip
