# Part 5 - API Services and Controllers

<!--toc:start-->

- [Services](#services)
- [BookService](#bookservice)
- [AuthorService](#authorservice)
- [UserService](#userservice)
- [Controllers](#controllers)
- [BookController](#bookcontroller)
- [UserController](#usercontroller)
- [AuthorController](#authorcontroller)
- [Notes](#notes)

<!--toc:end-->

This section will focus on implementing both Controllers and Services to our API.
Most of the hard-work will be done here as it is very code-intensive

## Services

Services pretty much handle the logic aspect of the application.
Implementing both `JPA's` methods and functions,
alongside how we're going to apply them to the model in question.
We setup all CRUD operations to be executed whenever the controller gets a request.

As with the previous models and repositories,
it's almost always about identifying the proper annotations and relationships.

### BookService

```java

// imports
@Service
public class BookService {

  @Autowired
  private BookRepository bookRepository;

  // Get
  public List<Book> getAllBooks() {
    return bookRepository.findAll();
  }

  // Get one by Id
  public Book getBookById(Long id) {
    return bookRepository.findById(id).orElse(null);
  }

  // Post
  public Book createBook(Book book) {
    return bookRepository.save(book);
  }

  // Put
  public Book updateBook(Long id, Book bookDetails) {
    return bookRepository.findById(id)
    .map(book -> {
      book.setName(bookDetails.getName());
      return bookRepository.save(book);
    })
    .orElseGet(() -> {
      bookDetails.setId(id);
      return bookRepository.save(bookDetails);
    });
  }

  // Delete
  public void deleteBook(Long id) {
    bookRepository.deleteById(id);
  }

}
```

This service will implement methods provided by `JpaRepository`.
Configured in your `BookRepository` _interface_.

Most basic logic is already defined.

> As you can see, there aren't many changes from one service to another.
> So this a rather fast-forward section of development.

### UserService

```java
// imports

@Service
public class UserService {

  @Autowired
  private UserRepository userRepository;

  // Method to retrieve all users
  public List<User> findAllUsers() {
    return userRepository.findAll();
  }

  // Method to find a user by ID
  public Optional<User> findUserById(Long id) {
    return userRepository.findById(id);
  }

  // Method to create a new user
  public User saveUser(User user) {
    return userRepository.save(user);
  }

  // Method to update an existing user
  public User updateUser(Long id, User userDetails) {
    return userRepository.findById(id)
    .map(user -> {
      user.setUsername(userDetails.getUsername());
      // use other attributes here if any exist
      return userRepository.save(user);
    })
    .orElseGet(() -> {
      userDetails.setId(id);
      return userRepository.save(userDetails);
    });
  }

  // Method to delete a user
  public boolean deleteUser(Long id) {
    userRepository.deleteById(id);
    return true;
    // returns a boolean
    // you'll see why in the controller
  }
}

```

## Controllers

Controllers define which `service` methods will execute
whenever an endpoint is being requested by a client.
These can be very simple `GET` requests or complex transactional `POST/PUT`,
depending on the complexity and size of the app.

### BookController

```java
// Set up which url endpoint will handle these requests
@RequestMapping(path="/api/books")
@RestController
public class BookController {

  private BookService bookService;

  @Autowired
  public BookController(BookService bookService) {
    super();
    this.bookService = bookService;
  }

  // GET all books
  @GetMapping
  public List<Book> getAllBooks() {
    return bookService.getAllBooks();
  }

  // GET a single book by id
  @GetMapping("/{id}")
  public ResponseEntity<Book> getBookById(@PathVariable Long id) {
    Book book = bookService.getBookById(id);
    if (book != null) {
      return ResponseEntity.ok(book);
    } else {
      return ResponseEntity.notFound().build();
    }
  }

  // POST a new book
  @PostMapping
  public Book createBook(@RequestBody Book book) {
    return bookService.createBook(book);
  }

  // PUT to update a book
  @PutMapping("/{id}")
  public ResponseEntity<Book> updateBook(@PathVariable Long id, @RequestBody Book bookDetails) {
    Book updatedBook = bookService.updateBook(id, bookDetails);
    if (updatedBook != null) {
      return ResponseEntity.ok(updatedBook);
    } else {
      return ResponseEntity.notFound().build();
    }
  }

  // DELETE a book
  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteBook(@PathVariable Long id) {
    Book book = bookService.getBookById(id);
    if (book != null) {
      bookService.deleteBook(id);
      return ResponseEntity.ok().<Void>build();
    } else {
      return ResponseEntity.notFound().build();
    }
  }

  // Additional endpoints for other operations can be added here

  // Example of a custom query endpoint
  // @GetMapping("/search")
  // public ResponseEntity<List<Book>> searchBooks(@RequestParam String query) {
  //     List<Book> books = bookService.searchBooks(query);
  //     return ResponseEntity.ok(books);
  // }
}

```

- `getAllBooks` returns all books.
- `getBookById` fetches a single book by its ID.
- `createBook` handles creating a new book.
- `updateBook` updates an existing book by ID.
- `deleteBook` deletes a book by ID.

You can uncomment the `searchBooks` method if you want to add a custom operation.
Make sure you replace the `@RequestMapping` value to match your API's URL.

### UserController

```java
// imports
@RequestMapping(path="/api/users")
@RestController
public class UserController {

  private UserService userService;

  @Autowired
  public UserController(UserService userService) {
    this.userService = userService;
  }

  // GET all users
  @GetMapping
  public List<User> getAllUsers() {
    return userService.findAllUsers();
  }

  // GET a single user by id
  @GetMapping("/{id}")
  public ResponseEntity<User> getUserById(@PathVariable Long id) {
    return userService.findUserById(id)
    .map(ResponseEntity::ok)
    .orElse(ResponseEntity.notFound().build());
  }

  // POST a new user
  @PostMapping
  public User createUser(@RequestBody User newUser) {
    return userService.saveUser(newUser);
  }

  // PUT to update a user
  @PutMapping("/{id}")
  public ResponseEntity<User> updateUser(@PathVariable Long id, @RequestBody User userDetails) {
    User updatedUser = userService.updateUser(id, userDetails);
    if (updatedUser != null) {
      return ResponseEntity.ok(updatedUser);
    } else {
      return ResponseEntity.notFound().build();
    }
  }

  // DELETE a user
  @DeleteMapping("/{id}")
  public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
    boolean wasDeleted = userService.deleteUser(id);
    if (wasDeleted) {
      return ResponseEntity.ok().build();
    } else {
      return ResponseEntity.notFound().build();
    }
  }

  // Additional endpoints for other operations can be added here
}

```

- Note that the `deleteUser` method in the service is expected to return a boolean.
  - This will indicate whether the deletion was successful.
  - The api will return a `200` if successfull or a `404` if there was no user found.
- You can add this as a _'verification'_ method although it's not verifying anything with great complexity or robustness.

## Notes

This API handles multiple entities and will look differently depending on your requirements.

Due to limitations and practical constraints,
we won't go further into writing every single `Service` and `Controller`.
Instead, check what we've done so far and create them on your own.

You're encouraged to build upon this groundwork, crafting the additional components needed to meet your unique requirements.

Remember to check documentation and multiple online resources.
**Don't take this as the absolute truth.**

Keep in mind that the strategies discussed here are starting points,
rather than definitive solutions.
The development landscape is dynamic, and best practices evolve.
Stay adaptable, be open to new ideas,
and don't shy away from reevaluating and improving your codebase as you gain more insights and experience.
