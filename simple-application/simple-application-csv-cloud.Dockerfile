FROM debian:stable

RUN apt-get -y update; apt-get -y install curl

ARG BUILD_DIR
WORKDIR /app

COPY $BUILD_DIR/q q
COPY $BUILD_DIR/kc.lic kc.lic

ENV PATH $PATH:/app/q/l64
ENV QHOME /app/q

COPY lib/ lib/
COPY simple-application-csv-cloud.q simple-application-csv-cloud.q
COPY entrypoint.sh entrypoint.sh

RUN chmod +x q/l64/q
RUN chmod +x entrypoint.sh
RUN useradd -ms /bin/bash appuser

USER appuser

ENTRYPOINT ["/app/entrypoint.sh", "simple-application-csv-cloud.q"]

