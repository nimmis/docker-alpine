FROM alpine:3.1

MAINTAINER nimmis <kjell.havneskold@gmail.com>

COPY rootfs/ /

RUN apk update && apk upgrade && \
    apk add ca-certificates supervisor rsyslog && \
    chmod +x /my_* && \
    mkdir /etc/my_runonce /etc/my_runalways /etc/container_environment /etc/workaround-docker-2267 /var/log/supervisor && \
    touch /var/log/startup.log && chmod 666 /var/log/startup.log && \
    rm -rf /var/cache/apk/*

# Set environment variables.
ENV HOME /root

# Define default command.
CMD ["/my_init"]

