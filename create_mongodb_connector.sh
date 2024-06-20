#! /bin/sh

set -e

source ./ccloud.env

CONNECTOR_CONFIG=`cat << EOF
{
    "connector.class": "com.mongodb.kafka.connect.MongoSinkConnector",
    "topics": "MONGODB.SALES",
    "connection.uri": "mongodb+srv://$MONGODB_USER:$MONGODB_PASSWORD@$MONGODB_URL/?retryWrites=true&w=majority&appName=mongodb_sink_connector",
    "database": "oracle",
    "mongo.errors.log.enable":"true",
    "delete.on.null.values": "true",
    "document.id.strategy": "com.mongodb.kafka.connect.sink.processor.id.strategy.FullKeyStrategy",
    "delete.writemodel.strategy": "com.mongodb.kafka.connect.sink.writemodel.strategy.DeleteOneDefaultStrategy",
    "publish.full.document.only": "true",
    "key.converter": "io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url": "$CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL",
    "key.converter.schema.registry.basic.auth.user.info" : "$CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO",
    "key.converter.schema.registry.basic.auth.credentials.source": "$CONNECT_KEY_CONVERTER_BASIC_AUTH_CREDENTIALS_SOURCE"

}

EOF`

curl -H "Content-Type:application/json" -X PUT http://localhost:8083/connectors/mongo/config --data "$CONNECTOR_CONFIG"
