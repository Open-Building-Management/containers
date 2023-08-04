# Emoncms module makefile
# Copyright (C) 2021 Alexandre Cuer <alexandre.cuer at cerema dot fr>

.PHONY: help

www := /var/www
emoncms_www := $(www)/emoncms
emoncms_dir := /opt/emoncms

createDBupdatefile:
	@printf "<?php\n" > emoncmsdbupdate.php
	@printf "%sapplychanges = true;\n" $$ >> emoncmsdbupdate.php
	@printf "define('EMONCMS_EXEC', 1);\n" >> emoncmsdbupdate.php
	@printf "chdir('$(emoncms_www)');\n" >> emoncmsdbupdate.php
	@printf "require 'process_settings.php';\n" >> emoncmsdbupdate.php
	@printf "require 'core.php';\n" >> emoncmsdbupdate.php
	@printf "%smysqli = @new mysqli(\n" $$ >> emoncmsdbupdate.php
	@printf "    %ssettings['sql']['server'],\n" $$ >> emoncmsdbupdate.php
	@printf "    %ssettings['sql']['username'],\n" $$ >> emoncmsdbupdate.php
	@printf "    %ssettings['sql']['password'],\n" $$ >> emoncmsdbupdate.php
	@printf "    %ssettings['sql']['database'],\n" $$ >> emoncmsdbupdate.php
	@printf "    %ssettings['sql']['port']\n" $$ >> emoncmsdbupdate.php
	@printf ");\n" >> emoncmsdbupdate.php
	@printf "require_once 'Lib/dbschemasetup.php';\n" >> emoncmsdbupdate.php
	@printf "print json_encode(db_schema_setup(%smysqli,load_db_schema(),%sapplychanges)).'%s';" $$ $$ "\n" >> emoncmsdbupdate.php

module:
	@$(MAKE) --no-print-directory createDBupdatefile
	@if [ ! -d "$(emoncms_www)/Modules/$(name)" ]; then\
		echo "Installing module $(name)";\
		cd $(emoncms_www)/Modules && git clone -b stable https://github.com/emoncms/$(name);\
	fi
	@echo "update emoncms database"
	@php emoncmsdbupdate.php

symodule:
	@mkdir -p $(emoncms_dir)/modules
	@$(MAKE) --no-print-directory createDBupdatefile
	@if [ ! -d "$(emoncms_dir)/modules/$(name)" ]; then\
		echo "Installing module $(name)";\
		cd $(emoncms_dir)/modules && git clone -b stable https://github.com/emoncms/$(name);\
	fi
	@if [ -d $(emoncms_dir)/modules/$(name)/$(name)-module ]; then\
        	echo "symlinking IU directory";\
        	ln -s $(emoncms_dir)/modules/$(name)/$(name)-module $(emoncms_www)/Modules/$(name);\
	fi
	@if [ -f $(emoncms_dir)/modules/$(name)/install.sh ]; then\
		echo "running install script";\
		$(emoncms_dir)/modules/$(name)/install.sh $(openenergymonitor_dir);\
        fi
	@echo "update emoncms database"
	@php emoncmsdbupdate.php
