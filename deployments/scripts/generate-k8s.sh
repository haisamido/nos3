#!/bin/bash -e

RECREATE=${1:-no} # recreate namespaces, pods, etc.
MY_PWD=${PWD}

#------------------------------------------------------------------------------
# A script to generate k8s deployment, service... yaml files and apply them
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
K8S_CONTEXT=docker-desktop
NODE_SELECTOR=docker-desktop

K8S_MODE='docker-desktop' # if this value is different from K8S_CONTEXT, target remote k8s on aws

#------------------------------------------------------------------------------
NOS3_CONFIG=$(cat ./scripts/nos3.yaml  | yq 'explode(.)' | grep -iv '^null$')
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Mission/SC/Component Arrays
#------------------------------------------------------------------------------
OU=$(echo "${NOS3_CONFIG}" | yq '.metadata.OU')
ENVIRO=$(echo "${NOS3_CONFIG}" | yq '.metadata.ENVIRO')
TENANT=$(echo "${NOS3_CONFIG}" | yq '.metadata.TENANT')
# -exp must exist to match remote AWS EKS cluster in appdat
CONTEXT=$(echo "${NOS3_CONFIG}" | yq '.metadata.CONTEXT')
nodeSelector=$(echo "${NOS3_CONFIG}" | yq '.defaults.spec.nodes.nodeSelector') # will be overridden if target k8s is remote
imagePullPolicy=$(echo "${NOS3_CONFIG}" | yq '.defaults.spec.nodes.imagePullPolicy')
HEALTHCHECK_PORT=$(echo "${NOS3_CONFIG}" | yq '.defaults.spec.HEALTHCHECK_PORT')

MISSIONS=($(echo "$NOS3_CONFIG" | yq '.missions[] | keys[]'))
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Creds
#------------------------------------------------------------------------------
MISSION_GIT_USER=$(cat ~/.appdat/personal_access_token)
MISSION_GIT_TOKEN=$(cat ~/.appdat/personal_access_token)
MISSION_GIT_SERVER=appdat.jsc.nasa.gov

K8S_LOCAL=true  # to know if k8s is local
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# K8s local or remote
#------------------------------------------------------------------------------
if [ "${K8S_MODE}" != "${K8S_CONTEXT}" ]; then

  AWS_CLUSTER_NAME=${OU}-${ENVIRO}-${CONTEXT}

  ENVIRO=$(echo ${AWS_CLUSTER_NAME} | cut -d- -f2)

  # All this is to capitalize the first letter!
  ENVIRO_USE=`echo ${ENVIRO:0:1} | tr  '[a-z]' '[A-Z]'`${ENVIRO:1}

  echo; echo "Cluster name: $AWS_CLUSTER_NAME"

  mkdir -p /tmp/${HOME}/development/APPDAT/appdat.jsc.nasa.gov/ssmo/SSMO-APPDAT/
  cd /tmp/${HOME}/development/APPDAT/appdat.jsc.nasa.gov/ssmo/SSMO-APPDAT/

  git clone git@appdat.jsc.nasa.gov:ssmo/SSMO-APPDAT/sysconf.git || true
  cd ./sysconf/admin

  make kubeconfig AWS_CLUSTER_NAME=${AWS_CLUSTER_NAME}
  source /tmp/aws-credentials_SSMO-Appdat-Hybrid-Gov${ENVIRO_USE}.sh

  cd ${MY_PWD} # critical

  K8S_CONTEXT=arn:aws-us-gov:eks:${AWS_REGION}:${AWS_ACCOUNT}:cluster/${AWS_CLUSTER_NAME}

  imagePullPolicy=Always
  K8S_LOCAL=false
fi

echo; echo Using and setting context ${K8S_CONTEXT}...
kubectl config use-context ${K8S_CONTEXT}
kubectl config set-context ${K8S_CONTEXT}
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Image URI with its creds
#------------------------------------------------------------------------------
IMAGE_REGISTRY=registry.appdat.jsc.nasa.gov
IMAGE_URI=${IMAGE_REGISTRY}/ssmo/images/ssmo/nos3/nos3-base:20250217
IMAGE_REGISTRY_USER=$(cat ~/.appdat/personal_access_token)
IMAGE_REGISTRY_PASSWORD=$(cat ~/.appdat/personal_access_token)

IMAGE_SECRET_NAME=appdat-registry 

cat <<-EOF > /tmp/config.json
{
  "auths": {
    "${IMAGE_REGISTRY}": {
      "auth": "$(echo -n ${IMAGE_REGISTRY_USER}:${IMAGE_REGISTRY_PASSWORD} | base64 | tr -d '\n')",
      "username": "${IMAGE_REGISTRY_USER}",
      "password": "${IMAGE_REGISTRY_PASSWORD}"
    }
  }
}
EOF

#------------------------------------------------------------------------------
# Missions Loop
#------------------------------------------------------------------------------
for MISSION in "${MISSIONS[@]}"
do

  _MISSION_ENABLED=$(echo "${NOS3_CONFIG}" | yq ".missions[].${MISSION}.enabled"  | grep -iv '^null$')

  if [ "${_MISSION_ENABLED}" != "true" ]; then
    echo; echo MISSION ${MISSION} is not enabled, add enabled: true, skipping...
    continue
  else
    echo; echo MISSION ${MISSION} is enabled continuing.
  fi

  MISSION_PATH=./environments/${OU}/${ENVIRO}/${CONTEXT}/${MISSION}
  mkdir -p ${MISSION_PATH}

  KUSTOMIZATION_FILE_MISSION=${MISSION_PATH}/kustomization.yaml
  touch ${KUSTOMIZATION_FILE_MISSION}

  # Printout preamble of kustomization file
  cat <<-EOF > ${KUSTOMIZATION_FILE_MISSION}
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
EOF

  SPACECRAFT=($(echo "${NOS3_CONFIG}" | yq ".missions[].${MISSION}.spacecraft[] | keys[]"))

  #------------------------------------------------------------------------------
  # Generate deployment and service yaml files
  #  run is below that
  #------------------------------------------------------------------------------
  for SC in "${SPACECRAFT[@]}"
  do
  
    _SPACECRAFT_ENABLED=$(echo "${NOS3_CONFIG}" | yq ".missions[].${MISSION}.spacecraft[].${SC}.enabled"  | grep -iv '^null$')

    if [ "${_SPACECRAFT_ENABLED}" != "true" ]; then
      echo "  MISSION ${MISSION} is enabled, but SPACECRAFT ${SC} is not enabled, add enabled: true, skipping..."
      continue
    else
      echo "  MISSION ${MISSION} is enabled, and SPACECRAFT ${SC} is enabled continuing."
    fi

    if [ "${K8S_LOCAL}" != "true" ]; then
      nodeSelector=$(
      cat <<EOF
      nodeSelector:
        node-selector: ${MISSION}-${SC}   
EOF
      )
    fi

    NAMESPACE=${OU}-${ENVIRO}-${CONTEXT}-${MISSION}-${SC}

    cat <<-EOF >> ${KUSTOMIZATION_FILE_MISSION}
  - ./${SC}/kubernetes
EOF

    SPACECRAFT_PATH=${MISSION_PATH}/${SC}
    mkdir -p ${SPACECRAFT_PATH}

    SPACECRAFT_PATH_K8S=${SPACECRAFT_PATH}/kubernetes/
    mkdir -p ${SPACECRAFT_PATH_K8S}

    KUSTOMIZATION_FILE_SC=${SPACECRAFT_PATH_K8S}/kustomization.yaml
    rm -f ${KUSTOMIZATION_FILE_SC}
    touch ${KUSTOMIZATION_FILE_SC}

    SPACECRAFT_PATH_DOCKER=${SPACECRAFT_PATH}/docker/${NAMESPACE}
    mkdir -p ${SPACECRAFT_PATH_DOCKER}

    #------------------------------------------------------------------------------
    # docker-compose
    #------------------------------------------------------------------------------
    DOCKER_COMPOSE_FILE=${SPACECRAFT_PATH_DOCKER}/${NAMESPACE}_docker-compose.yaml

    rm -rf ${DOCKER_COMPOSE_FILE} 
    touch ${DOCKER_COMPOSE_FILE}

    cat <<-EOF > ${DOCKER_COMPOSE_FILE}
# generated on $(date -u "+%YT%T")

services:
EOF
    #------------------------------------------------------------------------------

    # create configMap per namespace TODO: how to use
    cat <<-EOF > ${SPACECRAFT_PATH_K8S}/${NAMESPACE}_configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${NAMESPACE}-configmap
  namespace: ${NAMESPACE}
data:
  key1: value1
EOF

    # Print preamble of kustomization file
    cat <<-EOF > ${KUSTOMIZATION_FILE_SC}
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
EOF

  #------------------------------------------------------------------------------
  # By component
  #------------------------------------------------------------------------------
  COMPONENTS=($(echo "${NOS3_CONFIG}" | yq ".missions[].${MISSION}.spacecraft[].${SC}.components" | grep -iv '^null$' | yq ' keys[]'))

  THINGS=(${COMPONENTS[@]})

  _COMPONENTS=$(echo "${NOS3_CONFIG}" | yq ".missions[].${MISSION}.spacecraft[].${SC}.components" | grep -iv '^null$')

  for COMPONENT in "${THINGS[@]}"
  do

    COMPONENTS=($(echo "${_COMPONENTS}" | yq ' keys[]'))

    _CONTAINER=$(echo "${_COMPONENTS}" | yq ".${COMPONENT}.container" | grep -iv '^null$')
    CONTAINER_RESOURCES=$(echo "${_CONTAINER}" | yq ".resources"  | grep -iv '^null$')

    CONTAINER_LIMITS_MEMORY=$(echo "${CONTAINER_RESOURCES}"| yq ".limits.memory"  | grep -iv '^null$' )
    CONTAINER_LIMITS_CPU=$(echo "${CONTAINER_RESOURCES}"| yq ".limits.cpu"  | grep -iv '^null$' )

    CONTAINER_REQUESTS_MEMORY=$(echo "${CONTAINER_RESOURCES}"| yq ".requests.memory"  | grep -iv '^null$' )
    CONTAINER_REQUESTS_CPU=$(echo "${CONTAINER_RESOURCES}"| yq ".requests.cpu"  | grep -iv '^null$' )

    _PATHS=$(echo "${_CONTAINER}" | yq ".PATHS"  | grep -iv '^null$')
    CONTAINER_PATHS=($(echo "${_PATHS}"))

    BASE_DIR=$(echo "${_PATHS}" | yq '.BASE_DIR')
    SIM_BIN=$(echo "${_PATHS}" | yq '.SIM_BIN')
    SIMULATOR_BIN=$(echo "${_PATHS}" | yq '.SIMULATOR_BIN')
    LOG_CONFIG=$(echo "${_PATHS}" | yq '.LOG_CONFIG')
    CFG_FILE=$(echo "${_PATHS}" | yq '.CFG_FILE')

    METADATA_NAME=${MISSION}-${SC}-${COMPONENT}
    DEPLOYMENT=${MISSION}-${SC}-${COMPONENT}

    COMPONENT_PATH=${SPACECRAFT_PATH_K8S}/${COMPONENT}
    mkdir -p ${COMPONENT_PATH}

    KUSTOMIZATION_FILE_COMPONENT=${COMPONENT_PATH}/kustomization.yaml
    rm -f ${KUSTOMIZATION_FILE_COMPONENT}

    #------------------------------------------------------------------------------
    # Generate Kustomization files
    #------------------------------------------------------------------------------
    cat <<-EOF >> ${KUSTOMIZATION_FILE_COMPONENT}
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ./deployment.yaml
  - ./service.yaml
EOF

    SERVICE_FILE_COMPONENT=${COMPONENT_PATH}/service.yaml
    rm -f ${SERVICE_FILE_COMPONENT}

    cat <<-EOF >> ${KUSTOMIZATION_FILE_SC}
  - ./${COMPONENT}
EOF

    DEPLOYMENT_FILE_COMPONENT=${COMPONENT_PATH}/deployment.yaml
    rm -f ${DEPLOYMENT_FILE_COMPONENT}

    #------------------------------------------------------------------------------
    # Generate Deployment files
    #------------------------------------------------------------------------------
    cat <<-EOF >> ${DEPLOYMENT_FILE_COMPONENT}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: ${NAMESPACE}
  name: ${DEPLOYMENT}
  labels:
    app: ${NAMESPACE}-${COMPONENT}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${NAMESPACE}-${COMPONENT}
  template:
    metadata:
      labels:
        app: ${NAMESPACE}-${COMPONENT}
    spec:
      # imagePullSecrets:
      #   - name: appdat-registry
${nodeSelector}
      containers:
      - name: ${METADATA_NAME}
        image: ${IMAGE_URI}
        imagePullPolicy: ${imagePullPolicy}
        resources:
          limits:
            memory: ${CONTAINER_LIMITS_MEMORY}
            cpu: ${CONTAINER_LIMITS_CPU}
          requests:
            memory: ${CONTAINER_REQUESTS_MEMORY}
            cpu: ${CONTAINER_REQUESTS_CPU}
        ports:
        - containerPort: ${HEALTHCHECK_PORT}
        env:
          - name: HEALTHCHECK_PORT
            value: "${HEALTHCHECK_PORT}"
          - name: OU
            value: ${OU}
          - name: TENANT
            value: ${TENANT}
          - name: ENVIRO
            value: ${ENVIRO}
          - name: CONTEXT
            value: missions
          - name: MISSION
            value: ${MISSION}
          - name: SPACECRAFT
            value: ${SC}
          - name: MISSION_GIT_USER
            value: ${MISSION_GIT_USER}
          - name: MISSION_GIT_TOKEN
            value: ${MISSION_GIT_TOKEN}
          - name: MISSION_GIT_SERVER
            value: ${MISSION_GIT_SERVER}
          - name: BASE_DIR
            value: ${BASE_DIR}
          - name: SIM_BIN
            value: ${SIM_BIN}
          - name: SIMULATOR_BIN
            value: ${SIMULATOR_BIN}
          - name: LOG_CONFIG
            value: ${LOG_CONFIG}
          - name: CFG_FILE
            value: ${CFG_FILE}
          - name: NETWORK
            value: nos3_sc1
# PROVIDER_MISSION_PATH=/ssmo-dev/git/appdat.jsc.nasa.gov/ssmo/missions/ssmo/dev/nos3/
# CFG_FILE=${PROVIDER_MISSION_PATH}/missions/nos301/spacecraft/sc1/services/nos3/nos3-simulator.xml
#            value: /builds/nos3/sims/build/bin/nos3-simulator.xml
          - name: COMPONENT_NAME
            value: ${COMPONENT}
EOF

    #------------------------------------------------------------------------------
    # Generate Service files
    #------------------------------------------------------------------------------
    cat <<-EOF >> ${SERVICE_FILE_COMPONENT}
---
apiVersion: v1
kind: Service
metadata:
  name: ${MISSION}-${SC}-${COMPONENT}
  namespace: ${NAMESPACE}
spec:
  selector:
    app: ${NAMESPACE}-${COMPONENT}
  ports:
    - name: healthcheck-tcp
      protocol: TCP
      port: ${HEALTHCHECK_PORT}
      targetPort: ${HEALTHCHECK_PORT}
    - name: healthcheck-udp
      protocol: UDP
      port: ${HEALTHCHECK_PORT}
      targetPort: ${HEALTHCHECK_PORT}
  type: ClusterIP

EOF

    #------------------------------------------------------------------------------
    # docker-compose: services
    #------------------------------------------------------------------------------
    SERVICE_NAME=${NAMESPACE}-${COMPONENT}

    cat <<-EOF >> ${DOCKER_COMPOSE_FILE}
  ${SERVICE_NAME}:
    image: ${IMAGE_URI}
    container_name: ${SERVICE_NAME}
    hostname: ${SERVICE_NAME}
    environment:
      HEALTHCHECK_PORT: ${HEALTHCHECK_PORT}
      OU: ${OU}
      TENANT: ${TENANT}
      ENVIRO: ${ENVIRO}
      CONTEXT: missions
      MISSION: ${MISSION}
      SPACECRAFT: ${SC}
      MISSION_GIT_USER: ${MISSION_GIT_USER}
      MISSION_GIT_TOKEN: ${MISSION_GIT_TOKEN}
      MISSION_GIT_SERVER: ${MISSION_GIT_SERVER}
      BASE_DIR: ${BASE_DIR}
      SIM_BIN: ${SIM_BIN}
      NOS3_SIMULATOR_BIN: ${SIMULATOR_BIN}
      LOG_CONFIG: ${LOG_CONFIG}
      CFG_FILE: ${CFG_FILE}
      COMPONENT_NAME: ${COMPONENT}
    privileged: true
    networks:
      - ${NAMESPACE}
EOF

    done # COMPONENT loop

    #------------------------------------------------------------------------------
    # docker-compose completion for sc
    #------------------------------------------------------------------------------
    cat <<-EOF >> ${DOCKER_COMPOSE_FILE}

networks:
  ${NAMESPACE}:
    driver: bridge

EOF
    #------------------------------------------------------------------------------

  done # SC loop

done # MISSIONS loop

#------------------------------------------------------------------------------
# Run kubectl on created yaml files
#------------------------------------------------------------------------------
# Missions Loop
for MISSION in "${MISSIONS[@]}"
do

  MISSION_PATH=./environments/${OU}/${ENVIRO}/${CONTEXT}/${MISSION}
  
  _MISSION_ENABLED=$(echo "${NOS3_CONFIG}" | yq ".missions[].${MISSION}.enabled"  | grep -iv '^null$')

  if [ "${_MISSION_ENABLED}" != "true" ]; then
    echo; echo MISSION ${MISSION} is not enabled, add enabled: true, skipping...
    continue
  else
    echo; echo MISSION ${MISSION} is enabled continuing.
  fi

  SPACECRAFT=($(echo "${NOS3_CONFIG}" | yq ".missions[].${MISSION}.spacecraft[] | keys[]"))

  for SC in "${SPACECRAFT[@]}"
  do

    _SPACECRAFT_ENABLED=$(echo "${NOS3_CONFIG}" | yq ".missions[].${MISSION}.spacecraft[].${SC}.enabled"  | grep -iv '^null$')

    if [ "${_SPACECRAFT_ENABLED}" != "true" ]; then
      echo "  MISSION ${MISSION} is enabled, but SPACECRAFT ${SC} is not enabled, add enabled: true, skipping..."
      continue
    else
      echo "  MISSION ${MISSION} is enabled, and SPACECRAFT ${SC} is enabled continuing."
    fi

    NAMESPACE=${OU}-${ENVIRO}-${CONTEXT}-${MISSION}-${SC}

    if [ "${RECREATE}" == "yes" ]; then
      echo; echo Deleting namespace ${NAMESPACE} in context ${K8S_CONTEXT}...
      kubectl delete namespace ${NAMESPACE} --context ${K8S_CONTEXT} || true
    fi

    echo; echo Creating namespace ${NAMESPACE} in context ${K8S_CONTEXT}...
    kubectl create namespace ${NAMESPACE} --context ${K8S_CONTEXT} || true

    echo; echo Creating secret ${IMAGE_SECRET_NAME} in namespace ${NAMESPACE} in context ${K8S_CONTEXT}...
    kubectl delete secret ${IMAGE_SECRET_NAME} -n ${NAMESPACE} || true
    kubectl create secret generic ${IMAGE_SECRET_NAME} \
      --from-file=.dockerconfigjson=/tmp/config.json \
      --type=kubernetes.io/dockerconfigjson \
      -n ${NAMESPACE}
    kubectl get secret ${IMAGE_SECRET_NAME} --output=yaml -n ${NAMESPACE}

    SPACECRAFT_PATH=${MISSION_PATH}/${SC}
    SPACECRAFT_PATH_K8S=${SPACECRAFT_PATH}/kubernetes
    
    KUSTOMIZATION_FILE_SC=${SPACECRAFT_PATH_K8S}

    echo; echo Applying ${KUSTOMIZATION_FILE_SC} in context ${K8S_CONTEXT}...
    kubectl apply -k ${KUSTOMIZATION_FILE_SC}
    kubectl get deployments -n ${NAMESPACE}

    echo; echo Get pods in namespace ${NAMESPACE} in context ${K8S_CONTEXT}...
    kubectl get pods -o wide -n ${NAMESPACE}

  done # SC

done # MISSIONS
