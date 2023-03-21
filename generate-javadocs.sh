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
    
    "identity/azure-identity"
    "search/azure-search-documents"
    "tables/azure-data-tables"
)

git clone --depth 1 --branch main https://github.com/Azure/azure-sdk-for-java.git


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

# optional - delete the cloned repo
#rm -rf ./azure-sdk-for-java
