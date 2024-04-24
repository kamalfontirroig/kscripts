#!/bin/bash
#Version v1.0
#Since 07-03-2024
#Autor Kamál Fontirroig

  
# Check if the correct number of arguments were passed
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <environment>"
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
