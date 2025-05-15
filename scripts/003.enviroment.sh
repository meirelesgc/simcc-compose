#!/bin/bash

CONFIG_FILE="Jade-Extrator-Hop/dev.project-config.json"

declare -a var_names=("HOST" "PORT" "PASSWORD" "DATABASE" "DATABASE_ADMIN")
declare -a default_values=("simcc-postgres" "5432" "postgres" "simcc" "simcc_admin")

read -p "Do you want to manually configure Apache Hop variables? (y/n): " answer

mkdir -p "$(dirname "$CONFIG_FILE")"

for i in "${!var_names[@]}"; do
    var="${var_names[$i]}"
    default="${default_values[$i]}"

    if [[ "$answer" == "y" ]]; then
        read -p "Enter value for $var (default: $default): " input
        values[$i]="${input:-$default}"
    else
        values[$i]="$default"
    fi
done

cat > "$CONFIG_FILE" <<EOF
{
  "metadataBaseFolder" : "\${PROJECT_HOME}/metadata",
  "unitTestsBasePath" : "\${PROJECT_HOME}",
  "dataSetsCsvFolder" : "\${PROJECT_HOME}/datasets",
  "enforcingExecutionInHome" : true,
  "parentProjectName" : "default",
  "config" : {
    "variables" : [ {
      "name" : "HOST",
      "value" : "${values[0]}",
      "description" : "NONE"
    }, {
      "name" : "PORT",
      "value" : "${values[1]}",
      "description" : "NONE"
    }, {
      "name" : "PASSWORD",
      "value" : "${values[2]}",
      "description" : "NONE"
    }, {
      "name" : "DATABASE",
      "value" : "${values[3]}",
      "description" : "NONE"
    }, {
      "name" : "DATABASE_ADMIN",
      "value" : "${values[4]}",
      "description" : "NONE"
    } ]
  }
}
EOF

echo "Configuration saved to $CONFIG_FILE"
