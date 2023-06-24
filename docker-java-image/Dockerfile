# original image: https://github.com/Cimpress-MCP/docker-git2consul
FROM anapsix/alpine-java:8_jdk_nashorn

RUN mkdir /myapp

COPY entrypoint.sh /

COPY hello.jar /myapp/app.jar

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
