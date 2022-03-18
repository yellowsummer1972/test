FROM alpine:latest

RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk --no-cache add curl bash wget

# this is the built-in default
RUN mkdir /pump-init
WORKDIR /pump-init
COPY deliver.sh .
COPY lib.sh . 
COPY pump.conf . 
COPY sites.lst . 
COPY thread.sh . 
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x *.sh

CMD ["/bin/bash", "entrypoint.sh", " ", "&"]
