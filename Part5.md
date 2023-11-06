# Part 5 - API Services and Controllers<!-- omit from toc -->

This section will focus on implementing both Controllers and Services to our API. Most of the hard-work will be done here as it is very code-intensive

- [Services](#services)
  - [BookService](#bookservice)
- [Controllers](#controllers)
- [Notes](#notes)

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


## Notes

This API handles multiple entities and will play out differently regarding the requirements and specifications. Due to limitations and practical constraints, we won't go further into writing every single `Service` and `Controller`. Instead, check what we've done so far and create them on your own. You're encouraged to build upon this groundwork, crafting the additional components needed to meet your unique requirements.
Remember to check documentation and multiple online resources.
Don't take this as the absolute truth. 

Keep in mind that the strategies discussed here are starting points rather than definitive solutions. The development landscape is dynamic, and best practices evolve. Stay adaptable, be open to new ideas, and don't shy away from reevaluating and improving your codebase as you gain more insights and experience.