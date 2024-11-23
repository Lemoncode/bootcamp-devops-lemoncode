FROM gitlab.local:5001/base_images/python:v1.0.0
COPY requirements.txt /app/requirements.txt
RUN python3 -m venv /app/venv
RUN /app/venv/bin/python -m pip install -r /app/requirements.txt
COPY bootcamp.py /app/bootcamp.py
WORKDIR /app
ENTRYPOINT [ "/app/venv/bin/python", "/app/bootcamp.py" ]
EXPOSE 8080