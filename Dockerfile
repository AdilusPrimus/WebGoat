FROM docker.io/eclipse-temurin:17-jre-focal

RUN useradd -ms /bin/bash webgoat && chgrp -R 0 /home/webgoat && chmod -R g=u /home/webgoat

USER webgoat

COPY --chown=webgoat target/webgoat-*.jar /home/webgoat/webgoat.jar
# If you are already using Datadog, upgrade your Agent to version 7.20.2+ or 6.20.2+. 
# If you don’t have APM enabled to set up your application to send data to Datadog, in your Agent, set the DD_APM_ENABLED environment variable to true and listening to the port 8126/TCP.
# Download it Manually:
# wget -O dd-java-agent.jar 'https://dtdg.co/latest-java-tracer' # Refer to the download folder in the next command for the COPY source
# The Datadog Agent must be installed as instructed here for your platform (Linux in this example in the next line)
# sudo apt-get install datadog-apm-inject datadog-apm-library-all
# Build the application as instruced: ./mvn clean install
# Now move the tracer to the target folder located in the root of your git workspace, as required by the .dockerignore file
# cp /opt/datadog/apm/library/java/dd-java-agent.jar target/ (The source folder path in the example was from where the datadog-apm-library-all was deployed, please specify where you have downloaded it )
COPY --chown=webgoat target/dd-java-agent.jar /home/webgoat/dd-java-agent.jar

EXPOSE 8080
EXPOSE 9090

WORKDIR /home/webgoat
ENTRYPOINT [ "java", \
   "-javaagent:dd-java-agent.jar", \
   "-Ddd.service=webgoat", \
   "-Ddd.env=test", \
   "-Ddd.version=1.0.0", \
   "-Ddd.profiling.enabled=true", \
   "-XX:FlightRecorderOptions=stackdepth=256", \
   "-Duser.home=/home/webgoat", \
   "-Dfile.encoding=UTF-8", \
   "--add-opens", "java.base/java.lang=ALL-UNNAMED", \
   "--add-opens", "java.base/java.util=ALL-UNNAMED", \
   "--add-opens", "java.base/java.lang.reflect=ALL-UNNAMED", \
   "--add-opens", "java.base/java.text=ALL-UNNAMED", \
   "--add-opens", "java.desktop/java.beans=ALL-UNNAMED", \
   "--add-opens", "java.desktop/java.awt.font=ALL-UNNAMED", \
   "--add-opens", "java.base/sun.nio.ch=ALL-UNNAMED", \
   "--add-opens", "java.base/java.io=ALL-UNNAMED", \
   "--add-opens", "java.base/java.util=ALL-UNNAMED", \
   "--add-opens", "java.base/sun.nio.ch=ALL-UNNAMED", \
   "--add-opens", "java.base/java.io=ALL-UNNAMED", \
   "-Drunning.in.docker=true", \
   "-Dwebgoat.host=0.0.0.0", \
   "-Dwebwolf.host=0.0.0.0", \
   "-Dwebgoat.port=8080", \
   "-Dwebwolf.port=9090", \
   "-jar", "webgoat.jar" ]
