# -*-Makefile-*-

WD := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))));
UUID = $(shell ./to_uuid.sh)
ETC_FOS_DIR = /etc/fos/
VAR_FOS_DIR = /var/fos/
FOS_CONF_FILE = /etc/fos/agent.json
KVM_PLUGIN_DIR = /etc/fos/plugins/plugin-fdu-kvm
LKVM_PLUGIN_CONFFILE = /etc/fos/plugins/plugin-fdu-kvm/KVM_plugin.json
all:
	echo "Nothing to do"

install:
	sudo pip3 install libvirt-python jinja2
	sudo usermod -aG kvm fos
	sudo usermod -aG libvirt fos
ifeq "$(wildcard $(KVM_PLUGIN_DIR))" ""
	sudo cp -r ../plugin-fdu-kvm /etc/fos/plugins/
else
	sudo cp -r ../plugin-fdu-kvm/templates /etc/fos/plugins/plugin-fdu-kvm/
	sudo cp ../plugin-fdu-kvm/__init__.py /etc/fos/plugins/plugin-fdu-kvm/
	sudo cp ../plugin-fdu-kvm/KVM_plugin /etc/fos/plugins/plugin-fdu-kvm/
	sudo cp ../plugin-fdu-kvm/KVMFDU.py /etc/fos/plugins/plugin-fdu-kvm/
	sudo cp ../plugin-fdu-kvm/README.md /etc/fos/plugins/plugin-fdu-kvm/
	sudo cp /etc/fos/plugins/KVM/fos_kvm.service /lib/systemd/system/
endif
	sudo cp /etc/fos/plugins/plugin-fdu-kvm/fos_kvm.service /lib/systemd/system/
	sudo sh -c "echo $(UUID) | xargs -i  jq  '.configuration.nodeid = \"{}\"' /etc/fos/plugins/plugin-fdu-kvm/KVM_plugin.json > /tmp/kvm_plugin.tmp && mv /tmp/kvm_plugin.tmp /etc/fos/plugins/plugin-fdu-kvm/KVM_plugin.json"


uninstall:
	sudo systemctl disable fos_kvm
	gpasswd -d fos kvm
	gpasswd -d fos libvirtd
	sudo rm -rf /etc/fos/plugins/plugin-fdu-kvm
	sudo rm -rf /var/fos/kvm
	sudo rm /lib/systemd/system/fos_kvm.service
