#!/bin/bash

docker-compose down

docker volume rm pki_tik_ca_data
docker volume rm pki_svc_ca_data
docker volume rm pki_root_ca_data
docker volume rm pki_cert_db_data

docker-compose up --no-start
docker-compose start cert_db
echo "waiting for cert_db to be initialized"
sleep 2

docker-compose start sub_ca
echo "waiting for sub_ca to be initialized"
sleep 10
docker-compose logs sub_ca

docker-compose start svc_ca
echo "waiting for svc_ca to be initialized"
sleep 4
docker-compose logs svc_ca

docker-compose start tik_ca
echo "waiting for tik_ca to be initialized"
sleep 4
docker-compose logs tik_ca





