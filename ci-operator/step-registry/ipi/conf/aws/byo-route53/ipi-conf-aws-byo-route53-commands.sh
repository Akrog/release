#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

trap 'CHILDREN=$(jobs -p); if test -n "${CHILDREN}"; then kill ${CHILDREN} && wait; fi' TERM

CONFIG="${SHARED_DIR}/install-config.yaml"


# subnet, AZs and hosted zone
HostedZoneId="${SHARED_DIR}/hosted_zone_id"
if [ ! -f "${HostedZoneId}" ]; then
    echo "File ${HostedZoneId} does not exist."
    exit 1
fi

echo -e "hosted zone: $(cat ${HostedZoneId})"

CONFIG_ROUTE53_PRIVATE_HOSTEDZONE="/tmp/install-config-route53-private-hosted-zone.yaml.patch"
cat > "${CONFIG_ROUTE53_PRIVATE_HOSTEDZONE}" << EOF
platform:
  aws:
    hostedZone: $(cat "${HostedZoneId}")
EOF

yq-go m -x -i "${CONFIG}" "${CONFIG_ROUTE53_PRIVATE_HOSTEDZONE}"
