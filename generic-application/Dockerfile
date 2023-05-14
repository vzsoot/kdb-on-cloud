FROM debian:stable

ARG BUILD_DIR
WORKDIR /

COPY $BUILD_DIR/q /app/q
COPY $BUILD_DIR/kc.lic /app/kc.lic

ENV PATH $PATH:/app/q/l64
ENV QHOME /app/q

COPY lib/ app/lib/
COPY generic-application.q /app/generic-application.q
COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/q/l64/q
RUN chmod +x /app/entrypoint.sh
RUN useradd -ms /bin/bash appuser

USER appuser

ENTRYPOINT ["/app/entrypoint.sh"]

