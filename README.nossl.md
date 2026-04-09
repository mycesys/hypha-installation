You can use your own web server to obtain TLS/SSL and run Hypha behind it.

For this, there are examples: hypha-ui/docker-compose-nossl.yml and hub-ui/docker-compose-nossl.yml

You can simply change the paths to them in allinione/docker-compose.yml

In the .env file, you need to specify the correct addresses `${HUB_PUBLIC_URL}`, `${HUB_PUBLIC_PORT}`, `${HYPHA_PUBLIC_URL}`, `${HYPHA_PUBLIC_PORT}` that your service will use.

Example for nginx, where <hypha-address> and <hub-address> are the addresses of your hosts where the services are running.

```
server {
    server_name <hypha.example.com>;
    listen 443 ssl http2;
    < YOUR SSL CONFIGURATION >;

    location /bff/api/v1/ws {
        proxy_pass http://<hypha-address>:3000/bff/api/v1/ws$is_args$args;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 3600s;
        proxy_read_timeout 3600s;
        proxy_buffering off;
    }

    location /bff/ {
        proxy_pass http://<hypha-address>:3000/bff/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
    }

    location / {
        proxy_pass http://<hypha-address>:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
    }
}

server {
    server_name <hub.example.com>;
    acme example;
    listen 443 ssl;
    < YOUR SSL CONFIGURATION >;

    location /bff/api/v1/ws {
        proxy_pass http://<hub-address>:3001/bff/api/v1/ws$is_args$args;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 3600s;
        proxy_read_timeout 3600s;
        proxy_buffering off;
    }

    location /bff/ {
        proxy_pass http://<hub-address>:3001/bff/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
    }

    location / {
        proxy_pass http://<hub-address>:3001/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
    }
}
```
