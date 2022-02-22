FROM ubuntu:22.04

RUN mkdir recordings

RUN apt-get update && apt-get install -y \
    socat \
    mosquitto-clients \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash", "-l", "-c"]