CREATE DATABASE bookstoredb;
USE bookstoredb;

-- 1. Book and Related Entities

-- Table: book_language
CREATE TABLE book_language (
  language_id INT AUTO_INCREMENT PRIMARY KEY,
  language_name VARCHAR(100) NOT NULL,
  language_code VARCHAR(10)  -- e.g., 'en', 'fr'
);

-- Table: publisher
CREATE TABLE publisher (
  publisher_id INT AUTO_INCREMENT PRIMARY KEY,
  publisher_name VARCHAR(255) NOT NULL,
  contact_email VARCHAR(255),
  website VARCHAR(255)
);

-- Table: book
CREATE TABLE book (
  book_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  isbn VARCHAR(20) UNIQUE NOT NULL,  -- can store ISBN-10 or ISBN-13
  publish_date DATE,
  price DECIMAL(10,2) NOT NULL,
  publisher_id INT NOT NULL,
  language_id INT NOT NULL,
  description TEXT,
  CONSTRAINT fk_book_publisher FOREIGN KEY (publisher_id)
      REFERENCES publisher(publisher_id),
  CONSTRAINT fk_book_language FOREIGN KEY (language_id)
      REFERENCES book_language(language_id)
);

-- Table: author
CREATE TABLE author (
  author_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  bio TEXT,
  birth_date DATE
);

-- Table: book_author (join table for many-to-many between book and author)
CREATE TABLE book_author (
  book_id INT NOT NULL,
  author_id INT NOT NULL,
  PRIMARY KEY (book_id, author_id),
  CONSTRAINT fk_ba_book FOREIGN KEY (book_id)
      REFERENCES book(book_id),
  CONSTRAINT fk_ba_author FOREIGN KEY (author_id)
      REFERENCES author(author_id)
);

-- 2. Customers and Addresses

-- Table: country
CREATE TABLE country (
  country_id INT AUTO_INCREMENT PRIMARY KEY,
  country_name VARCHAR(100) NOT NULL,
  iso_code VARCHAR(3)  -- e.g., 'USA', 'GBR'
);

-- Table: address
CREATE TABLE address (
  address_id INT AUTO_INCREMENT PRIMARY KEY,
  street VARCHAR(255) NOT NULL,
  city VARCHAR(100) NOT NULL,
  state_province VARCHAR(100),
  postal_code VARCHAR(20),
  country_id INT NOT NULL,
  CONSTRAINT fk_address_country FOREIGN KEY (country_id)
      REFERENCES country(country_id)
);

-- Table: address_status
CREATE TABLE address_status (
  status_id INT AUTO_INCREMENT PRIMARY KEY,
  status_name VARCHAR(50) NOT NULL  -- e.g., 'current', 'old'
);

-- Table: customer
CREATE TABLE customer (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(50),
  registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: customer_address (maps customers to multiple addresses)
CREATE TABLE customer_address (
  customer_address_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  address_id INT NOT NULL,
  status_id INT NOT NULL,
  added_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_cust_addr_customer FOREIGN KEY (customer_id)
      REFERENCES customer(customer_id),
  CONSTRAINT fk_cust_addr_address FOREIGN KEY (address_id)
      REFERENCES address(address_id),
  CONSTRAINT fk_cust_addr_status FOREIGN KEY (status_id)
      REFERENCES address_status(status_id)
);

-- 3. Orders, Shipping, and Order History

-- Table: shipping_method
CREATE TABLE shipping_method (
  shipping_method_id INT AUTO_INCREMENT PRIMARY KEY,
  method_name VARCHAR(100) NOT NULL,
  details TEXT,
  cost DECIMAL(10,2) NOT NULL
);

-- Table: order_status
CREATE TABLE order_status (
  status_id INT AUTO_INCREMENT PRIMARY KEY,
  status_name VARCHAR(50) NOT NULL  -- e.g., 'pending', 'shipped', 'delivered'
);

-- Table: cust_order
CREATE TABLE cust_order (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  shipping_method_id INT NOT NULL,
  order_status_id INT NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_order_customer FOREIGN KEY (customer_id)
      REFERENCES customer(customer_id),
  CONSTRAINT fk_order_shipping FOREIGN KEY (shipping_method_id)
      REFERENCES shipping_method(shipping_method_id),
  CONSTRAINT fk_order_status FOREIGN KEY (order_status_id)
      REFERENCES order_status(status_id)
);

-- Table: order_line (each line represents a book in an order)
CREATE TABLE order_line (
  order_line_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  book_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_orderline_order FOREIGN KEY (order_id)
      REFERENCES cust_order(order_id),
  CONSTRAINT fk_orderline_book FOREIGN KEY (book_id)
      REFERENCES book(book_id)
);

-- Table: order_history (logs changes in order status)
CREATE TABLE order_history (
  order_history_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  status_id INT NOT NULL,
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  note VARCHAR(255),
  CONSTRAINT fk_history_order FOREIGN KEY (order_id)
      REFERENCES cust_order(order_id),
  CONSTRAINT fk_history_status FOREIGN KEY (status_id)
      REFERENCES order_status(status_id)
);