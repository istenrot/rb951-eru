:global "bridge_done"
:if ($"bridge_done" != 1) do={
  :error "Error! Bridge needs to be configured before wireless can be configured. Terminating the script!"
}

# If SSID variable not given default to "Default SSID"
:global ssid
if ($ssid = "") do={
  :set ssid "Default SSID"
}

# If PSK variable not given default to "DefaultPassword"
:global psk
:if ($psk = "") do={
  :set psk "DefaultPassword"
}

# Configure wireless
:do {
  /interface wireless security-profiles remove [find name="ERU"]
  /interface wireless channels remove [find]
}
/interface wireless security-profiles add name="ERU" mode=dynamic-keys authentication-types=wpa2-psk group-ciphers=aes-ccm unicast-ciphers=aes-ccm wpa2-pre-shared-key=$psk
/interface wireless channels add list=1-6-11 name=ch1 frequency=2412 extension-channel=disabled band=2ghz-b/g/n width=20
/interface wireless channels add list=1-6-11 name=ch6 frequency=2437 extension-channel=disabled band=2ghz-b/g/n width=20
/interface wireless channels add list=1-6-11 name=ch11 frequency=2462 extension-channel=disabled band=2ghz-b/g/n width=20
:do {
  :local wlan [/interface wireless find name="wlan1"]
  /interface wireless reset-configuration $wlan
  /interface wireless set wireless-protocol=802.11 $wlan
  /interface wireless set mode=ap-bridge $wlan
  /interface wireless set ssid=$ssid $wlan
  /interface wireless set band=2ghz-b/g/n $wlan
  /interface wireless set country="etsi 2.4 5.5-5.7" $wlan
  /interface wireless set frequency-mode=regulatory-domain $wlan
  /interface wireless set frequency=auto $wlan
  /interface wireless set channel-width=20mhz $wlan
  /interface wireless set scan-list=1-6-11 $wlan
  /interface wireless set bridge-mode=enabled $wlan
  /interface wireless set default-authentication=yes $wlan
  /interface wireless set default-forwarding=yes $wlan
  /interface wireless set wmm-support=enabled $wlan
  /interface wireless set security-profile=ERU $wlan
  /interface bridge port add bridge=bridge1 interface=wlan1
  /interface wireless enable $wlan
} on-error={
  :put "No wireless interfaces configured"
}


