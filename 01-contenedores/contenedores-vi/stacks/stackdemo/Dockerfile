FROM python:3.7.11-slim

ADD . /code

WORKDIR /code

RUN pip install -r requirements.txt

EXPOSE 8000

CMD ["python", "app.py"]