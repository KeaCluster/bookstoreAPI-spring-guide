# Part 4 - API Development<!-- omit from toc -->

This section will focus on the code-aspect of our API. Take note that due to the considerable size of the project, we won't be able to write every single line of code here. Most of the entities will be left out. But necessary annotations and concepts are *definitely* going to be shown here.

Take this as what we are really doing here: A **guide**. So practice, research, and put your knowledge and understanding to the test.

- [Models](#models)
  - [Book](#book)
  - [Author](#author)
- [Repositories](#repositories)
  - [BookRepository](#bookrepository)


## Models

Models are the *OOP* representation of the relational entities inside the database. This includes: foreign keys, attributes and primary keys, alongside some extra things we could come across.

So how exactly do we translate all of this to a `java` class? Very simple:

### Book

```java

// imports
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

    @ManyToMany
    @JoinTable(
        name = "Book_has_Author",
        joinColumns = @JoinColumn(name = "Book_book_id"),
        inverseJoinColumns = @JoinColumn(name = "Author_author_id")
    )
    private Set<Author> authors;

    @OneToMany(mappedBy = "book")
    private Set<OrderHasBook> orderHasBooks;

    // Default constructor
    public Book() {}

    // Constructor without ID for new book creation
    public Book(String name, Date releaseDate, String editorial, String edition, Genre genre) {
        this.name = name;
        this.releaseDate = releaseDate;
        this.editorial = editorial;
        this.edition = edition;
        this.genre = genre;
    }

    // Full constructor including ID
    public Book(Long id, String name, Date releaseDate, String editorial, String edition, Genre genre) {
        this.id = id;
        this.name = name;
        this.releaseDate = releaseDate;
        this.editorial = editorial;
        this.edition = edition;
        this.genre = genre;
    }
    // Getters and setters...
}
```

Note the following:

- The `@Entity` annotation specifies that this class is a **JPA entity.**
- The `@Table` annotation specifies the name of the table as it is in the database.
- The `@Id` and `@GeneratedValue` annotations are used to specify the primary key and its generation strategy.
- The `@Column` annotations are used to specify the *details of each column* as they are in our database.
- The `@ManyToOne` and `OneToMany` annotations are used to specify the *relationships* between `Book` and other entities like `Genre`, `BookAuthor`, and `OrderDetail`. `BookAuthor` and `OrderDetail` are hypothetical intermediate entities that would represent the many-to-many relationships managed by `Book_has_Author` and `Order_has_Book` tables respectively.
- The `@Temporal` annotation is used with Date fields to specify the SQL date type.

This current model structure assumes the existence of other model classes (`Genre, OrderDetail`) which we'll need to define.

### Author

```java
// imports
import javax.persistence.*;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "Author")
public class Author {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "author_id")
    private Long id;

    @Column(name = "first_name", nullable = false, length = 45)
    private String firstName;

    @Column(name = "last_name", nullable = false, length = 70)
    private String lastName;

    @ManyToMany(mappedBy = "authors")
    private Set<Book> books = new HashSet<>();

    // Default constructor
    public Author() {}

    // Constructor with parameters
    public Author(String firstName, String lastName) {
        this.firstName = firstName;
        this.lastName = lastName;
    }

    // Methods to add and remove books
    public void addBook(Book book) {
        this.books.add(book);
        book.getAuthors().add(this);
    }

    public void removeBook(Book book) {
        this.books.remove(book);
        book.getAuthors().remove(this);
    }

    // getters and setters

    // Other methods...
}

```

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