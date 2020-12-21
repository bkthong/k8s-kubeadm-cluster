#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
cdrom
# Use graphical install
graphical
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=vda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=static --device=eth0 --ip=192.168.122.211 --netmask=255.255.255.0 --gateway=192.168.122.1 --nameserver=192.168.122.1 --ipv6=auto --onboot=on
#network  --bootproto=dhcp --device=eth0 --onboot=off --ipv6=auto 
network  --hostname=worker01.lab.example.com

#Open ports for worker node. 
firewall --enabled --port=10250:tcp,30000-32767:tcp --ssh

# Root password
rootpw --iscrypted $6$BbIGGqiP90b22.ms$4bluUz.a4uDNP4ZaPPsqrklCYBanQVc7kJ6PVXCPKXTzjsHJFFS08IzkzYsV6WBxXeIK4gLpkJRwYfyuq5d8w0
# System services
services --disabled="chronyd"
# System timezone
timezone Asia/Kuala_Lumpur --isUtc --nontp
user --groups=wheel --name=student --password=$6$HTlP8lfKbE4FUt4t$aawd7V1IxJmb0B8yM2qBybOGgoDShD1AyyHUwAjvhOb6efqjdqONgnXuPmQY3vTby4ExwOo7Ur/wYLlPuGVTW1 --iscrypted --gecos="student"
# System bootloader configuration
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=vda
# Partition clearing information
clearpart --none --initlabel
# Disk partitioning information
part /boot --fstype="xfs" --ondisk=vda --size=1024
part pv.157 --fstype="lvmpv" --ondisk=vda --grow
volgroup centos --pesize=4096 pv.157
logvol /  --fstype="xfs" --grow --percent=100 --name=root --vgname=centos
reboot

%packages
@^minimal
@core
kexec-tools
bash-completion
vim-enhanced

%end

%post
cat <<EOF | sudo tee -a /etc/hosts
192.168.122.201 master01 master01.lab.example.com
192.168.122.211 worker01 worker01.lab.example.com
192.168.122.212 worker02 worker02.lab.example.com
EOF
%end 

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end
