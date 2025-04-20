#!/bin/sh

command -v kubectl > /dev/null 2>&1 && KUBECTL=kubectl
command -v microk8s.kubectl > /dev/null 2>&1 && KUBECTL=microk8s.kubectl

INGTMPFILE=$(mktemp -t ingress_daemonset.XXXXXXXX)

trap "rm -f ${INGTMPFILE}" 0 1 2 3

${KUBECTL} -n ingress get daemonset nginx-ingress-microk8s-controller -o yaml | \
    sed -e 's|- --publish-status-address=.*|- --publish-service=$(POD_NAMESPACE)/ingress|' > ${INGTMPFILE}

${KUBECTL} diff -f ${INGTMPFILE}
if [ $? -eq 0 ]; then
    echo "No changes need to be made"
else
    ${KUBECTL} apply -f ${INGTMPFILE}
fi