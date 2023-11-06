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
    - Attributes: username, password, email, phone, photo_url
5. Order:
    - PK: order_id
    - FK: user_id

## ER Diagram

En ER-Diagram will help us visualize the relationship between entities in our database. In our library system the ER-Diagram will look something similar to the following:


## Normalization

## SQL Scripts
