FROM openjdk:7-alpine

LABEL maintainer="Paolo Smiraglia" \
      maintainer.email="paolo.smiraglia@gmail.com"

ENV CASSANDRA_VERSION=1.2.19 \
    CASSANDRA_USER=cassandra \
    CASSANDRA_GROUP=cassandra \
    CASSANDRA_HOME=/opt/cassandra

# download and verify Cassandra tarball
RUN apk --update --no-cache add \
        curl \
        gnupg \
    && curl https://www.apache.org/dist/cassandra/KEYS 2>/dev/null | gpg --import \
    && wget http://archive.apache.org/dist/cassandra/${CASSANDRA_VERSION}/apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz -O /tmp/cassandra.tar.gz \
    && wget http://archive.apache.org/dist/cassandra/${CASSANDRA_VERSION}/apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz.asc -O /tmp/cassandra.tar.gz.asc \
    && gpg --verify /tmp/cassandra.tar.gz.asc /tmp/cassandra.tar.gz

# install cassandra
RUN mkdir -p ${CASSANDRA_HOME} \
    && addgroup -S ${CASSANDRA_GROUP} \
    && adduser -h ${CASSANDRA_HOME} -s /sbin/nologin -G ${CASSANDRA_GROUP} -S -D ${CASSANDRA_USER} \
    && cd ${CASSANDRA_HOME} \
    && tar xf /tmp/cassandra.tar.gz --strip-components=1 \
    && mkdir -p \
        /var/lib/cassandra \
        /var/log/cassandra \
    && chown -R ${CASSANDRA_USER}:${CASSANDRA_GROUP} \
        ${CASSANDRA_HOME} \
        /var/lib/cassandra \
        /var/log/cassandra

# add bootstrap script
COPY docker-bootstrap /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-bootstrap

# cleanup environment
RUN apk del \
        curl \
        gnupg \
    && rm -fr \
        /root/.gnupg \
        /tmp/* \
        /var/cache/apk/*

# execute Cassandra
WORKDIR ${CASSANDRA_HOME}
EXPOSE 9160
USER ${CASSANDRA_USER}
CMD ["/usr/local/bin/docker-bootstrap"]
