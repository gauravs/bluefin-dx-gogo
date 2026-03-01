lang en_US.UTF-8
keyboard us
timezone UTC --utc
network --bootproto=dhcp --activate --onboot=yes
zerombr
clearpart --all --initlabel
autopart --type=btrfs
rootpw --lock
user --name=gogo --groups=wheel --password=changeme --plaintext
bootloader --location=mbr
reboot --eject

%post --erroronfail --log=/root/ks-post.log
set -euo pipefail
bootc switch --no-signature-verification --transport registry ghcr.io/gauravs/bluefin-dx-gogo:latest
%end
