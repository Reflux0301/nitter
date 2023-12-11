FROM nimlang/nim:1.6.10-alpine-regular as nim
LABEL maintainer="setenforce@protonmail.com"

RUN apk --no-cache add libsass-dev pcre git

RUN git clone https://github.com/zedeus/nitter.git /src/nitter

WORKDIR /src/nitter

RUN nimble install -y --depsOnly

RUN nimble build -d:danger -d:lto -d:strip \
    && nimble scss \
    && nimble md

FROM alpine:latest

WORKDIR /src/

RUN apk --no-cache add pcre ca-certificates

COPY nitter.conf ./nitter.conf
COPY --from=nim /src/nitter/nitter ./
COPY --from=nim /src/nitter/public ./public

RUN adduser -h /src/ -D -s /bin/sh nitter
USER nitter

CMD ./nitter