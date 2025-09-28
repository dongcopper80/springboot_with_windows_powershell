Open PowerShell and run command: .\scaffold-microservices.ps1 -BaseDir .\

login sonar: admin / admin to get token

mvn clean verify sonar:sonar \
  -Dsonar.projectKey=<service-name> \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=<your_sonar_token>
  

