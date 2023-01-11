COMPANY?=company
CLOUD?=cloud
RELAY?=relay
COMMON_SAN?=dns:localhost,ip:127.0.0.1
TIMEZONE?=Europe/Budapest

sql:
	chmod +x $(CURDIR)/scripts/initSQL.sh
	$(CURDIR)/scripts/initSQL.sh

clean-sql:
	rm -r $(CURDIR)/sql/

certs:
	chmod +x $(CURDIR)/scripts/create_p12_certs.sh
	$(CURDIR)/scripts/create_p12_certs.sh $(COMPANY) $(CLOUD) $(RELAY) $(COMMON_SAN)

clean-certs:
	rm -r $(CURDIR)/certs/

secure: certs
	for SERVICE in $(CURDIR)/services/arrowhead-*; do \
		PROPERTIES=$$SERVICE/application.properties; \
		SERVICE_NAME=$$(grep -o "core_system_name=[a-zA-Z]*" $$PROPERTIES | tr A-Z a-z | sed "s|core_system_name=||"); \
		sed -i \
		-e "s|server.ssl.enabled=.*|server.ssl.enabled=true|" \
		-e "s|server.ssl.key-store=.*|server.ssl.key-store=file:certificates/$$SERVICE_NAME.p12|" \
		-e "s|server.ssl.key-alias=.*|server.ssl.key-alias=$$SERVICE_NAME.$(CLOUD).$(COMPANY).arrowhead.eu|" \
		-e "s|server.ssl.trust-store=.*|server.ssl.trust-store=file:certificates/truststore.p12|" \
		-e "s|cloud.ssl.key-store=.*|cloud.ssl.key-store=file:certificates/cloud/$(CLOUD).p12|" \
		-e "s|cloud.ssl.key-alias=.*|cloud.ssl.key-alias=$(CLOUD).$(COMPANY).arrowhead.eu|" \
		$$PROPERTIES; \
    done

network:
	for SERVICE in $(CURDIR)/services/arrowhead-*; do \
		PROPERTIES=$$SERVICE/application.properties; \
		SERVICE_NAME=$$(grep -o "core_system_name=[a-zA-Z]*" $$PROPERTIES | tr A-Z a-z | sed "s|core_system_name=||"); \
		sed -i \
		-e "s|spring.datasource.url=.*|spring.datasource.url=jdbc:mysql://mysql:3306/arrowhead?serverTimezone=$(TIMEZONE)|" \
		-e "s|domain.name=.*|domain.name=$$SERVICE_NAME|" \
		-e "s|sr_address=.*|sr_address=serviceregistry|" \
		$$PROPERTIES; \
    done

up:
	docker compose up -d

down:
	docker compose down

debug:
	docker compose up

low-memory:
	docker compose up -XX:+UseSerialGC -Xmx1G -Xms32m

all: down network secure sql up

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
