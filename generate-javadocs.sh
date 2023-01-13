#!/bin/bash

declare -a dependencies=(
    "core/azure-core"  # azure-core/json/xml is a dependency for other libraries, so we include it here
    "core/azure-json"
    "core/azure-xml"
    "core/azure-core-experimental"
    "core/azure-core-test"

    "core/azure-core-amqp" # azure-core-amqp is a dependency for other libraries, so we include it here
    "core/azure-core-amqp-experimental"

    "storage/azure-storage-common" # azurestorage-common is a dependency for other libraries, so we include it here
    "storage/azure-storage-internal-avro"
)

declare -a projects=(
    "core/azure-core"
    "core/azure-json"
    "core/azure-xml"
    "core/azure-core-amqp"
    "core/azure-core-http-jdk-httpclient"
    "core/azure-core-http-netty"
    "core/azure-core-http-okhttp"
    "core/azure-core-http-vertx"
    "core/azure-core-metrics-opentelemetry"
    "core/azure-core-serializer-avro-apache"
    "core/azure-core-serializer-avro-jackson"
    "core/azure-core-serializer-json-gson"
    "core/azure-core-serializer-json-jackson"
    "core/azure-core-tracing-opentelemetry"
    
    # "agrifood/azure-verticals-agrifood-farming"
    "anomalydetector/azure-ai-anomalydetector"
    "appconfiguration/azure-data-appconfiguration"
    "attestation/azure-security-attestation"
    # "communication/azure-communication-callautomation"
    # "communication/azure-communication-callingserver"
    # "communication/azure-communication-chat"
    # "communication/azure-communication-common"
    # "communication/azure-communication-email"
    # "communication/azure-communication-identity"
    # "communication/azure-communication-jobrouter"
    # "communication/azure-communication-networktraversal"
    # "communication/azure-communication-phonenumbers"
    # "communication/azure-communication-rooms"
    # "communication/azure-communication-sms"
    # "confidentialledger/azure-security-confidentialledger"
    "containerregistry/azure-containers-containerregistry"
    # "cosmos/azure-cosmos-encryption"
    # "cosmos/azure-cosmos"
    # "devcenter/azure-developer-devcenter"
    # "deviceupdate/azure-iot-deviceupdate"
    # "digitaltwins/azure-digitaltwins-core"
    # "eventgrid/azure-messaging-eventgrid-cloudnative-cloudevents"
    "eventgrid/azure-messaging-eventgrid"
    "eventhubs/azure-messaging-eventhubs"
    "eventhubs/azure-messaging-eventhubs-checkpointstore-blob"
    "eventhubs/azure-messaging-eventhubs-checkpointstore-jedis"
    "formrecognizer/azure-ai-formrecognizer"
    "identity/azure-identity"
    # "jdbc/azure-identity-providers-core"
    # "jdbc/azure-identity-providers-jdbc-mysql"
    # "jdbc/azure-identity-providers-jdbc-postgresql"
    "keyvault/azure-security-keyvault-administration"
    "keyvault/azure-security-keyvault-certificates"
    "keyvault/azure-security-keyvault-jca"
    "keyvault/azure-security-keyvault-keys"
    "keyvault/azure-security-keyvault-secrets"
    # "maps/azure-maps-elevation"
    # "maps/azure-maps-geolocation"
    # "maps/azure-maps-render"
    # "maps/azure-maps-route"
    # "maps/azure-maps-search"
    # "maps/azure-maps-timezone"
    # "maps/azure-maps-traffic"
    # "maps/azure-maps-weather"
    "metricsadvisor/azure-ai-metricsadvisor"
    # "mixedreality/azure-mixedreality-authentication"
    # "modelsrepository/azure-iot-modelsrepository"
    "monitor/azure-monitor-ingestion"
    # "monitor/azure-monitor-opentelemetry-exporter"
    "monitor/azure-monitor-query"
    "personalizer/azure-ai-personalizer"
    "purview/azure-analytics-purview-administration"
    "purview/azure-analytics-purview-catalog"
    "purview/azure-analytics-purview-scanning"
    # "quantum/azure-quantum-jobs"
    # "remoterendering/azure-mixedreality-remoterendering"
    "schemaregistry/azure-data-schemaregistry"
    "schemaregistry/azure-data-schemaregistry-apacheavro"
    "search/azure-search-documents"
    "servicebus/azure-messaging-servicebus"

    "storage/azure-storage-common"
    "storage/azure-storage-blob"
    "storage/azure-storage-blob-batch"
    "storage/azure-storage-blob-changefeed"
    "storage/azure-storage-blob-cryptography"
    "storage/azure-storage-blob-nio"
    "storage/azure-storage-file-datalake"
    "storage/azure-storage-file-share"
    "storage/azure-storage-queue"
    # "synapse/azure-analytics-synapse-accesscontrol"
    # "synapse/azure-analytics-synapse-artifacts"
    # "synapse/azure-analytics-synapse-managedprivateendpoints"
    # "synapse/azure-analytics-synapse-monitoring"
    # "synapse/azure-analytics-synapse-spark"
    "tables/azure-data-tables"
    "textanalytics/azure-ai-textanalytics"
    "translation/azure-ai-documenttranslator"
    # "videoanalyzer/azure-media-videoanalyzer-edge"
    "webpubsub/azure-messaging-webpubsub"
)

# git clone --depth 1 --branch main https://github.com/Azure/azure-sdk-for-java.git
git clone --depth 1 --branch javadoc-inherit https://github.com/srnagar/azure-sdk-for-java.git

# install build tools
mvn -q -f azure-sdk-for-java/eng/code-quality-reports/pom.xml install

rm -rf output
mkdir -p output

# generate index.html
touch output/index.html
cat > output/index.html << EOF
<!DOCTYPE html>
<html>
  <head>
    <title>JavaDoc for Azure SDK for Java</title>
  </head>
  <body>
    <h1>JavaDoc for Azure SDK for Java</h1>
    <ul>
EOF

# Iterate and install all dependencies
for dependency in ${dependencies[*]}
do
  echo "Processing dependency $dependency"
  mvn -q -f ./azure-sdk-for-java/sdk/$dependency/pom.xml -DskipTests -Dcheckstyle.skip -Drevapi.skip -Dspotbugs.skip -T 32 clean package install
done

# Iterate through all projects
for project in ${projects[*]}
do
   echo "Processing $project"
   mvn -q -f ./azure-sdk-for-java/sdk/$project/pom.xml -DskipTests -Dmaven.test.skip -Dcheckstyle.skip -Drevapi.skip -Dspotbugs.skip -T 32 clean package install javadoc:javadoc
   mkdir -p ./output/$project
   mv ./azure-sdk-for-java/sdk/$project/target/site/apidocs/* ./output/$project

   # Add project to HTML output
   echo "      <li><a href=\"$project/index.html\">$project</a></li>" >> output/index.html
done

# Close out HTML file
cat >> output/index.html << EOF
    </ul>
  </body>
</html>
EOF

#rm -rf ./azure-sdk-for-java