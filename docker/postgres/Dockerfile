# PostgreSQL com TLS.
#
# Os certificados sao COPIADOS para dentro da imagem, nao montados por bind:
# o PostgreSQL recusa iniciar se a chave privada tiver permissao de grupo ou
# de terceiros, e bind mount vindo do Windows nao permite ajustar isso.
FROM postgres:18-alpine
COPY certs/postgres.crt /etc/ssl/portfoliohub/server.crt
COPY certs/postgres.key /etc/ssl/portfoliohub/server.key
RUN chown postgres:postgres /etc/ssl/portfoliohub/server.crt /etc/ssl/portfoliohub/server.key \
    && chmod 644 /etc/ssl/portfoliohub/server.crt \
    && chmod 600 /etc/ssl/portfoliohub/server.key
