# SUSE Observability v1 logs-collector

## Notes

Ensure you have `kubectl` access to the SUSE Observability cluster. If not, download the kubeconfig file and set it using the command: `export KUBECONFIG=$PATH-TO-YOUR/kubeconfig`.

## Usage

The script needs to be downloaded and run directly on the node, using the `root` user or `sudo`.

### Download and run the script
* Save the script as: `suse-observability_logs_collector.sh`

  Using `wget`:
    ```bash
    wget https://raw.githubusercontent.com/amolkharche13/suse-observability/refs/heads/main/suse-observability_logs_collector.sh
    ```
  Using `curl`:
    ```bash
    curl -OLs https://raw.githubusercontent.com/amolkharche13/suse-observability/refs/heads/main/suse-observability_logs_collector.sh
    ```
 
* Run the script using following commands:
  ```bash
  bash suse-observability_logs_collector.sh
  ```
  
