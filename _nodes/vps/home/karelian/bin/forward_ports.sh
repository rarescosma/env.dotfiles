#!/usr/bin/env bash

# > Get the default gateway IP
# - pass me the awk column index to grab from the `ip route` call
default_gw_route() {
  local col="\$${1:-3}"

  ip route | awk "/default/ { print ${col} }"
}

# > Get the public IP of the current VPS/VM/container
get_public_ip() {
  # Default param + pipes + grep + cut + sed
  local interface=${1:-"$(default_gw_route 5)"}
  ip addr show dev $interface \
  | grep "inet " \
  | cut -d"/" -f1 \
  | sed 's/[^0-9.]*//g'
}

# > Get the first ingress IP from k8s
get_k8s_ingress_ip() {
  kubectl get ingress --all-namespaces --output=json \
  | jq '.items[0].status.loadBalancer.ingress[0].ip' \
  | sed -e 's/^"//' -e 's/"$//'
}

PORTS="$@"
PUBLIC_IFACE="$(default_gw_route 5)"
PUBLIC_IP="$(get_public_ip ${PUBLIC_IFACE})"
INGRESS_IP="$(get_k8s_ingress_ip)"

echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

sudo iptables -t nat -D POSTROUTING --out-interface ${PUBLIC_IFACE} -j MASQUERADE
sudo iptables -t nat -A POSTROUTING --out-interface ${PUBLIC_IFACE} -j MASQUERADE

for p in $PORTS; do
  echo "Forwarding port ${p} from public IP ${PUBLIC_IP} to ingress IP ${INGRESS_IP}"
  sudo iptables -t nat -D PREROUTING -i ${PUBLIC_IFACE} -p tcp --dport ${p} \
    -j DNAT --to-destination ${INGRESS_IP}:${p}
  sudo iptables -t nat -A PREROUTING -i ${PUBLIC_IFACE} -p tcp --dport ${p} \
    -j DNAT --to-destination ${INGRESS_IP}:${p}
done
