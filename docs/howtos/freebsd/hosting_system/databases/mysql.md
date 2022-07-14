---
title: 'MySQL'
description: 'In diesem HowTo wird step-by-step die Installation des MySQL Datenbanksystem für ein WebHosting System auf Basis von FreeBSD 64Bit auf einem dedizierten Server beschrieben.'
date: '2010-08-25'
updated: '2022-07-14'
author: 'Markus Kohlmeyer'
author_url: https://github.com/JoeUser78
contributors:
    - 'Jesco Freund'
    - 'Matthias Weiss'
tags:
    - FreeBSD
    - MySQL
---

# MySQL

## Einleitung

Zu den Voraussetzungen für dieses HowTo siehe bitte: [Voraussetzungen](/howtos/freebsd/hosting_system/)

Unser WebHosting System wird um folgende Dienste erweitert.

- MySQL 8.0.29 (InnoDB, GTID)

## Installation

MySQL unterstützt mehrere Engines, dieses HowTo beschränkt sich allerdings auf die am Häufigsten verwendete: InnoDB

Wir installieren `databases/mysql80-client` und dessen Abhängigkeiten.

``` bash
cat >> /etc/make.conf << "EOF"
DEFAULT_VERSIONS+=mysql=8.0
"EOF"
```

``` bash
mkdir -p /var/db/ports/security_libfido2
cat > /var/db/ports/security_libfido2/options << "EOF"
_OPTIONS_READ=libfido2-1.11.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/comms_hidapi
cat > /var/db/ports/comms_hidapi/options << "EOF"
_OPTIONS_READ=hidapi-0.12.0
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/print_gsfonts
cat > /var/db/ports/print_gsfonts/options << "EOF"
_OPTIONS_READ=gsfonts-8.11
_FILE_COMPLETE_OPTIONS_LIST=DOCS
OPTIONS_FILE_SET+=DOCS
"EOF"

mkdir -p /var/db/ports/databases_mysql80-client
cat > /var/db/ports/databases_mysql80-client/options << "EOF"
_OPTIONS_READ=mysql80-client-8.0.29
_FILE_COMPLETE_OPTIONS_LIST=SASLCLIENT
OPTIONS_FILE_UNSET+=SASLCLIENT
"EOF"


cd /usr/ports/databases/mysql80-client
make all install clean-depends clean
```

Wir installieren `databases/mysql80-server` und dessen Abhängigkeiten.

``` bash
mkdir -p /var/db/ports/databases_mysql80-server
cat > /var/db/ports/databases_mysql80-server/options << "EOF"
_OPTIONS_READ=mysql80-server-8.0.29
_FILE_COMPLETE_OPTIONS_LIST= ARCHIVE BLACKHOLE EXAMPLE FEDERATED INNOBASE PARTITION PERFSCHEMA PERFSCHM
OPTIONS_FILE_UNSET+=ARCHIVE
OPTIONS_FILE_UNSET+=BLACKHOLE
OPTIONS_FILE_UNSET+=EXAMPLE
OPTIONS_FILE_UNSET+=FEDERATED
OPTIONS_FILE_UNSET+=INNOBASE
OPTIONS_FILE_UNSET+=PARTITION
OPTIONS_FILE_UNSET+=PERFSCHEMA
OPTIONS_FILE_UNSET+=PERFSCHM
"EOF"


cd /usr/ports/databases/mysql80-server
make all install clean-depends clean


mkdir -p /data/db/mysql{,_secure,_tmpdir}
chmod 0750 /data/db/mysql{_secure,_tmpdir}
chown mysql:mysql /data/db/mysql{,_secure,_tmpdir}


sysrc mysql_enable=YES
sysrc mysql_dbdir="/data/db/mysql"
sysrc mysql_optfile="/usr/local/etc/mysql/my.cnf"
```

## Konfiguration

???+ note

    Die Konfiguration orientiert sich an diesem [RootForum Community Forenbeitrag](https://www.rootforum.org/forum/viewtopic.php?t=36343){: target="_blank" rel="noopener"}.

``` bash
cat > /usr/local/etc/mysql/my.cnf << "EOF"
[client]
port                            = 3306
socket                          = /tmp/mysql.sock

[mysqld]
user                            = mysql
port                            = 3306
socket                          = /tmp/mysql.sock
bind_address                    = 127.0.0.1,::1
basedir                         = /usr/local
datadir                         = /data/db/mysql
tmpdir                          = /data/db/mysql_tmpdir
secure_file_priv                = /data/db/mysql_secure
log_bin                         = mysql-bin
log_output                      = TABLE,FILE
relay_log_recovery              = ON
slow_query_log                  = OFF
slow_query_log_file             = slow-query.log
server_id                       = 1
sync_binlog                     = 1
sync_relay_log                  = 1
binlog_cache_size               = 256K
binlog_stmt_cache_size          = 256K
enforce_gtid_consistency        = ON
gtid_mode                       = ON
max_connections                 = 501
safe_user_create                = ON
lower_case_table_names          = 1
myisam_recover_options          = FORCE,BACKUP
net_retry_count                 = 16384
open_files_limit                = 32768
table_open_cache                = 8192
table_definition_cache          = 4096
join_buffer_size                = 512K
sort_buffer_size                = 2048K
read_buffer_size                = 256K
read_rnd_buffer_size            = 512K
max_heap_table_size             = 256M
tmp_table_size                  = 256M
long_query_time                 = 0.05
innodb_thread_concurrency       = 8
innodb_buffer_pool_size         = 2G
innodb_buffer_pool_instances    = 2
innodb_data_home_dir            = /data/db/mysql
innodb_log_group_home_dir       = /data/db/mysql
innodb_data_file_path           = ibdata1:1G;ibdata2:1G;ibdata3:128M:autoextend
innodb_temp_data_file_path      = ibtmp1:128M:autoextend
innodb_flush_method             = O_DIRECT
innodb_log_file_size            = 256M
innodb_sort_buffer_size         = 2048K
#log_queries_not_using_indexes   = ON
skip_name_resolve               = ON

mysqlx                          = OFF
mysqlx_port                     = 33060
mysqlx_socket                   = /tmp/mysqlx.sock
mysqlx_bind_address             = 127.0.0.1,::1
"EOF"
```

## Sicherheit

MySQL wird nun zum ersten Mal gestartet, was durch das Erzeugen der InnoDB-Files einige Minuten dauern kann.

``` bash
service mysql-server start
```

Abschliessend wird das MySQL root-Passwort neu gesetzt und mittels `mysql_config_editor` verschlüsselt in `/root/.mylogin.cnf` gespeichert.

``` bash
# First set new MySQL-root password
mysqladmin -h localhost -uroot password --default-auth=caching_sha2_password

# Setup /root/.mylogin.cnf
mysql_config_editor set --login-path=client --host=::1 --host=127.0.0.1 --host=localhost --socket=/tmp/mysql.sock --user=root --password
```

Wir erlauben dem MySQL-root User das Einloggen von `::1`, `127.0.0.1` und `localhost` mit dem zuvor festgelegtem Passwort.

``` bash
mysql -h localhost -uroot --default-auth=caching_sha2_password

ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '__MYSQL_ROOT_PASSWORD__' PASSWORD EXPIRE NEVER;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
CREATE USER 'root'@'127.0.0.1' IDENTIFIED WITH caching_sha2_password BY '__MYSQL_ROOT_PASSWORD__' PASSWORD EXPIRE NEVER;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION;
CREATE USER 'root'@'::1' IDENTIFIED WITH caching_sha2_password BY '__MYSQL_ROOT_PASSWORD__' PASSWORD EXPIRE NEVER;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'::1' WITH GRANT OPTION;
FLUSH PRIVILEGES;
QUIT;
```

## Abschluss

MySQL sollte abschliessend einmal neu gestartet werden.

``` bash
service mysql-server restart
```
