#!/bin/bash

set -e

handle_error() {
    echo -e "\n\nHouve um erro. Encerrando o script."
    exit 1
}

docker exec simcc-back poetry run python /app/routines/soap_lattes.py || handle_error

mkdir -p Jade-Extrator-Hop/metadata/dataset/xml || handle_error
docker cp simcc-back:/app/storage/xml/. Jade-Extrator-Hop/metadata/dataset/xml/ || handle_error

docker run -it --rm \
    --network=simcc-compose_default \
    --env HOP_LOG_LEVEL=Basic \
    --env HOP_FILE_PATH="${PROJECT_HOME}/metadata/dataset/workflow/Index.hwf" \
    --env HOP_PROJECT_CONFIG_FILE_NAME="dev.project-config.json" \
    --env HOP_PROJECT_FOLDER=/files \
    --env HOP_PROJECT_NAME=Jade-Extrator-Hop \
    --env HOP_RUN_CONFIG=local \
    --name hop-daily-routine \
    -v "$(pwd)/Jade-Extrator-Hop:/files" \
    apache/hop:2.13.0 || handle_error

docker exec simcc-back poetry run python /app/routines/population.py || handle_error
docker exec simcc-back poetry run python /app/routines/pog.py || handle_error
docker exec simcc-back poetry run python /app/routines/production.py || handle_error
docker exec simcc-back poetry run python /app/routines/researcher_image.py || handle_error
docker exec simcc-back poetry run python /app/routines/researcher_indprod.py || handle_error
docker exec simcc-back poetry run python /app/routines/program_indprod.py || handle_error
docker exec simcc-back poetry run python /app/routines/powerBI.py || handle_error
