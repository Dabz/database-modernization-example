#! /bin/sh

set -e

source ./ccloud.env

CONNECTOR_CONFIG=`cat << EOF
{
    "connector.class":"com.snowflake.kafka.connector.SnowflakeSinkConnector",
    "tasks.max":"8",
    "topics.regex":"ORCLPDB1.SALES.*",
    "buffer.count.records":"10000",
    "buffer.flush.time":"60",
    "buffer.size.bytes":"5000000",
    "snowflake.url.name":"$SNOWFLAKE_URL",
    "snowflake.user.name":"$SNOWFLAKE_USER",
    "snowflake.private.key":"$SNOWFLAKE_PRIVATE_KEY",
    "snowflake.private.key.passphrase":"$SNOWFLAKE_PRIVATE_KEY_PASSPHRASE",
    "snowflake.database.name":"KAFKA_DB",
    "snowflake.schema.name":"KAFKA_SCHEMA",
    "value.converter":"com.snowflake.kafka.connector.records.SnowflakeAvroConverter",
    "value.converter.schema.registry.url": "$CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL",
    "value.converter.schema.registry.basic.auth.user.info" : "$CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO",
    "value.converter.schema.registry.basic.auth.credentials.source": "$CONNECT_KEY_CONVERTER_BASIC_AUTH_CREDENTIALS_SOURCE"
}
EOF`

curl -H "Content-Type:application/json" -X PUT http://localhost:8083/connectors/snowflake/config --data "$CONNECTOR_CONFIG"
