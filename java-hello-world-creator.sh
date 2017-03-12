#!/usr/bin/env bash

# Creates a Gradle, Java, Jersey, JUnit, Jetty hello world project.
echo "Enter a project name (ex. helloWorldProject): "
read projectName
echo "Enter a resource package name (ex. com.domain.resources -- this is where your hello world bootstrap class goes): "
read packageName
packageNameFolder=$(echo $packageName | tr . /)

if [ ! -d "$projectName" ]; then
    mkdir "$projectName" && cd "$projectName"
else
    echo "Named project directory $projectName already exists in current path. \n
    Use another project name or remove $projectName and try again."
    exit 1
fi

gradle init --type basic

mkdir -p {src/main/java/$packageNameFolder/,src/main/resources/META-INF,src/main/webapp/WEB-INF,logs}
touch ./src/main/webapp/WEB-INF/web.xml
touch ./.gitignore

echo "# IntelliJ IDEA

# User-specific stuff:
.idea/workspace.xml
.idea/tasks.xml
.idea/dictionaries
.idea/vcs.xml
.idea/jsLibraryMappings.xml

# Sensitive or high-churn files:
.idea/dataSources.ids
.idea/dataSources.xml
.idea/dataSources.local.xml
.idea/sqlDataSources.xml
.idea/dynamic.xml
.idea/uiDesigner.xml

# Gradle:
.idea/gradle.xml
.idea/libraries

# File-based project format:
*.iws

# Add your plugin exclusions here:

# IntelliJ
/out/
" > ./.gitignore

# Set Jersey servlet configuration
echo "<web-app>
    <servlet>
        <servlet-name>HelloWorld</servlet-name>
        <servlet-class>
                org.glassfish.jersey.servlet.ServletContainer
        </servlet-class>
        <init-param>
            <param-name>jersey.config.server.provider.packages</param-name>
            <param-value>$packageName</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>
    <servlet-mapping>
        <servlet-name>HelloWorld</servlet-name>
        <url-pattern>/*</url-pattern>
    </servlet-mapping>
</web-app>
" > ./src/main/webapp/WEB-INF/web.xml

# Overwrite build.gradle defaults
echo "apply plugin: 'war'
apply plugin: 'eclipse'
apply plugin: 'jettyEclipse'

repositories {
    mavenCentral()
}

buildscript {
    repositories {    
        jcenter()
    }
    dependencies {
            classpath (group: 'com.sahlbach.gradle', name: 'gradle-jetty-eclipse-plugin', version: '1.9.+')
    }
}

dependencies {
    testCompile 'junit:junit:4.11'
    testCompile 'org.hamcrest:hamcrest-all:1.3'
    testCompile 'com.jayway.restassured:rest-assured:2.8.0'
    compile 'org.glassfish.jersey.containers:jersey-container-servlet:2.14'
    compile 'commons-httpclient:commons-httpclient:3.1'
    compile 'log4j:log4j:1.2.7'
    compile 'org.slf4j:slf4j-log4j12:1.6.6'
}

jettyEclipse {
    contextPath = '/'
    // httpPort = 8011 change this if there are port collisions
}
" > build.gradle

# Create hello world resource
echo "package $packageName;

import org.apache.commons.httpclient.HttpStatus;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.core.Response;

/***
 * This is the hello world endpoint.
 */ 
@Path(\"/rest/\")
public class HelloWorldResource {

    private static final Logger LOGGER = LogManager.getLogger(HelloWorldResource.class);
    @GET
    @Path(\"/greeting\")
    public Response getResource() {
        LOGGER.info(\"HTTP Status \" + HttpStatus.SC_OK + \" \" +
                HttpStatus.getStatusText(HttpStatus.SC_OK));
        return Response.status(HttpStatus.SC_OK).entity(\"Hello world!\").build(); 
    }
}" > src/main/java/$packageNameFolder/HelloWorldResource.java

touch ./src/main/resources/log4j.properties

echo "
# Direct info messages to standard output, to switch to file logs, replace the rootCategory 'stdout' setting to 'rollingFile'
log4j.rootCategory=INFO, stdout

# Stdout log config
log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.Target=System.out
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss} %-5p %c{1}:%L - %m%n

# File log config
log4j.appender.rollingFile=org.apache.log4j.RollingFileAppender
log4j.appender.rollingFile.File=logs/application.log
log4j.appender.rollingFile.MaxFileSize=10MB
log4j.appender.rollingFile.MaxBackupIndex=2
log4j.appender.rollingFile.layout = org.apache.log4j.PatternLayout
log4j.appender.rollingFile.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss} %-5p %c{1}:%L - %m%n
" > ./src/main/resources/log4j.properties

echo "Building..."
./gradlew build
echo "Launching Jetty..."
echo "Default endpoint: http://localhost:8080/rest/greeting"
./gradlew jettyEclipseRun
