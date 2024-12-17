#!/bin/bash

NAMESPACE="suse-observability"

# Check if kubectl is installed or not
if ! command -v kubectl &>/dev/null; then
   echo "kubectl is not installed. Please install it and try again."
   exit 1
fi

# Check if KUBECONFIG is set
if [[ -z "$KUBECONFIG" || ! -f "$KUBECONFIG" ]]; then
    echo "Error: KUBECONFIG is not set. Please ensure KUBECONFIG is set to the path of a valid kubeconfig file before running this script."
    echo "If kubeconfig is not set, use the command: export KUBECONFIG=PATH-TO-YOUR/kubeconfig. Exiting..."
 exit 1
fi

echo -e "\n\033[36mWelcome to the SUSE Observability setup script!\033[0m"
echo -e "\033[33mPlease follow the instructions carefully.\033[0m"

# Check if StorageClass already exists
echo -e "\n\033[33mChecking for existing StorageClasses in the cluster...\033[0m"
existing_storageclass=$(kubectl get storageclass --no-headers 2>/dev/null)

if [[ -z "$existing_storageclass" ]]; then
    echo -e "\nNo StorageClass found in the cluster."
    echo  "Would you like to install a StorageClass?"
    echo  "1. Install SUSE Storage (Longhorn)"
    echo  "2. Install local-path-provisioner"
    echo  "3. Exit"
    read -p "Enter your choice (1/2/3): " choice

    case $choice in
        1)
            echo -e "Installing SUSE Storage (Longhorn)..."
            kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.7.2/deploy/longhorn.yaml
            echo -e "SUSE Storage (Longhorn) installation initiated. Please refer Documentation for more info: https://longhorn.io/docs "
            ;;
        2)
            echo -e "Installing local-path-provisioner..."
            kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.30/deploy/local-path-storage.yaml
            echo -e "local-path-provisioner installation initiated. Feel free to check repository: https://github.com/rancher/local-path-provisioner"
            ;;
        3)
            echo -e "Exiting without installing a StorageClass."
            exit 0
            ;;
        *)
            echo -e  "Invalid choice. Please run the script again."
            exit 1
            ;;
    esac
else
    echo -e "\n\033[32mStorageClass already exists in the cluster:\033[0m"
    echo "$existing_storageclass"
fi

existing_release=$(helm list -n "$NAMESPACE" --filter  "^suse-observability$"  -q)

if [[ -n "$existing_release" ]]; then
    echo -e "\n\033[33mWarning: Helm release "suse-observability" already exists in namespace $NAMESPACE.\033[0m"
    echo -e "Do you want to uninstall the existing release and proceed with a new deployment? (yes/no):"
    read response

    if [[ "$response" =~ ^(yes|y)$ ]]; then
        echo -e "\n\033[33mUninstalling existing release...\033[0m"
        helm uninstall "suse-observability" -n "$NAMESPACE"
        if [[ $? -eq 0 ]]; then
            echo -e "\033[32mExisting release uninstalled successfully.\033[0m"
        else
            echo -e "\033[31mError: Failed to uninstall the existing release.\033[0m"
            exit 1
        fi
    else
        echo -e "\033[31mAborting deployment.\033[0m"
        exit 1
    fi
else
    echo -e "\n\033[32mNo existing Helm release found. Proceeding with deployment...\033[0m"
fi

echo -e "\n\033[32mAdding suse observability repository ... \033[0m"
helm repo add suse-observability https://charts.rancher.com/server-charts/prime/suse-observability

echo -e "\n\033[32mUpdating suse observability repository... \033[0m"
helm repo update

echo -e "\n\033[32mCreating suse observability namespace ... \033[0m"
kubectl create namespace suse-observability

echo -e "\n\033[32mSetting current directory path... \033[0m"
export VALUES_DIR=.

echo -e "\n\033[33mEnter license key: \033[0m"
read license

key_regex="^[A-Z0-9]{5}-[A-Z0-9]{5}-[A-Z0-9]{5}$"
if [[ $license =~ $key_regex ]]; then
    echo ""
else
    echo -e "\033[31mInvalid license key format. Please enter a key like ABCDE-FGHIJ-KLMNO.\033[0m"
    exit 1
fi

echo -e "\n\033[33mEnter SUSE Observability BASE URL: default: http://localhost:8080 \033[0m"
read basurl

if [[ -z "$basurl" ]]; then
    basurl="http://localhost:8080"
fi

echo -e "\n\033[33mEnter your sizing profile for your SUSE Observability cluster: \033[0m"
echo -e "Current Supported sizing profile :\ntrial \n10-nonha \n20-nonha \n50-nonha \n100-nonha \n150-ha \n250-ha \n500-ha \n"
read sizingprofile

echo -e "\nGenerating helm template with license=${license} , BASE URL=${basurl} and sizing profile=${sizingprofile}:\n"
helm template --set license="${license}" --set baseUrl="${basurl}" --set sizing.profile="${sizingprofile}" suse-observability-values  suse-observability/suse-observability-values --output-dir $VALUES_DIR

echo -e "\033[33mWould you like to provide any additional values.yaml file for LDAP, email, authentication, OIDC, or other configurations? (yes/no):\033[0m"
read values_response

if [[ "$values_response" =~ ^(yes|y)$ ]]; then
    echo -e "\033[33mEnter the path to the extra values.yaml file: \033[0m"
    read values_file

    if [[ ! -f "$values_file" ]]; then
        echo -e "\033[31mError: File not found '$values_file'. Please check the path.\033[0m"
        exit 1
    fi
    echo -e "\n\033[33mProceeding using extra values file: $values_file \033[0m"
    echo -e "\033[33mSit back and relax , We are installing SUSE Observability cluster : \033[0m \n"
    helm upgrade --install --namespace suse-observability --values $VALUES_DIR/suse-observability-values/templates/baseConfig_values.yaml --values $VALUES_DIR/suse-observability-values/templates/sizing_values.yaml --values "${values_file}" suse-observability suse-observability/suse-observability
else
    echo -e "\n\033[33mProceeding without an extra values file... \033[0m \n"
    echo -e "\033[33mSit back and relax , We are installing SUSE Observability cluster :\033[0m \n"
    helm upgrade --install --namespace suse-observability --values $VALUES_DIR/suse-observability-values/templates/baseConfig_values.yaml --values $VALUES_DIR/suse-observability-values/templates/sizing_values.yaml suse-observability suse-observability/suse-observability

fi

