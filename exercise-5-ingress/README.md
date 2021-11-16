# Use Ingress and IngressRules

In this exercise, you will create an application pod `/v1` and expose it through an Ingress targetting a Service.

Then you will create a second version of the application (`/v2`) and manage the routing via another Ingress.

## Deploy version /v1 of the application

Create the pod:
```console
$ kubectl run web --image=gcr.io/google-samples/hello-app:1.0 --port=8080
pod/web created
```

Expose the pod as a service:
```console
$ kubectl expose pod web --target-port=8080 --type=NodePort
service/web exposed
$ kubectl get service web
NAME   TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
web    NodePort   10.43.196.166   <none>        8080:31893/TCP   19s
```

## Create an Ingress resource without path based routing rules

Here is the Ingress definition file:
```console
$ cat << EOF > basic-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: basic-ingress
spec:
  defaultBackend:
    service:
      name: web
      port:
        number: 8080
EOF
```

Create the ingress. Be carefull, it may be incorrect regarding the service we want to target...
```console
$ kubectl apply -f basic-ingress.yaml
ingress.networking.k8s.io/basic-ingress created
```

Ensure the ingress is correctly created (it can take some time):
```console
$ kubectl get ingress basic-ingress
NAME            CLASS    HOSTS   ADDRESS        PORTS   AGE
basic-ingress   <none>   *       10.66.250.29   80      97s
```

Test the connectivity - what is the URL to connect on ?
```console
$ curl http://212.47.251.109     
Hello, world!
Version: 1.0.0
Hostname: web
```

## Deploy a second version of the application

Create the Pod and service for the version 2:
```console
$ kubectl create deployment web2 --image=gcr.io/google-samples/hello-app:2.0 --port=8080
deployment.apps/web2 created
$ kubectl expose deployment web2 --target-port=8080 --type=NodePort
service/web2 exposed
```

Create a new Ingress with the routing rules:
```console
$ cat << EOF > fanout-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fanout-ingress
spec:
  rules:
  - http:
      paths:
      - path: /v1
        pathType: ImplementationSpecific
        backend:
          service:
            name: web
            port:
              number: 8080
      - path: /v2
        pathType: ImplementationSpecific
        backend:
          service:
            name: web2
            port:
              number: 8080
EOF
```

```console
$ kubectl apply -f fanout-ingress.yaml
ingress.networking.k8s.io/fanout-ingress created
```

Ensure the ingress is correctly created (it can take some time):

```console
$ kubectl get ingress fanout-ingress
NAME             CLASS    HOSTS   ADDRESS        PORTS   AGE
fanout-ingress   <none>   *       10.66.250.29   80      31s
```

Connect to the services via the new Ingress.

Test URLs `/v1` and `/v2`.
```console
$ curl http://212.47.251.109/v1
Hello, world!
Version: 1.0.0
Hostname: web
$ curl http://212.47.251.109/v2
Hello, world!
Version: 2.0.0
Hostname: web2-66bdbd4d9b-8mszt
```

## Clean
```console
$ kubectl delete ingress basic-ingress
$ kubectl delete ingress fanout-ingress
$ kubectl delete pod web
$ kubectl delete deployment web2
$ kubectl delete service web web2
```
