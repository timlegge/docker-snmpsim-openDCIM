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
    git checkout bd2ce1ac6944a312ca9b15819ea5a777ab75dae2 && \
    python setup.py install

EXPOSE 161/udp

CMD snmpsimd.py --v3-engine-id=201e20fde8d064c6 --agent-udpv4-endpoint=0.0.0.0:161 --data-dir=/usr/local/snmpsim/data --cache-dir=/usr/local/snmpsim/cache --process-user=snmpsim --process-group=snmpsim $EXTRA_FLAGS
