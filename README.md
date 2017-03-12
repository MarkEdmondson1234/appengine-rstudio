## RStudio Appengine

Clone repo then in same directory run:

```
gcloud app deploy --project your-project
```

https://mark-rstudio.appspot.com - can put on Google OAuth2 proxy login to protect server.

Session disconnects on default scaling settings, as only one session allowed per connection and appengine defaults to 2
https://cloud.google.com/appengine/docs/standard/python/how-instances-are-managed

## app.yaml configuration

See how to config the [app.yaml here](https://cloud.google.com/appengine/docs/flexible/custom-runtimes/configuring-your-app-with-app-yaml)

Set to only 1 per instance with 30min timeout via:

```yaml
automatic_scaling:
  min_num_instances: 1
  max_num_instances: 1
```

If you want the instance to run all the time, replace basic scaling with manual scaling:

```yaml
manual_scaling:
  instances: 1
```

Flexible containers do not support basic_scaling

## Instance size

Via the resources config:

e.g. 

```yaml
resources:
  cpu: 2
  memory_gb: 2.3
  disk_size_gb: 10
  volumes:
  - name: ramdisk1
    volume_type: tmpfs
    size_gb: 0.5
```

## reference

https://support.rstudio.com/hc/en-us/articles/200552316-Configuring-the-Server

https://github.com/rocker-org/rocker/blob/master/rstudio/testing/Dockerfile

https://cloud.google.com/appengine/docs/standard/python/an-overview-of-app-engine

## debug

```
gcloud app --project [PROJECT-ID] instances enable-debug
```

