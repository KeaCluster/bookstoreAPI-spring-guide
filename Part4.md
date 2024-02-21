# Part 4 - API Development<!-- omit from toc -->

## Table of Contents

<!-- toc -->

- [Models](#models)
  - [Book](#book)
  - [User](#user)
  - [Order](#order)
  - [Order details](#order-details)
- [Repositories](#repositories)
  - [BookRepository](#bookrepository)

<!-- tocstop -->

This section will focus on the code-aspect of our API.
Take note that due to the considerable size of the project,
we won't be able to write every single line of code here.
Most of the entities will be left out.
But necessary annotations and concepts are _definitely_ going to be shown here.

Take this as what we are really doing here: A **guide**.
So practice, research, and put your knowledge and understanding to the test.

## Models

Models are the _OOP_ representation of the relational entities inside the database.
This includes: foreign keys, attributes and primary keys,
alongside some extra things we could come across.

So how exactly do we translate all of this to a `java` class? Very simple:

### Book

```java

// imports
@Entity
@Table(name = "Book")
public class Book {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "idBook")
  private Long id;

  @Column(name = "name", nullable = false, length = 150)
  private String name;

  @Column(name = "author", nullable = false, length = 150)
  private String author;

  @Column(name = "stock", nullable = false)
  private int stock;

  @Column(name = "price", nullable = false)
  private double price;

  @OneToMany(mappedBy = "Book", cascade = CascadeType.ALL, orphanRemoval = true)
  private Set<OrderDetail> orderDetails = new HashSet<>();

  // Default constructor
  public Book() {}

  // Constructor without ID for new book creation
  public Book(String name, String author, int stock, double price) {
    this.name = name;
    this.author = author;
    this.stock = stock;
    this.price = price;
  }

  // Full constructor including ID
  public Book(Long id, String name, String author, int stock, double price) {
    this.id = id;
    this.name = name;
    this.author = author;
    this.stock = stock;
    this.price = price;
  }

  // Getters and setters...

  // Utility method to add order detail to a book
  public void addOrderDetail(OrderDetail orderDetail) {
    this.orderDetails.add(orderDetail);
    orderDetail.setBook(this);
  }

  // Utility method to remove order detail from a book
  public void removeOrderDetail(OrderDetail orderDetail) {
    this.orderDetails.remove(orderDetail);
    orderDetail.setBook(null);
  }
}

```

Note the following:

- `@Entity` annotation specifies that this class is a **JPA entity.**
- `@Table` annotation specifies the name of the table as it is in the database.
- `@Id` and `@GeneratedValue` annotations are used to specify the primary key and its generation strategy.
- `@Column` annotations are used to specify the _details of each column_ as they are in our database.
- `@OneToMany` annotations specify the relationship to their respective foreign keys.
  - These annotations can vary depending on their hierarchy and type of relationship.
- `@Temporal` annotation is used with Date fields to specify the SQL date type.

### User

```java

// imports
@Entity
@Table(name = "User")
public class User {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "idUser")
  private Long id;

  @Column(name = "username", nullable = false, length = 50, unique = true)
  private String username;

  @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
  private Set<Order> orders = new HashSet<>();

  // Default constructor
  public User() {}

  // Constructor with parameters
  public User(String username) {
    this.username = username;
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
  @Column(name = "idOrder")
  private Long id;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "User_idUser", nullable = false)
  private User user;

  @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
  private Set<OrderDetails> orderDetails = new HashSet<>();

  // Default constructor
  public Order() {}

  // Constructor with user parameter
  public Order(Long id, User user, Set<OrderDetails> OrderDetails) {
    super();
    this.id = id;
    this.user = user;
    this.OrderDetails = OrderDetails;
  }

  // Utility method to add order detail to a book
  public void addOrderDetail(OrderDetails orderDetail) {
    this.orderDetails.add(orderDetail);
    orderDetail.setBook(this);
  }

  // Utility method to remove order detail from a book
  public void removeOrderDetail(OrderDetails orderDetail) {
    this.orderDetails.remove(orderDetail);
    orderDetail.setBook(null);
  }

  // Getters and setters
}

```

- Each `Order` is related to a `User`, established by a many-to-one relationship `(@ManyToOne)`.
- The `Order` entity also has a one-to-many relationship with `OrderDetails`, which is a join table containing the many-to-many relationship between `Order` and Book `entities` with an additional quantity field.
- A **constructor** that accepts a `User` is also provided, which is useful when creating a new `Order` linked to an existing `User`.

### Order details

This entity will be ajusted to include a composite primary key. This will simplify the implementation of a `@ManyToMany` relationship as well as custom attributes (quantity).

```java
// imports

@Entity
@Table(name = "OrderDetails")
public class OrderDetails {

  @EmbeddedId
  private OrderBookId id;

  @ManyToOne(fetch = FetchType.LAZY)
 // @MapsId("orderId")
  @JoinColumn(name = "Order_idOrder")
  private Order order;

  @ManyToOne(fetch = FetchType.LAZY)
 // @MapsId("bookId")
  @JoinColumn(name = "Book_idBook")
  private Book book;

  @Column(name = "quantity")
  private int quantity;

  public OrderDetails() {
    // Default constructor
  }

  public OrderDetails(OrderBookId id, Order order, Book book, int quantity) {
    this.id = id;
    this.order = order;
    this.book = book;
    this.quantity = quantity;
  }

  // Getters and setters

  // Embeddable key class but only necessary for certain cases
  /*
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
  */

  // Other methods...
}

```

A `composite` key implementation is more of an opinion instead of a good practice.
You can add it through the code above if necessary, else, keep it simple.

## Repositories

The next step is to setup our `BookRepository` so the model can work with `JPA's` methods. Fortunately that's a quick solution and usually these files don't usually have a lot of lines of code.

Create a new `interface` called `BookRepository` inside a _package_ dedicated solely for repositories.

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

You'll need to make a Repository for all entities that will have any CRUD operations executed _through_ them.

- We'll only write CRUD operations for `User`, `Author` and `Book` since this is a demo.
- If you want to add `Orders` and/or `Genres` then you might want to add one for those too.
