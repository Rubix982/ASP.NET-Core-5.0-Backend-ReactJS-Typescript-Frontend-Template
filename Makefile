# PRODUCTION

## Stop all containers
stop:
	@ docker container stop $(docker ps -aq)

## Remove all containers
delete:
	@ docker container rm $(docker ps -aq)

# DEVELOPMENT

## Temporarily shut down containers
remove:
	@ sudo docker-compose down --remove-orphans

## Build containers from scratch
build:
	@ sudo docker-compose -f docker-compose.dev.yml up --build

## Start temporarily stopped containers again
up:
	@ sudo docker-compose -f docker-compose.dev.yml up

## List all containers currently present
ps:
	@ sudo docker-compose ps -a

# CONTAINERS

## Client container
client-con:
	@ sudo docker exec -it client bash

## Backend container
backend-con:
	@ sudo docker exec -it backend bash

## Web Server Container
web-server-con:
	@ sudo docker exec -it web-server bash

## PostGre Container
primary-con:
	@ sudo docker exec -it primary bash

## MongoDB Container
secondary-con:
	@ sudo docker exec -it secondary bash

## Cache container
cache-con:
	@ sudo docker exec -it cache bash

## SSH to containers
ssh:
	@ ssh `grep 'deploy_user=' ./ansible/hosts | tail -n1 | awk -F'=' '{ print $2}'`@`awk 'f{print;f=0} /[production]/{f=1}' ./ansible/hosts | head -n 1

# TESTING

## Testing Server And Client
test:
	@ echo "------------------"
	@ echo "Testing For Server"
	@ echo "------------------"
	@ cd ./Tests/server/
	@ dotnet test
	@ echo "------------------"
	@ echo "Testing For Client"
	@ echo "------------------"
	@ cd ../../
	@ ./client/node_modules/jest/node_modules/.bin/jest ./client/src/tests/App.test.tsx

lint:
	@ echo "Linting client ... "
	@ ./node_modules/.bin/eslint ./client/

lint-fix:
	@ echo "Running prettier and eslint on client for possible fix ... "
	@ ./node_modules/.bin/prettier --write ./client/src/**/*.ts{,x}
	@ ./node_modules/.bin/eslint ./client/ --fix

# DOTNET

## Make pre release for the project
prerelease:
	@ npm run --prefix client webpack:build
	@ ./node_modules/.bin/cross-env ASPNETCORE_ENVIRONMENT=Production
	@ cd ./server/ && dotnet publish -c Release

## After making a pre release
postinstall:
	@ dotnet restore ./server/

## Create migration
migrate:
	# TODO: Create script to migrate database for server
	@ cd ./server/ 
	# @ node ./Scripts/create-migration.js 
	@ dotnet ef database update

# ANSIBLE

## Provision Containers
provision:
	@ ansible-playbook -l production -i ./ansible/config.yml ./ansible/provision.yml

## Deploy to containers
deploy:
	@ npm run prerelease 
	@ ansible-playbook -l production -i ./ansible/config.yml ./ansible/deploy.yml