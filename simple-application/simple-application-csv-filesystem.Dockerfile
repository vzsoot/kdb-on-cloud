FROM debian:stable

RUN apt-get -y update; apt-get -y install curl

ARG BUILD_DIR
WORKDIR /app

COPY $BUILD_DIR/q q
COPY $BUILD_DIR/k4.lic k4.lic

ENV PATH $PATH:/app/q/l64
ENV QHOME /app/q

COPY lib/ lib/
COPY simple-application-csv-filesystem.q simple-application-csv-filesystem.q
COPY entrypoint-params.sh entrypoint-params.sh

RUN chmod +x q/l64/q
RUN chmod +x entrypoint-params.sh
RUN useradd -ms /bin/bash appuser

USER appuser

ENTRYPOINT ["/app/entrypoint-params.sh", "simple-application-csv-filesystem.q"]

