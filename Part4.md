# Part 4 - API Development<!-- omit from toc -->

This section will focus on the code-aspect of our API. Take note that due to the considerable size of the project, we won't be able to write every single line of code here. Most of the entities will be left out. But necessary annotations and concepts are *definitely* going to be shown here.

Take this as what we are really doing here: A **guide**. So practice, research, and put your knowledge and understanding to the test.

- [Models](#models)
  - [Book](#book)
  - [BookAuthor](#bookauthor)
  - [Author](#author)
- [Repositories](#repositories)
  - [BookRepository](#bookrepository)
- [Services](#services)
  - [BookService](#bookservice)
- [Controllers](#controllers)
  - [BookController](#bookcontroller)
- [Notes](#notes)


## Models

Models are the *OOP* representation of the relational entities inside the database. This includes: foreign keys, attributes and primary keys, alongside some extra things we could come across.

So how exactly do we translate all of this to a `java` class? Very simple:

### Book

```java
import javax.persistence.*;
import java.util.Date;
import java.util.Set;

@Entity
@Table(name = "Book")
public class Book {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "book_id")
    private Long id;

    @Column(name = "name", nullable = false, length = 75)
    private String name;

    @Column(name = "release_date", nullable = false)
    @Temporal(TemporalType.DATE)
    private Date releaseDate;

    @Column(name = "editorial", nullable = false, length = 50)
    private String editorial;

    @Column(name = "edition", nullable = false, length = 30)
    private String edition;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "Genre_genre_id", nullable = false)
    private Genre genre;

    @OneToMany(mappedBy = "book")
    private Set<BookAuthor> bookAuthors;

    @OneToMany(mappedBy = "book")
    private Set<OrderDetail> orderDetails;

    // Constructor with all fields
    public Book(Integer id, String name, Date releaseDate, String editorial, String edition, Genre genre) {
        this.id = id;
        this.name = name;
        this.releaseDate = releaseDate;
        this.editorial = editorial;
        this.edition = edition;
        this.genre = genre;
        this.bookAuthors = new HashSet<>();
        this.orderDetails = new HashSet<>();
    }

    // Default constructor
    public Book() {
        this.bookAuthors = new HashSet<>();
        this.orderDetails = new HashSet<>();
    }

    // getters and setters, and toString (optional) and other methods...
}

```

Note the following:

- The `@Entity` annotation specifies that this class is a **JPA entity.**
- The `@Table` annotation specifies the name of the table as it is in the database.
- The `@Id` and `@GeneratedValue` annotations are used to specify the primary key and its generation strategy.
- The `@Column` annotations are used to specify the *details of each column* as they are in our database.
- The `@ManyToOne` and `OneToMany` annotations are used to specify the *relationships* between `Book` and other entities like `Genre`, `BookAuthor`, and `OrderDetail`. `BookAuthor` and `OrderDetail` are hypothetical intermediate entities that would represent the many-to-many relationships managed by `Book_has_Author` and `Order_has_Book` tables respectively.
- The `@Temporal` annotation is used with Date fields to specify the SQL date type.

This current model structure assumes the existence of other model classes (`Genre, BookAuthor, OrderDetail`) which we'll need to define.

### BookAuthor

This model will represent the pivot table in our database. Take special note of how the foreign keys are handled since they depend on other tables' primary keys.

```java
// imports

@Entity
@Table(name = "Book_has_Author")
public class BookAuthor {

    @Id
    @ManyToOne
    @JoinColumn(name = "Book_book_id", referencedColumnName = "book_id")
    private Book book;

    @Id
    @ManyToOne
    @JoinColumn(name = "Author_author_id", referencedColumnName = "author_id")
    private Author author;

    // Default constructor
    public BookAuthor() {
    }

    // Parameterized constructor
    public BookAuthor(Book book, Author author) {
        this.book = book;
        this.author = author;
    }
```

- This model doesn't need its own `id` because the combination of `book` and `author` acts as a composite primary key, which is why both are annotated with `@id`.

### Author

```java
// imports

@Entity
@Table(name = "Author")
public class Author {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "author_id")
    private Integer id;

    @Column(name = "first_name", nullable = false, length = 45)
    private String firstName;

    @Column(name = "last_name", nullable = false, length = 70)
    private String lastName;

    @OneToMany(mappedBy = "author")
    private Set<BookAuthor> bookAuthors;

    // Default constructor
    public Author() {
        this.bookAuthors = new HashSet<>();
    }

    // Args constructor
    public Author(Integer id, String firstName, String lastName) {
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.bookAuthors = new HashSet<>();
    }

    // Getters and setters
}

```

- This class includes a `Set<BookAuthor>` to represent the collection of `BookAuthor` entities associated with the `Author`. This basically allows us to show every single `Book` a specific `Author` has "written".
- The `@JoinColumn` annotation is used to specify the **foreign key** column in the `BookAuthor` entity.

## Repositories

The next step is to setup our `BookRepository` so the model can work with `JPA's` methods. Fortunately that's a quick solution and usually these files don't usually have a lot of lines of code.

Create a new `interface` called `BookRepository` inside a *package* dedicated solely for repositories.

No we'll have our `interface` `extend` `JPA's` methods and make them available for us.

### BookRepository

```java
// imports

// This annotation is a marker to indicate that the interface is a repository and a component of the Spring context.
@Repository
public interface BookRepository extends JpaRepository<Book, Long> {
    // No need to define findById(Long id) as it's already provided.

    // Example custom query method
    Optional<Book> findBookByIsbn(String isbn);

    // Additional custom methods as required for your application.
}
```

- Repository Interface: By extending JpaRepository, BookRepository not only inherits methods for basic CRUD operations but also paging and sorting capabilities. The generic parameters `<Book, Long>` indicate that the repository is for the entity Book and the type of its primary key is Long.

You'll need to make a Repository for all entities that will have any CRUD operations executed *through* them.

## Services

Services pretty much handle the logic aspect of implementing both `JPA's` methods and functions alongside how we're going to apply them to the model in question. We setup all necessary CRUD operations to be executed later whenever the controller identfies one from a request.

As with the previous models and repositories, it's almost always about identifying the annotations and relationships.

### BookService

```java
// Service imports

@Service
public class BookService {

    @Autowired
    private BookRepository bookRepository;

    // GET
    public Optional<Book> findBookById(Long id) {
        return bookRepository.findById(id);
    }

    // POST
    public Book saveBook(Book book) {
        return bookRepository.save(book);
    }

    // DELETE
    public void deleteBook(Long id) {
        bookRepository.deleteById(id);
    }

    // PUT
    public Optional<Book> updateBook(Long id, Book bookDetails) {
        return bookRepository.findById(id).map(existingBook -> {
            existingBook.setName(bookDetails.getName());
            existingBook.setReleaseDate(bookDetails.getReleaseDate());
            existingBook.setEditorial(bookDetails.getEditorial());
            existingBook.setEdition(bookDetails.getEdition());
            existingBook.setGenre(bookDetails.getGenre());
            // Save only if there are changes

            return bookRepository.save(existingBook);
        });
    }

    // Aditional GET
    public List<Book> findAllBooks() {
        return bookRepository.findAll();
    }

    // Additional methods for other repository operations can be added here
}

```

- `findBookById(Long id)`: Retrieves a book by its ID using the findById method from the repository.
- `saveBook(Book book)`: Saves a new book or updates an existing book in the repository.
- `deleteBook(Long id)`: Deletes a book by its ID using the deleteById method from the repository.
- `updateBook(Long id, Book bookDetails)`: Updates an existing book by its ID with the provided book details. It uses findById to get the current book data, maps the current book to update its fields, and then saves the updated book back to the repository.
- `findAllBooks()`: Retrieves a list of all books using the findAll method from the repository.

It's also a good practice to implement error and exception handling to methods in case they ever need it or should find some exceptions.

Note that `updateBook()` is configured to update *all* attributes of a `Book` model. So make the necessary adjustments `(conditionals)` in case you'll only update some.

## Controllers

Controllers define which *service* methods will be executed and called whenever an endpoint is being requested by a client. This can either be very simple `GET` requests or complext transactional `POST/PUT` requests, depending on the complexity and size of the application.

### BookController

```java
// imports

@RestController
@RequestMapping("/api/books")
public class BookController {

    private final BookService bookService;

    @Autowired
    public BookController(BookService bookService) {
        this.bookService = bookService;
    }

    // GET /api/books/{id} - Get a book by ID
    @GetMapping("/{id}")
    public ResponseEntity<Book> getBookById(@PathVariable Long id) {
        return bookService.findBookById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    // GET /api/books - Get all books
    @GetMapping
    public List<Book> getAllBooks() {
        return bookService.findAllBooks();
    }

    // POST /api/books - Create a new book
    @PostMapping
    public ResponseEntity<Book> createBook(@RequestBody Book book) {
        Book createdBook = bookService.saveBook(book);
        return ResponseEntity.ok(createdBook);
    }

    // PUT /api/books/{id} - Update a book by ID
    @PutMapping("/{id}")
    public ResponseEntity<Book> updateBook(@PathVariable Long id, @RequestBody Book bookDetails) {
        return bookService.updateBook(id, bookDetails)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    // DELETE /api/books/{id} - Delete a book by ID
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteBook(@PathVariable Long id) {
        bookService.deleteBook(id);
        return ResponseEntity.ok().build();
    }

    // Additional endpoints related to the relationships (if needed):
    // For example, to get all books of a certain genre or books from a certain author

    // GET /api/books/genre/{genreId} - Get books by genre

    // You'll need to write the findBooksByGenreId method inside BookService
    @GetMapping("/genre/{genreId}")
    public ResponseEntity<List<Book>> getBooksByGenre(@PathVariable Long genreId) {
        List<Book> books = bookService.findBooksByGenreId(genreId);
        return books.isEmpty() ? ResponseEntity.notFound().build() : ResponseEntity.ok(books);
    }
    // Add any extra methods you might require

}
```

- `@RequestMapping("/api/books")` annotation is a specification that this controller will handle requests made to the prefix `/api/books`
- CRUD operations are mapped through their respective HTTP syntax:
  - `getAllBooks`
  - `createBook`
  - `updateBook`
  - `deleteBook`
- additional endpoints for `getBooksByGenre` are mere examples.

## Notes

This API handles multiple entities and will play out differently regarding the requirements and specifications. Due to limitations and practical constraints, we won't go further into writing every single `Service` and `Controller`. Instead, check what we've done so far and create them on your own. You're encouraged to build upon this groundwork, crafting the additional components needed to meet your unique requirements.
Remember to check documentation and multiple online resources.
Don't take this as the absolute truth. 

Keep in mind that the strategies discussed here are starting points rather than definitive solutions. The development landscape is dynamic, and best practices evolve. Stay adaptable, be open to new ideas, and don't shy away from reevaluating and improving your codebase as you gain more insights and experience.