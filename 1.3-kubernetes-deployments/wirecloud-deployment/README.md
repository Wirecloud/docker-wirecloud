[![tigalab's logo](https://raw.githubusercontent.com/tigalab/kubernetes-deployments-docker-wirecloud/tigalab/1.3-kubernetes-deployments/tiga-ico.JPG)](https://www.tiga.com.tr/)


# How to use Deployment files
This folder consists:
-deployments file
-service file
-persistent volume file
-persisten volume claim

How to install:
***Make sure you have  an installed kubernetes cluster node and kubectl tool to manage kubernetes deployments***



- Create persistent volume that service uses.
edit volume file's #change this part
 create volume with the following command
 ```
kubectl apply -f wirecloud-static-volume.yaml
```

-create persistent volume with the following command
```
kubectl apply -f wirecloud-static-persistentvolumeclaim.yaml
```

-Edit the deployment file's #change this part
 create deployment with the following command:
```
kubectl apply -f wirecloud-deployment.yaml
```

-edit service file's #change this part
 create service with the following command:

```
kubectl apply -f wirecloud-service.yaml
```







