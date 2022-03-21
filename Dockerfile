FROM python:3.9-slim

RUN mkdir recordings

RUN apt-get update && apt-get install -y \
    netcat-openbsd \
    socat \
    mosquitto-clients \
    jq \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt

COPY ./bin/to_csv /usr/local/bin/to_csv
RUN chmod a+x /usr/local/bin/to_csv

COPY ./bin/raw_to_brefv.sh /usr/local/bin/raw_to_brefv
RUN chmod a+x /usr/local/bin/raw_to_brefv

ENTRYPOINT ["/bin/bash", "-l", "-c"]