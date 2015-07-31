# Configuring port ether1 for WAN access
:put "Configuring port ether1 for WAN access"

:local wan [/interface ethernet find name="ether1"]
/interface ethernet disable $wan
/interface ethernet reset-counters $wan
/interface ethernet {
  set auto-negotiation=yes $wan
  set full-duplex=yes $wan
  set rx-flow-control=auto $wan
  set tx-flow-control=auto $wan
}
/interface ethernet enable $wan

/ip dhcp-client add interface=ether1 add-default-route=yes default-route-distance=5 use-peer-dns=yes
:put "Port ether1 has DHCP client listening"

:put "Disabling Winbox access on ether1..."
# Disable MAC server/Winbox on interfaces ether1
/tool mac-server remove [find interface=ether1]
/tool mac-server mac-winbox remove [find interface=ether1]


