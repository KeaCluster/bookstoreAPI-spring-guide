# Part 5 - API Services and Controllers<!-- omit from toc -->

This section will focus on implementing both Controllers and Services to our API. Most of the hard-work will be done here as it is very code-intensive

- [Services](#services)
  - [BookService](#bookservice)
  - [AuthorService](#authorservice)
  - [UserService](#userservice)
- [Controllers](#controllers)
  - [BookController](#bookcontroller)
  - [UserController](#usercontroller)
  - [AuthorController](#authorcontroller)
- [Notes](#notes)

## Services

Services pretty much handle the logic aspect of implementing both `JPA's` methods and functions alongside how we're going to apply them to the model in question. We setup all necessary CRUD operations to be executed later whenever the controller identfies one from a request.

As with the previous models and repositories, it's almost always about identifying the annotations and relationships.

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
		// You can throw an exception here instead of the null value
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
	                    book.setReleaseDate(bookDetails.getReleaseDate());
	                    book.setEditorial(bookDetails.getEditorial());
	                    book.setEdition(bookDetails.getEdition());
	                    // Assuming Genre is a managed reference, you may need to set it with the existing Genre entity
	                    // book.setGenre(bookDetails.getGenre());
	                    // Update other fields as needed
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

- This service wil implement methods provided by `JpaRepository` configured in your `BookRepository` *interface*. So all the logic is fortunatelly already defined.

### AuthorService

```java

// imports
@Service
public class AuthorService {

	@Autowired
    private AuthorRepository authorRepository;

    // Method to retrieve all authors
    public List<Author> findAllAuthors() {
        return authorRepository.findAll();
    }

    // Method to find an author by ID
    public Optional<Author> findAuthorById(Long id) {
        return authorRepository.findById(id);
    }

    // Method to save a new author
    public Author saveAuthor(Author author) {
        return authorRepository.save(author);
    }

    // Method to update an existing author
    public Author updateAuthor(Long id, Author authorDetails) {
        return authorRepository.findById(id)
                .map(author -> {
                    author.setFirstName(authorDetails.getFirstName());
                    author.setLastName(authorDetails.getLastName());
                    // Update other fields if necessary
                    return authorRepository.save(author);
                })
                .orElseGet(() -> {
                    authorDetails.setId(id);
                    return authorRepository.save(authorDetails);
                });
    }

    // Method to delete an author
    public void deleteAuthor(Long id) {
        authorRepository.deleteById(id);
    }
}

```

- As you can see, there aren't many changes from one service to another. So this a rather fast-forward section of development.

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
                    user.setPassword(userDetails.getPassword());
                    user.setEmail(userDetails.getEmail());
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

Controllers define which *service* methods will be executed and called whenever an endpoint is being requested by a client. This can either be very simple `GET` requests or complext transactional `POST/PUT` requests, depending on the complexity and size of the application.

### BookController

```java

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

You can uncomment and implement the `searchBooks` method if you want to add a custom search operation, depending on your requirements. Ensure you replace `com.yourpackage.model` and `com.yourpackage.service` with your actual package names, and modify the `@RequestMapping` value to match your API's URL structure.

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

- Note that the `deleteUser` method in the service is expected to return a boolean indicating whether the deletion was successful. The controller will respond with a `200 OK status` if the user was successfully deleted or a `404 Not Found status` if there was no user with the provided ID.
  - You can add this as a *'verification'* method although it insn't verifying anything with great complexity.

### AuthorController

```java

// imports

@RequestMapping(path="/api/authors")
@RestController
public class AuthorController {


    private AuthorService authorService;

    @Autowired
    public AuthorController(AuthorService authorService) {
		super();
		this.authorService = authorService;
	}

	// GET all authors
    @GetMapping
    public List<Author> getAllAuthors() {
        return authorService.findAllAuthors();
    }

    // GET a single author by id
    @GetMapping("/{id}")
    public ResponseEntity<Author> getAuthorById(@PathVariable Long id) {
        return authorService.findAuthorById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // POST a new author
    @PostMapping
    public Author createAuthor(@RequestBody Author author) {
        return authorService.saveAuthor(author);
    }

    // PUT to update an author
    @PutMapping("/{id}")
    public ResponseEntity<Author> updateAuthor(@PathVariable Long id, @RequestBody Author authorDetails) {
        Author updatedAuthor = authorService.updateAuthor(id, authorDetails);
        if(updatedAuthor != null) {
            return ResponseEntity.ok(updatedAuthor);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // DELETE an author
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAuthor(@PathVariable Long id) {
        authorService.deleteAuthor(id);
        return ResponseEntity.ok().build();
    }

}

```

- As you can see they're all very similar files so long as you're sticking to standard CRUD requests.

## Notes

This API handles multiple entities and will play out differently regarding the requirements and specifications. Due to limitations and practical constraints, we won't go further into writing every single `Service` and `Controller`. Instead, check what we've done so far and create them on your own. You're encouraged to build upon this groundwork, crafting the additional components needed to meet your unique requirements.
Remember to check documentation and multiple online resources.
Don't take this as the absolute truth. 

Keep in mind that the strategies discussed here are starting points rather than definitive solutions. The development landscape is dynamic, and best practices evolve. Stay adaptable, be open to new ideas, and don't shy away from reevaluating and improving your codebase as you gain more insights and experience.