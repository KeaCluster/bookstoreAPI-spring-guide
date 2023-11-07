# Part 4 - API Development<!-- omit from toc -->

This section will focus on the code-aspect of our API. Take note that due to the considerable size of the project, we won't be able to write every single line of code here. Most of the entities will be left out. But necessary annotations and concepts are *definitely* going to be shown here.

Take this as what we are really doing here: A **guide**. So practice, research, and put your knowledge and understanding to the test.

- [Models](#models)
  - [Book](#book)
  - [Author](#author)
  - [Genre](#genre)
  - [User](#user)
  - [Order](#order)
  - [OrderHasBook](#orderhasbook)
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

    @OneToMany(mappedBy = "book", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<OrderHasBook> orderHasBooks = new HashSet<>();

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

     // Utility methods to manage bidirectional relationships
    public void addOrder(Order order, int quantity) {
        OrderHasBook.OrderBookId orderBookId = new OrderHasBook.OrderBookId(order.getId(), this.getId());
        OrderHasBook orderHasBook = new OrderHasBook(orderBookId, order, this, quantity);
        orderHasBooks.add(orderHasBook);
        order.getOrderHasBooks().add(orderHasBook);
    }

    public void removeOrder(Order order) {
        for (Iterator<OrderHasBook> iterator = orderHasBooks.iterator(); iterator.hasNext(); ) {
            OrderHasBook orderHasBook = iterator.next();

            if (orderHasBook.getBook().equals(this) && orderHasBook.getOrder().equals(order)) {
                iterator.remove();
                orderHasBook.getOrder().getOrderHasBooks().remove(orderHasBook);
                orderHasBook.setOrder(null);
                orderHasBook.setBook(null);
            }
        }
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

### Genre

```java

@Entity
@Table(name = "Genre")
public class Genre {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "genre_id")
    private Long id;

    @Column(name = "name", nullable = false, length = 45)
    private String name;

    @Column(name = "description", nullable = false, length = 200)
    private String description;

    @OneToMany(mappedBy = "genre", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<Book> books = new HashSet<>();

    // Default constructor
    public Genre() {}

    // Constructor with parameters
    public Genre(String name, String description) {
        this.name = name;
        this.description = description;
    }

    // Methods to add and remove books if necessary
    public void addBook(Book book) {
        books.add(book);
        book.setGenre(this);
    }

    public void removeBook(Book book) {
        books.remove(book);
        book.setGenre(null);
    }

    // Other methods...
}

```

- The `Genre` entity has a one-to-many relationship with the `Book` entity. This is because one genre can be associated with many books, but each book has only one genre.
- The`@OneToMany` annotation is used to declare this relationship, with the `mappedBy` attribute pointing to the `genre` field in the `Book` entity.
- The `addBook` and `removeBook` methods manage the association between `Genre` and `Book`, ensuring the relationship is correctly established or disassociated on both sides when a book is added or removed from a genre.
- The constructors enable the creation of `Genre` instances either with default values or with specific name and description.

### User

```java

// imports
@Entity
@Table(name = "User")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Long id;

    @Column(name = "username", nullable = false, length = 45, unique = true)
    private String username;

    @Column(name = "password", nullable = false, length = 25)
    private String password;

    @Column(name = "email", nullable = false, length = 45, unique = true)
    private String email;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<Order> orders = new HashSet<>();

    // Default constructor
    public User() {}

    // Constructor with parameters
    public User(String username, String password, String email) {
        this.username = username;
        this.password = password;
        this.email = email;
    }

    // Methods to add and remove orders if necessary
    public void addOrder(Order order) {
        orders.add(order);
        order.setUser(this);
    }

    public void removeOrder(Order order) {
        orders.remove(order);
        order.setUser(null);
    }

    // Getters and setters
    // Other methods...
}

```

- There's a `one-to-many` relationship between `User` and `Order`, indicating that a user can have multiple orders.
- The `@OneToMany` relationship is managed with the `mappedBy` attribute, which points to the user field in the `Order` entity.


### Order

```java
// imports

@Entity
@Table(name = "Order")
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "order_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "User_user_id", nullable = false)
    private User user;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<OrderHasBook> orderHasBooks = new HashSet<>();

    // Default constructor
    public Order() {}

    // Constructor with user parameter
    public Order(Long id, User user, Set<OrderHasBook> orderHasBooks) {
		super();
		this.id = id;
		this.user = user;
		this.orderHasBooks = orderHasBooks;
	}

    // Method to add a book to the order
    public void addBook(Book book, int quantity) {
        OrderHasBook.OrderBookId orderBookId = new OrderHasBook.OrderBookId(this.getId(), book.getId());
        OrderHasBook orderHasBook = new OrderHasBook(orderBookId, this, book, quantity);
        this.orderHasBooks.add(orderHasBook);
        book.getOrderHasBooks().add(orderHasBook);
    }

    // Method to remove a book from the order
    public void removeBook(Book book) {
        OrderHasBook.OrderBookId orderBookId = new OrderHasBook.OrderBookId(this.getId(), book.getId());
        OrderHasBook orderHasBook = new OrderHasBook(orderBookId, this, book, 0); // Quantity is not relevant for removal
        book.getOrderHasBooks().remove(orderHasBook);
        this.orderHasBooks.remove(orderHasBook);
        // Explicitly setting the relationships to null is handled by orphanRemoval = true in the @OneToMany annotation
    }


    // Getters and setters
}

```

- Each `Order` is related to a `User`, established by a many-to-one relationship `(@ManyToOne)`.
- The `Order` entity also has a one-to-many relationship with `OrderHasBook`, which is a join table containing the many-to-many relationship between `Order` and Book `entities` with an additional quantity field.
- A **constructor** that accepts a `User` is also provided, which is useful when creating a new `Order` linked to an existing `User`.

### OrderHasBook

This entity will be ajusted to include a composite primary key. This will simplify the implementation of a `@ManyToMany` relationship as well as custom attributes (quantity).

```java
// imports

@Entity
@Table(name = "Order_has_Book")
public class OrderHasBook {

    @EmbeddedId
    private OrderBookId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("orderId")
    @JoinColumn(name = "Order_order_id")
    private Order order;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("bookId")
    @JoinColumn(name = "Book_book_id")
    private Book book;

    @Column(name = "quantity")
    private int quantity;

   public OrderHasBook(OrderBookId id, Order order, Book book, int quantity) {
        this.id = id;
        this.order = order;
        this.book = book;
        this.quantity = quantity;
    }

    public OrderHasBook() {
        // Default constructor
    }

    // Getters and setters

    // Embeddable key class
    @Embeddable
    public static class OrderBookId implements Serializable {

        @Column(name = "Order_order_id")
        private Long orderId;

        @Column(name = "Book_book_id")
        private Long bookId;

        // Default constructor
        public OrderBookId() {}

        // Constructor with parameters
        public OrderBookId(Long orderId, Long bookId) {
            this.orderId = orderId;
            this.bookId = bookId;
        }

        // Getters and setters
    }

    // Other methods...
}

```

This adjustment of a composite key will properly adhere to industry standards and best practices by `JPA`.


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
- We'll only write CRUD operations for `User`, `Author` and `Book` since this is a demo.
- If you want to add `Orders` and/or `Genres` then you might want to add one for those too. 