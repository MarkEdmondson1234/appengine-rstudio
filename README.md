## RStudio App Engine

App Engine is a managed compute service that recently started to [support Docker environments that can run any code](https://cloud.google.com/appengine/docs/flexible/).  This is a demo of deploying RStudio.

App Engine offers benefits such as auto scaling that turns off the instance when you are not using it.  It reboots upon request of the application URL.

This builds on top of the [persistent RStudio image](https://cloudyr.github.io/googleComputeEngineR/articles/persistent-rstudio.html) developed for googleComputeEngineR, with which you can configure persistent GitHub/SSH keys and backups on Cloud Storage. 

## Launch

1. If you haven't got one already, set up a Google Cloud Storage bucket that will contain the backup data
2. Clone this repo
3. The authentication service email will be the default App Engine project one: e.g. `your-project@appspot.gserviceaccount.com` - give this at least Cloud Storage access to the bucket from step 1
4. Change this line in the Dockerfile to the bucket from step 1

```
ENV GCS_SESSION_BUCKET="your-bucket"
```

5. In the same directory run:

```
gcloud app deploy --project you-project
```

It takes a while. 

## Configuration

The `app.yaml` configures how the RStudio instance performs:

```yaml
runtime: custom
env: flex
automatic_scaling:
  min_num_instances: 1
  max_num_instances: 1
  
resources:
  cpu: 2
  memory_gb: 4
```

The `Dockerfile` downloads a prepared RStudio instance with tools to persist data, and `rserver.conf` puts RStudio on port `8080` as required by App Engine, which will then route traffic onto normal web ports `80`. 

## Authentication

Setup an Identity Aware Proxy https://console.cloud.google.com/iam-admin/iap for the App Engine. [How-to guide](https://cloud.google.com/iap/docs/app-engine-quickstart).

The instance uses this to add a Google OAuth2 proxy login over the top of the normal RStudio login, you can configure access

After Google Auth, you can log into RStudio using the default rstudio / rstudio login. 

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

If you want the instance to run all the time, replace basic scaling with manual scaling - but this is not worth doing as its much more expensive than running a GCE instance. 

```yaml
manual_scaling:
  instances: 1
```

Flexible containers do not support basic_scaling

### Instance size

You can set the size of the instance via the resources config.  

e.g. 

```yaml
resources:
  cpu: 2
  memory_gb: 2
```

### Environment

Set this to the bucket that contains your backups.  This will be saved under the "rstudio" username - see [this link](https://cloudyr.github.io/googleComputeEngineR/articles/persistent-rstudio.html) on how to configure this to be persistent between other GCE instances and local RStudio. 

```
env_variables:
  GCS_SESSION_BUCKET: "the-gcs-session-bucket"
```

## Pricing

[Pricing is here](https://cloud.google.com/appengine/pricing#flexible-environment-instances).  Flexible doesn't do a free tier yet. 

A rough guide is $1.26 per 24hours per core, $0.17 per 24hours per GB of RAM.

Running a 1 core instance with 2GB of ram per day will be $1.60 for 24hours, or $0.07 an hour.  

Assuming 3 hours use per 5day weekdays (20 days * 3 hours) this is $4 a month.



## reference

https://cloudyr.github.io/googleComputeEngineR/articles/persistent-rstudio.html

https://support.rstudio.com/hc/en-us/articles/200552316-Configuring-the-Server

https://github.com/rocker-org/rocker/blob/master/rstudio/testing/Dockerfile

https://cloud.google.com/appengine/docs/standard/python/an-overview-of-app-engine

## debug

```
gcloud app --project [PROJECT-ID] instances enable-debug
```

