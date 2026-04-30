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

## tidy: tidy module dependencies and format all .go files
.PHONY: tidy
tidy:
	@echo 'Tidying module dependencies...'
	go mod tidy
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