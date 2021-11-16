# Using secret and a configmap for a database.

In this exercise, you will create a k8s secret as well as a k8s configmap to correctly configure a MariaDB database.

# Secrets

## Create the MYSQL_ROOT_PASSWORD secret

Generate a base-64 encoded string:
```console
$ echo -n 'KubernetesTraining!' | base64
S3ViZXJuZXRlc1RyYWluaW5nIQ==
```

Note the value and put it in the secret definition:
```console
$ cat << EOF > mysql-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: mariadb-root-password
type: Opaque
data:
  password: YOUR_VALUE
EOF
```

Then, create the `mariadb-root-password` secret:
```console
$ kubectl apply -f mysql-secret.yaml
secret/mariadb-root-password created
```

View the secret:

```console
$ kubectl describe secret mariadb-root-password
Name:         mariadb-root-password
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
password:  19 bytes
$ kubectl get secret mariadb-root-password -o jsonpath='{.data.password}' | base64 -d
KubernetesTraining!
```

Create a secret for the db user - second way to create a secret

```console
$ kubectl create secret generic mariadb-user-creds \
      --from-literal=MYSQL_USER=kubeuser\
      --from-literal=MYSQL_PASSWORD=KubernetesTraining
secret/mariadb-user-creds created
```

View the secret:
```console
$ kubectl get secret mariadb-user-creds -o jsonpath='{.data.MYSQL_PASSWORD}' | base64 -d
KubernetesTraining
```

# ConfigMap

## Create a configMap to configure the mariadb application

```console
$ cat << EOF > max_allowed_packet.cnf
[mysqld]
max_allowed_packet = 64M
EOF

$ kubectl create configmap mariadb-config --from-file=max_allowed_packet.cnf
configmap/mariadb-config created
```

Edit the configMap to change the value 32M to `max_allowed_packet`.
```console
$ kubectl edit configmap mariadb-config
configmap/mariadb-config edited
```


View the configmap:
```console
$ kubectl get configmap mariadb-config -o yaml
apiVersion: v1
data:
  max_allowed_packet.cnf: |
    [mysqld]
    max_allowed_packet = 32M
kind: ConfigMap
metadata:
  creationTimestamp: "2021-11-16T13:32:45Z"
  managedFields:
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:data: {}
    manager: kubectl-create
    operation: Update
    time: "2021-11-16T13:32:45Z"
  - apiVersion: v1
    fieldsType: FieldsV1
    fieldsV1:
      f:data:
        f:max_allowed_packet.cnf: {}
    manager: kubectl-edit
    operation: Update
    time: "2021-11-16T13:33:36Z"
  name: mariadb-config
  namespace: default
  resourceVersion: "16682986"
  uid: c27ccd8e-9056-4c76-8d6c-00610f457aa0
```

# Use the secrets and configMap

## Add 2 secrets as environment variables to the Deployment:

* `mariadb-root-password`: key/value pair
* `mariadb-user-creds`: key/value pair

Create a mariaDb Deployment file
```console
$ cat << EOF > mariadb-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: mariadb
  name: mariadb-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mariadb
  template:
    metadata:
      labels:
        app: mariadb
    spec:
      containers:
      - name: mariadb
        image: docker.io/mariadb:10.4
        ports:
        - containerPort: 3306
          protocol: TCP
        volumeMounts:
        - mountPath: /var/lib/mysql
          name: mariadb-volume-1
      volumes:
      - emptyDir: {}
        name: mariadb-volume-1
EOF
```

Both elements must be added in the deployment:

```
env:
   - name: MYSQL_ROOT_PASSWORD
     valueFrom:
       secretKeyRef:
         name: mariadb-root-password
         key: password
```

and

```
envFrom:
- secretRef:
    name: mariadb-user-creds
```

## Add your configMap to the deployment

Add your ConfigMap as source, adding it to `volumes` entry of the pod spec. Then add a `volumeMount` to the container definition.

Use the configMap as a `volumeMount` to `/etc/mysql/conf.d`

```
<...>

  volumeMounts:
  - mountPath: /var/lib/mysql
    name: mariadb-volume-1
  - mountPath: /etc/mysql/conf.d
    name: mariadb-config-volume

<...>

volumes:
- emptyDir: {}
  name: mariadb-volume-1
- configMap:
    name: mariadb-config
    items:
      - key: max_allowed_packet.cnf
        path: max_allowed_packet.cnf
  name: mariadb-config-volume

<...>
```

```console
$ cat << EOF > mariadb-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: mariadb
  name: mariadb-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mariadb
  template:
    metadata:
      labels:
        app: mariadb
    spec:
      containers:
      - name: mariadb
        image: docker.io/mariadb:10.4
        ports:
        - containerPort: 3306
          protocol: TCP
        volumeMounts:
        - mountPath: /var/lib/mysql
          name: mariadb-volume-1
        - mountPath: /etc/mysql/conf.d
          name: mariadb-config-volume
        env:
           - name: MYSQL_ROOT_PASSWORD
             valueFrom:
               secretKeyRef:
                 name: mariadb-root-password
                 key: password
        envFrom:
        - secretRef:
           name: mariadb-user-creds
      volumes:
      - emptyDir: {}
        name: mariadb-volume-1
      - configMap:
          name: mariadb-config
          items:
            - key: max_allowed_packet.cnf
              path: max_allowed_packet.cnf
        name: mariadb-config-volume
EOF
```

## Create the deployment

```console
$ kubectl create -f mariadb-deployment.yaml
deployment.apps/mariadb-deployment created
```

Verify the pod uses the Secrets and ConfigMap
```console
$ kubectl get pods
NAME                                  READY   STATUS    RESTARTS   AGE
web                                   1/1     Running   0          22m
mariadb-deployment-587c7947bf-jk92q   1/1     Running   0          29s
$ kubectl exec -it mariadb-deployment-587c7947bf-jk92q  -- env | grep MYSQL
MYSQL_PASSWORD=KubernetesTraining
MYSQL_USER=kubeuser
MYSQL_ROOT_PASSWORD=KubernetesTraining!
$ kubectl exec -it mariadb-deployment-587c7947bf-jk92q  -- ls /etc/mysql/conf.d
max_allowed_packet.cnf
$ kubectl exec -it mariadb-deployment-587c7947bf-jk92q -- cat /etc/mysql/conf.d/max_allowed_packet.cnf
[mysqld]
max_allowed_packet = 32M
```

## Check if it works
```console
$ kubectl get pods
NAME                                  READY   STATUS    RESTARTS   AGE
web                                   1/1     Running   0          44m
mariadb-deployment-587c7947bf-jk92q   1/1     Running   0          22m
$ kubectl exec -it mariadb-deployment-587c7947bf-jk92q -- /bin/sh
#
# mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e 'show databases;'
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
# mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SHOW VARIABLES LIKE 'max_allowed_packet';"
+--------------------+----------+
| Variable_name      | Value    |
+--------------------+----------+
| max_allowed_packet | 33554432 |
+--------------------+----------+
# exit
$
```

# Clean
```console
$ kubectl delete deployment mariadb-deployment
deployment.apps "mariadb-deployment" deleted
$ kubectl delete cm mariadb-config
configmap "mariadb-config" deleted
$ kubectl delete secret mariadb-root-password mariadb-user-creds
secret "mariadb-root-password" deleted
secret "mariadb-user-creds" deleted
```
