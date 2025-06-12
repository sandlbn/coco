# CoCo Installation for Aether with TDX Support

This guide describes how to install the [CoCo](https://github.com/sandlbn/coco) runtime and monitoring extensions into an existing [Aether](https://github.com/omec-project/aether-roc) environment, with support for confidential containers and TDX.

---

## 🧩 Prerequisites

Ensure that `aether-onramp` is cloned and working.

---

## 🚀 Setup Steps

### 1. Clone CoCo Repository

```bash
cd aether-onramp/deps
git clone https://github.com/sandlbn/coco
```


2. Modify Makefile in aether-onramp

Add the following lines to your root Makefile:
```bash
export COCO_ROOT_DIR ?= $(AETHER_ROOT_DIR)/deps/coco
include $(COCO_ROOT_DIR)/Makefile
```
📦 Install Aether Components
```bash
make aether-k8s-install
make aether-5gc-install
make amp-install
```
📊 Install AMP Extensions with CoCo Monitoring
```bash
git clone https://github.com/sandlbn/aether-amp amp-coco

kubectl apply -k amp-coco/roles/monitor-load/templates/coco-monitoring/
kubectl apply -k amp-coco/roles/monitor-load/templates/container-monitoring/
```
Then forward Grafana to localhost:

```bash
kubectl port-forward -n cattle-monitoring-system rancher-monitoring-grafana-<pod-id> 8080
```
Now open http://localhost:8080 in your browser.

🧪 Test Image Overrides

You can test replacing the SMF deployment image with:
```bash
kubectl set image deployment/smf smf=sureshmarikkannu2025/5gc-smf:2.0.6-bt-v3 -n aether-5gc
kubectl set image deployment/smf smf=registry.aetherproject.org/proxy/omecproject/5gc-smf:rel-2.0.4 -n aether-5gc
```

🔐 Enable CoCo with TDX

```bash
make coco-install
```
✅ Verify RuntimeClass Assignment
```bash
kubectl get pods -n aether-5gc -o custom-columns=NAME:.metadata.name,RUNTIME:.spec.runtimeClassName
```
🚀 Reapply Deployment with TDX Image
```bash
kubectl set image deployment/smf smf=sureshmarikkannu2025/5gc-smf:2.0.6-bt-v3 -n aether-5gc
```
🧹 Remove Lock Policy if Necessary
```bash
kubectl delete clusterpolicy deny-updates-to-locked-tdx-deployments
```
🔎 Verify Lock and Runtime Status
```bash
kubectl get deployments -n aether-5gc -o custom-columns=NAME:.metadata.name,LOCKED:.metadata.annotations."intel\.com/locked",RUNTIME:.spec.template.spec.runtimeClassName
```
📍 Notes

Make sure to replace <pod-id> with your actual Grafana pod name.
This setup assumes TDX is enabled and correctly configured on the nodes.