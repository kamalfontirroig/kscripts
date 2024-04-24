#!/bin/bash
#Version v1.0
#Since 07-03-2024
#Autor Kamál Fontirroig

 
# Define the log folder path
LOG_FOLDER=$KUBECTL_LOG_FOLDER
 
# Check if the correct number of arguments were passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <environment> <service-name>"
    exit 1
fi
 
environment=$1
service_name=$2
 
# Determine the target context based on the environment
if [ "$environment" = "qa" ]; then
    target_context="bci-api-cert001"
elif [ "$environment" = "int" ]; then
    target_context="bci-api-desa001"
else
    echo "Invalid environment. Use 'qa' or 'int'."
    exit 1
fi
 
# Get the current context
current_context=$(kubectl config current-context)
 
# Switch context only if necessary
if [ "$current_context" != "$target_context" ]; then
    echo "Switching context from $current_context to $target_context."
    kubectl config use-context $target_context
else
    echo "Already in the correct context ($current_context), no need to switch."
fi
 
# Determine namespace and filter pods based on service name
if [[ $service_name == ig-* ]]; then
    namespace="bci-integ"
else
    namespace="bci-api"
fi
 
# Get pods and filter by service name
echo "Loading pods..."
pods=$(kubectl -n $namespace get pods | grep $service_name)
 
if [ -z "$pods" ]; then
    echo "No pods found for service name $service_name in namespace $namespace."
    exit 1
fi
 
#echo "Available pods:"
#echo "$pods"
echo "Enter the number of the pod to download logs from:"
 
# Convert pods to array and display choices
IFS=$'\n' read -rd '' -a pod_array <<<"$pods"
select pod_choice in "${pod_array[@]}"; do
    if [ -n "$pod_choice" ]; then
        pod_name=$(echo $pod_choice | awk '{print $1}')
        break
    else
        echo "Invalid choice. Try again."
    fi
done
 
# Get timestamp
timestamp=$(date "+%Y-%m-%d-%H%M%S")
 
# Download logs
log_file_name="log-${environment}-${pod_name}-${timestamp}.txt"
kubectl -n $namespace logs $pod_name > "${LOG_FOLDER}/${log_file_name}"
 
echo "Logs downloaded to ${LOG_FOLDER}/${log_file_name}"

open "${LOG_FOLDER}/${log_file_name}"