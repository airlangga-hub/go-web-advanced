-include .env
export

MIGRATIONS_DIR := ./migrations

.PHONY: migrations/new migrations/up migrations/status migrations/down

migrations/new:
	@goose -dir ${MIGRATIONS_DIR} create ${name} sql

migrations/up:
	@goose -dir ${MIGRATIONS_DIR} postgres ${DB_DSN} up

migrations/status:
	@goose -dir ${MIGRATIONS_DIR} postgres ${DB_DSN} status

migrations/down:
	@goose -dir ${MIGRATIONS_DIR} postgres ${DB_DSN} down