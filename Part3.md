# Part 3 - Setting up

This section is fairly straightforward. We'll take a look at some recommendations and basic configurations for smooth development and maximum error prevention.

# Table of Contents

1. [Java Environment](#java-environment)
2. [Initializr](#initializr)
    - [Framework](#framework)
    - [Dependencies](#dependencies)
3. [How to](#how-to)
4. [Notes](#notes)

## Java Environment

For simplicity's sake and also greater compatibility, we'll work under `Java 17` or slightly older.
As of the time of this writing, the latest `JDK` is version `JDK 21`. But since what we want/need is compatibility and straightforwardness, we'll stick to `Java 17`. 
Make sure to have that JDK installed alongside your favorite java *IDE*. 

## Initializr

We'll make use of the [spring.initializr](https://start.spring.io) as it allows for a quick setup for our entire project. This means automatic dependency injection, project, language, and also `Spring Boot` version selection

### Framework

We'll work under `Gradle` since it's very user-friendly and easy to use when building our project.

- For `Spring Boot` stick with the latest version under `3.0` available. Currently that is `2.7.18 (SNAPSHOT)`. 

Feel free to adjust your project's metadata as you see fit.

- Packaging: Jar
- Java: Version 17

### Dependencies

We'll need three main dependencies:

1. `Spring Data JPA`: To have persistence in our `API`
2. `MySQL Driver`: To connect with our database server
3. `Spring Web`: This provides most of the REST API annotations and tools we'll use.


## How to

1. Click on **Generate** at the bottom. It will download a `.zip` file.
2. Extract it into your *java workspace* and **import** it as a `Gradle` project.
    - Please do check your directory imported is the root directory and not a nested one.
3. It should start the configuration and build right away depending on your IDE. 
4. If any errors occur, double check directory structure and retry from step *2*.

## Notes

Take some time to familiarize yourself with the project and its structure **before** moving on to the next section. Explore the files, do some research about them, and really get to know why everything is there.
