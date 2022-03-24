FROM python:3.10.3-buster

RUN apt-get update \
&& apt-get -y install libpq-dev gcc \
&& pip install psycopg2 \
&& pip install boto3

COPY requirements.txt app/requirements.txt
RUN pip install --no-cache-dir -r app/requirements.txt

COPY main.py app/main.py

CMD [ "python3", "app/main.py"]