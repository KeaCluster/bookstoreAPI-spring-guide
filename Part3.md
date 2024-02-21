# Part 3 - Setting up

This section is fairly straightforward.
We'll take a look at some recommendations and basic configurations.

## Table of Contents

<!-- toc -->

- [Java Environment](#java-environment)
- [Initializr](#initializr)
  - [Framework](#framework)
  - [Dependencies](#dependencies)
- [How to](#how-to)
- [Notes](#notes)

<!-- tocstop -->

## Java Environment

For simplicity's sake we'll work under `Java 17` or slightly older.
As of the time of this writing, the latest `JDK` is version `JDK 21`.
But since what we need is compatibility and straightforwardness, we'll stick to `Java 17`.
Make sure to have that `JDK` installed alongside your favorite java _IDE_(Eclipse).

## Initializr

We'll make use of the [spring.initializr](https://start.spring.io)
as it allows for a quick setup for our entire project.
This means automatic dependency injection, project,
language, and also `Spring Boot` version selection

### Framework

We'll work under `Gradle` since it's very dev-friendly when building our project.

- For `Spring Boot` stick with the latest (SNAPSHOT) version available.

Feel free to adjust your project's metadata as you see fit.

- Packaging: Jar
- Java: Version 17

### Dependencies

We'll need three main dependencies:

1. `Spring Data JPA`: To have persistence in our `API`.
2. `MySQL Driver`: To connect to our database.
3. `Spring Web`: This provides most of the REST API annotations and tools we'll use.

## How to

1. Click on **Generate** at the bottom. It will download a `.zip` file.
2. Extract it into your _java workspace_ and **import** it as a `Gradle` project.
   - Please check your directory **is** the root directory and **not** a nested one.
3. It should start the configuration and build right away depending on your IDE.
4. If any errors occur, double check directory structure and retry from step _2_.

## Notes

Take some time to familiarize yourself with the project and its structure **before** moving on to the next section.
Explore the files, do some research, and really get to know why everything is there.
