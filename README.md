# Advanced Go Web App
This project implements advanced patterns for Golang Web Application, including:
* Full-text search with PostgreSQL
* IP-based rate limiter
* Safe concurrency
* Permission-based authorization
* Sending emails
* Pagination & filtering

# Project Structure
Below is the directory structure of this project:
```bash
.
├── cmd
│   ├── api
│   │   ├── context.go # set and get request context
│   │   ├── errors.go # error response
│   │   ├── healthcheck.go # handler
│   │   ├── helpers.go
│   │   ├── main.go
│   │   ├── middleware.go
│   │   ├── movies.go # handler
│   │   ├── routes.go # routes registration
│   │   ├── server.go # start server and graceful shutdown
│   │   ├── tokens.go # handler
│   │   └── users.go # handler
│   └── examples # dummy clients
│       └── cors
│           ├── preflight
│           │   └── main.go
│           └── simple
│               └── main.go
├── internal
│   ├── data # database operations
│   │   ├── filter.go # for pagination and filtering
│   │   ├── models.go # to be injected into app
│   │   ├── movies.go
│   │   ├── permissions.go
│   │   ├── runtime.go
│   │   ├── tokens.go
│   │   └── users.go
│   ├── mailer # sending emails
│   │   ├── mailer.go
│   │   └── templates # email templates
│   │       └── user_welcome.tmpl
│   ├── validator # struct validator
│   │   └── validator.go
│   └── vcs # show build version
│       └── vcs.go
├── migrations # sql migrations managed with goose
│   ├── 20260422110424_create_movies_table.sql
│   ├── 20260422111858_add_movies_check_constraint.sql
│   ├── 20260424005456_add_movies_indexes.sql
│   ├── 20260424062316_create_users_table.sql
│   ├── 20260427015410_create_tokens_table.sql
│   └── 20260428234559_add_permissions.sql
└── remote # for deployment
    ├── production
    │   └── api.service
    └── setup
        └── 01.sh
```

# Tech Stack
* Go
* PostgreSQL
* Goose