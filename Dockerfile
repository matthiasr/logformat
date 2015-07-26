FROM python:2-slim

WORKDIR /srv/app
VOLUME /srv/irc/logs
EXPOSE 8080

COPY *.py index.html /srv/app/
COPY css/ /srv/app/css/

RUN echo 'en_US UTF-8' >> /etc/locale.gen && echo 'de_DE UTF-8' >> /etc/locale.gen && apt-get update && apt-get -y install locales && apt-get clean && rm -rf /var/lib/apt/lists/*

CMD [ "python", "./handler.py" ]
