FROM alpine:3.2

WORKDIR /srv/app
COPY . /srv/app
EXPOSE 8080

ENV RACK_ENV production
ENV BIND 0.0.0.0

RUN apk add --update -t build-deps openssl ca-certificates make gcc g++ musl-dev mariadb-dev postgresql-dev sqlite-dev libffi-dev \
    && apk add ruby ruby-dev libgcc \
    && echo 'gem: --no-rdoc --no-ri' >> "$HOME/.gemrc" \
    && gem install bundler --no-document \
    && bundle install --deployment --binstubs \
    && apk del --purge build-deps \
    && apk add mariadb-libs sqlite-libs libpq libffi \
    && rm -rf /var/cache/apk/*

ENTRYPOINT ["/srv/app/bin/run"]
CMD ["web.rb"]
