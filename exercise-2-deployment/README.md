# Use deployments to ensure pods are running

In this exercise, you will deploy pods via deployment resources.
You will see the interests of using deployment:
* easy update of pods
* horizontal scalability
* maintaining *n* replicas of pods

## Deploy version 1.0 with 2 replicas

Create a deployment file with the following content (be carefull, the provided `.yaml` file may be incorrect! See [the documentation if needed](https://v1-18.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#deploymentspec-v1-apps)):
```console
$ cat << EOF > hello-v1.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-dep
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-dep
  template:
    metadata:
      labels:
        app: hello-dep
    spec:
      containers:
      - image: gcr.io/google-samples/hello-app:1.0
        imagePullPolicy: Always
        name: hello-dep
        ports:
        - containerPort: 8080
EOF
```

Create the deployment:
```console
$ kubectl apply -f hello-v1.yml
deployment.apps/hello-dep created
```

Ensure you have 2 running pods:
```console
$ kubectl get deployment,pods
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hello-dep   2/2     2            2           23s

NAME                            READY   STATUS    RESTARTS   AGE
pod/hello-dep-fdb5b555c-n5qrk   1/1     Running   0          22s
pod/hello-dep-fdb5b555c-wttjv   1/1     Running   0          22s
```

Now delete one of the 2 created pod:
```console
$ kubectl delete pod/hello-dep-fdb5b555c-n5qrk
pod "hello-dep-fdb5b555c-n5qrk" deleted
```

Wait few seconds to see a replacement pod for the one you deleted:
```console
$ kubectl get deployment,pods
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hello-dep   2/2     2            2           2m46s

NAME                            READY   STATUS    RESTARTS   AGE
pod/hello-dep-fdb5b555c-wttjv   1/1     Running   0          2m45s
pod/hello-dep-fdb5b555c-hgq54   1/1     Running   0          64s
```

## Deploy the version 2.0
Create the following file
```console
$ cat << EOF > hello-v2.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-dep
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-dep
  template:
    metadata:
      labels:
        app: hello-dep
    spec:
      containers:
      - image: gcr.io/google-samples/hello-app:2.0
        imagePullPolicy: Always
        name: hello-dep
        ports:
        - containerPort: 8080
EOF
 ```

Apply the changes:
```console
$ kubectl apply -f hello-v2.yml
deployment.apps/hello-dep configured
```

## "Scale up" the application

You will change the number of replicas:
```console
$ kubectl scale deployment hello-dep --replicas=3
deployment.apps/hello-dep scaled
```

Wait few seconds and count the pods:
```console
$ kubectl get deployment,pods
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hello-dep   3/3     3            3           6m10s

NAME                            READY   STATUS    RESTARTS   AGE
pod/hello-dep-7c86658f6-nm97d   1/1     Running   0          95s
pod/hello-dep-7c86658f6-68hsp   1/1     Running   0          92s
pod/hello-dep-7c86658f6-5zw6j   1/1     Running   0          29s
```

## Clean all the resources
```console
$ kubectl delete deployment --all
deployment.apps "hello-dep" deleted
```
