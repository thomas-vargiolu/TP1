FROM postgres:11.6-alpine

COPY database/CreateScheme.sql /docker-entrypoint-initdb.d
COPY database/InsertData.sql /docker-entrypoint-initdb.d

EXPOSE 5432

ENV POSTGRES_DB=db \
POSTGRES_USER=usr \
POSTGRES_PASSWORD=pwd