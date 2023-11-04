FROM python:3.10-slim-buster

WORKDIR /src

COPY ./analytics/requirements.txt requirements.txt

RUN apt update -y && apt install -y libpq-dev python3-dev

RUN pip install -r requirements.txt

COPY ./analytics .

CMD python app.py