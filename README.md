# arrowhead-setup <!-- omit in toc -->
This project is derived and expanded from scripts and docker-compose found in [Arrowhead framework core project](https://github.com/eclipse-arrowhead/core-java-spring).

- Setup Arrowhead Framework core systems utilizing Docker and Docker-compose.
- Create PKCS #12 certificates and unpack them for clients.


## Table of Contents <!-- omit in toc -->
- [Requirements](#requirements)
- [Quickstart](#quickstart)
- [Setup](#setup)
  - [Arrowhead services](#arrowhead-services)
    - [Getting Arrowhead service files](#getting-arrowhead-service-files)
    - [Service file location and structure](#service-file-location-and-structure)
  - [Configuring `application.properties`](#configuring-applicationproperties)
    - [Container network](#container-network)
    - [SSL certificates and configuration](#ssl-certificates-and-configuration)
  - [SQL database initialization](#sql-database-initialization)
- [Usage](#usage)
  - [Start services](#start-services)
  - [Stop services](#stop-services)
  - [Access services](#access-services)
  - [Test service availability](#test-service-availability)
  - [Generate relay certificates](#generate-relay-certificates)
- [Troubleshooting](#troubleshooting)
    - [...with lower memory usage (and less performance)](#with-lower-memory-usage-and-less-performance)
    - [...with management tool](#with-management-tool)
    - [...with all above options](#with-all-above-options)
- [`.p12` certificate unpacking](#p12-certificate-unpacking)

## Requirements

- Docker
- Docker Compose
- Arrowhead services version [`4.6.0`](https://github.com/eclipse-arrowhead/core-java-spring/releases/tag/4.6.0)

Clone the repository to your machine with:
```
git clone https://github.com/VTT-OM/arrowhead-setup.git
```

## Quickstart
To just run a test version of a secure Arrowhead cloud (Arrowhead service configuration, certificates, SQL database tables, start containers with logs in terminal). Drop the desired Arrowhead services under the `services` folder (unzipped, foldername: i.e. `arrowhead-<service>-4.6.0`). Then run the command:
```
make all
```
Booting up all services may take a couple of minutes. If this doesn't work, keep reading the following sections.

Clean up generated files with:
```
make clean
```

## Setup
Create and set desired settings and names as environment variables to a `.env` file. The default vaules can be seen in [Makefile](Makefile). The settings configurable in `.env` file: 
```
# Information for the Arrowhead cloud certificates (keep it simple)
COMPANY=company
CLOUD=cloud
COMMON_SAN=dns:localhost,ip:127.0.0.1
# Relay system certificate name and SAN
RELAY_NAME=your_relay
RELAY_SAN=dns:localhost,ip:127.0.0.1
# Password for generated .p12 certificate/key stores
PASSWORD=123456

# Timezone used for Arrowhead service and MySQL database connection
TIMEZONE=Europe/Budapest

# MySQL root password. Default defined in docker-compose.yml.
MYSQL_ROOT_PASSWORD=changethispassword

# Develompent flag (Arrowhead services log to terminal)
DEBUG=true
```

### Arrowhead services
Arrowhead services are placed under the `services` directory to launch them containers with the `docker-compose.yml`.

#### Getting Arrowhead service files
- Latest released Arrowhead service files can be found in the [official releases](https://github.com/eclipse-arrowhead/core-java-spring/releases/).
- If 
- Instuctions on how to build `.jar` files for Arrowhead services can be found in the [official](https://github.com/eclipse-arrowhead/core-java-spring) repository.

#### Service file location and structure
Each Arrowhead service under `services` folder should include `.jar` and `application.properties` files. For example, `services/arrowhead-serviceregistry-4.6.0/` contains:
- `application.properties`
- `arrowhead-serviceregistry-4.6.0.jar`
- `log4j2.xml`

### Configuring `application.properties`
Arrowhead service `application.properties` vary between services. This repository provides scripts to automatically configure the properties of services found in `services` folder.

#### Container network
The properties require network addresses to be updated for the services to find each other within the container network formed by the `docker-compose.yml`. This can be automatically configured to all services using the commands in [Makefile](Makefile).
```
make network
```
Depending on the Arrowhead services that are used, additional configuration is required to specific `application.properties` of services.

#### SSL certificates and configuration
To generate certificates and configure Arrowhead services to use secured communication:
```
make secure
``` 

### SQL database initialization
Run following to download an organize SQL database files for MySQL service to use:
```
make sql
```
If you want to remake the certificates, delete the `certs` folder before calling the previous command:
```
make clean-sql
```

## Usage

### Start services
Start the Arrowhead services with:
```
make all
```
or
```
docker compose up
```

### Stop services
Stop services with (`CTRL+C` if running attached) and with command:
```
make down
```
or
```
docker compose down
```

### Access services
Use `sysop` certificates found in `./certs` to access secured Arrowhead core systems.

Instructions on how to import the `sysop.p12` certificate to your browser can be found [here](https://www.ibm.com/support/knowledgecenter/SSYMRC_6.0.2/com.ibm.team.jp.jrs.doc/topics/t_jrs_brwsr_cert_cfg.html).  
Default pasword for the `.p12` file is `123456` (if unchanged in the `.env` settings).

With browser you may now access Arrowhead core Swagger ui from:
```
https://localhost:8443/  # Service registry
https://localhost:8445/  # Authorization
https://localhost:8441/  # Orchestrator
https://localhost:8449/  # Gatekeeper
https://localhost:8453/  # Gateway
```

### Test service availability
```
make echo
```

### Generate relay certificates
You may generate system certificate for Arrowhead relay systems with:
```
make relay-certs
```

## Troubleshooting
For Arrowhead related issues refer to the [official documentation](https://github.com/eclipse-arrowhead/core-java-spring).
- If you run into errors executing the scripts (directly or via `make`) you may need to run `dos2unix` / `unix2dos` on the scripts depending on which OS you're using.
- `make sql` may fail if the resources accessed in [initSQL.sh](scripts/initSQL.sh) are not available. Comment out missing table generation rules from the generated `sql/create_empty_arrowhead_db.sql` file.
- Check that service names and external paths are correct in the `docker-compose.yml`.



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

## `.p12` certificate unpacking

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
Supply a password with option:
```
-passin pass:your_pass
```

Show SAN from .crt/.key/.ca:
```
openssl x509 -text -noout -in your_client.pem | grep DNS
```
