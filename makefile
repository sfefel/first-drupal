# Useful things for Drupal projects

default: up

DRUPAL_ROOT ?= /var/www/site/docroot
PROJECT_ROOT ?= /var/www/site
IMAGE_NAME = first-drupal

# Spin up the docker container as defined in the docker-compose.yaml
up:
	docker-compose up -d

# Spin down the docker container when you're no longer needing this as a local site
down:
	docker-compose down

# This will do everything that is needed to get your site up and running for the first time
# Right now spins up container, then makes sure all composer dependencies are downloaded
first-launch:
	make up
	make install-dependencies

# Rebuilds the Drupal cache, useful anytime you make template changes or edit module files
cache-rebuild:
	docker exec -ti -w $(PROJECT_ROOT) $(IMAGE_NAME) /bin/bash -ci "drupal cr all"

# Install all dependencies defined in the composer.json
install-dependencies:
	docker exec -ti -w $(PROJECT_ROOT) $(IMAGE_NAME) /bin/bash -ci "composer install"

# Example command looks like "make require-module module=recaptcha"
require-module:
	docker exec -ti -w $(PROJECT_ROOT) $(IMAGE_NAME) /bin/bash -ci "composer require drupal/$(module)"

# Example command looks like "make remove-module module=recaptcha"
remove-module:
	docker exec -ti -w $(PROJECT_ROOT) $(IMAGE_NAME) /bin/bash -ci "drupal module:uninstall $(module)"
	docker exec -ti -w $(PROJECT_ROOT) $(IMAGE_NAME) /bin/bash -ci "composer remove drupal/$(module)"

# Example command looks like "make install-module module=recaptcha"
install-module:
	docker exec -ti -w $(PROJECT_ROOT) $(IMAGE_NAME) /bin/bash -ci "drupal module:install $(module)"

# If you put the db you want in the root of the project and run this command it will import that database
# the database filename must be starter.sql and in the root of this repo
# WARNING: You will lose any local changes you have made
import-db:
	docker-compose down
	sudo rm -Rf ../sites-databases/$(IMAGE_NAME)
	docker-compose up -d

# See all the logs of the docker container, useful for finding PHP errors
logs:
	docker logs $(IMAGE_NAME) -f

# Export the config from the DB into config files
config-export:
	docker exec -ti -w $(DRUPAL_ROOT) $(IMAGE_NAME) /bin/bash -ci "drush config-export"

# import the config from config files into the DB
config-import:
	docker exec -ti -w $(DRUPAL_ROOT) $(IMAGE_NAME) /bin/bash -ci "drush config-import"

setup-config:
	docker exec -ti -w $(DRUPAL_ROOT) $(IMAGE_NAME) /bin/bash -ci "cp -R config_split/* config/default/default/. && drush config-import"
