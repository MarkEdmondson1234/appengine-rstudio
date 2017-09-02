FROM gcr.io/gcer-public/persistent-rstudio
MAINTAINER Mark Edmondson (r@sunholo.com)

EXPOSE 8080

## copy configuration file
COPY rserver.conf /etc/rstudio/rserver.conf

## change this line to your session bucket
ENV GCS_SESSION_BUCKET="your-bucket"
