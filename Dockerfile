FROM jenkins/jenkins:lts-alpine

LABEL "description"="This image is built on top of official Jenkins image and contain latest awscli, maven, jq."

USER root

RUN apk add --update \ 
    python \
    py-pip && \
    pip install awscli && \
    apk -v --purge del py-pip

ENV MAVEN_VERSION="3.6.0" \
    M2_HOME=/usr/lib/mvn

RUN apk add --update wget && \
    cd /tmp && \
    wget "http://ftp.unicamp.br/pub/apache/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz" && \
    tar -zxvf "apache-maven-$MAVEN_VERSION-bin.tar.gz" && \
    mv "apache-maven-$MAVEN_VERSION" "$M2_HOME" && \
    ln -s "$M2_HOME/bin/mvn" /usr/bin/mvn && \
    apk -v --purge del wget

RUN apk add --update jq

RUN rm -rf /tmp/* /var/cache/apk/*

USER jenkins