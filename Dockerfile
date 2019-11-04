FROM python:3.8.0-alpine3.10

#RUN sed -n 's/main/testing/p' /etc/apk/repositories >> /etc/apk/repositories && \
RUN apk add --update && \
    apk add py3-asn1 py3-snmp py3-ply && \
    apk add sudo gcc libc-dev git patch diffutils

RUN adduser --system snmpsim
RUN addgroup --system snmpsim

COPY snmpsim.diff /

ADD data /usr/local/snmpsim/data

RUN mkdir -p /usr/local/snmpsim/cache && \
    chown -R snmpsim:snmpsim /usr/local/snmpsim/cache && \
    cd /home/snmpsim && \
    git clone https://github.com/etingof/snmpsim.git && \
    cd snmpsim && \
    patch -p1 < /snmpsim.diff && \
    rm -fr /home/snmpsim/snmpsim/data/* && \
    python setup.py install

EXPOSE 161/udp

CMD snmpsimd.py --agent-udpv4-endpoint=0.0.0.0:161 --data-dir=/usr/local/snmpsim/data --cache-dir=/usr/local/snmpsim/cache --process-user=snmpsim --process-group=snmpsim $EXTRA_FLAGS
