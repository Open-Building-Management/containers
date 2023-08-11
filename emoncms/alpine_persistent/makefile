# Emoncms module makefile
# Copyright (C) 2021 Alexandre Cuer <alexandre.cuer at cerema dot fr>

.PHONY: help

www := /var/www
emoncms_www := $(www)/emoncms
emoncms_dir := /opt/emoncms

module:
	@if [ ! -d "$(emoncms_www)/Modules/$(name)" ]; then\
		echo "Installing module $(name)";\
		cd $(emoncms_www)/Modules && git clone -b stable https://github.com/emoncms/$(name);\
	fi

symodule:
	@mkdir -p $(emoncms_dir)/modules
	@if [ ! -d "$(emoncms_dir)/modules/$(name)" ]; then\
		echo "Installing module $(name)";\
		cd $(emoncms_dir)/modules && git clone -b stable https://github.com/emoncms/$(name);\
	fi
	@if [ -d $(emoncms_dir)/modules/$(name)/$(name)-module ]; then\
        	echo "symlinking IU directory";\
        	ln -s $(emoncms_dir)/modules/$(name)/$(name)-module $(emoncms_www)/Modules/$(name);\
	fi
