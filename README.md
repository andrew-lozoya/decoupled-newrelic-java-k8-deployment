[![Example Code header](https://github.com/newrelic/opensource-website/raw/master/src/images/categories/Example_Code.png)](https://opensource.newrelic.com/oss-category/#example-code)

Introduction
----------------------
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![New Relic Java Agent](https://img.shields.io/badge/Java_Agent-v6.2.1-0ab0bf?logo=image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI2NCIgaGVpZ2h0PSI2NCI+PHBhdGggZD0iTTYzLjUzIDI1LjE0NWMtMy4wMDMtMTMuOC0xOS41NS0yMS45MTQtMzYuOTY2LTE4LjEzUy0yLjUzIDI1LjA2LjQ3IDM4Ljg1NHMxOS41NSAyMS45MTggMzYuOTYyIDE4LjEzIDI5LjA5OC0xOC4wMjcgMjYuMS0zMS44NHpNMzIuMDAyIDQ0LjcyYTEyLjcyIDEyLjcyIDAgMCAxLTguOTk0LTIxLjcxNCAxMi43MiAxMi43MiAwIDAgMSAyMS43MTQgOC45OTRjMCA3LjAyNS01LjY5NSAxMi43Mi0xMi43MiAxMi43MnoiIGZpbGw9IiMwMDhjOTkiLz48cGF0aCBkPSJNMzQuODEzIDE0LjE5MmMtMTAuMDg2LjAwMi0xOC4yNiA4LjE4LTE4LjI2IDE4LjI2NnM4LjE3OCAxOC4yNiAxOC4yNjQgMTguMjZTNTMuMDggNDIuNTQgNTMuMDggMzIuNDU1YzAtNC44NDQtMS45MjUtOS41LTUuMzUtMTIuOTE1cy04LjA3Mi01LjM1LTEyLjkxNi01LjM0OHpNMzEuOTk4IDQzLjFhMTEuMTEgMTEuMTEgMCAwIDEtNy44NTYtMTguOTY2IDExLjExIDExLjExIDAgMCAxIDE4Ljk2NiA3Ljg1NmMwIDYuMTM0LTQuOTcyIDExLjEwOC0xMS4xMDYgMTEuMXoiIGZpbGw9IiM3MGNjZDMiLz48L3N2Zz4=)](https://docs.newrelic.com/docs/release-notes/agent-release-notes/java-release-notes/java-agent-621)
 [![Docker Image Size](https://img.shields.io/docker/image-size/andrewlozoya/springapp)](https://hub.docker.com/layers/129577024/andrewlozoya/springapp/3.0/images/sha256-ab24090e681a19988f62ab7c73d69693e7677f15c3887758562ab2f5fa3af71b?context=explore) 

Using Minikube this project aims to demonstrate decoupling New Relic from the docker build process altogether with New Relic instrumentation best practices in mind. This concept would effectively allow you to reduce toil and be more flexible in your deployment workflows. Since we are using Minikube this project will focus on `hostPath` but can easily be applied to various other types of volumes like:

    AWS EBS/EFS
    azureDisk
    gcePersistentDisk
    etc.
    
  
![PVC](https://github.com/andrew-lozoya/decoupled-newrelic-java-k8-deployment/blob/master/images/pvc.png)

## Getting Started

1) You need a New Relic account and license key. You can create one on https://newrelic.com/signup

2) Deploy a Kubernetes secret with your New Relic license key: `kubectl create secret generic newrelic-secret --from-literal=new_relic_license_key='[[NEW RELIC LICENSE KEY]]'`

3) The example code already assumes you have a defined a New Relic directory with the java agent unpacked. We will use this location later as the mount point to decouple the `newrelic.jar` from the docker build process. If you need to download the agent please see: 

* Start a command-line session.
* Change to your mount directory where you can download the zip file.
* Execute this curl commands:

```bash
$ curl -O https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip
$ Unzip newrelic-java.zip
```

**OPTIONAL:** You can build the application using Maven>=3.8.0
```bash
$ git clone https://github.com/andrewlozoya/decoupled-newrelic-java-k8-deployment
$ cd decoupled-newrelic-java-k8-deployment/docker-spring-boot
$ mvn clean package
```

**OPTIONAL:** Docker build/push commands to support your own repository
```bash
$ sudo docker build -t springapp:1.0 .
$ sudo docker push {USERNAME}/springapp:1.0
```

Set up Ingress on Minikube with the NGINX Ingress Controller
----------------------

```bash
$ minikube start --container-runtime=docker --kubernetes-version=v1.18.9 --mount=true --mount-string="$HOME/NewRelic/java:/opt/app/newrelic"
```

**Note:** the `--mount-string="$HOME/NewRelic/java:/opt/app/newrelic"` is the hostmount location.

If you are already running minikube you can mount a volume retroactively:

```bash
$ nohup minikube mount $HOME/NewRelic/java:/opt/app/newrelic &
```

## Enable the Ingress controller:

1. To enable the NGINX Ingress controller, run the following command:

```bash
$ minikube addons enable ingress
```

2. Verify that the NGINX Ingress controller is running

```bash
$ kubectl get pods -n kube-system
```

**Note:** This can take up to a minute.

Output:
```bash
NAME                                        READY   STATUS      RESTARTS   AGE
coredns-66bff467f8-mbw8t                    1/1     Running     0          7m
etcd-minikube                               1/1     Running     0          7m
ingress-nginx-admission-create-knlfp        0/1     Completed   0          7m
ingress-nginx-admission-patch-qvszc         0/1     Completed   0          7m
ingress-nginx-controller-6f5f4f5cfc-rx8dm   1/1     Running     0          7m
kube-apiserver-minikube                     1/1     Running     0          7m
kube-controller-manager-minikube            1/1     Running     0          7m
kube-proxy-2phv9                            1/1     Running     0          7m
kube-scheduler-minikube                     1/1     Running     0          7m
storage-provisioner                         1/1     Running     0          7m
```

Now that our cluster is up you can validate if your volume mount is working!:
![Minikube](https://github.com/andrew-lozoya/decoupled-newrelic-java-k8-deployment/blob/master/images/minikube.png)


## Deploy the ConfigMap
1. Create a ConfigMap using the following command:
```bash
$ kubectl apply -f configmap.yaml
```

Output:
```bash
configmap/newrelic-config created
```

## Deploy the Spring App

1. Create a Deployment using the following command:
```bash
$ kubectl apply -f deployment.yaml
```

![deployment.yaml](https://github.com/andrew-lozoya/decoupled-newrelic-java-k8-deployment/blob/master/images/deployment.png)

**Notice:** We are passing `JAVA_OPTS` in the container spec as well defining the volume mounts that will be used to decouple the agent & config from any docker build processes.**

Output:
```bash
deployment.apps/springapp-deployment created
```

2. Expose the Deployment:
```bash
$ kubectl expose deployment springapp-deployment --type=NodePort --port=8080
```

Output:
```bash
service/springapp-deployment exposed
```

3. Verify the Service is created and is available on a node port:
```bash
$ kubectl get service springapp-deployment
```

Output:
```bash
NAME                   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
springapp-deployment   NodePort   10.111.26.245   <none>        8080:32288/TCP   3h29m
```

4. Visit the service via NodePort:
```bash
minikube service springapp-deployment --url
```

Output:
```bash
http://192.168.64.18:32288
```

## Apply the Ingress resource

1. Create the Ingress resource by running the following command:
```bash
$ kubectl apply -f ingress.yaml
```

Output:
```bash
ingress.networking.k8s.io/rewrite configured
```

2. Verify the IP address is set:
```bash
$ kubectl get ingress
```

Note: This can take a couple of minutes.
```bash
NAME      CLASS    HOSTS             ADDRESS         PORTS   AGE
rewrite   <none>   spring-app.info   192.168.64.18   80      123m
```

4. Add the following line to the bottom of the `/etc/hosts` file.

Note: If you are running Minikube locally, use `minikube ip` to get the external IP. The IP address displayed within the ingress list will be the internal IP.

```bash
192.168.64.18 spring-app.info
```

This sends requests from spring-app.info to Minikube.

## Generate load
1. Generate some load on the ingress.networking.k8s.io/rewrite rule to the MVC controller:

Browser: http://spring-app.info

alternatively, 

``` bash
$ curl --request GET --url http://spring-app.info
```

## Verify
![newrelic.yml](https://github.com/andrew-lozoya/decoupled-newrelic-java-k8-deployment/blob/master/images/newrelic.png)


## System property considerations

The [system property](https://docs.newrelic.com/docs/agents/java-agent/configuration/java-agent-configuration-config-file#System_Properties) configurations can be passed as JAVA_OPTS. Most of the given settings in the config file are setting names prefixed by `-Dnewrelic.config.` For example, the system property for the `log_level` setting is `-Dnewrelic.config.log_level=info`.

However, not all options are usable in this way. Consider referencing the `newrelic.yml` location or creating a ConfigMap where needed like in this example. [Kustomize.io](https://kustomize.io/) is also a great solution where you maybe considering a ConfigMap with mulitple deployment variations.
