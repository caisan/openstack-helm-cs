#!/bin/bash

make nova

#NOTE: Deploy nova
tee /tmp/nova.yaml << EOF
labels:
  api_metadata:
    node_selector_key: openstack-helm-node-class
    node_selector_value: primary
pod:
  replicas:
    api_metadata: 1
    placement: 1
    osapi: 1
    conductor: 1
    consoleauth: 1
    scheduler: 1
    novncproxy: 1
conf:
  ceph:
    enabled: true
    admin_keyring: AQBZWsxbaJNHLhAAzF9vfqMjiQ3tRjM68x3fqw==
    cinder:
      user: "cinder"
      keyring: AQBeKM1bo1ipJRAAEM+wpTixbo6HoFFymnh+hg==
      secret_uuid: 457eb676-33da-42ec-9a8c-9293d545c337

EOF
if [ "x$(systemd-detect-virt)" == "xnone" ]; then
  echo 'OSH is not being deployed in virtualized environment'
  helm upgrade --install nova ./nova \
      --namespace=openstack \
      --values=/tmp/nova.yaml \
      ${OSH_EXTRA_HELM_ARGS} \
      ${OSH_EXTRA_HELM_ARGS_NOVA}
else
  echo 'OSH is being deployed in virtualized environment, using qemu for nova'
  helm upgrade --install nova ./nova \
      --namespace=openstack \
      --values=/tmp/nova.yaml \
      --set conf.nova.libvirt.virt_type=qemu \
      --set conf.nova.libvirt.cpu_mode=none \
      ${OSH_EXTRA_HELM_ARGS} \
      ${OSH_EXTRA_HELM_ARGS_NOVA}
fi
