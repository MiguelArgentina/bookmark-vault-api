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