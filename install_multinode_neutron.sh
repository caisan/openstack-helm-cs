tee /tmp/neutron.yaml << EOF
network:
  interface:
    tunnel: "eth3"
labels:
  agent:
    dhcp:
      node_selector_key: openstack-helm-node-class
      node_selector_value: primary
    l3:
      node_selector_key: openstack-helm-node-class
      node_selector_value: primary
    metadata:
      node_selector_key: openstack-helm-node-class
      node_selector_value: primary
pod:
  replicas:
    server: 1
conf:
  neutron:
    DEFAULT:
      l3_ha: True
      router_distributed: True
      min_l3_agents_per_router: 1
      max_l3_agents_per_router: 3
      l3_ha_network_type: vxlan
      dhcp_agents_per_network: 1
  plugins:
    ml2_conf:
      ml2_type_flat:
        flat_networks: public
    openvswitch_agent:
      agent:
        tunnel_types: vxlan
        enable_distributed_routing: True
      ovs:
        bridge_mappings: public:br-ex
  l3_agent:
    DEFAULT:
      agent_mode: dvr_snat
      ovs_integration_bridge = br-int
      interface_driver: neutron.agent.linux.interface.OVSInterfaceDriver
EOF
helm upgrade --install neutron ./neutron \
    --namespace=openstack \
    --values=/tmp/neutron.yaml \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_NEUTRON}
