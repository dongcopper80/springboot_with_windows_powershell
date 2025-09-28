Param(
    [string]$ProjectName = "thymeleaf-adminlte"
)

Write-Host "==> Tạo Spring Boot + Thymeleaf project: $ProjectName"

# 1. Tạo project từ Spring Initializr
mvn archetype:generate `
    -DgroupId=com.example `
    -DartifactId=$ProjectName `
    -DarchetypeArtifactId=maven-archetype-quickstart `
    -DinteractiveMode=false

Set-Location $ProjectName

# 2. Thêm dependency vào pom.xml
Write-Host "==> Thêm Spring Boot, Thymeleaf, Security, Websocket"
# Bạn có thể dùng đoạn XML append vào pom.xml hoặc dùng Spring Initializr API

# 3. Tải AdminLTE
Write-Host "==> Tải AdminLTE..."
Invoke-WebRequest https://github.com/ColorlibHQ/AdminLTE/archive/refs/heads/master.zip -OutFile adminlte.zip
Expand-Archive adminlte.zip -DestinationPath src/main/resources/static/adminlte -Force
Remove-Item adminlte.zip

# 4. Tạo template cơ bản
New-Item -ItemType Directory -Path src/main/resources/templates/fragments -Force
@"
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
  <meta charset="UTF-8"/>
  <title th:text="#{app.title}">Admin</title>
  <link th:href="@{/adminlte/dist/css/adminlte.min.css}" rel="stylesheet"/>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
  <div th:replace="fragments/header :: header"></div>
  <div th:replace="fragments/menubar :: menubar"></div>
  <div class="content-wrapper" th:insert="~{::body}"></div>
  <div th:replace="fragments/footer :: footer"></div>
</div>
<script th:src="@{/adminlte/dist/js/adminlte.min.js}"></script>
</body>
</html>
"@ | Out-File src/main/resources/templates/layout.html -Encoding UTF8

Write-Host "==> Scaffold hoàn tất. Mở dự án và chạy: mvn spring-boot:run"
