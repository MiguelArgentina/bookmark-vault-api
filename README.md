 # Endpoints
## Auth
- POST /v1/auth/signup
- POST /v1/auth/login
- POST /v1/auth/refresh
- POST /v1/auth/logout

## Bookmarks
- GET /v1/bookmarks
- POST /v1/bookmarks
- GET /v1/bookmarks/:id
- PATCH /v1/bookmarks/:id
- DELETE /v1/bookmarks/:id

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