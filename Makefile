#### Variables ####
export ROOT_DIR ?= $(PWD)
export COCO_ROOT_DIR ?= $(ROOT_DIR)
export ANSIBLE_NAME ?= ansible-coco
export HOSTS_INI_FILE ?= $(COCO_ROOT_DIR)/hosts.ini
export EXTRA_VARS ?= ""

#### Start Ansible docker ####
coco-ansible:
	export ANSIBLE_NAME=$(ANSIBLE_NAME); \
	sh $(COCO_ROOT_DIR)/scripts/ansible ssh-agent bash

#### a. Debugging ####
coco-debug:
	ansible-playbook -i $(HOSTS_INI_FILE) $(COCO_ROOT_DIR)/debug.yml \
		--extra-vars "ROOT_DIR=$(ROOT_DIR)" --extra-vars $(EXTRA_VARS)

#### b. Provision CoCo ####
coco-install:
	ansible-playbook -i $(HOSTS_INI_FILE) $(COCO_ROOT_DIR)/coco.yml --tags install \
		--extra-vars "ROOT_DIR=$(ROOT_DIR)" --extra-vars $(EXTRA_VARS)

coco-uninstall:
	ansible-playbook -i $(HOSTS_INI_FILE) $(COCO_ROOT_DIR)/coco.yml --tags uninstall \
		--extra-vars "ROOT_DIR=$(ROOT_DIR)" --extra-vars $(EXTRA_VARS)
