# Part 5 - Services

<!--toc:start-->

- [Services](#services)
  - [BookService](#bookservice)
  - [UserService](#userservice)
  - [OrderService](#orderservice)
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
@Service
public class BookService {
  @Autowired
  private BookRepository bookRepository;

  // get
  public List<Book> findAllBooks() {
    return bookRepository.findAll();
  }

  public Optional<Book> findBookById(Integer id) {
    return bookRepository.findById(id);
  }

  // post
  public Book saveBook(Book book) {
    return bookRepository.save(book);
  }

  // put
  // You might want to write this one yourself

  // delete
  public void deleteBook(Integer id) {
    bookRepository.deleteById(id);
  }
  // Additional methods as needed
}
```

This service will implement methods provided by `JpaRepository`.
Configured in your `BookRepository` _interface_.

Most basic logic is already defined.

> As you can see, there aren't many changes from one service to another.
> So this a rather fast-forward section of development.

### UserService

```java
@Service
public class UserService {
  @Autowired
  private UserRepository userRepository;

  public Optional<User> findUserById(Integer id) {
    return userRepository.findById(id);
  }

  public User saveUser(User user) {
    return userRepository.save(user);
  }

  public void deleteUser(Integer id) {
    userRepository.deleteById(id);
  }
}
```

### OrderService

```java
@Service
public class OrderService {
  @Autowired
  private OrderRepository orderRepository;

  public Optional<Order> findOrderById(Integer id) {
    return orderRepository.findById(id);
  }

  public Order saveOrder(Order order) {
    return orderRepository.save(order);
  }

  public void deleteOrder(Integer id) {
    orderRepository.deleteById(id);
  }
}
```

## Notes

This API handles multiple entities and will look differently depending on your requirements.

You're encouraged to build upon this groundwork,
crafting the additional components needed to meet your unique requirements.

Remember to check documentation and multiple online resources.
**Don't take this as the absolute truth.**

Keep in mind that the strategies discussed here are starting points,
rather than definitive solutions.
The development landscape is dynamic, and best practices evolve.
Stay adaptable, be open to new ideas,
and don't shy away from reevaluating and improving your codebase.
