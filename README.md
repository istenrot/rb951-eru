# MikroTik RB951 basic configuration script

This script set configures RB951 router with basic settings.

You need to edit variables in the main script file eru-basic-2015-v1.rsc before running the script.

## Ethernet port configuration

* **ether1** - WAN - DHCP client
* **ether2** - Winbox - no IP, no bridge
* **ether3** - Port for internal bridge
* **ether4** - Port for internal bridge
* **ether5** - Port for internal bridge

## Modules

You can comment out modules in the main script file you don't want to use.

* **Bridge and basic IP settings** (creates LAN subnet 10.100.0.0/24)
* **Wireless** (depends on bridge module)
* **Firewall** (depends on bridge module)
* **DHCP server** (depends on bridge module)
* **PPP and LTE interfaces**
* **WAN on ether1** (creates a DHCP client)
* **Queues and traffic classification** (separate upload and download queues)

## Usage

Copy all .rsc files to a RouterBoard. Clear RouterBoard configurations and connect Winbox to ether2. Then type in Winbox Terminal:
```
/import eru-basic-2015-v1.rsc
```


