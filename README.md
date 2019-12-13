# php-fpm-laravel
Dockerfile for running Laravel
``` 
docker pull chrsc/php-fpm-laravel:7.3 
```

## docker compose
Using this docker compose file, you need to have the following directory structure and files:
- folder: docker/config
- file: docker/config/default.conf
  ``` config
  server {
	  listen 80 default_server;
	  listen 443 ssl;

	  ssl_certificate /etc/nginx/certs/localhost.crt;
	  ssl_certificate_key /etc/nginx/certs/localhost.key;

	  # Doesn't really matter because default server, but this way email doesn't throw errors
	  server_name localhost;

	  access_log   /var/log/nginx/access.log;
	  error_log    /var/log/nginx/error.log;

  	root /var/www/public;
	  index index.php index.html;
  
  	location / {
  		try_files $uri $uri/ /index.php?$args;
	  }

  	error_page 404 /index.php;

	  location ~ \.php$ {
		  try_files $uri =404;
  		fastcgi_split_path_info ^(.+\.php)(/.+)$;

	  	include /etc/nginx/fastcgi_params;
		  fastcgi_pass unpac-phpfpm:9000;
  		fastcgi_index index.php;
	  	fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
  	}

	  location ~* ^.+\.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf)$ {
		  access_log off; log_not_found off; expires max;

  		add_header Access-Control-Allow-Origin *;
	  }

  	# This should match upload_max_filesize in php.ini
	  client_max_body_size 100m;
  }
  ```
- file: docker/config/redis.conf
  ``` conf
  bind 127.0.0.1
  port 6379
  tcp-backlog 511
  timeout 0
  tcp-keepalive 300
  supervised no
  pidfile /var/run/redis_6379.pid
  loglevel notice
  logfile ""
  databases 16
  save 900 1
  save 300 10
  save 60 10000
  stop-writes-on-bgsave-error yes
  rdbcompression yes
  rdbchecksum yes
  dbfilename dump.rdb
  dir ./
  slave-serve-stale-data yes
  slave-read-only yes
  repl-diskless-sync no
  repl-diskless-sync-delay 5
  repl-disable-tcp-nodelay no
  slave-priority 100
  lazyfree-lazy-eviction no
  lazyfree-lazy-expire no
  lazyfree-lazy-server-del no
  slave-lazy-flush no
  appendonly no
  appendfilename "appendonly.aof"
  appendfsync everysec
  no-appendfsync-on-rewrite no
  auto-aof-rewrite-percentage 100
  auto-aof-rewrite-min-size 64mb
  aof-load-truncated yes
  aof-use-rdb-preamble no
  lua-time-limit 5000
  slowlog-max-len 128
  latency-monitor-threshold 0
  notify-keyspace-events ""
  hash-max-ziplist-entries 512
  hash-max-ziplist-value 64
  list-max-ziplist-size -2
  list-compress-depth 0
  set-max-intset-entries 512
  zset-max-ziplist-entries 128
  zset-max-ziplist-value 64
  hll-sparse-max-bytes 3000
  activerehashing yes
  client-output-buffer-limit normal 0 0 0
  client-output-buffer-limit slave 256mb 64mb 60
  client-output-buffer-limit pubsub 32mb 8mb 60
  hz 10
  aof-rewrite-incremental-fsync yes
  ```
- file: docker/config/php-fpm/php.ini
  ``` conf
  # empty
  ```
- folder: docker/logs
- folder: docker/certs
- file: docker/certs/localhost.crt

  ``` text
  -----BEGIN CERTIFICATE-----
  MIICsjCCAhugAwIBAgIJAK9HXB0+bKUaMA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNV
  BAYTAkFVMRMwEQYDVQQIEwpTb21lLVN0YXRlMSEwHwYDVQQKExhJbnRlcm5ldCBX
  aWRnaXRzIFB0eSBMdGQwIBcNMTcwNjI3MTkwMTE2WhgPMjA4NTA3MTUxOTAxMTZa
  MEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIEwpTb21lLVN0YXRlMSEwHwYDVQQKExhJ
  bnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJ
  AoGBALvW04ukqYNjqoG70UM3RDlPVYtExJAUapDDuxYm6j861/LPPPFjFOT3XygC
  WDRGJAQuSx+SSU8tD+scsZwl1sKppLX19BbnDAWxXVuCoxD7CdL+HORQ/oYCWVn8
  6L1Nucn41NkCytz/lVMYYIu0U3Jpib7XvV2sRgVvS9byjT9xAgMBAAGjgacwgaQw
  HQYDVR0OBBYEFJWQDkQ3kfZNEFvRd7JT3frl0fjSMHUGA1UdIwRuMGyAFJWQDkQ3
  kfZNEFvRd7JT3frl0fjSoUmkRzBFMQswCQYDVQQGEwJBVTETMBEGA1UECBMKU29t
  ZS1TdGF0ZTEhMB8GA1UEChMYSW50ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkggkAr0dc
  HT5spRowDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOBgQAt8ASJ/0zYHOIp
  WBOKSbammIFLnh/2Mttosi/HWpmr0+5GMN7yAPZKadK8XHbg1D4zw7YaJ18EBIcu
  Fp9+Dvs/uyvzG9Q4oJWt4eYTY4uu8GYv0jaQnBmybQZfrkf8VLSCPZ0SPVc1+vBs
  Fsm4eOUWHCfe11QxWE/b6q2zwUqULQ==
  -----END CERTIFICATE-----
  ```

- file: docker/certs/localhost.key 
  ``` text
  -----BEGIN RSA PRIVATE KEY-----
  MIICXAIBAAKBgQC71tOLpKmDY6qBu9FDN0Q5T1WLRMSQFGqQw7sWJuo/Otfyzzzx
  YxTk918oAlg0RiQELksfkklPLQ/rHLGcJdbCqaS19fQW5wwFsV1bgqMQ+wnS/hzk
  UP6GAllZ/Oi9TbnJ+NTZAsrc/5VTGGCLtFNyaYm+171drEYFb0vW8o0/cQIDAQAB
  AoGAWJn3hPnxn3EmnzU5ewwZmTLLtfqFATUwIwLAP62xdovKCtUn+PB0jaAFeXjJ
  pDaljHdNpiG5hKhLxuns+St8Bd1P1/sZ7a4m8HXpW3JiE8yCBYXxUFNrCJH3pExs
  KnM3o+S2woZ9RT8UzWdzODIhQgRmWERbeghtnkOJkFkkg6UCQQDhDhYRk+VkNQTh
  1njsRDR+0C11oF57ioggWmzDlRaDEYU0WnqoIjvXNXgljo347zA74S2NJzGI52Dj
  feinvLhHAkEA1aq+5/Icn/5Cf8vGOd9Po+cD9xWokVx5ETStrDOBKp7NWz32do1F
  MN7i8BlN7N5ht2X/NAwJeTEXADD557JehwJBANb/LfX849enDtLwoPSU89Fx7vvA
  CILdBM5jlCQD+U2dHzO0fBjDG4esfOrkFJ0LY3jQ1UNTfe7bm6O4VNppX2ECQEMA
  WwMS+gT1z1aRyORG8YtdGvI1WXnTvKc3lKpmMD/0MkNFZ+7/F85eZl2SIcyAY7YG
  BwQELkhRq3vE3+jXFysCQFW8Eq1qzfv07DInCz6KJ3OuN+AvPxaNnuSh4ENHMxS0
  jsHubtcvg7w6jKsBYuifVba5bp/pqC9/xZctoEkItVI=
  -----END RSA PRIVATE KEY-----
  ```
- folder: docker/data/db
- folder: docker/data/redis

