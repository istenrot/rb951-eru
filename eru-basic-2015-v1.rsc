# Global variables
:global "bridge_done" 0
:global "wan_speed_kbit_up" 0
:global "wan_speed_kbit_down" 0
:global "admin_password_set" 0

:put "This is setup script for Basic ERU router 2015 v1."
:put "Tested with RB951G-2HnD and RB951Ui-2HnD."
:put "May work on other models but not supported or tested."

# Check ROS version is 6.30.x
:local version [/system resource get version];
:if ( [:pick $version 0 5] != "6.30." ) do={ :error "Error! ROS version $version is not supported. Script terminated!"; }

# Make sure Winbox is available on ether2
:do {
  /tool mac-server add interface=[/interface ethernet get value-name=name 1] disabled=no
} on-error={}
:do {
  /tool mac-server mac-winbox add interface=[/interface ethernet get value-name=name 1] disabled=no
} on-error={}
/ip neighbor discovery set discover=yes [find name=[/interface ethernet get value-name=name 1]]

# Check that PC is connected to ether2 during configuration
#:local running [/interface ethernet get value-name=running 1]
#:if ($running != true) do={ :error "Please connect Winbox to interface ether2 while running the script! Script terminated!"; }

:do {
  /password old-password="" new-password="" confirm-new-password=""
} on-error={
  :put "Good, admin password seems to be set."
  :global "admin_password_set" 1
}

:if ($"admin_password_set" = 0) do={
  :put "Warning! Empty admin password!!"
}

/system identity set name="Basic ERU router 2015 v1"

# Disable all packages and enable only required ones
/system package disable [ find ]
/system package enable [ find name="routeros-mipsbe" ]
/system package enable [ find name="system" ]
/system package enable [ find name="wireless-fp" ]
/system package enable [ find name="advanced-tools" ]
/system package enable [ find name="security" ]
/system package enable [ find name="dhcp" ]
/system package enable [ find name="ppp" ]
/system package enable [ find name="routing" ]

# Make sure the RB firmware is the latest one
:local cfw [/system routerboard get current-firmware]
:local nfw [/system routerboard get upgrade-firmware]
:if ( $cfw != $nfw ) do={
  :put "Current firmware version $cfw is different than the one provided with ROS: $nfw."
  :put "Upgrading firmware..."
  /system routerboard upgrade
  :put "Wait..."
  :delay delay-time=3
} else={
  :put "Firmware OK, no need to upgrade."
}

:if ( [/system package find scheduled!=""] != "" ) do={
  # Commit to the new package selection and firmware version by rebooting
  :put "Need to reboot the router to commit new set of enabled software packages."
  :put "Execute this script again after the reboot."
  /system reboot
}

# Mandatory to clear configurations
/import eru-basic-2015-v1-clear-configs.rsc

:put "Starting to execute modules..."

# Choose which parts of the scripts you want to enable:
:do {
  /import eru-basic-2015-v1-ip-bridge-networking.rsc
} on-error={ :put "Bridge and IP settings failed!"; }
:do {
  :global ssid "Default SSID"
  :global psk "DefaultPassword"
  /import eru-basic-2015-v1-wireless.rsc
} on-error={ :put "Wireless configuration failed!"; }
:do {
  /import eru-basic-2015-v1-firewall.rsc
} on-error={ :put "Firewall configuration failed!"; }
:do {
  /import eru-basic-2015-v1-dhcp.rsc
} on-error={ :put "DHCP server setup failed!"; }
:do {
  :global "ppp_apn" "internet"
  /import eru-basic-2015-v1-ppp-lte.rsc
} on-error={ :put "PPP and LTE setup failed!"; }
:do {
  :global "wan_speed_kbit_up" 512
  :global "wan_speed_kbit_down" 5243
  /import eru-basic-2015-v1-wan-ether1.rsc
} on-error={ :put "WAN configuraion on ether1 failed!"; }
:do {
  /import eru-basic-2015-v1-queues.rsc
} on-error={ :put "Setting up queues failed!"; }

:put "All configurations done."

# Remove global variables
:set "bridge_done"
:set "wan_speed_kbit_up"
:set "wan_speed_kbit_down"
:set "admin_password_set"

