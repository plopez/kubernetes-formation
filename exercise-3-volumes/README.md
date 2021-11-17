
# Volumes, Persistent Volumes and Persistent Volume Claims

In this exercise, you will create a persistent volume claim and reference that claim in an nginx pod.
You will write content to the persistent volume, then delete the pod.

Finally, you will check you retrieve the written content if you create an other pod with the same reference to the PVC.

## See the storage Classes
To allow dynamic allocation, we have created a StorageClass. See its details :

```console
$ kubectl get storageClass
$ kubectl describe storageClass <...>
```

Create a Persistent Volume Claim to ask a 1Gi R/W storage.

Declare the claim (be carefull, the provided `.yaml` file may be incorrect....)
```console
$ cat << EOF > pv-claim.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: task-pv-claim
spec:
  accessModes:
    - ReadWriteOneToRuleThemAll
  resources:
    requests:
      storage: 1Gi
EOF
```

Do you see a persistent volume automatically created ?
Why?

## Create a pod which references the Persistent Volume Claim

Here is the pod spec:
```console
$ cat << EOF > pv-pod.yaml
kind: Pod
apiVersion: v1
metadata:
  name: task-pv-pod
spec:
  volumes:
    - name: task-pv-storing
      persistentVolumeClaim:
       claimName: task-pv-claim
  containers:
    - name: task-pv-container
      image: nginx
      ports:
        - containerPort: 80
          name: "http-server"
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: task-pv-storage
EOF
```

Create the pod.

## Write content to the persistent volume

You should get a pv and a pod.

Now, write content to the persistent volume.
```console
$ kubectl exec -it task-pv-pod -- bash
root@task-pv-pod:/# echo 'K8s rules!' > /usr/share/nginx/html/index.html
root@task-pv-pod:/# curl http://localhost
K8s rules!
root@task-pv-pod:/# exit
$
```


## Delete the pod and recreate it

Run the kubectl commands to delete the pod.
Then create-it again.
Check if the index.html file still exists.

## Clean
```console
$ kubectl delete pvc task-pv-claim
persistentvolumeclaim "task-pv-claim" deleted
$ kubectl delete pod task-pv-pod
pod "task-pv-pod" deleted
```
