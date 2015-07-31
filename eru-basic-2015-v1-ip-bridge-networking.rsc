# IP settings
/ip settings set ip-forward=yes
/ip settings set send-redirects=no
/ip settings set accept-source-route=no
/ip settings set accept-redirects=no

# Create a new  bridge and assign ether ports except ether1 and ether 2to it
:do {
  /interface bridge remove [find name=bridge1]
}
/interface bridge add name=bridge1 protocol-mode=none forward-delay=4s
:do {
  /interface bridge port {
    :foreach interface in=[/interface find type="ether"] do={
      :local name [/interface get value-name=name $interface]
      :if ($name != "ether1" && $name != "ether2") do={
        add bridge=bridge1 interface=$name
        :put "Interface $name has been added to internal bridge"
      }
    }
  }
}

# Set IP address for bridge1
/ip address add interface=bridge1 address=10.100.0.1/24
:put "bridge1 has IP address 10.100.0.1"

# Flag bridge setup as done
:global "bridge_done" 1

# Enable ethernet interfaces
/interface enable [find type="ether"]

# Enable mac/winbox services and discovery on bridge1 and ether2
/tool mac-server add interface=bridge1 disabled=no
/tool mac-server mac-winbox add interface=bridge1 disabled=no
/ip neighbor discovery set discover=no [find]
/ip neighbor discovery set discover=yes [find name="bridge1"]
/ip neighbor discovery set discover=yes [find name="ether2"]

