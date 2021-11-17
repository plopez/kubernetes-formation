# Using secret and a configmap for a database.

In this exercise, you will create a k8s secret as well as a k8s configmap to correctly configure a MariaDB database.

# Secrets

## Create the MYSQL_ROOT_PASSWORD secret

Generate a base-64 encoded string:
```console
$ echo -n 'KubernetesTraining!' | base64
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
  password: <YOUR_VALUE>
EOF
```

Then, create the `mariadb-root-password` secret.
View the secret

```console
$ kubectl describe secret mariadb-root-password
$ kubectl get secret mariadb-root-password -o jsonpath='{.data.password}' | base64 -d
```

Create a secret for the db user - second way to create a secret

```console
$ kubectl create secret generic mariadb-user-creds \
      --from-literal=MYSQL_USER=kubeuser\
      --from-literal=MYSQL_PASSWORD=KubernetesTraining
secret/mariadb-user-creds created
```

View the secret.

# ConfigMap

## Create a configMap to configure the mariadb application

```console
$ cat << EOF > max_allowed_packet.cnf
[mysqld]
max_allowed_packet = 64M
EOF

$ kubectl create configmap mariadb-config --from-file=max_allowed_packet.cnf
```

Edit the configMap to change the value 32M to `max_allowed_packet`.


View the configmap

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

## Create the deployment

```console
$ kubectl create -f mariadb-deployment.yaml
```

Verify the pod uses the Secrets and ConfigMap
```console
$ kubectl get pods
$ kubectl exec -it mariadb-deployment-<xxx>  -- env | grep MYSQL
$ kubectl exec -it mariadb-deployment-<xxx>  -- ls /etc/mysql/conf.d
$ kubectl exec -it mariadb-deployment-<xxx> -- cat <xxx>/max_allowed_packet.cnf
```

## Check if it works
```console
$ kubectl get pods
$ kubectl exec -it mariadb-deployment-<xxx> -- /bin/sh
#
# mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e 'show databases;'
# mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SHOW VARIABLES LIKE 'max_allowed_packet';"
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
