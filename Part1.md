# Part 1 Requirements

<!--toc:start-->

- [Part 1 Requirements](#part-1-requirements)
  - [Understanding the system](#understanding-the-system)
    - [Basics](#basics)
    - [Entities and relationships](#entities-and-relationships)
  - [Documenting functionality](#documenting-functionality)
  - [Planning](#planning)
    - [Stages](#stages)

<!--toc:end-->

In this section,
we'll delve into understanding the basic requirements for our bookshop system.
This will range from its basic functionality,
to the database and an overall description of the system to better understand its purpose and requirements.

## Understanding the system

### Basics

We are designing a system for managing a bookshop's book renting service.
The bookstore system should run in a web-application,
one which we'll not delve into where due to the small scale and time available.
However, note that the system will respond to the requests from that application.

Additionally,
we could argue that since its called a _bookshop_ the name might imply the user be able to **buy** or **shop** books.
But we'll focus solely on the book renting functionality for simplicity's,
since thats the reason we're here in the first place and our primary goal.

### Entities and relationships

The core entities of the system are rather simple and plain:

- **User**: Individuals who can rent books from the bookshop.
- **Book**: Books available for rent/buy
- Orders: List of orders made
- OrderDetails: Details of each order to handle a `M:N` relationship

As for the relationships,
at this point we recommend having a solid grasp of basic relational database structure,
and how entities communicate and _relate_ to each other.

- A **User** can rent _multiple_ **Books**, and a **Book** can be rented by _multiple_ **Users**: Many-to-Many - M:N

## Documenting functionality

Everything we do here could be documented through a third-party tool but for simplicity,
we'll just stick to simple comments alongside this guide.
We do however recommend you take your own notes along the way.

## Planning

Now that we have an idea of our system's requirements,
we can talk about the different stages we'll need to go through.

### Stages

We'll have to go through several stages in order to completely release this "project".
However please note that **the resulting project is not production ready**
and will have to go through several **security**
phases and sections to make sure it can be considered a real application.

1. Designing and Setting up our Database (MySQL)
2. Setting up our development environment with Java and Spring Boot. We'll use the _Spring Initializr_ to automate this process. Choosing the right plugins, frameworks etc...
3. Development using _MVC_ design pattern.
4. Some error handling and final adjustments.
5. Validations.
6. Deployment.
