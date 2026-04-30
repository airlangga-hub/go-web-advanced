-include .env
export

MIGRATIONS_DIR := ./migrations

# ==================================================================================== #
# HELPERS
# ==================================================================================== #

## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

.PHONY: confirm
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

# ==================================================================================== #
# DEVELOPMENT
# ==================================================================================== #

## migrations/new name=$1: create a new database migration file
.PHONY: migrations/new
migrations/new: confirm
	@goose -dir ${MIGRATIONS_DIR} create ${name} sql

## migrations/up: apply all database migrations
.PHONY: migrations/up
migrations/up: confirm
	@goose -dir ${MIGRATIONS_DIR} postgres ${DB_DSN} up

## migrations/status: view db migrations status
.PHONY: migrations/status
migrations/status:
	@goose -dir ${MIGRATIONS_DIR} postgres ${DB_DSN} status

## migrations/down: roll back all db migrations
.PHONY: migrations/down
migrations/down: confirm
	@goose -dir ${MIGRATIONS_DIR} postgres ${DB_DSN} down

## run/api: run the ./cmd/api/ application
.PHONY: run/api
run/api:
	go run ./cmd/api

# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #

## tidy: tidy and vendor module dependencies and format all .go files
.PHONY: tidy
tidy:
	@echo 'Tidying module dependencies...'
	go mod tidy
	@echo 'Verifying and vendoring module dependencies...'
	go mod verify
	go mod vendor
	@echo 'Formatting .go files...'
	go fmt ./...

## audit: run quality control checks
.PHONY: audit
audit:
	@echo 'Checking module dependencies...'
	go mod tidy -diff
	go mod verify
	@echo 'Vetting code...'
	go vet ./...
	go tool staticcheck ./...
	@echo 'Running tests...'
	go test -race -vet=off ./...

# ==================================================================================== #
# BUILD
# ==================================================================================== #

## build/api: build the cmd/api application
.PHONY: build/api
build/api:
	@echo 'Building cmd/api...'
	go build -ldflags='-s' -o=./bin/api ./cmd/api
	GOOS=linux GOARCH=amd64 go build -ldflags='-s' -o=./bin/linux_amd64/api ./cmd/api

# ==================================================================================== #
# DEPLOYMENT
# ==================================================================================== #

## ssh/gen: generate new ssh keys
.PHONY: ssh/gen
ssh/gen:
	ssh-keygen -t rsa -b 4096 -C "airlangga" -f $HOME/.ssh/id_rsa_deploy

## remote/sync ip=$1: copy script to remote server 
.PHONY: remote/sync
remote/sync:
	rsync -rP --delete ./remote/setup root@${ip}:/root

## production/connect ip=$1: connect to the production server
.PHONY: production/connect
production/connect:
	ssh airlangga@${ip}

## production/deploy/api ip=$1: deploy the api to production
.PHONY: production/deploy/api
production/deploy/api:
	rsync -P ./bin/linux_amd64/api airlangga@${ip}:~
	rsync -rP --delete ./migrations airlangga@${ip}:~
	rsync -P ./remote/production/api.service airlangga@${ip}:~
	ssh -t airlangga@${ip} 'goose -dir ~/migrations postgres $$DB_DSN up && sudo mv ~/api.service /etc/systemd/system/ && sudo systemctl enable api && sudo systemctl restart api'