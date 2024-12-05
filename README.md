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
  This will generate a file in the current directory named `suse-observability_logs_<date>.tar.gz`. Please upload this file to the case.
  
{% tab %} {% tab title="Sample Output" %}
root@jumpsrv:~/terraform/suse-observability# bash suse-observability_logs_collector.sh
Collecting node details...
Collecting pod statuses...
Collecting StatefulSets information...
Collecting DaemonSets information...
Collecting Deployments information...
Collecting services information...
Collecting information about configmaps and secrets...
Collecting cronjob information...
Collecting events in suse-observability ...
Collecting pod logs...
Pod logs collected.
Collecting YAML configurations...
YAML configurations collected.
Creating archive suse-observability_logs_20241204133512.tar.gz...
Archive created.
Cleaning up the output directory...
Output directory removed.
All information collected in the suse-observability_logs_20241204133512.tar.gz
root@jumpsrv:~/terraform/suse-observability
{% endtab %}
