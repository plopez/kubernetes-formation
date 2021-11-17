# Create a pod, execute commands inside then delete it

In this exercise, you will create an Nginx and modify the served content.
Then you will connect to it.

## Start the pod

Check that kubectl CLI is installed


Create a `nginx.yaml` file to declare the nginx pod:
```console
$ cat << EOF > nginx.yml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: development

spec:
  containers:
  - name: nginx
    image: nginx
    command: ["nginx"]
    args: ["-g", "daemon off;", "-q"]
    ports:
    - containerPort: 80
EOF
```

Then create the pod using this YAML file
```console
$ kubectl create -f nginx.yml
```

List all the pods and see their status
Note the IP of the nginx pod : <IP_POD>

## Execute a Shell inside the nginx container:
Enter the pod and use an interactive shell
```console
$ kubectl exec -it nginx -- /bin/bash
root@nginx:/#
```

List all the folders inside the root directory:
Create an `index.html` file with the content "Hello shell demo" inside `/usr/share/nginx/html/`
Test the nginx server from within.
You should see the "Hello shell demo" string.

## Leave the container and delete the pod:
```console
root@nginx:/# exit
```

```console
$ kubectl delete pod nginx
```

List all the pods and see their status

## Congrats, you're done !
