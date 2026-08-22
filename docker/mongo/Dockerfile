# MongoDB com TLS.
#
# O mongod exige chave e certificado no MESMO arquivo (mongo.pem), gerado por
# scripts/gerar-certificados.sh. Copiado para dentro da imagem pelo mesmo motivo
# de permissao descrito no Dockerfile do PostgreSQL.
FROM mongo:8.0
COPY certs/mongo.pem /etc/ssl/portfoliohub/mongo.pem
COPY certs/ca.crt    /etc/ssl/portfoliohub/ca.crt
RUN chown mongodb:mongodb /etc/ssl/portfoliohub/mongo.pem /etc/ssl/portfoliohub/ca.crt \
    && chmod 600 /etc/ssl/portfoliohub/mongo.pem \
    && chmod 644 /etc/ssl/portfoliohub/ca.crt
