# Create a pod, execute commands inside then delete it

In this exercise, you will create an Nginx and modify the served content.
Then you will connect to it.

## Start the pod

Create a `nginx.yaml` file to declare the nginx pod:

```
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
```

Then create the pod:
```sh
kubectl create -f nginx.yml
```

List all the pods and see their status
```sh
kubectl get pods -o wide
```

Note the IP of the nginx pod : <IP_POD>

## Execute a Shell inside the nginx container:
Enter the pod and use an interactive shell
```sh
kubectl exec -it nginx -- /bin/bash
```

List all the folders inside the root directory:
```
ls -l /
```

Create an `index.html` file with the content "Hello shell demo" inside `/usr/share/nginx/html/`
```sh
echo Hello shell demo > /usr/share/nginx/html/index.html
```

Test the nginx server from within.
```sh
curl http://localhost
curl http://<IP_POD>
```
You should see the "Hello shell demo" string.

## Leave the container and delete the pod:
```sh
exit
```

```sh
kubectl delete pod nginx
```

List all the pods and see their status
```sh
kubectl get pods -o wide
```
