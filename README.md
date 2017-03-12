## RStudio Appengine

Appengine is a managed compute service that recently started to [support Docker environments that can run any code](https://cloud.google.com/appengine/docs/flexible/).  This is a demo of deploying R.

Appengine offers benefits such as a free tier and auto scaling that turns off the instance when you are not using it.  It reboots upon request of the application URL.

I wouldn't keep any data on the instance, but with the use of [Google Cloud Storage](https://github.com/cloudyr/googleCloudStorageR) you can preserve state. 

Other applications of R on appengine include an R API via OpenCPU/plumber.  Shiny sadly can't be supported yet as it uses websockets, that aren't yet supported on Appengine flexible containers. 


## Setup

Clone repo then in same directory run:

```
gcloud app deploy --project your-project
```

Demo: https://mark-rstudio.appspot.com (auth login only) 

## authentication

Instance has a Google OAuth2 proxy login over the normal RStudio login, you can configure access via 
https://console.cloud.google.com/iam-admin/gatekeeper/project

## scaling config

The RStudio session disconnects on default scaling settings, as only one session is allowed per RStudio Server connection and appengine defaults to 2
https://cloud.google.com/appengine/docs/standard/python/how-instances-are-managed

Configure app.yaml to get around this:

### app.yaml configuration

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

You can set the size of the instance via the resources config:

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

