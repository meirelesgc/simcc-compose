#!/bin/bash

CONTAINER_NAME="simcc-postgres"

docker compose up -d "$CONTAINER_NAME"
echo "Aguardando PostgreSQL iniciar no container '$CONTAINER_NAME'..."
until docker exec -i "$CONTAINER_NAME" pg_isready -U postgres >/dev/null 2>&1; do
    sleep 1
done

read -p "Deseja definir manualmente os nomes dos bancos? (s/n): " CUSTOM_NAMES

if [[ "$CUSTOM_NAMES" =~ ^[Ss]$ ]]; then
    read -p "Informe o nome do banco principal (default: simcc): " DB1
    DB1=${DB1:-simcc}

    read -p "Informe o nome do banco de administração (default: simcc_admin): " DB2
    DB2=${DB2:-simcc_admin}
else
    DB1="simcc"
    DB2="simcc_admin"
fi

echo "Criando bancos de dados '$DB1' e '$DB2' no container '$CONTAINER_NAME'..."

docker exec -i "$CONTAINER_NAME" psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$DB1'" | grep -q 1 || \
docker exec -i "$CONTAINER_NAME" psql -U postgres -c "CREATE DATABASE $DB1"

docker exec -i "$CONTAINER_NAME" psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$DB2'" | grep -q 1 || \
docker exec -i "$CONTAINER_NAME" psql -U postgres -c "CREATE DATABASE $DB2"

echo "Executando scripts de inicialização..."

if [ -f "simcc-back/init.sql" ]; then
    docker exec -i "$CONTAINER_NAME" psql -U postgres -d "$DB1" < simcc-back/init.sql
else
    echo "Script simcc-back/init.sql não encontrado. Pulando execução para o banco '$DB1'."
fi

if [ -f "simcc-admin/init.sql" ]; then
    docker exec -i "$CONTAINER_NAME" psql -U postgres -d "$DB2" < simcc-admin/init.sql
else
    echo "Script simcc-admin/init.sql não encontrado. Pulando execução para o banco '$DB2'."
fi

docker compose down "$CONTAINER_NAME"

echo "Processo concluído."
