version: '3'

services:
  zabbix-agent:
    image: kuzma343/zabbix-agent:alpine-6.2-latest
    ports:
      - "161:161/udp"
      - "10050:10050"
      - "1099:1099"
      - "9999:9999"

  mariadb:
    image: kuzma343/mariadb:10.5
    environment:
      MYSQL_ROOT_PASSWORD: your_root_password
      MYSQL_USER: your_user
      MYSQL_PASSWORD: your_password
      MYSQL_DATABASE: your_database_name
    ports:
      - "3306:3306"

  zabbix-server:
    image: kuzma343/zabbix-server-mysql:alpine-6.2-latest
    environment:
      DB_SERVER_HOST: mariadb
      MYSQL_USER: your_user
      MYSQL_PASSWORD: your_password
      MYSQL_DATABASE: your_database_name
    ports:
      - "10051:10051"

  zabbix-web:
    image: kuzma343/zabbix-web-nginx-mysql:alpine-6.2-latest
    environment:
      DB_SERVER_HOST: mariadb
      MYSQL_USER: your_user
      MYSQL_PASSWORD: your_password
      MYSQL_DATABASE: your_database_name
      ZBX_SERVER_HOST: zabbix-server
    ports:
      - "8080:8080"
      - "443:443"
