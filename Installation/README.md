## Notes

The primary goal is to eliminate the need for manual installation.  This script is designed to simplify the installation of the SUSE-Observability cluster.  

The script should be executed from a host that has `kubectl` configured with access to the kubernetes cluster or from any other host with the necessary permissions and connectivity to the kubernetes cluster. 
If kubeconfig is not set, use the command `export KUBECONFIG=$PATH-TO-YOUR/kubeconfig`.

⚠️ **This script is not designed to run on air gapped environments**

Before running the script, ensure you have the following ready:  
- **License key** : The SUSE Observability license key from SCC portal.
- **Base URL** : The external URL for SUSE Observability that users and agents will use to connect. 
- **Sizing profile** : OneOf `trial`, `10-nonha`, `20-nonha`, `50-nonha`, `100-nonha`, `150-ha`, `250-ha`, `500-ha`. Based on this profiles the sizing_values.yaml file is generated containing default sizes for the SUSE Observability resources and configuration to be deployed on an Ha or NonHa mode. E.g. `10-nonha` will produce a sizing_values.yaml meant to deploy a NonHa SUSE Observability instance to observe a 10 node cluster in a Non High Available mode. Currently moving from a nonha to an ha environment is not possible, so if you expect that your environment willrequire to observe around 150 nodes then better to go with ha immediately.

### Download and run the script
* Download 

  Using `wget`:
    ```bash
    wget https://raw.githubusercontent.com/amolkharche13/suse-observability-scripts/refs/heads/main/Installation/SOinstallation.sh
    ```
  Using `curl`:
    ```bash
    curl -OLs https://raw.githubusercontent.com/amolkharche13/suse-observability-scripts/refs/heads/main/Installation/SOinstallation.sh
    ```
 
* Run the script using following commands:
  ```bash
  bash SOinstallation.sh
