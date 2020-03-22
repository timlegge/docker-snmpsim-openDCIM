FROM python:3.8.0-alpine3.10

#RUN sed -n 's/main/testing/p' /etc/apk/repositories >> /etc/apk/repositories && \
RUN apk add --update && \
    apk add py3-asn1 py3-snmp py3-ply && \
    apk add sudo gcc libc-dev git patch diffutils

RUN adduser --system snmpsim
RUN addgroup --system snmpsim

ADD data /usr/local/snmpsim/data

RUN mkdir -p /usr/local/snmpsim/cache && \
    chown -R snmpsim:snmpsim /usr/local/snmpsim/cache && \
    chown -R snmpsim:snmpsim /usr/local/snmpsim/data && \
    cd /home/snmpsim && \
    git clone https://github.com/etingof/snmpsim.git && \
    cd snmpsim && \
#    git checkout tags/v0.4.7 -b v0.4.7 && \
    python setup.py install

EXPOSE 161/udp
CMD snmpsim-command-responder --v3-engine-id=201e20fde8d064c6 --agent-udpv4-endpoint=0.0.0.0:161 --data-dir=/usr/local/snmpsim/data --cache-dir=/usr/local/snmpsim/cache --process-user=snmpsim --process-group=snmpsim $EXTRA_FLAGS
