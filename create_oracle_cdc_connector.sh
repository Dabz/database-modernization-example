#! /bin/sh

set -e

source ./ccloud.env

CONNECTOR_CONFIG=`cat << EOF
{
   "connector.class": "io.confluent.connect.oracle.cdc.OracleCdcSourceConnector",
   "oracle.username": "C##CDC",
   "oracle.password": "password",
   "oracle.server": "oracle",
   "oracle.port": "1521",
   "oracle.sid": "ORCLCDB",
   "oracle.service.name": "ORCLCDB",
   "oracle.pdb.name": "ORCLPDB1",
   "tasks.max": 2,
   "numeric.mapping": "best_fit_or_string",
   "redo.log.consumer.bootstrap.servers": "$CONNECT_BOOTSTRAP_SERVERS",
   "redo.log.consumer.security.protocol": "$CONNECT_SECURITY_PROTOCOL",
   "redo.log.consumer.sasl.jaas.config": "$CONNECT_SASL_JAAS_CONFIG",
   "redo.log.consumer.sasl.mechanism": "$CONNECT_SASL_MECHANISM",
   "table.inclusion.regex": "ORCLPDB1.SALES..*",
   "value.converter": "io.confluent.connect.avro.AvroConverter",
   "key.converter": "io.confluent.connect.avro.AvroConverter",
   "key.converter.schema.registry.url": "$CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL",
   "value.converter.schema.registry.url": "$CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL",
   "key.converter.basic.auth.credentials.source": "USER_INFO",
   "value.converter.basic.auth.credentials.source": "USER_INFO",
   "key.converter.basic.auth.user.info": "$CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO",
   "value.converter.basic.auth.user.info": "$CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO",
   "redo.log.topic.name": "redo-log-topic",
   "topic.creation.groups": "redo",
   "topic.creation.redo.include": "redo-log-topic",
   "topic.creation.redo.replication.factor": 3,
   "topic.creation.redo.partitions": 1,
   "topic.creation.redo.cleanup.policy": "delete",
   "topic.creation.redo.retention.ms": 1209600000,
   "topic.creation.default.replication.factor": 3,
   "topic.creation.default.partitions": 5,
   "topic.creation.default.cleanup.policy": "compact"
}
EOF`

curl -H "Content-Type:application/json" -X PUT http://localhost:8083/connectors/oracle_cdc/config --data "$CONNECTOR_CONFIG"
