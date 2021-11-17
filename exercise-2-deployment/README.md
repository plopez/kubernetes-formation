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
  number-of-replicas: 2
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

Create the deployment.
Ensure you have 2 running pods.

Now delete one of the 2 created pod:
```console
$ kubectl delete pod/hello-dep-<xxx>
```

Wait few seconds to see a replacement pod for the one you deleted:
```console
$ kubectl get deployment,pods
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

Apply the changes.

## "Scale up" the application

You will change the number of replicas:
```console
$ kubectl scale deployment hello-dep --replicas=3
```

Wait few seconds and count the pods.

## Clean all the resources
```console
$ kubectl delete deployment --all
deployment.apps "hello-dep" deleted
```
