## RStudio Appengine

Clone repo then in same directory run:

```
gcloud app deploy --project your-project
```

https://mark-rstudio.appspot.com - can put on Google OAuth2 proxy login to protect server.

Session disconnects on default settings, as only one session allowed per connection and appengine defaults to 5
https://cloud.google.com/appengine/docs/standard/python/how-instances-are-managed

Set to only 1 per instance via:

```yaml
basic_scaling:
  max_instances: 1
  idle_timeout: 30m
```


## reference

https://support.rstudio.com/hc/en-us/articles/200552316-Configuring-the-Server

https://github.com/rocker-org/rocker/blob/master/rstudio/testing/Dockerfile

## debug

```
gcloud app --project [PROJECT-ID] instances enable-debug
```

