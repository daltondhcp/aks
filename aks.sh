#!/bin/bash

function configureKubectl()
{
    #download kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

    #move kubectl to local path
    mkdir -p ~/.local/bin/kubectl
    mv ./kubectl ~/.local/bin/kubectl
    chmod +x ~/.local/bin/kubectl/kubectl
    PATH=$PATH:~/.local/bin/kubectl

}

function installHelm()
{
   #install helm
   curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
}


main() {

    if ! command -v kubectl &> /dev/null
    then
        configureKubectl
    fi

    if ! command -v kubectl &> /dev/null
    then
        installHelm
    fi
    #get AKS credentials
    az aks get-credentials --name $AKS_CLUSTER_NAME --resource-group $AKS_CLUSTER_RESOURCE_GROUP_NAME --admin
    #Onboard to arc
    az extension add --name connectedk8s --yes
    az connectedk8s connect --name $AKS_CLUSTER_NAME --resource-group $AKS_CLUSTER_RESOURCE_GROUP_NAME --location westeurope
    echo "calling main with $@"
    IFS=';' read -r -a command <<< "$@"
    echo "Number of commands: ${#command[@]}"
    output='{"results": []}'
    for (( i=0; i<${#command[@]}; i++ ));
    do
        cmd=${command[$i]}
        echo "Executing command: ${command[$i]}"
        read -r -d '' result <<< $(${command[$i]})
        echo "$result"
        if [ ! -z "$result" ]; then
            if jq -e . >/dev/null 2>&1 <<<"$result"; then
                echo "Parsed JSON successfully"
                output=$(echo $output | jq    --arg i "${command[$i]}" \
                                            --argjson r "$result" \
                                            '.results += [{command: $i, result: $r}]')
            else
                echo "Failed to parse JSON, or got false/null"
                output=$(echo $output | jq  --arg i "${command[$i]}" \
                                            --arg r "$result" \
                                        '.results += [{command: $i, result: $r}]')
            fi
        else
            echo "result is null"
            output=$(echo $output | jq  --arg i "${command[$i]}" \
                                        '.results += [{command: $i}]')
        fi
    done
    echo "-------------"
    echo "AZ_SCRIPTS_OUTPUT_PATH: $AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY/$AZ_SCRIPTS_PATH_SCRIPT_OUTPUT_FILE_NAME"
    echo $output > $AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY/$AZ_SCRIPTS_PATH_SCRIPT_OUTPUT_FILE_NAME
    #cat $AZ_SCRIPTS_OUTPUT_PATH
}
main "$@"