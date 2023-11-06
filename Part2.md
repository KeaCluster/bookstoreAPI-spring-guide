# Part 2 - Database

This section will focus solely on the design, requirements, attributes, relationships and normalization of the database to be implemented with our `API`

# Table of Contents

1. [Design](#design)
    - [Entities and Relationships](#entities-and-relationships)
2. [ER Diagram](#er-diagram)
3. [Normalization](#normalization)
4. [SQL Scripts](#sql-scripts)

## Design

The database design for our library system revolves around six key entities: `Genre`, `Book`, `Author`, `User` and two pivot tables: `User_has_Book` and `Book_has_Author`. These entities encapsulate all necessary details and relationships required to model our system accurately. All of these relationships are structured to ensure data integrity and to facilitate easy querying and data manipulation.

According to our system's requirements, the design will be as follows:

- `Genres` are unique categories under which `Books` are classified
- `Books` can have multiple `Authors`, and `Authors` can write multiple `Books`. This is represented by the pivot table `Book_has_Author`.
- `User` can rent multiple `Books`, and `Books` can be rented by multiple `User`. This relationship will be simplified by implementing an extra entity called `Order`. 
    - `Order` itself is a simple entity containing only a relationship to a *pivot table*.

### Entities and Relationships:

1. Genre:
    - PK: genre_id
    - Attributes: name, description
2. Book:
    - PK: book_id
    - Attributes: name, release_data, editorial, edition
    - FK: Genre_genre_id -> Genre.genre_id
3. Author:
    - PK: author_id
    - Attributes: first_name, last_name
4. User:
    - PK: user_id
    - Attributes: username, password, email
5. Order:
    - PK: order_id
    - FK: user_id

### Pivot tables

In addition to the previous tables, we'll need to implement a couple of pivot tables in order to manage *M:N* relationshps:

1. `Order_has_Book` 
    - to connect `Order` and `Book`
    Attributes: quantity
    FK: Order_order_id and Book_book_id

2. `Book_has_Author`
    - To connect `Author` and `Book`
    - FK: Book_book_id and Author_author_id

## ER Diagram

En ER-Diagram will help us visualize the relationship between entities in our database. In our library system the ER-Diagram will look something similar to the following:

![bookstoreER](./img/bookstoreER.png)


## Normalization

Normalization is performed to minimize redundancy and dependency in order to ensure a good structure and organization or the data. 

There are three main steps to Normalization:

- First Normal Form (1NF)
    - Each table should have a primary key and atomic columns.
- Second Normal Form (2NF)
    - There aren't any composite primary keys nor partial dependencies.
- Third Normal Form (3NF)
    - All columns in a table are only dependent on the primary key.

## SQL Scripts

You can write (or generate) the SQL script through any tool you prefer. Stick to the previously mentioned relationships and attributes for better results. If you're using this as a resource, more than a guide, then just remember to double check your requirements.
