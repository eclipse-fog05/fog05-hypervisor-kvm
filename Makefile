# -*-Makefile-*-

WD := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))));
UUID = $(shell ./to_uuid.sh)
KVM_PLUGIN_DIR = /etc/fos/plugins/plugin-fdu-kvm
KVM_PLUGIN_CONFFILE = $(KVM_PLUGIN_DIR)/KVM_plugin.json
SYSTEMD_DIR = /lib/systemd/system/

all:
	echo "Nothing to do"

clean:
	echo "Nothing to do"

install:
	sudo usermod -aG kvm fos
	sudo usermod -aG libvirt fos
ifeq "$(wildcard $(KVM_PLUGIN_DIR))" ""
	mkdir -p $(KVM_PLUGIN_DIR)
	sudo cp -r ./templates $(KVM_PLUGIN_DIR)
	sudo cp ./__init__.py $(KVM_PLUGIN_DIR)
	sudo cp ./KVM_plugin $(KVM_PLUGIN_DIR)
	sudo cp ./KVMFDU.py $(KVM_PLUGIN_DIR)
	sudo cp ./README.md $(KVM_PLUGIN_DIR)
	sudo cp ./KVM_plugin.json $(KVM_PLUGIN_DIR)
else
	sudo cp -r ./templates $(KVM_PLUGIN_DIR)
	sudo cp ./__init__.py $(KVM_PLUGIN_DIR)
	sudo cp ./KVM_plugin $(KVM_PLUGIN_DIR)
	sudo cp ./KVMFDU.py $(KVM_PLUGIN_DIR)
	sudo cp ./README.md $(KVM_PLUGIN_DIR)

endif
	sudo cp ./fos_kvm.service $(SYSTEMD_DIR).
	sudo sh -c "uname -r | xargs -i jq '.configuration.arch = \"{}\"' $(KVM_PLUGIN_CONFFILE) > /tmp/kvm_plugin.tmp && mv /tmp/kvm_plugin.tmp $(KVM_PLUGIN_CONFFILE)"
	sudo sh -c "uname -r | xargs -i jq '.configuration.emulator = \"/usr/bin/qemu-system-{}\"' $(KVM_PLUGIN_CONFFILE) > /tmp/kvm_plugin.tmp && mv /tmp/kvm_plugin.tmp $(KVM_PLUGIN_CONFFILE)"
	sudo sh -c "echo $(UUID) | xargs -i  jq  '.configuration.nodeid = \"{}\"' $(KVM_PLUGIN_CONFFILE) > /tmp/kvm_plugin.tmp && mv /tmp/kvm_plugin.tmp $(KVM_PLUGIN_CONFFILE)"


uninstall:
	sudo systemctl disable fos_kvm
	gpasswd -d fos kvm
	gpasswd -d fos libvirtd
	sudo rm -rf /etc/fos/plugins/plugin-fdu-kvm
	sudo rm -rf /var/fos/kvm
	sudo rm /lib/systemd/system/fos_kvm.service
