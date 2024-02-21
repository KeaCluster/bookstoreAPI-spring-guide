# Part 1 - Requirements

In this section, we'll delve into understanding the basic requirements for our bookshop system. This will range from its basic functionality, to the database and an overall description of the system to better understand its purpose and requirements.

## Table of Contents

<!-- toc -->

- [Understanding the system](#understanding-the-system)
  - [Basics](#basics)
  - [Entities and relationships](#entities-and-relationships)
- [Documenting functionality](#documenting-functionality)
- [Planning](#planning)
  - [Stages](#stages)
- [Overall Description](#overall-description)

<!-- tocstop -->

## Understanding the system

### Basics

We are designing a system for managing a bookshop's book renting service. The bookstore system should run in a web-application, one which we'll not delve into where due to the small scale and time available. However, note that the system will respond to the requests from that application.

Additionally, we could argue that since its called a _bookshop_ the name might imply the user be able to **buy** or **shop** books. But we'll focus solely on the book renting functionality for simplicity's, since thats the reason we're here in the first place and our primary goal.

### Entities and relationships

The core entities of the system are rather simple and plain:

- **User**: Individuals who can rent books from the bookshop.
- **Book**: Books available for rent/buy
- Orders: List of orders made
- OrderDetails: Details of each order to handle a `M:N` relationship

As for the relationships, at this point we recommend having a solid grasp of basic relational database structure and how their entities communicate and _relate_ to each other.

- A **User** can rent _multiple_ **Books**, and a **Book** can be rented by _multiple_ **Users**: Many-to-Many - M:N

So, to summarize, the relationships these entities have will result in an interesting ER diagram, as well as very important pivot tables to normalize M:N relationsips.

## Documenting functionality

Everything we do here could be documented through a third-party tool but for simplicity, we'll just stick to simple comments alongside this guide. We do however recommend you take your own notes along the way.

## Planning

Now that we have an idea of our system's requirements, we can talk about the different stages we'll need to go through.

### Stages

We'll have to go through several stages in order to completely release this project onto the public (or small side-project). However please not that **the resulting project is not production ready** and will have to go through several **security** phases and sections to make sure it can be implemented _IRL_.

1. Designing and Setting up our Database (MySQL)
2. Setting up our Dev Env with Java and Spring Boot. We'll use the _Spring Initializr_ to automate this process. Choosing the right plugins, frameworks etc...
3. Development using the _MVC_ software design pattern.
4. Some error handling and final adjustments.
5. Validations.
6. Deployment.

## Overall Description

So, lets sum things up for a bit...

In this initial segment of our guide, we embarked on a journey to lay the foundational understanding and planning required for our bookshop system focusing on the book renting service.

We highlighted the essential entities, namely: `Users, Books and Orders`, and elucidated the relational dynamics among them, emphasizing the Many-to-Many and Many-to-One relationships. This understanding is pivotal as it sets the stage for an intriguing Entity-Relationship diagram and the creation of pivot tables to normalize the relationships, facilitating a robust database structure.

Subsequently, we touched upon the importance of documenting functionality, advocating for simplicity in this endeavor by utilizing comments within this guide, whilst also encouraging personal note-taking for a better grasp of the process.

By encapsulating these crucial aspects, this part of the guide aims to equip you with a clear understanding and a well-laid plan, ensuring a smooth transition into the subsequent sections where we will delve deeper into the implementation details of our bookshop system.
