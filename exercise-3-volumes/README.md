
# Volumes, Persistent Volumes and Persistent Volume Claims

In this exercise, you will create a persistent volume claim and reference that claim in an nginx pod.
You will write content to the persistent volume, then delete the pod.

Finally, you will check you retrieve the written content if you create an other pod with the same reference to the PVC.

## See the storage Classes
To allow dynamic allocation, we have created a StorageClass. See its details :

```sh
kubectl get storageClass
kubectl describe storageClass [name storageClass]
```

Create a Persistent Volume Claim to ask a 1Gi R/W storage.

Declare the claim (be carefull, the provided `.yaml` file may be incorrect....)
```sh
cat << EOF > pv-claim.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: task-pv-claim
spec:
  accessModes:
    - ReadWriteOneRingToRuleThemAll
  resources:
    requests:
      storage: 1Gi
EOF
```

```sh
kubectl apply -f pv-claim.yaml
```

Do you see a persistent volume automatically created ?
```sh
kubectl get pv
```

Why?

## Create a pod which references the Persistent Volume Claim

Here is the pod spec:
```sh
cat << EOF > pv-pod.yaml
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
```sh
kubectl apply -f pv-pod.yaml
```

## Write content to the persistent volume

You should get a pv and a pod:
```
kubectl get pv,pod -o wide
```

Now, write content to the persistent volume:
```sh
kubectl exec -it task-pv-pod -- bash
echo 'K8s rules!' > /usr/share/nginx/html/index.html
curl http://localhost
exit
```


## Delete the pod and recreate it

Run the kubectl commands to delete the pod.
Then create-it again.

Check if the index.html file still exists.

## Bonus: force the pod to be created on another node

Note the worker node which hosts the pod.
Then delete the task-pv-pod pod.

Edit the `.yaml` file and use the `nodeName` field in the spec to indicate another worker node.

Apply the changes.

Is it possible?

## Clean
```sh
kubectl delete pvc task-pv-claim
kubectl delete pod task-pv-pod
```
