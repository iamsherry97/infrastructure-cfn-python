# Boxer Admin

## Setting this tool up:
Requires: docker-compose.

Run: `docker-compose build`

Then `./up.sh` to enter interactive bash shell.

### Within container shell:
Run `aws config` if you haven't before.

## Administration
### Creating the cluster
Using `eksctl` to create/control cluster: https://github.com/weaveworks/eksctl

Run `just create_eks_cluster` to create an empty "boxer-dev1" auto-scaling kubernetes cluster on AWS.


### Making kubeconfig
Run `just kubeconfig` to create ~/.kube/config for the "boxer-dev1" cluster.

### Installing helm:

See: https://eksworkshop.com/helm_root/helm_intro/install/

#### Create svc account for "tiller" and init/depoy
```
kubectl apply -f /boxeradmin/config/rbac.yaml

helm init --service-account tiller

kubectl -n kube-system rollout status deploy tiller-deploy
```

### Metrics server:
```
helm install stable/metrics-server \
    --name metrics-server \
    --version 2.0.2 \
    --namespace metrics

kubectl -n metrics \
    rollout status \
    deployment metrics-server
```

### Installing auto-scaler with helm:

```
	helm install --name cluster-autoscaler \
	 --namespace kube-system \
	 --set image.tag=v1.2.0 \
	 --set autoDiscovery.clusterName=boxer-dev1 \
	 --set extraArgs.balance-similar-node-groups=false \
	 --set extraArgs.expander=random \
	 --set rbac.create=true \
	 --set rbac.pspEnabled=true \
	 --set awsRegion=us-west-2 \
	 --set nodeSelector."node-role\.kubernetes\.io/master"="" \
	 --set tolerations[0].effect=NoSchedule \
	 --set tolerations[0].key=node-role.kubernetes.io/master \
	 --set cloudProvider=aws \
	 stable/cluster-autoscaler
 ```

## Misc Links:
https://gist.github.com/vfarcic/3dfc71dc687de3ed98e8f804d7abba0b