# Services : Cluster IP

You will create a Cluster IP service and access it.

## Create a Deployment

Here is the deployment file:
```console
$ cat << EOF > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
spec:
  selector:
    matchLabels:
      app: metrics
      department: sales
  replicas: 3
  template:
    metadata:
      labels:
        app: metrics
        department: sales
    spec:
      containers:
      - name: hello
        image: "gcr.io/google-samples/hello-app:2.0"
EOF
```

```console
$ kubectl apply -f deployment.yaml
deployment.apps/my-deployment created
```

## Create a Cluster IP service

Here is the service file:
```console
$ cat << EOF > service.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-cip-service
spec:
  type: ClusterIP
  selector:
    app: metrics
    department: sales
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
EOF
```

```console
$ kubectl apply -f service.yaml
service/my-cip-service created
```

Ensure the service has entries in its endpoints... if not, correct the `service.yaml` because it may be incorrect!

To see the endpoints:
```console
$ kubectl describe svc my-cip-service
Name:              my-cip-service
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=metrics,department=ingeneering
Type:              ClusterIP
IP Families:       <none>
IP:                10.43.149.3
IPs:               10.43.149.3
Port:              <unset>  80/TCP
TargetPort:        8080/TCP
Endpoints:         <none>
Session Affinity:  None
Events:            <none>
```

## Test the service connectivity

Determine the CLUSTER IP
```console
$ kubectl get service my-cip-service -o wide
NAME             TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE   SELECTOR
my-cip-service   ClusterIP   10.43.149.3   <none>        80/TCP    40s   app=metrics,department=ingeneering
```

Access the service: try the [CLUSTER_IP]:80. This does not work. How can you access the service?
```console
$ curl http://10.43.149.3
curl: (7) Failed to connect to 10.43.149.3 port 80: Connection refused
```
Why ?
Cluster IP is a virtual IP which does not "exists" outside the cluster.
You can access the service by proxifying this IP through kubectl or acessing it from inside a pod
```console
$ kubectl port-forward service/my-cip-service 8080:80
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Handling connection for 8080
$ curl http://localhost:8080
Hello, world!
Version: 2.0.0
Hostname: my-deployment-5d7b664866-q7p4w
```

Execute a console shell inside a pod of the service
Try the curl on http://my-cip-service.default.svc.cluster.local:80
```console
$ kubectl exec -it  my-deployment-7bc95fb476-q75rz sh
# Install curl
/ # apk add --no-cache curl
fetch https://dl-cdn.alpinelinux.org/alpine/v3.14/main/x86_64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.14/community/x86_64/APKINDEX.tar.gz
(1/5) Installing ca-certificates (20191127-r5)
(2/5) Installing brotli-libs (1.0.9-r5)
(3/5) Installing nghttp2-libs (1.43.0-r0)
(4/5) Installing libcurl (7.79.1-r0)
(5/5) Installing curl (7.79.1-r0)
Executing busybox-1.33.1-r3.trigger
Executing ca-certificates-20191127-r5.trigger
OK: 8 MiB in 19 packages
/ # curl http://my-cip-service.default.svc.cluster.local:80
Hello, world!
Version: 2.0.0
Hostname: my-deployment-5d7b664866-q7p4w
```

## Clean all resources

```console
$ kubectl  delete -f .
```
