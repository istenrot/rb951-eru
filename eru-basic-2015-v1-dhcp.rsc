# Create IP pool for DHCP server
/ip pool add name=pool1 ranges=10.100.0.10-10.100.0.254

# Create DHCP server network
/ip dhcp-server network add address=10.100.0.0/24 netmask=24 gateway=10.100.0.1 dns-server=10.100.0.1

# Create DHCP server
/ip dhcp-server add interface=bridge1 delay-threshold=none authoritative=yes address-pool=pool1 disabled=no

# Enable DNS server
/ip dns set servers=8.8.8.8
/ip dns set allow-remote-requests=yes


