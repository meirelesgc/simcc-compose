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
if [ -f "simcc-admin/init.data.sql" ]; then
    docker exec -i "$CONTAINER_NAME" psql -U postgres -d "$DB2" < simcc-admin/init.data.sql
else
    echo "Script simcc-admin/init.data.sql não encontrado. Pulando execução para o banco '$DB2'."
fi

# --- Apache Hop
#!/bin/bash

FILE="Jade-Extrator-Hop/metadata/dataset/csv/research_lines.csv"

if [ ! -f "$FILE" ]; then
    echo "File not found. Downloading..."
    wget --no-check-certificate -O "$FILE" "http://ftp.cnpq.br/pub/Gestao_BI/DGP/Linhas%20de%20Pesquisa/Censo%202023%20linhas%20de%20pesquisa.csv"
else
    echo "File already exists. No action needed."
fi

docker run -it --rm \
    --network=simcc-compose_default \
    --env HOP_LOG_LEVEL=Basic \
    --env HOP_FILE_PATH="${PROJECT_HOME}/metadata/dataset/workflow/BaseData.hwf" \
    --env HOP_PROJECT_CONFIG_FILE_NAME="dev.project-config.json" \
    --env HOP_PROJECT_FOLDER=/files \
    --env HOP_PROJECT_NAME=Jade-Extrator-Hop \
    --env HOP_RUN_CONFIG=local \
    --name hop-daily-routine \
    -v "$(pwd)/Jade-Extrator-Hop:/files" \
    apache/hop:2.13.0

docker compose down "$CONTAINER_NAME"

echo "Processo concluído."
