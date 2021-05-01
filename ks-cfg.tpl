# Install a fresh new system (optional)
install

# Specify installation method to use for installation
cdrom

# Set language to use during installation and the default language to use on the installed system (required)
lang en_US.UTF-8

# Set system keyboard type / layout (required)
keyboard us

# Configure network information for target system and activate network devices in the installer environment (optional)
network --onboot yes --hostname ${hostname} --device ens192 --bootproto static  --ipv6 auto   --ip=${ipv4_address} --netmask=${netmask} --gateway=${gateway} --nameserver ${nameserver1},${nameserver2} --noipv6

# Set the system's root password (required)
rootpw --iscrypted ..d2zEuQUAlps

firewall --disabled

# Set up the authentication options for the system (required)
# --enableshadow	enable shadowed passwords by default
# --passalgo		hash / crypt algorithm for new passwords
authconfig --enableshadow --passalgo=sha512

# State of SELinux on the installed system (optional)
selinux --disabled

# Set the system time zone (required)
timezone --utc America/New_York

# Specify how the bootloader should be installed (required)
# Plaintext password is: password
# encrypted password form for different plaintext password
bootloader --location=mbr --append="crashkernel=auto rhgb quiet" --password=$6$rhel6usgcb$kOzIfC4zLbuo3ECp1er99NRYikN419wxYMmons8Vm/37Qtg0T8aB9dKxHwqapz8wWAFuVkuI/UJqQBU92bA5C0

# Initialize (format) all disks (optional)
zerombr

# The following partition layout scheme assumes disk of size 20GB or larger
# Modify size of partitions appropriately to reflect actual machine's hardware

clearpart --all --initlabel --drives=sda
part /boot --fstype=xfs --size=1024
part pv.01 --grow --size=1

# Create a Logical Volume Management (LVM) group (optional)
volgroup VolGroup00 --pesize=4096 pv.01
# Create particular logical volumes (optional)
logvol / --fstype=xfs --name=lv_root --vgname=VolGroup00 --size=8192 --grow
# CCE-26557-9: Ensure /home Located On Separate Partition
logvol /home --fstype=xfs --name=lv_home --vgname=VolGroup00 --size=1024 --fsoptions="nodev"
# CCE-26435-8: Ensure /tmp Located On Separate Partition
logvol /tmp --fstype=xfs --name=lv_tmp --vgname=VolGroup00 --size=1024
# CCE-26639-5: Ensure /var Located On Separate Partition
logvol /var --fstype=xfs --name=lv_var --vgname=VolGroup00 --size=${var_size}
#logvol swap --name=lv_swap --vgname=VolGroup --size=2016
logvol /opt --fstype=xfs --name=lv_opt --vgname=VolGroup00 --size=4098 --grow


# Packages selection (%packages section is required)
%packages
# Require @Base
@Base
@core
sed
perl
less
dmidecode
bzip2
iproute
iputils
sysfsutils
rsync
nano
mdadm
man-pages.noarch
tar
net-tools
lsof
python
screen
lvm2
curl
ypbind
yp-tools
openssh-clients
acpid
irqbalance
which
bind-utils
man
chkconfig
gzip
-NetworkManager
-NetworkManager-tui
-*-firmware

# Install selected additional packages (required by profile)
# CCE-27024-9: Install AIDE
aide

# Install libreswan package
#libreswan
%end # End of %packages section

%pre
#!/bin/sh
echo "Test"
%end

%post --log=/root/ks-post.log

systemctl stop NetworkManager
systemctl disable NetworkManager

chkconfig sshd on
chkconfig ypbind on
chkconfig firewalld off
chkconfig sysstat off

%end



# Reboot after the installation is complete (optional)
# --eject	attempt to eject CD or DVD media before rebooting
reboot --eject
