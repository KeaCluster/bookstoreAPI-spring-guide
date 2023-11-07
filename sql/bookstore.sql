
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `library` DEFAULT CHARACTER SET utf8 ;
USE `library` ;

CREATE TABLE IF NOT EXISTS `library`.`Genre` (
  `genre_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `description` VARCHAR(200) NOT NULL,
  PRIMARY KEY (`genre_id`),
  UNIQUE INDEX `genre_id_UNIQUE` (`genre_id` ASC) )
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `library`.`Book` (
  `book_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(75) NOT NULL,
  `release_date` DATE NOT NULL,
  `editorial` VARCHAR(50) NOT NULL,
  `edition` VARCHAR(30) NOT NULL,
  `Genre_genre_id` INT NOT NULL,
  PRIMARY KEY (`book_id`),
  UNIQUE INDEX `book_id_UNIQUE` (`book_id` ASC) ,
  INDEX `fk_Book_Genre1_idx` (`Genre_genre_id` ASC) ,
  CONSTRAINT `fk_Book_Genre1`
    FOREIGN KEY (`Genre_genre_id`)
    REFERENCES `library`.`Genre` (`genre_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `library`.`Author` (
  `author_id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(45) NOT NULL,
  `last_name` VARCHAR(70) NOT NULL,
  PRIMARY KEY (`author_id`),
  UNIQUE INDEX `author_id_UNIQUE` (`author_id` ASC) )
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `library`.`User` (
  `user_id` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(45) NOT NULL,
  `password` VARCHAR(25) NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `user_id_UNIQUE` (`user_id` ASC) )
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `library`.`Book_has_Author` (
  `Book_book_id` INT NOT NULL,
  `Author_author_id` INT NOT NULL,
  INDEX `fk_Book_has_Author_Author1_idx` (`Author_author_id` ASC) ,
  INDEX `fk_Book_has_Author_Book1_idx` (`Book_book_id` ASC) ,
  CONSTRAINT `fk_Book_has_Author_Book1`
    FOREIGN KEY (`Book_book_id`)
    REFERENCES `library`.`Book` (`book_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Book_has_Author_Author1`
    FOREIGN KEY (`Author_author_id`)
    REFERENCES `library`.`Author` (`author_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `library`.`Order` (
  `order_id` INT NOT NULL AUTO_INCREMENT,
  `User_user_id` INT NOT NULL,
  PRIMARY KEY (`order_id`),
  UNIQUE INDEX `idOrder_UNIQUE` (`order_id` ASC) ,
  INDEX `fk_Order_User1_idx` (`User_user_id` ASC) ,
  CONSTRAINT `fk_Order_User1`
    FOREIGN KEY (`User_user_id`)
    REFERENCES `library`.`User` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `library`.`Order_has_Book` (
  `Order_order_id` INT NOT NULL,
  `Book_book_id` INT NOT NULL,
  `quantity` INT NOT NULL,
  PRIMARY KEY (`Order_order_id`, `Book_book_id`),
  INDEX `fk_Order_has_Book_Book1_idx` (`Book_book_id` ASC),
  INDEX `fk_Order_has_Book_Order1_idx` (`Order_order_id` ASC),
  CONSTRAINT `fk_Order_has_Book_Order1`
    FOREIGN KEY (`Order_order_id`)
    REFERENCES `library`.`Order` (`order_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Order_has_Book_Book1`
    FOREIGN KEY (`Book_book_id`)
    REFERENCES `library`.`Book` (`book_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
