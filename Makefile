-include .env
export

MIGRATIONS_DIR := ./migrations

.PHONY: help confirm migrations/new migrations/up migrations/status migrations/down run/api

## help: print this help message
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

## migrations/new name=$1: create a new database migration file
migrations/new: confirm
	@goose -dir ${MIGRATIONS_DIR} create ${name} sql

## migrations/up: apply all database migrations
migrations/up: confirm
	@goose -dir ${MIGRATIONS_DIR} postgres ${DB_DSN} up

## migrations/status: view db migrations status
migrations/status:
	@goose -dir ${MIGRATIONS_DIR} postgres ${DB_DSN} status

## migrations/down: roll back all db migrations
migrations/down: confirm
	@goose -dir ${MIGRATIONS_DIR} postgres ${DB_DSN} down

## run/api: run the ./cmd/api/ application
run/api:
	go run ./cmd/api