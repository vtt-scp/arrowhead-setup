-include .env
COMPANY?=company
CLOUD?=cloud
COMMON_SAN?=dns:localhost,ip:127.0.0.1
RELAY_NAME?=your_relay
RELAY_SAN?=dns:localhost,ip:127.0.0.1
PASSWORD?=123456
TIMEZONE?=Europe/Budapest
DEBUG?=true

all: down network secure sql
	if $(DEBUG); then\
		docker compose up; \
	else \
		docker compose up -d; \
	fi

down:
	docker compose down

clean: clean-docker clean-certs

clean-docker:
	docker compose down -v --rmi all

certs:
	chmod +x $(CURDIR)/scripts/create_p12_certs.sh
	@$(CURDIR)/scripts/create_p12_certs.sh $(COMPANY) $(CLOUD) $(COMMON_SAN) $(PASSWORD)

relay-certs: certs
	chmod +x $(CURDIR)/scripts/create_relay_cert.sh
	@$(CURDIR)/scripts/create_relay_cert.sh $(RELAY_NAME) $(RELAY_SAN) $(PASSWORD)

clean-certs:
	rm -r $(CURDIR)/certs/ ||:

secure: certs
	for SERVICE in $(CURDIR)/services/arrowhead-*; do \
		PROPERTIES=$$SERVICE/application.properties; \
		SERVICE_NAME=$$(grep -oP "core_system_name=\K\w+" $$PROPERTIES | tr A-Z a-z); \
		sed -i \
		-e "s|server.ssl.enabled=.*|server.ssl.enabled=true|" \
		-e "s|server.ssl.key-store=.*|server.ssl.key-store=file:certificates/$$SERVICE_NAME.p12|" \
		-e "s|server.ssl.key-alias=.*|server.ssl.key-alias=$$SERVICE_NAME.$(CLOUD).$(COMPANY).arrowhead.eu|" \
		-e "s|server.ssl.trust-store=.*|server.ssl.trust-store=file:certificates/truststore.p12|" \
		-e "s|cloud.ssl.key-store=.*|cloud.ssl.key-store=file:certificates/cloud/$(CLOUD).p12|" \
		-e "s|cloud.ssl.key-alias=.*|cloud.ssl.key-alias=$(CLOUD).$(COMPANY).arrowhead.eu|" \
		$$PROPERTIES; \
		sed -i -r -e "s|(\w+.ssl.+password)=.*|\1=$(PASSWORD)|" $$PROPERTIES; \
		echo Secure settings configured: $$PROPERTIES; \
    done

network:
	for SERVICE in $(CURDIR)/services/arrowhead-*; do \
		PROPERTIES=$$SERVICE/application.properties; \
		SERVICE_NAME=$$(grep -oP "core_system_name=\K\w+" $$PROPERTIES | tr A-Z a-z); \
		sed -i \
		-e "s|spring.datasource.url=.*|spring.datasource.url=jdbc:mysql://mysql:3306/arrowhead?serverTimezone=$(TIMEZONE)|" \
		-e "s|domain.name=.*|domain.name=$$SERVICE_NAME|" \
		-e "s|sr_address=.*|sr_address=serviceregistry|" \
		$$PROPERTIES; \
		echo Network settings configured: $$PROPERTIES; \
    done

low-memory:
	docker compose up -XX:+UseSerialGC -Xmx1G -Xms32m

echo:
	curl \
	--cert $(CURDIR)/certs/sysop.crt \
	--key $(CURDIR)/certs/sysop.key \
	--cacert $(CURDIR)/certs/sysop.ca \
	https://localhost:8443/serviceregistry/echo \
	https://localhost:8445/authorization/echo \
	https://localhost:8441/orchestrator/echo \
	https://localhost:8448/certificate-authority/echo \
	https://localhost:8449/gatekeeper/echo \
	https://localhost:8453/gateway/echo \
	https://localhost:8455/eventhandler/echo
