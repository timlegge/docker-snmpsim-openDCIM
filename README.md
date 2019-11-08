# docker-snmpsim-openDCIM

This docker image starts up snmpsim.

The UDP port `161` should be mapped to the desired SNMP port.

By default this image contains snmp data files useful for testing with openDCIM

To use your own snmpwalks you should mount a folder with snmpwalks like this:

    docker run -v snmpsim_data:/usr/local/snmpsim/data \
               -p 161:161/udp \
               timlegge/docker-snmpsim-opendcim

In this case snmpsim_data is a volume created under /var/lib/docker/volumes

The filename/directory determines the SNMP community name.

If you want to run snmpsimd with more flags then you can use `EXTRA_FLAGS`, like this:

    docker run -v snmpsim_data:/usr/local/snmpsim/data \
               -p 161:161/udp \
               -e EXTRA_FLAGS="--v3-user=opendcim --v3-auth-key=authpass"
               timlegge/docker-snmpsim-opendcim

## Using with OpenDCIM

### Configure the device Template

The [SNMP OID Information](#SNMP-OID-Information) gives the information necessary to add to your openDCIM template.  Be sure to choose the correct device type to display the correct OID fields.

### Configure the Device
Create or modify a device using the SNMP access information from the [SNMP Devices Provided](#SNMP-Devices-Provided).  

The Hostname/IP Address is the IP address of the host that is running the docker container.  If you are using openDCIM in a container you may wish to use a Docker network for the inter-container communication. That is outside the scope of this document.

### SNMP v3
OpenDCIM is compatible with SNMPv3 however it is not compatible with snmpsimd's options for SNMP v3.  Specifically the context (Contexts allows a server to "proxy" snmp for many devices).

To run a SNMP v3 version for testing with snmpwalk you can do the following:
 
    docker run --rm --name docker-snmpsim-opendcim \
               -v snmpsim_d/usr/local/snmpsim/data:z \
               -v snmpsim_cache:/usr/local/snmpsim/cache:z \
               -p 161:161/udp -e EXTRA_FLAGS="--v3-user=opendcim \
               --v3-auth-key=authpass --v3-auth-proto=SHA \
               --v3-priv-key=privpass --v3-priv-proto=AES" \
               timlegge/docker-snmpsim-opendcim

To test this you can use:

    snmpwalk **Docker HOST IP** -v3 -u opendcim -A authpass -a SHA \
            -X privpass -x AES -l authPriv -n cisco/catalyst-3750

## Contributing Data
The easiest method is via snmpwalk with the following command:

    snmpwalk -v2c -c public -ObentU localhost 1.3.6 > myagent.snmpwalk

### Cleansing the files
Be sure to remove data from production systems.  Things to change include:
   1. IP Addresses
   2. Company Names/References
   3. Domain Names/Hostnames
   4. Email Addresses
   5. Device Specific Descriptions (from port names, etc.)

Basically read the file and think about whether you (or worse someone at your company) would want that information publically available.  Likely asking approval is a good thing as well.  Grepping the file for STRING is also useful to see what data to replace.

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
The Watchdog 15P has an internal temperature and humidity sensor and has support for external temperature probes.

openDCIM deals with the internal and each external sensor as seperate templates and as a separate device with the same IP address and SNMP info. 

This makes sense when you realize that the external sensors may actually be in separate cabinets and rack position and need to read different OIDs.
     
Type | Description | OID | Multiplier
-----|--------|-------|--------------
sensor | Internal Temperature | .1.3.6.1.4.1.21239.5.1.2.1.5.1 | 0.1
sensor | Internal Humidity | .1.3.6.1.4.1.21239.5.1.2.1.6.1 | 1
sensor | External Temperature 1 | .1.3.6.1.4.1.21239.5.1.4.1.5.2 | 0.1
sensor | External Temperature 2 | .1.3.6.1.4.1.21239.5.1.4.1.5.3 | 0.1

#### Geist Responses
The simulator uses the built in variation modules to provide changable values for some of the OIDs:

   1. OID values for temperature are set using a numeric between 100 and 300 (0.1 multiplier)
   2. OID value for Humidity is set using a numeric between  25 and 50
 
Both increment until the values wraps and then repeats

### APC Power Distribution Units
The following settings are common for the following devices:
   1. AP7902B	
   2. AP8641
   3. AP8932

Type | Description | OID | Notes
-----|-------------|-----|-------
cdu | Firmware | .1.3.6.1.4.1.318.1.1.4.1.2.0
cdu | Power Outlet Names | .1.3.6.1.4.1.318.1.1.4.4.2.1.4 | (No standard names provided)
cdu | Power Connections | .1.3.6.1.4.1.318.1.1.4.4.2.1.4 | (No standard names provided)
cdu | Power Outlet Count | .1.3.6.1.4.1.318.1.1.4.4.1.0 |
cdu | Outlet State | .1.3.6.1.4.1.318.1.1.26.9.2.3.1.5 | On/Off State (1=off, 2=on)


Model   | Description | OID | Notes | Multiplier
--------|-------------|-----|-------|------------
AP7902B | OID for Phase1 | .1.3.6.1.4.1.318.1.1.12.2.3.1.1.2.1 | Phase 1 (or Bank 1 & 2 | 0.1 AMPS
AP7902B | OID for Phase2 | .1.3.6.1.4.1.318.1.1.12.2.3.1.1.2.2 | Phase 2 (or Bank 1) | 0.1 AMPS
AP7902B | OID for Phase3 | .1.3.6.1.4.1.318.1.1.12.2.3.1.1.2.3 | Phase 3 (or Bank 2) | 0.1 AMPS

#### APC Responses
The simulator uses the built in variation modules to provide changable values for some of the OIDs:

   1. Power Outlet Names -> .1.3.6.1.4.1.318.1.1.4.4.2.1.4 are set to an initial value that can be changed by performing an snmpset command:

    snmpset -v2c -c [community] [DOCKER HOST IP Address] \
        .1.3.6.1.4.1.318.1.1.4.4.2.1.4.1 s "My new Port Description"

Note that the command for the snmpset needs to have the port number appended to the OID from the table above.

   2. Outlet State -> .1.3.6.1.4.1.318.1.1.26.9.2.3.1.5 are set using a numeric between 1 and 2 for half the records (essentially it flips each time it is queried)

### Tripplite Power Transfer Switch
Type | Description | OID | Notes
-----|--------|-------|--------------
cdu | Firmware | .1.3.6.1.4.1.850.1.2.1.1.2.0 | 
cdu | Power Outlet Names | .1.3.6.1.4.1.850.1.1.3.4.3.3.1.1.2.1 |
cdu | Power Connections | .1.3.6.1.4.1.850.1.1.3.4.3.3.1.1.3.1 |
cdu | Power Outlet Count | .1.3.6.1.4.1.850.1.1.3.4.1.2.1.4.1 | 
cdu | Outlet State | .1.3.6.1.4.1.850.1.1.3.4.3.3.1.1.4.1 | On/Off State (1=off, 2=on)
cdu | ATS Status OID | .1.3.6.1.4.1.850.1.1.3.4.3.1.1.1.12.1 | Source Availability (1=A, 2=B, 3=Both)

#### Tripplite Responses
The simulator uses the built in variation modules to provide changable values for some of the OIDs:

   1. Power Outlet Names -> .1.3.6.1.4.1.850.1.1.3.4.3.3.1.1.2.1 are set to an initial value that can be changed by performing an snmpset command:

    snmpset -v2c -c tripplite/pdumh20atnet [DOCKER HOST IP Address] \
        .1.3.6.1.4.1.850.1.1.3.4.3.3.1.1.3.1.1 s "My new Port Description"

Note that the command for the snmpset needs to have the port number appended to the OID from the table above.
   2. Outlet State -> .1.3.6.1.4.1.850.1.1.3.4.3.3.1.1.4.1 are set using a numeric between 1 and 2 for half the records (essentially it flips each time it is queried)
   3. ATS Status OID -> .1.3.6.1.4.1.850.1.1.3.4.3.1.1.1.12.1 is set to an intial value of 3 that can be changed by performing an snmpset command:

    snmpset -v2c -c tripplite/pdumh20atnet [DOCKER HOST IP Address ] \
        192.168.10.172 .1.3.6.1.4.1.850.1.1.3.4.3.1.1.1.12.1 i 3
