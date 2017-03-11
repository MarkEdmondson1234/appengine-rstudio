FROM rocker/hadleyverse
MAINTAINER Mark Edmondson (r@sunholo.com)

EXPOSE 8080

## copy configuration file
COPY rserver.conf /etc/rstudio/rserver.conf

