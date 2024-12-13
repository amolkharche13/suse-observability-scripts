#!/bin/bash

# Namespace to collect information
NAMESPACE="suse-observability"

# Directory to store logs
OUTPUT_DIR="${NAMESPACE}_logs_$(date +%Y%m%d%H%M%S)"
ARCHIVE_FILE="${OUTPUT_DIR}.tar.gz"
mkdir -p "$OUTPUT_DIR"


echo "Collecting node details..."
kubectl get nodes -o wide > "$OUTPUT_DIR/nodes_status"
kubectl describe nodes > "$OUTPUT_DIR/nodes_describe"


collect_yaml_configs() {
    echo "Collecting YAML configurations..."

    mkdir -p "$OUTPUT_DIR/yaml"

    # StatefulSet YAMLs
    kubectl -n "$NAMESPACE" get statefulsets -o yaml > "$OUTPUT_DIR/yaml/statefulsets.yaml"
    # DaemonSet YAMLs
    kubectl -n "$NAMESPACE" get daemonsets -o yaml > "$OUTPUT_DIR/yaml/daemonsets.yaml"
    # Service YAMLs
    kubectl -n "$NAMESPACE" get services -o yaml > "$OUTPUT_DIR/yaml/services.yaml"
    # Deployment YAMLs
    kubectl -n "$NAMESPACE" get deployments -o yaml > "$OUTPUT_DIR/yaml/deployments.yaml"
    # ConfigMap YAMLs
    kubectl -n "$NAMESPACE" get configmaps -o yaml > "$OUTPUT_DIR/yaml/configmaps.yaml"
    # Secret YAMLs
    kubectl -n "$NAMESPACE" get secrets -o yaml > "$OUTPUT_DIR/yaml/secrets.yaml"
    # Cronjob YAMLs
    kubectl -n "$NAMESPACE" get cronjob -o yaml > "$OUTPUT_DIR/yaml/cronjob.yaml"

    echo "YAML configurations collected."
}

# Function to collect pod logs
collect_pod_logs() {
    echo "Collecting pod logs..."
    PODS=$(kubectl -n "$NAMESPACE" get pods -o jsonpath="{.items[*].metadata.name}")
    for pod in $PODS; do
        mkdir -p "$OUTPUT_DIR/pods/$pod"
        CONTAINERS=$(kubectl -n "$NAMESPACE" get pod "$pod" -o jsonpath="{.spec.containers[*].name}")
        for container in $CONTAINERS; do
            kubectl -n "$NAMESPACE" logs "$pod" -c "$container" > "$OUTPUT_DIR/pods/$pod/${container}.log" 2>&1
            kubectl -n "$NAMESPACE" logs "$pod" -c "$container" --previous > "$OUTPUT_DIR/pods/$pod/${container}_previous.log" 2>/dev/null
        done
    done
    echo "Pod logs collected."
}

# Collect general pod statuses
echo "Collecting pod statuses..."
kubectl -n "$NAMESPACE" get pods -o wide > "$OUTPUT_DIR/pods_status"

# Collect StatefulSets information
echo "Collecting StatefulSets information..."
kubectl -n "$NAMESPACE" get statefulsets -o wide > "$OUTPUT_DIR/statefulsets"
kubectl -n "$NAMESPACE" describe statefulsets > "$OUTPUT_DIR/statefulsets_describe"

# Collect DaemonSets information
echo "Collecting DaemonSets information..."
kubectl -n "$NAMESPACE" get daemonsets  > "$OUTPUT_DIR/daemonsets"
kubectl -n "$NAMESPACE" describe daemonsets > "$OUTPUT_DIR/daemonsets_describe"

echo "Collecting Deployments information..."
kubectl -n "$NAMESPACE" get deployments -o wide > "$OUTPUT_DIR/deployments"

echo "Collecting services information..."
kubectl -n "$NAMESPACE" get services -o wide > "$OUTPUT_DIR/services"

echo "Collecting information about configmaps and secrets..."
kubectl -n "$NAMESPACE" get configmaps -o wide > "$OUTPUT_DIR/configmaps"
kubectl -n "$NAMESPACE" get secrets -o wide > "$OUTPUT_DIR/secrets"

echo "Collecting cronjob information..."
kubectl -n "$NAMESPACE" get cronjob -o wide > "$OUTPUT_DIR/cronjob"

echo "Collecting events in $NAMESPACE ..."
kubectl -n "$NAMESPACE" get events --sort-by='.metadata.creationTimestamp' > "$OUTPUT_DIR/events"

archive_and_cleanup() {
    echo "Creating archive $ARCHIVE_FILE..."
    tar -czf "$ARCHIVE_FILE" "$OUTPUT_DIR"
    echo "Archive created."

    echo "Cleaning up the output directory..."
    rm -rf "$OUTPUT_DIR"
    echo "Output directory removed."
}
# Run the pod logs collection function
collect_pod_logs
collect_yaml_configs
archive_and_cleanup
echo "All information collected in the $ARCHIVE_FILE"
