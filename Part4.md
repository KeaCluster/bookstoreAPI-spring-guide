# Part 4 - API Development

<!--toc:start-->

- [Models](#models)
- [Book](#book)
- [User](#user)
- [Order](#order)
- [Order details](#order-details)
- [Repositories](#repositories)
  - [BookRepository](#bookrepository)

<!--toc:end-->

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
@Table(name = "books")
public class Book {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "book_id")
  private int id;

  @Column(name = "name", nullable = false, length = 150)
  private String name;

  @Column(name = "author", nullable = false, length = 150)
  private String author;

  @Column(name = "stock", nullable = false)
  private int stock;

  @Column(name = "price", nullable = false)
  private double price;

  @OneToMany(mappedBy = "book")
  private Set<OrderDetails> orderDetail;

  public Book () {
    // default
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
- `@Table` annotation specifies the name of the table matching the database.
- `@Id` and `@GeneratedValue` annotations to specify the primary key and AI.
- `@Column` annotations to specify the _details of each column_ matching our database.
- `@OneToMany` annotations specify the relationship to their respective foreign keys.
  - These annotations can vary depending on their hierarchy and type of relationship.
- `@Temporal` annotation is used with Date fields to specify the SQL date type.

### User

```java

// imports
@Entity
@Table(name = "users")
public class User {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "user_id")
  private int id;

  @Column(name = "username", nullable = false, length = 45, unique = true)
  private String username;

  @OneToMany(mappedBy = "user")
  private Set<Order> orders = new HashSet<>();

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

- There's a `one-to-many` relationship between `User` and `Order`
  - This idicates that a user can have multiple orders.
- The `@OneToMany` relationship is managed with the `mappedBy` attribute.
  - This points to the user field in the `Order` entity.

### Order

```java
// imports

@Entity
@Table(name = "orders")
public class Order {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "order_id")
  private int id;

  @ManyToOne
  @JoinColumn(name = "user_id", nullable = false)
  private User user;

  @OneToMany(mappedBy = "order")
  private Set<OrderDetails> orderDetail;

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

- Each `Order` is related to a `User`
  - Established by a many-to-one relationship `(@ManyToOne)`.
- The `Order` entity also has a one-to-many relationship with `OrderDetails`.
  - This is a pivot fixing the many-to-many relationship between `Order` and `Book`.
- A **constructor** that accepts a `User` is also provided
  - Which is useful when creating a new `Order` linked to an existing `User`.

### Order details

This entity can be adjusted to include a composite primary key.
It can simplify the logic of a `@ManyToMany` relationship
as well as handling custom attributes (quantity).

```java
// imports

@Entity
@Table(name = "order_details")
public class OrderDetails {
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name="order_detail_id")
  private int id;

  @ManyToOne
  @JoinColumn(name = "order_id")
  private Order order;

  @ManyToOne
  @JoinColumn(name = "book_id")
  private Book book;

  @Column(name = "quantity", nullable = false)
  private int quantity;

  public OrderDetails() {}

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

The next step is to setup our `BookRepository` so we can work with `JPA's` methods.
Fortunately that's a quick solution and these files have few loc.

Create a new `interface` called `BookRepository`
inside a _package_ dedicated solely for repositories.
Now we'll have our `interface` extend `JPA` methods making them available for us.

### BookRepository

```java
// This marker is used to indicate that the interface is a repository
// and a component of the Spring context.
@Repository
public interface BookRepository extends JpaRepository<Book, Long> {
  // No need to define findById(Long id) as it's already provided.
  // Example custom query method
  Optional<Book> findBookByIsbn(String isbn);

  // Additional custom methods as required for your application.
}
```

- Repository Interface:
  - By extending, BookRepository not only inherits methods for basic CRUD operations
    but also paging and sorting capabilities.
- You'll need to make a Repository for all entities with any CRUD.
- We'll only write CRUD operations for: `User, Author and Book` since this is a demo.
