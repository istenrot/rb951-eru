# Enable DHCP client on LTE interfaces
:foreach interface in=[/interface find type="LTE"] do={
  :local iname [/interface get value-name=name $interface]
  /ip dhcp-client add interface=$iname add-default-route=yes default-route-distance=20
  :put "DHCP client added for LTE interface $iname"
  /ip neighbor discovery set discover=no [find name="$iname"]
}

# If APN variable not given default to APN "internet"
:global "ppp_apn"
:if ($"ppp_apn" = "") do={
  :set "ppp_apn" "internet"
}

# Create interface ppp-out1 for the first USB port used by PPP
:global usb [/port find]

# Default to port usb1 if no USB PPP interfaces yet detected
:if ($usb != {}) do={
  :local i 0
  :foreach port in=$usb do={
    :set i ($i + 1)
    /interface ppp-client remove [find name="ppp-out$i"]
    :local "port_name" [/port get value-name=name $port]
    /interface ppp-client add name="ppp-out$i" port=$"port_name" data-channel=0 info-channel=1 dial-on-demand=yes \
        add-default-route=yes default-route-distance=25 use-peer-dns=yes apn=$"ppp_apn" disabled=no
    :put "PPP interface ppp-out$i created for port ($"port_name")"
    /ip neighbor discovery set discover=no [find name="ppp-out$i"]
  }
}


