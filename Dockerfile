FROM alpine:latest

MAINTAINER nimmis <kjell.havneskold@gmail.com>

COPY rootfs/ /

# configure supervisor
#ADD ./supervisor/supervisord.conf /etc/
#ADD ./supervisor/supervisor.d/crond.conf /etc/supervisor.d/
#ADD ./supervisor/supervisor.d/rsyslogd.conf /etc/supervisor.d/

# Add my_init script and help scripts 
#ADD bin/my_init /
#ADD bin/my_service /

RUN apk update && apk upgrade && \
    apk add ca-certificates supervisor rsyslog supervisor && \
    chmod +x /my_* && \
    mkdir /etc/my_runonce /etc/my_runalways /etc/container_environment /etc/workaround-docker-2267 /var/log/supervisor && \
    touch /var/log/startup.log && chmod 666 /var/log/startup.log && \
    rm -rf /var/cache/apk/*

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Define default command.
CMD ["/my_init"]

