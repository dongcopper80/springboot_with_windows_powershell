param(
    [string]$RootDir = ".\car-marketplace"
)

$javaVersion = "17"
$springBootVersion = "3.3.3"
$springdocVersion = "2.5.0"
$mapstructVersion = "1.5.5.Final"
$junitVersion = "5.10.0"

$services = @(
    "gateway-service",
    "user-service",
    "car-service",
    "payment-service",
    "featureflag-service",
    "notification-service",
    "analytics-service"
)

function New-Pom {
    param($artifactId)
@"
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                             http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.dongcopper80</groupId>
  <artifactId>$artifactId</artifactId>
  <version>1.0.0</version>
  <properties>
    <java.version>$javaVersion</java.version>
    <spring.boot.version>$springBootVersion</spring.boot.version>
    <springdoc.version>$springdocVersion</springdoc.version>
	<mapstruct.version>$mapstructVersion</mapstruct.version>
	<junit.version>$junitVersion</junit.version>
	<maven.compiler.source>1.8</maven.compiler.source>
    <maven.compiler.target>1.8</maven.compiler.target>
    <maven.compiler.release>8</maven.compiler.release>
  </properties>
  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-dependencies</artifactId>
        <version>`$`{spring.boot.version`}</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>
  <dependencies>
    <!-- Web + Validation -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>

    <!-- Security & JWT/OAuth2 -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-oauth2-resource-server</artifactId>
    </dependency>

    <!-- Swagger/OpenAPI -->
    <dependency>
      <groupId>org.springdoc</groupId>
      <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
      <version>`$`{springdoc.version`}</version>
    </dependency>

    <!-- Database + Flyway -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
      <groupId>org.flywaydb</groupId>
      <artifactId>flyway-core</artifactId>
    </dependency>
    <dependency>
      <groupId>org.postgresql</groupId>
      <artifactId>postgresql</artifactId>
      <scope>runtime</scope>
    </dependency>

	<!-- STOMP/WebSocket -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-websocket</artifactId>
        </dependency>
		
	<!-- GraphQL -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-graphql</artifactId>
        </dependency>
		
    <!-- Optional: Lombok -->
    <dependency>
      <groupId>org.projectlombok</groupId>
      <artifactId>lombok</artifactId>
      <optional>true</optional>
    </dependency>

	<!-- MapStruct -->
    <dependency>
      <groupId>org.mapstruct</groupId>
      <artifactId>mapstruct</artifactId>
      <version>`$`{mapstruct.version`}</version>
    </dependency>
    <dependency>
      <groupId>org.mapstruct</groupId>
      <artifactId>mapstruct-processor</artifactId>
      <version>`$`{mapstruct.version`}</version>
      <scope>provided</scope>
    </dependency>
	
	<dependency>
		<groupId>org.springframework.boot</groupId>
		<artifactId>spring-boot-starter-actuator</artifactId>
	</dependency>

	<dependency>
		<groupId>io.micrometer</groupId>
		<artifactId>micrometer-registry-prometheus</artifactId>
	</dependency>

    <!-- Test -->
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
	
	<dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>`$`{junit.version`}</version>
            <scope>test</scope>
        </dependency>
		
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
		<version>3.5.5</version>
      </plugin>
	  
	  <!-- MapStruct annotation processing -->
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
		<version>3.14.0</version>
        <configuration>
		  <release>8</release>
          <annotationProcessorPaths>
            <path>
              <groupId>org.mapstruct</groupId>
              <artifactId>mapstruct-processor</artifactId>
              <version>`$`{mapstruct.version`}</version>
            </path>
            <path>
              <groupId>org.projectlombok</groupId>
              <artifactId>lombok</artifactId>
              <version>1.18.30</version>
            </path>
          </annotationProcessorPaths>
        </configuration>
      </plugin>
	  
	  <!-- JaCoCo for code coverage -->
            <plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>0.8.10</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>prepare-agent</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>report</id>
                        <phase>test</phase>
                        <goals>
                            <goal>report</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
			
		<!-- Checkstyle -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-checkstyle-plugin</artifactId>
                <version>3.6.0</version>
                <configuration>
                    <configLocation>google_checks.xml</configLocation>
                    <inputEncoding>UTF-8</inputEncoding>
                    <outputEncoding>UTF-8</outputEncoding>
                    <consoleOutput>true</consoleOutput>
                    <failsOnError>true</failsOnError>
                </configuration>
                <executions>
                    <execution>
                        <phase>validate</phase>
                        <goals><goal>check</goal></goals>
                    </execution>
                </executions>
            </plugin>
			
            <!-- SonarQube -->
            <plugin>
                <groupId>org.sonarsource.scanner.maven</groupId>
                <artifactId>sonar-maven-plugin</artifactId>
                <version>3.10.0.2594</version>
            </plugin>
			
			<plugin>
			  <groupId>com.lazerycode.jmeter</groupId>
			  <artifactId>jmeter-maven-plugin</artifactId>
			  <version>3.8.0</version>
			  <executions>
				<execution>
				  <goals>
					<goal>jmeter</goal>
				  </goals>
				</execution>
			  </executions>
			  <configuration>
				<testFilesIncluded>
				  <jMeterTestFile>plans/sample_test_plan.jmx</jMeterTestFile>
				</testFilesIncluded>
			  </configuration>
			</plugin>

    </plugins>
  </build>
</project>
"@
}

function New-MainClass {
    param($package)
@"
/**
 * Application
 *
 * @author Đồng Nguyễn Thúc (dongcopper80)
 */
package $package;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
"@
}

function New-SecurityConfig {
    param($package)
@"
/**
 * SecurityConfig
 *
 * @author Đồng Nguyễn Thúc (dongcopper80)
 */
package $package.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .authorizeHttpRequests(auth -> auth
                .requestMatchers(
                        "/v3/api-docs/**",
                        "/swagger-ui.html",
                        "/swagger-ui/**",
                        "/actuator/health/**").permitAll()
                .anyRequest().authenticated()
                )
                .oauth2ResourceServer(oauth2 -> oauth2
                .jwt(Customizer.withDefaults()));
        return http.build();
    }
}
"@
}

function New-SwaggerConfig {
    param($package,$svc)
@"
/**
 * SwaggerConfig
 *
 * @author Đồng Nguyễn Thúc (dongcopper80)
 */
package $package.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {
    @Bean
    public OpenAPI apiInfo() {
        return new OpenAPI()
            .info(new Info()
                .title("$svc API")
                .description("Swagger UI with Bearer Token authentication")
                .version("1.0.0"));
    }
}
"@
}

function New-WebSocketConfig {
    param($package,$svc)
@"
/**
 * WebSocketConfig
 *
 * @author Đồng Nguyễn Thúc (dongcopper80)
 */
package $package.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {
    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        config.enableSimpleBroker("/topic");
        config.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws").setAllowedOriginPatterns("*").withSockJS();
    }
}
"@
}

New-Item -ItemType Directory -Force -Path $RootDir | Out-Null
Set-Location $RootDir

foreach ($svc in $services) {
    $base = Join-Path $RootDir $svc
    $pkg = "com.dongcopper80." + ($svc -replace '-','')
    $javaDir = "$base\src\main\java\com\dongcopper80\$($svc -replace '-','')"
	$javaTestDir = "$base\src\test\java\com\dongcopper80\$($svc -replace '-','')"
    $resDir  = "$base\src\main\resources"
    $migDir  = "$resDir\db\migration"

    New-Item -ItemType Directory -Force -Path "$javaDir\config" | Out-Null
    New-Item -ItemType Directory -Force -Path $migDir | Out-Null
	New-Item -ItemType Directory -Force -Path "$resDir\graphql" | Out-Null  # GraphQL schema folder
	
    # pom.xml
    New-Pom -artifactId $svc | Set-Content "$base\pom.xml"

    # Application.java
    New-MainClass -PackageName $pkg -package $pkg | Set-Content "$javaDir\Application.java"

    # SecurityConfig & SwaggerConfig & WebSocketConfig
    New-SecurityConfig -PackageName $pkg -package $pkg | Set-Content "$javaDir\config\SecurityConfig.java"
    New-SwaggerConfig -PackageName $pkg -package $pkg -svc $svc | Set-Content "$javaDir\config\SwaggerConfig.java"
	New-WebSocketConfig -PackageName $pkg -package $pkg -svc $svc | Set-Content "$javaDir\config\WebSocketConfig.java"

# dongcopper80 GraphQL schema
    $schema = @"
type Query {
    hello: String
}
"@
    Set-Content -Path "$resDir\graphql\schema.graphqls" -Value $schema

    # Simple GraphQL Query Resolver
    $resolver = @"
package $pkg.graphql;

import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;

@Controller
public class HelloQuery {
    @QueryMapping
    public String hello() {
        return "Hello from $module GraphQL!";
    }
}
"@
    New-Item -ItemType Directory -Force -Path "$javaDir\graphql" | Out-Null
    Set-Content -Path "$javaDir\graphql\HelloQuery.java" -Value $resolver
	
	# Checkstyle config chung
$googleChecks = @"
<?xml version="1.0"?>
<!DOCTYPE module PUBLIC
          "-//Checkstyle//DTD Checkstyle Configuration 1.3//EN"
          "https://checkstyle.org/dtds/configuration_1_3.dtd">

<module name="Checker">
    <property name="charset" value="UTF-8"/>
    <property name="severity" value="error"/>

    <!-- Kiểm tra header nếu cần
    <module name="Header">
        <property name="header" value="^// Copyright"/>
    </module>
    -->

    <!-- Mã hóa UTF-8 -->
    <module name="NewlineAtEndOfFile"/>

	<!-- LineLength phải là con của Checker -->
    <module name="LineLength">
        <property name="max" value="120"/>
        <property name="ignorePattern" value="^package.*|^import.*"/>
    </module>
	
    <module name="TreeWalker">
        <module name="OuterTypeFilename"/>
        <module name="IllegalTokenText">
            <property name="tokens" value="STRING_LITERAL, CHAR_LITERAL"/>
            <property name="format" value="\\u0000"/>
            <property name="message" value="Avoid Unicode NULL character"/>
        </module>

        <module name="AvoidStarImport"/>
        <module name="UnusedImports"/>
        <!--<module name="ImportOrder">
            <property name="option" value="top"/>
            <property name="groups" value="java,javax,org,com"/>
            <property name="ordered" value="true"/>
            <property name="separated" value="true"/>
        </module>-->

        <module name="Indentation">
            <property name="basicOffset" value="4"/>
            <property name="braceAdjustment" value="0"/>
            <property name="caseIndent" value="4"/>
            <property name="lineWrappingIndentation" value="8"/>
        </module>

        <module name="NeedBraces"/>
        <module name="LeftCurly">
            <property name="option" value="eol"/>
        </module>
        <module name="RightCurly">
            <property name="option" value="same"/>
        </module>

        <module name="WhitespaceAround"/>
        <module name="WhitespaceAfter"/>
        <module name="NoLineWrap"/>
        <module name="EmptyBlock">
            <property name="option" value="TEXT"/>
        </module>

        <module name="MethodParamPad"/>
        <module name="ParenPad"/>
        <module name="OperatorWrap"/>
        <module name="AnnotationLocation">
            <property name="allowSamelineMultipleAnnotations" value="true"/>
        </module>

        <module name="JavadocMethod"/>
        <module name="JavadocType"/>
        <module name="JavadocVariable">
            <property name="scope" value="private"/>
        </module>
        <module name="JavadocStyle"/>

        <module name="FinalClass"/>
        <module name="EqualsHashCode"/>
        <module name="MissingOverride">
			<property name="javaFiveCompatibility" value="true"/>
		</module>
        <module name="MissingSwitchDefault"/>
    </module>
</module>
"@

Set-Content -Path (Join-Path $base "google_checks.xml") -Value $googleChecks -Encoding UTF8

$Docker = @"
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
"@

Set-Content -Path (Join-Path $base "Dockerfile") -Value $Docker -Encoding UTF8

$prometheus = @"
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'microservices'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets:
          - 'user-service:8080'
          - 'payment-service:8080'
          - 'car-service:8080'
"@

Set-Content -Path (Join-Path $base "prometheus.yml") -Value $prometheus -Encoding UTF8

	# Sample JUnit test
    $test = @"
package $pkg;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
class ApplicationTests {
    @Test
    void contextLoads() {
        assertThat(true).isTrue();
    }
}
"@

New-Item -ItemType Directory -Force -Path "$javaTestDir" | Out-Null
    Set-Content -Path "$javaTestDir\ApplicationTests.java" -Value $test
	
	Write-Host "Creating JMeter performance testing module..."
New-Item -ItemType Directory -Force -Path "$base/performance/jmeter/plans"
New-Item -ItemType Directory -Force -Path "$base/performance/jmeter/data"
New-Item -ItemType Directory -Force -Path "$base/performance/jmeter/results"
Set-Content -Path "$base/performance/jmeter/README.md" -Value "# JMeter Performance Tests"
Set-Content -Path "$base/performance/jmeter/plans/sample_test_plan.jmx" -Value "<jmeterTestPlan/>"

    # application.yml
    @"
spring:
  application:
    name: user-service
  datasource:
    url: jdbc:postgresql://localhost:5432/
    username: myuser
    password: mypass
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
  cors:
    allowed-origins: "*"
    allowed-methods: "*"
  graphql:
    graphiql:
      enabled: true   # bật giao diện GraphiQL tại /graphiql
      schema:
        location: classpath:graphql/
  flyway:
    enabled: true
    locations: classpath:db/migration
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://localhost:8080/realms/master

management:
  endpoints:
    web:
      exposure:
        include: health,info,prometheus   # hoặc "*"
  security:
    enabled: true
  endpoint:
    prometheus:
      enabled: true
    health:
      show-details: always     # hiển thị thông tin chi tiết từng component
      probes:
        enabled: true
  metrics:
    tags:
      application: user-service
  health:
    livenessstate:
      enabled: true
    readinessstate:
      enabled: true

server:
  port: 0

"@ | Out-File -Encoding UTF8 "$resDir\application.yaml"

    # Initial migration
    @"
CREATE TABLE IF NOT EXISTS dongcopper80 (
    id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"@ | Out-File -Encoding UTF8 "$migDir\V1__init.sql"

    # Dockerfile
    @"
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -B package -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/$svc-1.0.0.jar app.jar
ENTRYPOINT ["java","-jar","/app/app.jar"]
"@ | Out-File -Encoding UTF8 "$base\Dockerfile"
}

Write-Host "✅ Scaffold with Swagger + Bearer Token + Flyway,  Lombok, MapStruct, STOMP, SonarQube, Micrometer Prometheus, Actuator, JMeter, JUnit 5 và JaCoCo coverage complete at $RootDir"
