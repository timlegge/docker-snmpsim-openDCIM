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
cdu | APC | AP7902B | apc/ap7902b | apc/ap7902b
cdu | APC | AP8641 | apc/ap8641 | apc/ap8641
cdu | APC | AP8932 | apc/ap8932 | apc/ap8932
cdu | Tripplite | pdumh20atnet | tripplite/pdumh20atnet | tripplite/pdumh20atnet
switch | Cisco | Catalyst 3750 | cisco/catalyst-3750 | cisco/catalyst-3750
switch | Cisco | Catalyst 3560 | cisco/catalyst-3560 | cisco/catalyst-3560
switch | Cisco | Nexus 5000 | cisco/nexus-5000 | cisco/nexus-5000
sensor | Geist | WatchDog 15P | geist/watchdog15p | geist/watchdog15p

## SNMP OID Information
### Geist Watchdog 15P
Type | Description | OID | Multiplier
-----|--------|-------|--------------
sensor | Internal Temperature | .1.3.6.1.4.1.21239.5.1.2.1.5.1 | 0.1
sensor | Internal Humidity | .1.3.6.1.4.1.21239.5.1.2.1.6.1 | 1
sensor | External Temperature 1 | .1.3.6.1.4.1.21239.5.1.4.1.5.2 | 0.1
sensor | External Temperature 2 | .1.3.6.1.4.1.21239.5.1.4.1.5.3 | 0.1
 
### APC Power Distribution Units
The following settings are common for the following devices:
   1. AP7902B
   2. AP8641
   3. AP8932

Type | Description | OID | Notes
-----|--------|-------|--------------
cdu | Firmware | .1.3.6.1.4.1.318.1.1.4.1.2.0 |
cdu | Power Outlet Names | .1.3.6.1.4.1.318.1.1.4.4.2.1.4 | (No standard names provided)
cdu | Power Connections | .1.3.6.1.4.1.318.1.1.4.4.2.1.4 | (No standard names provided)
cdu | Power Outlet Count | .1.3.6.1.4.1.318.1.1.4.4.1.0 |
cdu | Outlet State | .1.3.6.1.4.1.318.1.1.26.9.2.3.1.5 | On/Off State (1=off, 2=on)

### Triplite Power Transfer Switch
Type | Description | OID | Notes
-----|--------|-------|--------------
cdu | Firmware | .1.3.6.1.4.1.850.1.2.1.1.2.0 | 
cdu | Power Outlet Names | .1.3.6.1.4.1.850.1.1.3.4.3.3.1.1.2.1 |
cdu | Power Connections | .1.3.6.1.4.1.850.1.1.3.4.3.3.1.1.3.1 |
cdu | Power Outlet Count | .1.3.6.1.4.1.850.1.1.3.4.1.2.1.4.1 | 
cdu | Outlet State | .1.3.6.1.4.1.850.1.1.3.4.3.3.1.1.4.1 | On/Off State (1=off, 2=on)
cdu | ATS Status OID | .1.3.6.1.4.1.850.1.1.3.4.3.1.1.1.12.1 | Input Source Availability (1=Source A, 2=Source B, 3=Both)
