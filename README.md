# CoCo: Confidential Containers with Intel TDX

The CoCo repository configures Confidential Containers with Intel TDX support on an existing Kubernetes cluster. It handles both the Intel TDX configuration on host machines and the deployment of Confidential Containers with attestation capabilities.

### Prerequisites

1. An existing Kubernetes cluster (installed using the [aether-k8s repository](https://github.com/opennetworkinglab/aether-k8s) or other methods)
2. Ubuntu 24.04 with Intel processor supporting TDX (4th Gen or 5th Gen Intel Xeon Scalable Processors)
3. Minimum 8GB RAM and 4 vCPU for each Kubernetes node
4. Containerd runtime on all nodes

### Installation with aether-onramp

1. Clone the repository into the `aether-onramp/deps` directory:

```bash
cd aether-onramp/deps
git clone https://github.com/opennetworkinglab/aether-coco coco
```

2. Edit the top-level Makefile in the aether-onramp directory and add these lines:

```bash
export COCO_ROOT_DIR ?= $(AETHER_ROOT_DIR)/deps/coco
include $(COCO_ROOT_DIR)/Makefile
```

3. Configure nodes and settings:
- Update node configurations with IP addresses in the host.ini file
- Configure CoCo parameters in the ./vars/main.yml file

4. Run the installation:
make coco-install

### Standalone Installation

To set up Confidential Containers with Intel TDX as a standalone module, you need to provide the following:

1. Node configurations with IP addresses in the host.ini file
   - You should specify both master and worker nodes (same format as K8 repository)

2. CoCo configuration parameters in the ./vars/main.yml file, such as:
   - TDX version and kernel type
   - CoCo operator version
   - Attestation settings

3. Run the installation:

```bash
make coco-install
```

The repository will configure Intel TDX on all nodes and deploy Confidential Containers with the specified attestation capabilities.

### Verification

To verify that the Confidential Containers setup was successful, run the following commands on the master node:

```bash
# Check if the runtime classes are available
kubectl get runtimeclass | grep kata-qemu-tdx

# Deploy a test pod with TDX protection
kubectl apply -f test-tdx-pod.yaml

# Verify the pod is running
kubectl get pods
```

## KBS (Key Broker Service) Secret Configuration

### Overview

The Key Broker Service (KBS) requires a secret for encrypting sensitive data and securing attestation operations. This secret is used to protect confidential information exchanged between the KBS and trusted execution environments.

### Setting the KBS Secret

You can configure the KBS secret in two ways:

#### Method 1: Environment Variable (Recommended)

Set the `KBS_SECRET` environment variable before running the playbook:

```bash
export KBS_SECRET="your-super-secret-passphrase"
ansible-playbook -i inventory tdx-install.yml
```

Or pass it directly:

```bash
KBS_SECRET="your-super-secret-passphrase" ansible-playbook -i inventory tdx-install.yml
```

#### Method 2: Default Value

If no environment variable is set, the playbook will use the default secret: `"This is my super secret"`

**⚠️ Warning**: Always set a custom secret for production environments. The default value should only be used for testing.

### Secret Requirements

- The secret can be any string value
- For production use, choose a strong, unique passphrase
- The secret is stored in `overlays/key.bin` within the KBS configuration
- Keep this secret secure and backed up - you'll need it for future KBS operations

### Verifying KBS Deployment

After installation, the playbook will display the KBS service address:

```
KBS Service is running!
KBS Address: http://<node-ip>:<node-port>

To use KBS, export this address:
export KBS_ADDRESS=http://<node-ip>:<node-port>
```

### Example: Complete Installation with Custom Secret

```bash
# Set your custom secret
export KBS_SECRET="my-production-secret-2024"

# Run the installation using make
make coco-install

# Or with ansible-playbook directly
ansible-playbook -i hosts.ini coco.yml --tags install \
  --extra-vars "ROOT_DIR=$(pwd)"

# After installation, export the KBS address shown in the output
export KBS_ADDRESS=http://10.0.0.1:30123
```

### Using with Makefile

The KBS secret can be passed through the Makefile's `EXTRA_VARS`:

```bash
# Method 1: Export before running make
export KBS_SECRET="my-production-secret"
make coco-install

# Method 2: Pass via EXTRA_VARS
make coco-install EXTRA_VARS="KBS_SECRET=my-production-secret"
```

### Uninstalling

To uninstall CoCo components:

```bash
make coco-uninstall
```

### Security Best Practices

1. **Never commit secrets to version control**
2. **Use a password manager or secure vault for production secrets**
3. **Rotate secrets periodically**
4. **Use different secrets for different environments (dev, staging, prod)**
5. **Ensure the secret is complex enough to resist brute-force attacks**

### Available Features
Once installed, you can use the following features:

- Memory encryption for containerized workloads
- Hardware-based isolation using Intel TDX
- Support for encrypted container images
- Remote attestation with DCAP or Intel Trust Authority
- Sealed secrets for confidential workloads

### Useful Commands

- kubectl get runtimeclass - List available runtime classes including TDX-enabled ones
- kubectl get pods -n confidential-containers-system - Check CoCo operator status
- kubectl logs -n confidential-containers-system deployment/cc-operator-controller-manager - View operator logs
- kubectl describe pod POD_NAME - Check if a pod is using TDX protection

### Uninstallation
To uninstall Confidential Containers and TDX configuration:
```bash
make coco-uninstall
```
This will remove all CoCo components while preserving the underlying Kubernetes cluster.
