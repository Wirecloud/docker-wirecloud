

# How to use Deployment files
This folder consists:
-deployments file
-service file
-persistent volume file
-persisten volume claim

How to build the deployments:
***Make sure you have  an installed kubernetes cluster node and kubectl tool to manage kubernetes deployments***




edit volume file's #change this part
- create volume with the following command
 ```
kubectl apply -f wirecloud-static-volume.yaml
```

- create persistent volume with the following command
```
kubectl apply -f wirecloud-static-persistentvolumeclaim.yaml
```

edit the deployment file's #change this part
- create deployment with the following command:
```
kubectl apply -f wirecloud-deployment.yaml
```

edit service file's #change this part
- create services with the following command:
```
kubectl apply -f wirecloud-service.yaml
```







