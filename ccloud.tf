# Configure the Confluent Provider
terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.76.0"
    }
  }
}


resource "confluent_environment" "demo" {
  display_name = "DatabaseModernizationDemo"

  stream_governance {
    package = "ESSENTIALS"
  }
}

resource "confluent_kafka_cluster" "demo" {
  display_name = "Database modernization demo cluster"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "eu-west-1"
  basic {}

  environment {
    id = confluent_environment.demo.id
  }
}

data "confluent_schema_registry_cluster" "demo" {
  environment {
    id = confluent_environment.demo.id
  }
  depends_on = [confluent_kafka_cluster.demo]
}



resource "confluent_service_account" "app" {
  display_name = "app"
  description  = "Service Account for app"
}

resource "confluent_api_key" "app" {
  display_name = "appy"
  description  = "Kafka API Key that is owned by 'app' service account"
  owner {
    id          = confluent_service_account.app.id
    api_version = confluent_service_account.app.api_version
    kind        = confluent_service_account.app.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.demo.id
    api_version = confluent_kafka_cluster.demo.api_version
    kind        = confluent_kafka_cluster.demo.kind

    environment {
      id = confluent_environment.demo.id
    }
  }
}


resource "confluent_api_key" "app-sr" {
  display_name = "appy"
  description  = "Kafka API Key that is owned by 'app' service account"
  owner {
    id          = confluent_service_account.app.id
    api_version = confluent_service_account.app.api_version
    kind        = confluent_service_account.app.kind
  }

  managed_resource {
    id          = data.confluent_schema_registry_cluster.demo.id
    api_version = data.confluent_schema_registry_cluster.demo.api_version
    kind        = data.confluent_schema_registry_cluster.demo.kind

    environment {
      id = confluent_environment.demo.id
    }
  }
}

resource "confluent_flink_compute_pool" "main" {
  display_name = "compute_pool"
  cloud        = "AWS"
  region       = "eu-west-1"
  max_cfu      = 5
  environment {
    id = confluent_environment.demo.id
  }
}


resource "confluent_role_binding" "app-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.app.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.demo.rbac_crn
}

resource "confluent_role_binding" "app-sr-cluster-admin" {
  principal   = "User:${confluent_service_account.app.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${data.confluent_schema_registry_cluster.demo.resource_name}/subject=*"
}

resource "local_file" "private_key" {
  content  = <<EOT
bootstrap.servers=${confluent_kafka_cluster.demo.bootstrap_endpoint}
security.protocol=SASL_SSL
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username='${confluent_api_key.app.id}' password='${confluent_api_key.app.secret}';
sasl.mechanism=PLAIN
EOT
  filename = "ccloud.properties"
}

resource "local_file" "private_key_env" {
  content  = <<EOT
CONNECT_BOOTSTRAP_SERVERS=${confluent_kafka_cluster.demo.bootstrap_endpoint}
CONNECT_SECURITY_PROTOCOL=SASL_SSL
CONNECT_SASL_JAAS_CONFIG="org.apache.kafka.common.security.plain.PlainLoginModule required username='${confluent_api_key.app.id}' password='${confluent_api_key.app.secret}';"
CONNECT_SASL_MECHANISM=PLAIN

CONNECT_PRODUCER_SECURITY_PROTOCOL=SASL_SSL
CONNECT_PRODUCER_SASL_JAAS_CONFIG="org.apache.kafka.common.security.plain.PlainLoginModule required username='${confluent_api_key.app.id}' password='${confluent_api_key.app.secret}';"
CONNECT_PRODUCER_SASL_MECHANISM=PLAIN

CONNECT_CONSUMER_SECURITY_PROTOCOL=SASL_SSL
CONNECT_CONSUMER_SASL_JAAS_CONFIG="org.apache.kafka.common.security.plain.PlainLoginModule required username='${confluent_api_key.app.id}' password='${confluent_api_key.app.secret}';"
CONNECT_CONSUMER_SASL_MECHANISM=PLAIN

CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL=${data.confluent_schema_registry_cluster.demo.rest_endpoint}
CONNECT_VALUE_CONVERTER_BASIC_AUTH_CREDENTIALS_SOURCE=USER_INFO
CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO=${confluent_api_key.app-sr.id}:${confluent_api_key.app-sr.secret}

CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL=${data.confluent_schema_registry_cluster.demo.rest_endpoint}
CONNECT_KEY_CONVERTER_BASIC_AUTH_CREDENTIALS_SOURCE=USER_INFO
CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO=${confluent_api_key.app-sr.id}:${confluent_api_key.app-sr.secret}
EOT
  filename = "ccloud.env"
}

