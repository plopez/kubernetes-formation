# Create a pod, execute commands inside then delete it

In this exercise, you will create an Nginx and modify the served content.
Then you will connect to it.

## Start the pod

Check that kubectl CLI is installed
```console
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"20", GitVersion:"v1.20.5+k3s1", GitCommit:"355fff3017b06cde44dbd879408a3a6826fa7125", GitTreeState:"clean", BuildDate:"2021-03-31T06:21:52Z", GoVersion:"go1.15.10", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"20", GitVersion:"v1.20.5+k3s1", GitCommit:"355fff3017b06cde44dbd879408a3a6826fa7125", GitTreeState:"clean", BuildDate:"2021-03-31T06:21:52Z", GoVersion:"go1.15.10", Compiler:"gc", Platform:"linux/amd64"}
```

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

Then create the pod:
```console
$ kubectl create -f nginx.yml
pod/nginx created
```

List all the pods and see their status
```console
$ kubectl get pods -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP           NODE     NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          43s   10.42.0.25   node-0   <none>           <none>
```

Note the IP of the nginx pod : <IP_POD>

## Execute a Shell inside the nginx container:
Enter the pod and use an interactive shell
```console
$ kubectl exec -it nginx -- /bin/bash
root@nginx:/#
```

List all the folders inside the root directory:
```console
root@nginx:/# ls -l /
total 76
drwxr-xr-x   2 root root 4096 Oct 11 00:00 bin
drwxr-xr-x   2 root root 4096 Oct  3 09:15 boot
drwxr-xr-x   5 root root  360 Nov 16 09:32 dev
drwxr-xr-x   1 root root 4096 Nov 10 01:37 docker-entrypoint.d
-rwxrwxr-x   1 root root 1202 Nov 10 01:37 docker-entrypoint.sh
drwxr-xr-x   1 root root 4096 Nov 16 09:32 etc
drwxr-xr-x   2 root root 4096 Oct  3 09:15 home
drwxr-xr-x   1 root root 4096 Oct 11 00:00 lib
drwxr-xr-x   2 root root 4096 Oct 11 00:00 lib64
drwxr-xr-x   2 root root 4096 Oct 11 00:00 media
drwxr-xr-x   2 root root 4096 Oct 11 00:00 mnt
drwxr-xr-x   2 root root 4096 Oct 11 00:00 opt
dr-xr-xr-x 245 root root    0 Nov 16 09:32 proc
drwx------   2 root root 4096 Oct 11 00:00 root
drwxr-xr-x   1 root root 4096 Nov 16 09:32 run
drwxr-xr-x   2 root root 4096 Oct 11 00:00 sbin
drwxr-xr-x   2 root root 4096 Oct 11 00:00 srv
dr-xr-xr-x  13 root root    0 Nov 16 09:32 sys
drwxrwxrwt   1 root root 4096 Nov 10 01:37 tmp
drwxr-xr-x   1 root root 4096 Oct 11 00:00 usr
drwxr-xr-x   1 root root 4096 Oct 11 00:00 var
```

Create an `index.html` file with the content "Hello shell demo" inside `/usr/share/nginx/html/`
```console
root@nginx:/# echo Hello shell demo > /usr/share/nginx/html/index.html
```

Test the nginx server from within.
```console
root@nginx:/# curl http://localhost
Hello shell demo
root@nginx:/# curl http://<IP_POD>
Hello shell demo
```
You should see the "Hello shell demo" string.

## Leave the container and delete the pod:
```console
root@nginx:/# exit
$
```

```console
$ kubectl delete pod nginx
pod "nginx" deleted
```

List all the pods and see their status
```console
$ kubectl get pods -o wide
No resources found in default namespace.
```

## Congrats, you're done !
