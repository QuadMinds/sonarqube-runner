# docker run -d --name sonarqube -p 9000:9000 sonarqube
docker run \
    --rm \
    -e SONAR_HOST_URL="http://localhost:9000" \
    -v "/home/deiff/Documents/src/saas:/usr/src" \
    sonarsource/sonar-scanner-cli