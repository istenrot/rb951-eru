# Connection tracking tuning for satellite connections
/ip firewall connection tracking {
  set icmp-timeout=30s \
  tcp-close-timeout=1m \
  tcp-close-wait-timeout=1m \
  tcp-established-timeout=6h \
  tcp-fin-wait-timeout=1m \
  tcp-last-ack-timeout=1m \
  tcp-syn-received-timeout=30s \
  tcp-syn-sent-timeout=30s \
  tcp-time-wait-timeout=1m \
  udp-timeout=1m
}

# IP NAT masquerade rules
/ip firewall nat add chain=srcnat out-interface=all-ppp action=masquerade
/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade
:foreach interface in=[/interface find type="LTE"] do={
  :local iname [/interface get value-name=name $interface]
  /ip firewall nat add chain=srcnat out-interface=$iname action=masquerade
}

# Firewall filter rules
/ip firewall filter {
  add chain=input connection-state=established
  add chain=input connection-state=related
  add chain=input protocol=icmp
  add chain=input connection-state=new in-interface=bridge1
  add action=drop chain=input
  add chain=forward connection-state=established src-address=10.100.0.0/24
  add chain=forward connection-state=established dst-address=10.100.0.0/24
  add chain=forward connection-state=new src-address=10.100.0.0/24
  add chain=forward connection-state=related dst-address=10.100.0.0/24
  add action=drop chain=forward connection-state=invalid
  add action=drop chain=forward
  add chain=output
}
