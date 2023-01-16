DROP DATABASE IF EXISTS `arrowhead`;
CREATE DATABASE `arrowhead`;
USE `arrowhead`;

-- create tables
source  docker-entrypoint-initdb.d/privileges/create_arrowhead_tables.sql

-- Set up privileges

-- Service Registry
CREATE USER IF NOT EXISTS 'service_registry'@'localhost' IDENTIFIED BY 'ZzNNpxrbZGVvfJ8';
CREATE USER IF NOT EXISTS 'service_registry'@'%' IDENTIFIED BY 'ZzNNpxrbZGVvfJ8';
source  docker-entrypoint-initdb.d/privileges/service_registry_privileges.sql

-- Authorization
CREATE USER IF NOT EXISTS 'authorization'@'localhost' IDENTIFIED BY 'hqZFUkuHxhekio3';
CREATE USER IF NOT EXISTS 'authorization'@'%' IDENTIFIED BY 'hqZFUkuHxhekio3';
source  docker-entrypoint-initdb.d/privileges/authorization_privileges.sql

-- Orchestrator
CREATE USER IF NOT EXISTS 'orchestrator'@'localhost' IDENTIFIED BY 'KbgD2mTr8DQ4vtc';
CREATE USER IF NOT EXISTS 'orchestrator'@'%' IDENTIFIED BY 'KbgD2mTr8DQ4vtc';
source  docker-entrypoint-initdb.d/privileges/orchestrator_privileges.sql

-- Event Handler
CREATE USER IF NOT EXISTS 'event_handler'@'localhost' IDENTIFIED BY 'gRLjXbqu9YwYhfK';
CREATE USER IF NOT EXISTS 'event_handler'@'%' IDENTIFIED BY 'gRLjXbqu9YwYhfK';
source  docker-entrypoint-initdb.d/privileges/event_handler_privileges.sql

-- Gatekeeper
CREATE USER IF NOT EXISTS 'gatekeeper'@'localhost' IDENTIFIED BY 'fbJKYzKhU5t8QtT';
CREATE USER IF NOT EXISTS 'gatekeeper'@'%' IDENTIFIED BY 'fbJKYzKhU5t8QtT';
source  docker-entrypoint-initdb.d/privileges/gatekeeper_privileges.sql

-- Gateway
CREATE USER IF NOT EXISTS 'gateway'@'localhost' IDENTIFIED BY 'LfiSM9DpGfDEP5g';
CREATE USER IF NOT EXISTS 'gateway'@'%' IDENTIFIED BY 'LfiSM9DpGfDEP5g';
source  docker-entrypoint-initdb.d/privileges/gateway_privileges.sql

-- Certificate Authority
CREATE USER IF NOT EXISTS 'certificate_authority'@'localhost' IDENTIFIED BY 'FsdG6Kgf9QpPfv2';
CREATE USER IF NOT EXISTS 'certificate_authority'@'%' IDENTIFIED BY 'FsdG6Kgf9QpPfv2';
source  docker-entrypoint-initdb.d/privileges/certificate_authority_privileges.sql
