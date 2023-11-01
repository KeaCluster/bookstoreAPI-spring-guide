# Part 1 - Requirements

In this section, we'll delve into understanding the basic requirements for our bookshop system. This will range from its basic functionality, to the database and an overall description of the system to better understand its purpose and requirements.

# Table of Contents

1. [Understanding the system](#understanding-the-system)
    - [Basics](#basics)
    - [Entities and relationships](#entities-and-relationships)
2. [Documenting functionality](#documenting-functionality)
3. [Planning](#planning)
4. [Overall Description](#overall-description)

## Understanding the system

### Basics

We are designing a system for managing a bookshop's book renting service. The bookstore system should run in a web-application, one which we'll not delve into where due to the small scale and time available. However, note that the system will respond to the requests from that application.

Additionally, we could argue that since its called a *bookshop* the name might imply the user be able to **buy** or **shop** books. But we'll focus solely on the book renting functionality for simplicity's, since thats the reason we're here in the first place and our primary goal.

### Entities and relationships

The core entities of the system are rather simple and plain:

- **User**: Individuals who can rent books from the bookshop.
- **Book**: Books available for rent.
- **Author**: Individuals who have written the books.
- **Genre**: Categories under which books are classified.

As for the relationships, at this point we recommend having a solid grasp of basic relational database structure and how their entities communicate and *relate* to each other.

- A **User** can rent *multiple* **Books**, and a **Book** can be rented by *multiple* **Users**: Many-to-Many - M:N
- A **Book** is classified under *one* **Genre**: Many-to-One - M:1 (for simplicity)
- A **Book** can have multiple **Authors**, and an **Author** can write multiple **Books**: Many-to-Many - M:N

So, to summarize, the relationships these entities have will result in an interesting ER diagram, as well as very important pivot tables to normalize M:N relationsips.


## Documenting functionality


