# Demo

```
kubectl create clusterrolebinding \
          tiller-cluster-rule \
          --clusterrole=cluster-admin \
          --serviceaccount=kube-system:default
helm init
```

```bash
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.4.5/manifests/metallb.yaml
```
