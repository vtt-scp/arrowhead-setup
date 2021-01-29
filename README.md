# arrowhead-setup <!-- omit in toc -->
This project is derived and expanded from scripts and docker-compose found in [Arrowhead framework core project](https://github.com/eclipse-arrowhead/core-java-spring).

- Setup Arrowhead Framework core systems utilizing Docker and Docker-compose.
- Create PKCS #12 certificates and unpack them for clients.


## Table of Contents <!-- omit in toc -->
- [Running Arrowhead core systems with Docker](#running-arrowhead-core-systems-with-docker)
  - [Requirements](#requirements)
  - [Create certificates](#create-certificates)
    - [Insert your information](#insert-your-information)
    - [PKCS #12 password](#pkcs-12-password)
    - [Run certificate generation script](#run-certificate-generation-script)
  - [Start Arrowhead Core systems](#start-arrowhead-core-systems)
    - [...with default options](#with-default-options)
    - [...with docker images from jars](#with-docker-images-from-jars)
    - [...with lower memory usage (and less performance)](#with-lower-memory-usage-and-less-performance)
    - [...with management tool](#with-management-tool)
    - [...with all above options](#with-all-above-options)
  - [Shut down Arrowhead core systems](#shut-down-arrowhead-core-systems)
- [P12 certificate unpacking for clients](#p12-certificate-unpacking-for-clients)
  - [Python script unpack_p12.py](#python-script-unpack_p12py)
  - [Command line openssl unpack](#command-line-openssl-unpack)


## Running Arrowhead core systems with Docker


### Requirements
Requires Docker, which can be installed for Ubuntu or Raspberry Pi following the guide [here](https://docs.docker.com/engine/install/ubuntu/).  
For windows you need to download and install [Docker Desktop](https://www.docker.com/products/docker-desktop).

You also need to separately install docker-compose on Linux systems to which instructions can be found [here](https://docs.docker.com/compose/install/)


### Create certificates
Certificates are needed for HTTPS communication between the Arrowhead core and client systems.


#### Insert your information
Edit the script `./certs/scripts/create_p12_certs.sh` with your information to following fields:

- COMPANY
  - Your company name
- CLOUD
  - Your Arrowhead cloud name
- COMMON_SAN
  - Append here your dns and/or ip address of Arrowhead core systems host
  - Append dns and/or ip addresses you plan to decribe your client systems with
- YOUR CLIENTS
  - Append to the list of `create_consumer_system_keystore` your desired client system names


#### PKCS #12 password
You may set your own password to the P12 files before creating the certificates.  
By default the password is `123456`.

Edit the script `./certs/scripts/lib_certs.sh` with your desired default password for the .p12 certificate stores.

Also remember to set the same password to Arrowhead core properties in `./core_system_config` folder:
- `server.ssl.key-store-password`
- `server.ssl.key-password`
- `server.ssl.trust-store-password`


#### Run certificate generation script
Create the certificates for both Arrowhead core systems and clients by running the script found in directory:
```
cd ./certs/scripts
```
From there run command:
```
./create_p12_certs.sh
```
The script generates the certificates into a PKCS #12 (.p12) store within `./certs` folder. Incase the certificate already existed, it is not overwritten by the script.

If you run into errors executing the script you may need to run `dos2unix` / `unix2dos` on the script depending on which OS you're using.


### Start Arrowhead Core systems
Ensure you have the necessary .p12 certificates and truststore for the core systems in `./certs` folder.

Change `MYSQL_ROOT_PASSWORD` within `docker-compose.yml`.

Once Docker is up and running you need to create a volume for the MariaDB database:
```
docker volume create --name=mysql
```

#### ...with default options
Run following command to start Arrowhead Core systems with existing docker images:
```
docker-compose up --build
```


#### ...with docker images from jars
Ensure `.jar` packages for core systems are located in `./jars` folder.
Instuctions on how to build `.jar` files for Arrowhead core systems can be found in [core-java-spring](https://github.com/eclipse-arrowhead/core-java-spring) repository.

```
docker-compose \
-f docker-compose.yml \
-f docker-compose.jars.yml \
up --build
```

You may need to use this option to get Arrowhead running on Raspberry Pi as existing docker images may not support RPi processor architecture.

#### ...with lower memory usage (and less performance)
Recommended when running for example on Raspberry Pi

```
docker-compose \
-f docker-compose.yml \
-f docker-compose.low_mem.yml \
up --build
```


#### ...with management tool
```
docker-compose \
-f docker-compose.yml \
-f docker-compose.mgmt_tool.yml \
up --build
```


#### ...with all above options
```
docker-compose \
-f docker-compose.yml \
-f docker-compose.jars.yml \
-f docker-compose.low_mem.yml \
-f docker-compose.mgmt_tool.yml \
up --build
```


### Shut down Arrowhead core systems
To stop running Arrowhead press `CTRL+C` to interrupt.  
To clean up any remaining resources run:
```
docker-compose down
```


## P12 certificate unpacking for clients

### Python script unpack_p12.py

Requires Python>3.7 and pyOpenSSL.
```
pip install pyOpenSSL
```

Using via command line:
```
        script:                     path to file:         passphrase:
python3 certs/scripts/unpack_p12.py certs/your_client.p12 123456
```
Output:
```
Created file: certs/your_client.crt
Created file: certs/your_client.key
Created file: certs/your_client.ca
```


### Command line openssl unpack

Certificate
```
openssl pkcs12 -in your_client.p12 -clcerts -nokeys > your_client.crt
```
Private Key
```
openssl pkcs12 -in your_client.p12 -nocerts -nodes > your_client.key
```
CA Certificates
```
openssl pkcs12 -in your_client.p12 -cacerts -nokeys -chain > your_client.ca
```
Show SAN from .crt/.key/.ca:
```
openssl x509 -text -noout -in your_client.pem | grep DNS
```