
# Volumes, Persistent Volumes and Persistent Volume Claims

In this exercise, you will create a persistent volume claim and reference that claim in an nginx pod.
You will write content to the persistent volume, then delete the pod.

Finally, you will check you retrieve the written content if you create an other pod with the same reference to the PVC.

## See the storage Classes
To allow dynamic allocation, we have created a StorageClass. See its details :

```console
$ kubectl get storageClass
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  60d
$ kubectl describe storageClass local-path
Name:                  local-path
IsDefaultClass:        Yes
Annotations:           objectset.rio.cattle.io/applied={"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{"objectset.rio.cattle.io/id":"","objectset.rio.cattle.io/owner-gvk":"k3s.cattle.io/v1, Kind=Addon","objectset.rio.cattle.io/owner-name":"local-storage","objectset.rio.cattle.io/owner-namespace":"kube-system","storageclass.kubernetes.io/is-default-class":"true"},"labels":{"objectset.rio.cattle.io/hash":"183f35c65ffbc3064603f43f1580d8c68a2dabd4"},"name":"local-path"},"provisioner":"rancher.io/local-path","reclaimPolicy":"Delete","volumeBindingMode":"WaitForFirstConsumer"},objectset.rio.cattle.io/id=,objectset.rio.cattle.io/owner-gvk=k3s.cattle.io/v1, Kind=Addon,objectset.rio.cattle.io/owner-name=local-storage,objectset.rio.cattle.io/owner-namespace=kube-system,storageclass.kubernetes.io/is-default-class=true
Provisioner:           rancher.io/local-path
Parameters:            <none>
AllowVolumeExpansion:  <unset>
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     WaitForFirstConsumer
Events:                <none>
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
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF
```

```console
$ kubectl apply -f pv-claim.yaml
persistentvolumeclaim/task-pv-claim created
```

Do you see a persistent volume automatically created ?
```console
$ kubectl get pv
No resources found
```

Why?
Because StorageClass defines
VolumeBindingMode:     WaitForFirstConsumer
So as long as there is no consumer, the PV is not created


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
    - name: task-pv-storage
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

Create the pod:
```console
$ kubectl apply -f pv-pod.yaml
pod/task-pv-pod created
```

## Write content to the persistent volume

You should get a pv and a pod:
```console
$ kubectl get pv,pod -o wide
NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                   STORAGECLASS   REASON   AGE   VOLUMEMODE
persistentvolume/pvc-1e251774-1dd0-4eab-82bc-f279be9ad8b5   1Gi        RWO            Delete           Bound    default/task-pv-claim   local-path              8s    Filesystem

NAME              READY   STATUS    RESTARTS   AGE   IP           NODE    NOMINATED NODE   READINESS GATES
pod/task-pv-pod   1/1     Running   0          21s   10.42.0.33   node-0   <none>           <none>
```

Now, write content to the persistent volume:
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

```console
$ kubectl delete pod task-pv-pod
pod "task-pv-pod" deleted
$ kubectl apply -f pv-pod.yaml
pod/task-pv-pod created
$ kubectl exec task-pv-pod -- curl "http://localhost"
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    11  100    11    0     0  11000      0 --:--:-- --:--:-- --:--:-- 11000
K8s rules!
```

## Clean
```console
$ kubectl delete pvc task-pv-claim
persistentvolumeclaim "task-pv-claim" deleted
$ kubectl delete pod task-pv-pod
pod "task-pv-pod" deleted
```
