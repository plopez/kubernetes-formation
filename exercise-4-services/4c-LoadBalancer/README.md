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

## Test the service connectivity

Get the LB external IP.
Access the service.

## Clean all resources

```console
$ kubectl  delete -f .
```
