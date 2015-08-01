:global "bridge_done"
:if ($"bridge_done" != 1) do={
  :error "Error! Bridge needs to be configured before queues can be configured. Terminating the script!"
}

:global "wan_speed_kbit_up"
:if ($"wan_speed_kbit_up" = 0) do={
  :error "Error! WAN needs to be configured before queues can be configured. Terminating the script!"
}

:global "wan_speed_kbit_down"
:if ($"wan_speed_kbit_down" = 0) do={
  :error "Error! WAN needs to be configured before queues can be configured. Terminating the script!"
}

# Classify connections in prerouting chain and mark connections
/ip firewall mangle {
  add action=mark-connection chain=prerouting new-connection-mark=critical passthrough=no protocol=icmp
  add action=mark-connection chain=prerouting connection-state=new dst-port=53 new-connection-mark=critical passthrough=no protocol=udp
  add action=mark-connection chain=prerouting connection-state=new new-connection-mark=udp passthrough=no protocol=udp
  # Downgrade web connections to long class after 2 MB of traffic
  add action=mark-connection chain=prerouting connection-bytes=2097152-0 connection-mark=web connection-state=established new-connection-mark=long passthrough=no protocol=tcp
  add action=mark-connection chain=prerouting connection-state=new dst-port=80 new-connection-mark=web passthrough=no protocol=tcp
  add action=mark-connection chain=prerouting connection-state=new dst-port=443 new-connection-mark=web passthrough=no protocol=tcp
  add action=mark-connection chain=prerouting connection-state=new dst-port=22 new-connection-mark=critical passthrough=no protocol=tcp
  add action=mark-connection chain=prerouting connection-state=new dst-port=993 new-connection-mark=email passthrough=no protocol=tcp
  add action=mark-connection chain=prerouting connection-state=new dst-port=465 new-connection-mark=email passthrough=no protocol=tcp
  add action=mark-connection chain=prerouting connection-state=new dst-port=587 new-connection-mark=email passthrough=no protocol=tcp
  add action=mark-connection chain=prerouting connection-state=new dst-port=110 new-connection-mark=email passthrough=no protocol=tcp
  add action=mark-connection chain=prerouting connection-state=new dst-port=995 new-connection-mark=email passthrough=no protocol=tcp
  add action=mark-connection chain=prerouting connection-state=new dst-port=143 new-connection-mark=email passthrough=no protocol=tcp
  add action=mark-connection chain=prerouting connection-state=new new-connection-mark=long passthrough=no protocol=tcp
}

# Packet markings for upload queues
/ip firewall mangle {
  # Prioritize TCP ack packets to avoid retransmissions
  add action=mark-packet chain=postrouting connection-state=established dst-address=!10.100.0.0/24 new-packet-mark=critical-upload packet-size=0-89 passthrough=no protocol=tcp src-address=10.100.0.0/24 tcp-flags=ack

  add action=mark-packet chain=postrouting connection-mark=critical dst-address=!10.100.0.0/24 new-packet-mark=critical-upload passthrough=no src-address=10.100.0.0/24
  add action=mark-packet chain=postrouting connection-mark=udp dst-address=!10.100.0.0/24 new-packet-mark=udp-upload passthrough=no src-address=10.100.0.0/24
  add action=mark-packet chain=postrouting connection-mark=email dst-address=!10.100.0.0/24 new-packet-mark=email-upload passthrough=no src-address=10.100.0.0/24
  add action=mark-packet chain=postrouting connection-mark=web dst-address=!10.100.0.0/24 new-packet-mark=web-upload passthrough=no src-address=10.100.0.0/24
  add action=mark-packet chain=postrouting connection-mark=long dst-address=!10.100.0.0/24 new-packet-mark=long-upload passthrough=no src-address=10.100.0.0/24
}

# Packet markings for download queues
/ip firewall mangle {
  # Prioritize TCP ack packets to avoid retransmissions
  add action=mark-packet chain=postrouting connection-state=established dst-address=10.100.0.0/24 new-packet-mark=critical-download packet-size=0-89 passthrough=no protocol=tcp src-address=!10.100.0.0/24 tcp-flags=ack

  add action=mark-packet chain=postrouting connection-mark=critical dst-address=10.100.0.0/24 new-packet-mark=critical-download passthrough=no src-address=!10.100.0.0/24
  add action=mark-packet chain=postrouting connection-mark=udp dst-address=10.100.0.0/24 new-packet-mark=udp-download passthrough=no src-address=!10.100.0.0/24
  add action=mark-packet chain=postrouting connection-mark=email dst-address=10.100.0.0/24 new-packet-mark=email-download passthrough=no src-address=!10.100.0.0/24
  add action=mark-packet chain=postrouting connection-mark=web dst-address=10.100.0.0/24 new-packet-mark=web-download passthrough=no src-address=!10.100.0.0/24
  add action=mark-packet chain=postrouting connection-mark=long dst-address=10.100.0.0/24 new-packet-mark=long-download passthrough=no src-address=!10.100.0.0/24
}

# Mark packets which are heading to the router itself for correct queues
/ip firewall mangle {
  # Prioritize TCP ack packets to avoid retransmissions
  add action=mark-packet chain=input connection-state=established new-packet-mark=critical-download packet-size=0-89 passthrough=no protocol=tcp tcp-flags=ack

  add action=mark-packet chain=input connection-mark=critical new-packet-mark=critical-download passthrough=no
  add action=mark-packet chain=input connection-mark=udp new-packet-mark=udp-download passthrough=no
  add action=mark-packet chain=input connection-mark=email new-packet-mark=email-download passthrough=no
  add action=mark-packet chain=input connection-mark=web new-packet-mark=web-download passthrough=no
  add action=mark-packet chain=input connection-mark=long new-packet-mark=long-download passthrough=no
}

# Create queue tree for uploads
# Child queues are pcq-upload-default
/queue tree {
  add name=upload parent=global
  add max-limit=($"wan_speed_kbit_up" * 1000) name=critical-upload packet-mark=critical-upload parent=upload priority=2 queue=default
  add max-limit=((($"wan_speed_kbit_up") / 4) * 1000) name=udp-upload packet-mark=udp-upload parent=upload priority=5 queue=pcq-upload-default
  add max-limit=((($"wan_speed_kbit_up") / 2) * 1000) name=email-upload packet-mark=email-upload parent=upload priority=6 queue=pcq-upload-default
  add burst-limit=($"wan_speed_kbit_up" * 1000) burst-threshold=(((($"wan_speed_kbit_up") / 4 * 3) / 4) * 1000) burst-time=10s max-limit=((($"wan_speed_kbit_up") / 4) * 1000) name=web-upload packet-mark=web-upload parent=upload priority=7 queue=pcq-upload-default
  add max-limit=((($"wan_speed_kbit_up") / 4) * 1000) name=long-upload packet-mark=long-upload parent=upload priority=8 queue=pcq-upload-default
}

# Create queue tree for downloads
# Child queues are pcq-download-default
/queue tree {
  add name=download parent=global
  add max-limit=($"wan_speed_kbit_down" * 1000) name=critical-download packet-mark=critical-download parent=download priority=2 queue=default
  add max-limit=((($"wan_speed_kbit_down") / 6) * 1000) name=udp-download packet-mark=udp-download parent=download priority=5 queue=pcq-download-default
  add max-limit=((($"wan_speed_kbit_down") / 3) * 1000) name=email-download packet-mark=email-download parent=download priority=6 queue=pcq-download-default
  add burst-limit=($"wan_speed_kbit_down" * 1000) burst-threshold=(((($"wan_speed_kbit_down") / 3 * 3) / 4) * 1000) burst-time=10s max-limit=((($"wan_speed_kbit_down") / 3) * 1000) name=web-download packet-mark=web-download parent=download priority=7 queue=pcq-download-default
  add max-limit=((($"wan_speed_kbit_down") / 3) * 1000) name=long-download packet-mark=long-download parent=download priority=8 queue=pcq-download-default
}
