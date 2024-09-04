#!/bin/bash

##############################################################################
# Setup
##############################################################################
nfsnamespace=nfs-provisioner
rbac=/root/stage/nfs-provisioner-rbac.yaml
deploy=/root/stage/nfs-provisioner-deployment.yaml
sc=/root/stage/nfs-provisioner-sc.yaml

export PATH=/usr/local/bin:$PATH
export KUBECONFIG=/root/.kube/config

##############################################################################
# Check and if needed wait till can connect
##############################################################################
((count=0))
while : ; do
    oc get projects | grep -E "default|cluster"
    [[ $? == 0 ]] && break
    sleep 5
    ((count=count+5))
    if [[ ${count} -gt 300 ]] ; then
	echo "ERROR: Timed out waiting to connect to OpenShift"
	exit 1
    fi
done

##############################################################################
# Check if already deployed
##############################################################################
oc rollout status deployment nfs-client-provisioner -n nfs-provisioner
if [[ $? == 0 ]] ; then
    echo "NFS client provisioner already appears to be deployed"
    exit 0
fi

##############################################################################
# Check to see if important files are there
##############################################################################
for file in ${rbac} ${deploy} ${sc} ; do
    if [[ ! -f ${file} ]] ; then
	echo "ERROR: File ${file} does not exist"
	exit 254
    fi
done

##############################################################################
# Create project
##############################################################################
oc projects | grep ${nfsnamespace}
if [[ $? != 0 ]] ; then
    ((count=0))
    while : ; do
        oc new-project ${nfsnamespace}
        [[ $? == 0 ]] && break
        oc projects | grep ${nfsnamespace}
        [[ $? == 0 ]] && break
        sleep 5
        ((count=count+5))
        if [[ ${count} -gt 300 ]] ; then
            echo "ERROR: Problem creating new project $nfsnamespace"
            exit 1
        fi
    done
fi

##############################################################################
# Prepare everything
##############################################################################
oc project ${nfsnamespace}
if [[ $? != 0 ]] ; then
    ((count=0))
    while : ; do
        sleep 5
        oc project ${nfsnamespace}
        [[ $? == 0 ]] && break
        ((count=count+5))
        if [[ ${count} -gt 300 ]] ; then
            echo "ERROR: Problem switching to new project $nfsnamespace"
            exit 254
        fi
    done
fi

oc create -f ${rbac}
[[ $? != 0 ]] && echo "ERROR: Problem creating ${rbac}" && exit 254

oc adm policy add-scc-to-user hostmount-anyuid system:serviceaccount:${nfsnamespace}:nfs-client-provisioner
[[ $? != 0 ]] && echo "ERROR: Problem adjusting policy for nfs-client-provisioner" && exit 254

oc create -f ${deploy} -n ${nfsnamespace}
[[ $? != 0 ]] && echo "ERROR: Problem creating ${deploy}" && exit 254

oc create -f ${sc}
[[ $? != 0 ]] && echo "ERROR: Problem creating ${sc}" && exit 254

oc annotate storageclass nfs-storage-provisioner storageclass.kubernetes.io/is-default-class="true"
[[ $? != 0 ]] && echo "ERROR: Problem annotating storage class for nfs-storage-provisioner" && exit 254

##############################################################################
# Monitor deployment till success or failure
##############################################################################
oc rollout status deployment nfs-client-provisioner -n ${nfsnamespace} -w
[[ $? != 0 ]] && echo "ERROR: Problem deploying nfs-client-provisioner" && exit 254

oc project default
[[ $? != 0 ]] && echo "ERROR: Problem switching to default project" && exit 254

echo "Deployment of nfs-client-provisioner completed"
exit 0
