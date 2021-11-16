# Service : Node Port

You will create a Node Port service and access it.

## Create a Deployment

Here is the deployment file:
```console
$ cat << EOF > my-deployment-50000.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment-50000
spec:
  selector:
    matchLabels:
      app: metrics
      department: engineering
  replicas: 3
  template:
    metadata:
      labels:
        app: metrics
        department: engineering
    spec:
      containers:
      - name: hello
        image: "gcr.io/google-samples/hello-app:2.0"
        env:
        - name: "PORT"
          value: "50000"
EOF
```

```console
$ kubectl apply -f my-deployment-50000.yaml
deployment.apps/my-deployment-50000 created
```

## Create a Node Port service

```console
$ cat << EOF > service.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-np-service
spec:
  type: NodePort
  selector:
    app: metrics
    department: engineering
  ports:
  - protocol: TCP
    port: 80
    targetPort: 50000
    # nodePort: 30007   # NOTE: we dont set the nodePort, it will be taken randomly by default
EOF
```

```console
$ kubectl apply -f service.yaml
service/my-np-service created
```

Ensure the service has entries in its endpoints:
```console
$ kubectl describe svc my-np-service
Name:                     my-np-service
Namespace:                default
Labels:                   <none>
Annotations:              field.cattle.io/publicEndpoints: [{"port":32684,"protocol":"TCP","serviceName":"default:my-np-service","allNodes":true}]
Selector:                 app=metrics,department=engineering
Type:                     NodePort
IP Families:              <none>
IP:                       10.43.194.215
IPs:                      10.43.194.215
Port:                     <unset>  80/TCP
TargetPort:               50000/TCP
NodePort:                 <unset>  32684/TCP
Endpoints:                10.42.0.42:50000,10.42.0.43:50000,10.42.0.44:50000
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

## Test the service connectivity

Determine the public IP of any worker node:
```console
$ kubectl get nodes --output wide
NAME    STATUS   ROLES                  AGE   VERSION        INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION     CONTAINER-RUNTIME
abhra   Ready    control-plane,master   60d   v1.20.5+k3s1   10.66.250.29   <none>        Debian GNU/Linux 11 (bullseye)   5.10.46-scaleway   containerd://1.4.4-k3s1
```

Access the service
```console
$curl http://212.47.251.109:32684
Hello, world!
Version: 2.0.0
Hostname: my-deployment-50000-76c87b77b7-v8jsh
```
## Clean all resources

```console
$ kubectl  delete -f .
```
