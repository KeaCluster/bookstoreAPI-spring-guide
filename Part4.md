# Part 4 - API Development<!-- omit from toc -->

This section will focus on the code-aspect of our API. Take note that due to the considerable size of the project, we won't be able to write every single line of code here. Most of the entities will be left out. But necessary annotations and concepts are *definitely* going to be shown here.

Take this as what we are really doing here: A **guide**. So practice, research, and put your knowledge and understanding to the test.

- [Models](#models)
  - [Book](#book)
  - [BookAuthor](#bookauthor)
  - [Author](#author)
- [Controllers](#controllers)
- [Repositories](#repositories)
- [Services](#services)


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

## Controllers

## Repositories

## Services
