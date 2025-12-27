# Bookmark Vault API
[![CI](https://github.com/MiguelArgentina/bookmark-vault-api/actions/workflows/ci.yml/badge.svg?branch=main&cache_seconds=60)](https://github.com/MiguelArgentina/bookmark-vault-api/actions/workflows/ci.yml)

Simple Rails API to save bookmarks.
Main goal: show clean code, auth, rate limiting, and tests.

## Features
- JWT access token (Bearer token)
- Refresh token rotation + logout (refresh token is stored as digest in DB, raw token is never stored)
- Bookmarks CRUD, scoped to current user
- Filtering + search + pagination on bookmarks index
- Rate limiting with Rack::Attack
- Request specs for auth, bookmarks, rate limiting

---

# Quickstart

## Requirements
- Ruby 3.3.8
- DB (Postgres in this example)

## Setup
```bash
clone the repo then run:
> bundle install
> bin/rails db:create db:migrate
> bin/rails s
````

# Endpoints
## Auth
- POST /api/v1/register
- POST /api/v1/login
- POST /api/v1/refresh
- POST /api/v1/logout

## Bookmarks (requires Bearer token)
- GET /api/v1/bookmarks
- POST /api/v1/bookmarks
- GET /api/v1/bookmarks/:id
- PATCH /api/v1/bookmarks/:id
- DELETE /api/v1/bookmarks/:id

## Query features
### When making a `GET` request to `/bookmarks`

- Pagination: page, per_page
- Filtering: tag, q (search in title/url)

## Error response format

```json
{
  "error": {
    "code": "validation_error",
    "message": "Email is invalid",
    "details": { "email": ["is invalid"] }
  }
}

```

# Rate limiting (Rack::Attack)

## Current throttles:

- POST /api/v1/login: 2 requests / 20 seconds / IP
- POST /api/v1/register: 5 requests / minute / IP
- POST /api/v1/refresh: 10 requests / minute / IP
- /api/v1/* authenticated requests (excluding auth endpoints): 60 requests / minute / user (sub from JWT), fallback to IP

## Author

👤 &nbsp; **Miguel Ricardo Gomez**

- GitHub: [@MiguelArgentina](https://github.com/MiguelArgentina)
- Twitter: [@Qete_arg](https://twitter.com/Qete_arg)
- LinkedIn: [Miguel Ricardo Gomez](https://www.linkedin.com/in/miguelricardogomez/)

<br>
<br>
<p align="center">
  <a href="https://github.com/MiguelArgentina/bookmark-vault-api/issues">
  <img src="https://img.shields.io/github/issues-raw/MiguelArgentina/bookmark-vault-api?style=for-the-badge"
       alt="Issues"></a>

   <a href="https://github.com/MiguelArgentina/bookmark-vault-api/pulls">
  <img src="https://img.shields.io/github/issues-pr/MiguelArgentina/bookmark-vault-api?style=for-the-badge"
       alt="Pull Requests"></a>

   <a href="https://github.com/MiguelArgentina/bookmark-vault-api/blob/main/LICENSE">
  <img src="https://img.shields.io/github/license/MiguelArgentina/bookmark-vault-api?style=for-the-badge"
       alt="License"></a>
</p>

## Show your support

Give a &nbsp;⭐️ &nbsp; if you like this project!

## Acknowledgments
- Rails
- Rack::Attack
- JWT gem
- RSpec + FactoryBot + Faker