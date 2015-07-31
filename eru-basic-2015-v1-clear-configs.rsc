# BEGIN CLEANING CONFIGURATIONS

# Disable all interfaces not being ethernet
:put "Disabling all non-ethernet interfaces"
/interface disable [find type!="ether"]

# Disable ethernet switching
:put "Disabling ethernet switching"
/interface ethernet set master-port=none [find]

# Disable PoE
:put "Disabling PoE"
/interface ethernet poe set poe-out=off [find]

# Remove static IP routes
/ip route remove [find static]

# Remove all firewall and NAT rules
:put "Removing firewall filter rules"
/ip firewall filter remove [find dynamic=no]
:put "Removing firewall NAT rules"
/ip firewall nat remove [find dynamic=no]
:put "Removing firewall mangle rules"
/ip firewall mangle remove [find dynamic=no]

# Remove all existing DHCP servers
:put "Removing DHCP leases"
/ip dhcp-server lease remove [find]
:put "Removing DHCP servers networks"
/ip dhcp-server network remove [find]
:put "Removing DHCP servers"
/ip dhcp-server remove [find]

# Remove all existing address pools
:put "Removing IP address pools"
/ip pool remove [find]

# Remove all existing DHCP clients
:put "Removing DHCP clients"
/ip dhcp-client remove [find]

# Remove all existing IP addresses
:put "Removing IP addresses"
/ip address remove [find]

# Remove queues
/queue tree remove [find]
/queue simple remove [find]

# Remove all existing bridges
:put "Removing bridge ports"
/interface bridge port remove [find]
:put "Removing bridges"
/interface bridge remove [find]

# Remove Virtual-AP interfaces
/interface wireless remove [find interface-type="virtual-AP"]

# Remove PPP client interfaces
/interface ppp-client remove [find]

# Rename interfaces
:put "Renaming interfaces"
:local i 0
:foreach item in=[/interface find type="ether"] do={
  :set i (i+1)
  /interface set name="ether$i" $item
}
:set i 0
:foreach item in=[/interface find type="wlan"] do={
  :set i (i+1)
  /interface set name="wlan$i" $item
}

# Disable MAC server/Winbox on interfaces except ether2
/tool mac-server remove [find default=no interface!=ether2]
/tool mac-server disable [find default=yes]
/tool mac-server mac-winbox remove [find default=no interface!=ether2]
/tool mac-server mac-winbox disable [find default=yes]

:put "End of cleaning configs"

# END OF CLEANING CONFIGURATIONS

