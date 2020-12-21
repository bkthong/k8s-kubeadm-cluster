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
network  --bootproto=static --device=eth0 --ip=192.168.122.201 --netmask=255.255.255.0 --gateway=192.168.122.1 --nameserver=192.168.122.1 --ipv6=auto --onboot=on
network  --hostname=master01.lab.example.com

#Open ports for control node
firewall --enabled --port=6443:tcp,2379:tcp,2380:tcp,10250:tcp,10251:tcp,10252:tcp --ssh

# Root password
rootpw --iscrypted $6$Nhii7AfMDsah7JjV$v5fFgE0CrG8Uct/epTqKJaIjknwPcnmOIP2yQdUVsOCeLHigxdgvO2oyZeH5hBxz3LrzvoRPiFgjjM6jURwyW.
# System services
services --disabled="chronyd"
# System timezone
timezone Asia/Kuala_Lumpur --isUtc --nontp
user --groups=wheel --name=student --password=$6$Bk.v8wIc4HM2RR.O$..JtoVKU6HjXgLcyMAE9BxAo4ibjNqpKl9IsTNMGyUJ3epXHWf1fiIdyUbFf2MYmvWBs58zbCjvk.OsbubSVU0 --iscrypted --gecos="student"
# System bootloader configuration
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=vda
#autopart --type=lvm
part /boot --fstype="xfs" --ondisk=vda --size=1024
part pv.157 --fstype="lvmpv" --ondisk=vda --grow
volgroup centos --pesize=4096 pv.157
logvol /  --fstype="xfs" --grow --percent=100 --name=root --vgname=centos
# Partition clearing information
clearpart --none --initlabel
reboot

%packages
@^minimal
@core
kexec-tools
bash-completion
vim-enhanced
%end


%post

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

cat <<EOF | sudo tee -a /etc/hosts
192.168.122.201 master master.lab.example.com
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
