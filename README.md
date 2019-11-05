# docker-snmpsim-openDCIM

This docker image starts up snmpsim.

The UDP port `161` should be mapped to the desired SNMP port.

By default this image contains snmp data files usefull for testing with openDCIM

To use your own snmpwalks you should mount a folder with snmpwalks like this:

    docker run -v snmpsim_data:/usr/local/snmpsim/data \
               -p 161:161/udp \
               timlegge/docker-snmpsim-opendcim

The filename determines the SNMP community name.

If you want to run snmpsimd with more flags then you can use `EXTRA_FLAGS`, like this:

    docker run -v snmpsim_data:/usr/local/snmpsim/data \
               -p 161:161/udp \
               -e EXTRA_FLAGS="--v3-user=testing --v3-auth-key=testing123"
               timlegge/docker-snmpsim-opendcim

### SNMP v3
OpenDCIM is compatible with SNMPv3 however it is not compatible with snmpsimd's options for SNMP v3.  Specifically the context	

To run a SNMP v3 version for testing with snmpwalk you can do the following:
 
    docker run --rm --name docker-snmpsim-opendcim \
               -v snmpsim_d/usr/local/snmpsim/data:z \
               -v snmpsim_cache:/usr/local/snmpsim/cache:z \
               -p 161:161/udp -e EXTRA_FLAGS="--v3-user=testing \
               --v3-auth-key=authpass --v3-auth-proto=SHA \
               --v3-priv-key=privpass --v3-priv-proto=AES" \
               timlegge/docker-snmpsim-opendcim

To test this you can use:
    snmpwalk **Docker HOST IP** -v3 -u testing -A authpass -a SHA \
            -X privpass -x AES -l authPriv -n cisco/catalyst-3750

## SNMP Devices Provided

Type | Vendor | Model | Community | V3 Context Name
-----|--------|-------|-----------|----------------
switch | Cisco | Catalyst 3750 | cisco/catalyst-3750 | cisco/catalyst-3750
switch | Cisco | Catalyst 3560 | cisco/catalyst-3560 | cisco/catalyst-3560
switch | Cisco | Nexus 5000 | cisco/nexus-5000 | cisco/nexus-5000
