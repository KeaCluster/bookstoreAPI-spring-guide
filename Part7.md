# Part 7 Tests

<!--toc:start-->

- [Part 7 Tests](#part-7-tests)
  - [Tests](#tests)
    - [Postman](#postman)
      - [Books](#books)

<!--toc:end-->

## Tests

### Postman

Try using postman to add, get, delete and update one or more of our entities
through requests.

#### Books

- METHOD: POST
- URL: `http://localhost:{PORT}/api/books/`
- Body (raw JSON):

```json
{
  "name": "Frankenstein",
  "author": "Mary W Shelly",
  "stock": 3,
  "price": 29.99
}
```

- METHOD: PUT
- URL: `http://localhost:{PORT}/api/books/{bookid}`
  - Replace `bookid` with an actual existing ID.
- Body (raw JSON):

```json
{
  "title": "Updated Book Title",
  "author": "Updated Author Name",
  "stock": 15,
  "price": 25.99
}
```

- METHOD: DELETE
- URL: `http://localhost:{PORT}/api/books/{bookId}`
  - replace {bookId} with the actual ID of the book you want to delete.
  - If no book with that ID exists, check the response.
- Headers: None required for this simple example.
- Body: None
