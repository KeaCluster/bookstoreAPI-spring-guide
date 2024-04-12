# Part 6 Writing Controllers

<!--toc:start-->

- [Part 6 Writing Controllers](#part-6-writing-controllers)
  - [Book Controller](#book-controller)
    - [ResponseEntity](#responseentity)
  - [CORS](#cors)
    - [How to CORS](#how-to-cors)
  - [Notes](#notes)

<!--toc:end-->

Controllers define which `service` methods will execute
whenever an endpoint is being requested by a client.
These can be very simple `GET` requests or complex transactional `POST/PUT`,
depending on the complexity and size of the app.

## Book Controller

```java
@RestController
@RequestMapping("/api/books/")
public class BookController {
  @Autowired
  private BookService bookService;

  @GetMapping
  public List<Book> getAllBooks() {
    return bookService.findAllBooks();
  }

  @GetMapping("{id}")
  public ResponseEntity<Book> getBookById(@PathVariable Integer id) {
    return bookService.findBookById(id)
    .map(ResponseEntity::ok)
    .orElse(ResponseEntity.notFound().build());
  }

  @PostMapping
  public Book createBook(@RequestBody Book book) {
    return bookService.saveBook(book);
  }

  @DeleteMapping("{id}")
  public ResponseEntity<Void> deleteBook(@PathVariable Integer id) {
    return bookService.findBookById(id)
    .map(book -> {
      bookService.deleteBook(book.getId());
      return ResponseEntity.ok().<Void>build();
    })
    .orElse(ResponseEntity.notFound().build());
  }
}
```

### ResponseEntity

This is (as weird as it sounds) a `type` inside of Java.
It represents a complete HTTP response, including headers, status and body.

It allows us to control the response of our requests by
sending the client specific things depending on our code's specifications.

## CORS

If you know about `CORS` then you know about `cors`.
Such a simple thing but can sometimes freak us out a little.

They're basically a protocol/mechanism that allows an application hosted somewhere
to interact with another application hosted somewhere else.

For local development such as what we usually do, this isn't that hard to handle
since everything is usually inside `localhost` or a local container.

Once you reach deployment and the such, `CORS` can come in handy to manage and control
petitions from multiple sources such as our `API` in, say, an `AWS container`, and
our `front-end` application hosted in a platform like vercel. (Making things up here)

### How to CORS

Rather simple.

We can add this annotation in our `controller` right after we declare our `RequestMapping`:

```java
@CrossOrigin(origins="*", methods={
  RequestMethod.GET,
  RequestMethod.POST,
  RequestMethod.PUT,
  RequestMethod.DELETE
 })
```

Or, to have more control, we can write a separate class and declare everything there.
`CORS` is a complex subject with plenty of documentation.
You can customize it a lot.

```java
@Configuration
public class CorsConfig implements WebMvcConfigurer {

  @Override
  public void addCorsMappings(CorsRegistry registry) {
    registry.addMapping("/api/**")
      .allowedOrigins("*")
      .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS", "HEAD", "TRACE", "CONNECT");
  }
}
```

Check external resources for more info

- [CORS + RESTful + SPRING](https://spring.io/guides/gs/rest-service-cors)

## Notes

Honestly other controllers might look similar depending on what you need.
This is an example and as such, you might not need every line of code.

Adapt instead of copying the code. Improve from your own codebase.
