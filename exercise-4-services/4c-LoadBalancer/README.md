# Service: Load Balancer

You will create a Load Balancer service and access it.

## Create a Deployment

Here is the deployment file:
```console
$ cat << EOF > my-deployment-50001.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment-50001
spec:
  selector:
    matchLabels:
      app: products
      department: sales
  replicas: 3
  template:
    metadata:
      labels:
        app: products
        department: sales
    spec:
      containers:
      - name: hello
        image: "gcr.io/google-samples/hello-app:2.0"
        env:
        - name: "PORT"
          value: "50001"
EOF
```

```console
$ kubectl apply -f my-deployment-50001.yaml
deployment.apps/my-deployment-50001 created
```

## Create a LoadBalancer service

Here is the service file:
```console
$ cat << EOF > service.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-lb-service
spec:
  type: LoadBalancer
  selector:
    app: products
    department: sales
  ports:
  - protocol: TCP
    port: 60000
    targetPort: 50001
EOF
```

```console
$ kubectl apply -f service.yaml
service/my-lb-service created
```

## Test the service connectivity

Get the LB external IP:
```console
$ kubectl get service my-lb-service -o wide
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)           AGE   SELECTOR
my-lb-service   LoadBalancer   10.43.175.183   10.66.250.29   60000:32486/TCP   29s   app=products,department=sales
```

Access the service
```console
$ curl http://10.66.250.29:60000
Hello, world!
Version: 2.0.0
Hostname: my-deployment-50001-5666887c6-f2q6j
```

## Clean all resources

```console
$ kubectl  delete -f .
```
