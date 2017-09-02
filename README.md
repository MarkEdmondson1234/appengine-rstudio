## RStudio App Engine

App Engine is a managed compute service that recently started to [support Docker environments that can run any code](https://cloud.google.com/appengine/docs/flexible/).  This is a demo of deploying RStudio.

App Engine offers benefits such as auto scaling that turns off the instance when you are not using it.  It reboots upon request of the application URL.

This builds on top of the [persistent RStudio image](https://cloudyr.github.io/googleComputeEngineR/articles/persistent-rstudio.html) developed for googleComputeEngineR, with which you can configure persistent GitHub/SSH keys and backups on Cloud Storage. 

## Launch

1. If you haven't got one already, set up a Google Cloud Storage bucket that will contain the R session backup data
2. Clone this repo
3. The authentication service email will be the default App Engine project one: e.g. `your-project@appspot.gserviceaccount.com` - give this at least Cloud Storage access to the bucket from step 1
4. Change this line in the `Renviron.site` to the bucket from step 1

```
GCS_SESSION_BUCKET="your bucket"
```

5. [Optional] Add your default username that you use on other RStudio backups by altering `your_username` and `your_password` in the below.  If you don't do this, you will be saving files under `/home/rstudio` username.

```
## add your default user and password
RUN useradd --create-home --shell /bin/bash your_username && \
    echo your_username:your_password | chpasswd
```

6. In the same directory run:

```
gcloud app deploy --project your-project
```

It takes a while (10mins +)

7. Once ready, log in with username `rstudio` and password `rstudio`, or your details you set in step 5. 
8. Configure Identity Aware Proxy https://console.cloud.google.com/iam-admin/iap for the App Engine project URL. [How-to guide](https://cloud.google.com/iap/docs/app-engine-quickstart).  This will add a Google OAuth2 login over the RStudio login page (much more secure)

You should now have all the settings you saved under `/home/your_user` on the Cloud Service available each time you login. The server will turn off after some time of inactivity.  See [this link](https://cloudyr.github.io/googleComputeEngineR/articles/persistent-rstudio.html) for details. 

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

The `Dockerfile` downloads a prepared RStudio instance with tools to persist data, and `rserver.conf` puts RStudio on port `8080` as required by App Engine, which will then route traffic onto normal web ports `80`. It then adds any environment arguments saved in `Renviron.site` - minimum it needs `GCS_SESSION_BUCKET` but you can add other stuff such as other API keys, defaults etc. here. 

## Authentication

Identity Aware Proxy https://console.cloud.google.com/iam-admin/iap for the App Engine. [How-to guide](https://cloud.google.com/iap/docs/app-engine-quickstart).

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

