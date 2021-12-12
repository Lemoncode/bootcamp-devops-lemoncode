FROM python:3.8-slim
MAINTAINER Sergio Ramírez  "sergio@localhost"
COPY ./requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip install -r requirements.txt
COPY bootcamp.py /app/
ENTRYPOINT [ "python3" ]
CMD [ "bootcamp.py" ]
EXPOSE 8080
