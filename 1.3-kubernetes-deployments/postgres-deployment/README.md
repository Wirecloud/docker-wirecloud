[![tigalab's logo](https://raw.githubusercontent.com/tigalab/kubernetes-deployments-docker-wirecloud/tigalab/1.3-kubernetes-deployments/tiga-ico.JPG)](https://www.tiga.com.tr/)


[![tigalab's logo](https://raw.githubusercontent.com/tigalab/kubernetes-deployments-docker-wirecloud/tigalab/1.3-kubernetes-deployments/tiga-ico.JPG)](https://www.tiga.com.tr/)


# How to use Deployment files
This folder consists:
-deployments file
-service file
-persistent volume file
-persisten volume claim

How to install:
***Make sure you have  an installed kubernetes cluster node and kubectl tool to manage kubernetes deployments***




edit volume file's #change this part

- create volume with the following command
 ```
kubectl apply -f postgres-data-volume.yaml
```

- create persistent volume with the following command
```
kubectl apply -f postgres-data-claim.yaml
```

edit the deployment file's #change this part
- create deployment with the following command:
```
kubectl apply -f postgres-deployment.yaml
```

edit service file's #change this part
- create services with the following command:
```
kubectl apply -f postgres-service.yaml
```














