Open PowerShell and run command: .\scaffold-microservices.ps1 -BaseDir .\

login sonar: admin / admin to get token

mvn clean verify sonar:sonar \
  -Dsonar.projectKey=<service-name> \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=<your_sonar_token>
  

run mvn eclipse:eclipse to generate eclipse project config


./scaffold-angular-adminlte.ps1 -AppName my-adminlte-app

chạy ứng dụng : ng serve

./scaffold-nextjs-adminlte.ps1 -AppName my-next-adminlte

npm run dev

./scaffold-thymeleaf-adminlte.ps1 -ProjectName my-adminlte

./scaffold-thymeleaf-lint.ps1

