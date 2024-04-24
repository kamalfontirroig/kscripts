#!/bin/bash
 
# Define the log folder path
LOG_FOLDER=$KUBECTL_LOG_FOLDER

# Function to switch context if needed
switch_context_if_needed() {
    local environment=$1
    local target_context=""
 
    if [ "$environment" = "qa" ]; then
        target_context="bci-api-cert001"
    elif [ "$environment" = "int" ]; then
        target_context="bci-api-desa001"
    else
        echo "Invalid environment. Use 'qa' or 'int'."
        exit 1
    fi
 
    local current_context=$(kubectl config current-context)
    if [ "$current_context" != "$target_context" ]; then
        echo "Switching context from $current_context to $target_context."
        kubectl config use-context $target_context
    else
        echo "Already in the correct context ($current_context), no need to switch."
    fi
}
 
# Function to handle the cleanup and save the log file
cleanup() {
    echo "Terminating log tailing and saving logs..."
    # Get timestamp for the final log file
    local timestamp=$(date "+%Y-%m-%d-%H%M%S")
    local final_log_file_name="log-${environment}-${selected_pod}-${timestamp}.txt"
    mv "$temp_log_file" "${LOG_FOLDER}/${final_log_file_name}"
    echo "Logs saved to ${LOG_FOLDER}/${final_log_file_name}"
    open "${LOG_FOLDER}/${final_log_file_name}"
}
 
# Verify argument count
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <environment> <service-name>"
    exit 1
fi
 
environment=$1
service_name=$2
 
# Switch context if necessary
switch_context_if_needed $environment
 
# Determine namespace based on the service name
namespace="bci-api"
if [[ $service_name == ig-* ]]; then
    namespace="bci-integ"
fi
 
# Find and select pod
pods=$(kubectl -n $namespace get pods | grep $service_name)
if [ -z "$pods" ]; then
    echo "No pods found for service name $service_name in namespace $namespace."
    exit 1
fi
 
echo "Available pods:"
IFS=$'\n'; select pod_choice in $pods; do
    if [ -n "$pod_choice" ]; then
        selected_pod=$(echo $pod_choice | awk '{print $1}')
        break
    else
        echo "Invalid choice. Please select a valid pod."
    fi
done
 
# Prepare temporary file for logs
temp_log_file=$(mktemp)
 
# Download existing logs to temporary file
kubectl -n $namespace logs $selected_pod > "$temp_log_file"
 
# Setup trap to handle script termination and save the logs
trap cleanup EXIT
 
# Tail logs and append to the temporary file
echo "Tailing logs for pod $selected_pod. Press Ctrl+C to stop and save the logs."
kubectl -n $namespace logs -f $selected_pod | tee -a "$temp_log_file"