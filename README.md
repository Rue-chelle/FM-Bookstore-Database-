## FM Bookstore Database README

## Overview

The **Bookstore Database** is designed to support a full-featured online bookstore. It incorporates various aspects such as book inventory management, authorship, publishers, customer details, and the complete order management process including shipping and order history. The schema has been thoughtfully designed to handle many-to-many relationships (for example, books and authors) as well as one-to-many relationships (e.g., customers to addresses).

This database supports the following core functionalities:

- **Books Management:** Includes information on books, publishers, languages, and a many-to-many relation with authors.
- **Customer Management:** Manages customer personal details along with multiple addresses.
- **Order Processing:** Tracks customer orders, shipping methods, and detailed order line items.
- **Order History Logging:** Keeps a record of order status changes for audit and tracking purposes.

## Installation and Setup

1. **Create the Database**Open your MySQL client and execute the following commands:

   ```sql
   CREATE DATABASE bookstoredb;
   USE bookstoredb;
   ```
2. **Create Tables**Run the provided SQL script to create the necessary tables. The tables include:

   - **Book and Related Entities**
     - `book_language`
     - `publisher`
     - `book`
     - `author`
     - `book_author` (join table)
   - **Customers and Addresses**
     - `country`
     - `address`
     - `address_status`
     - `customer`
     - `customer_address`
   - **Orders, Shipping, and Order History**
     - `shipping_method`
     - `order_status`
     - `cust_order`
     - `order_line`
     - `order_history`
3. **Data Insertion**
   After creating the tables, the script further inserts sample data into each table (such as book languages, publishers, authors, books, countries, customer addresses, shipping methods, order statuses, and orders) to facilitate testing and demonstration.

## Database Schema Details

### 1. Books and Related Entities

- **`book_language`**Stores languages available for books with columns such as `language_id`, `language_name`, and `language_code`.
- **`publisher`**Contains publisher information including `publisher_name`, `contact_email`, and `website`.
- **`book`**Contains book information (title, ISBN, publish date, price, etc.). It includes foreign keys to:

  - `publisher` (publisher_id)
  - `book_language` (language_id)
- **`author`**Contains details about authors: first name, last name, biography, and birth date.
- **`book_author`**
  A junction table to handle the many-to-many relationship between books and authors. Each record links a `book_id` to an `author_id`.

### 2. Customers and Addresses

- **`country`**Manages country information with columns `country_id`, `country_name`, and an ISO code.
- **`address`**Contains detailed address information such as street, city, state/province, postal code, and a foreign key to `country`.
- **`address_status`**Tracks the status of an address (e.g., current, old).
- **`customer`**Contains customer information (first name, last name, email, phone, and registration timestamp). The email column is unique.
- **`customer_address`**
  Maps customers to their multiple addresses with a status field (reflecting whether it is current or old), along with a timestamp for when the address was added.

### 3. Orders, Shipping, and Order History

- **`shipping_method`**Lists available shipping methods along with details and associated costs.
- **`order_status`**Tracks status values for orders (such as pending, shipped, delivered).
- **`cust_order`**Records customer orders including customer reference, order date, shipping method, order status, and total order amount. Includes foreign keys to `customer`, `shipping_method`, and `order_status`.
- **`order_line`**Each record details a single book in an order: quantity and unit price are recorded. It includes foreign keys to `cust_order` and `book`.
- **`order_history`**
  Logs all changes to order statuses with a timestamp and optional note. It provides an audit trail for order status changes and references `cust_order` and `order_status` via foreign keys.

## Data Insertion Details

- **Initial data load:**The script includes SQL INSERT statements to populate tables with sample languages, publishers, authors, books, customers, addresses, shipping methods, order statuses, orders, order line items, and order history.
- **Join Tables:**The `book_author` and `customer_address` tables ensure that the many-to-many and one-to-many relationships are maintained properly.
- **Data Consistency:**
  Foreign key constraints are defined to enforce referential integrity across tables.

## Entity Relationships

- **Books and Authors:**

  - A book can be written by multiple authors, and an author may write multiple books. This is managed by the `book_author` junction table.
- **Books and Publishers/Language:**

  - Each book is associated with one publisher and one language.
- **Customers and Addresses:**

  - A customer may have multiple addresses, managed by the `customer_address` table.
- **Orders and Order Lines:**

  - Each order (in `cust_order`) can have multiple associated order lines (in `order_line`), each representing a book purchase within that order.
- **Order Tracking:**

  - The order history in the `order_history` table lets you track the evolution of each order status.

## Querying the Database

Here are some example queries to get you started:

- **Retrieve a list of books along with their publisher and language:**

  ```sql
  SELECT b.title, b.isbn, p.publisher_name, l.language_name
  FROM book AS b
  JOIN publisher AS p ON b.publisher_id = p.publisher_id
  JOIN book_language AS l ON b.language_id = l.language_id;
  ```
- **Find all books written by a specific author:**

  ```sql
  SELECT b.title, a.first_name, a.last_name
  FROM book b
  JOIN book_author ba ON b.book_id = ba.book_id
  JOIN author a ON ba.author_id = a.author_id
  WHERE a.last_name = 'Orwell';
  ```
- **Retrieve customer orders with their shipping details:**

  ```sql
  SELECT o.order_id, c.first_name, c.last_name, s.method_name, o.total_amount
  FROM cust_order o
  JOIN customer c ON o.customer_id = c.customer_id
  JOIN shipping_method s ON o.shipping_method_id = s.shipping_method_id;
  ```
- **Display the order history for a given order:**

  ```sql
  SELECT h.order_history_id, h.changed_at, os.status_name, h.note
  FROM order_history h
  JOIN order_status os ON h.status_id = os.status_id
  WHERE h.order_id = 1;
  ```

## Additional Notes

- **Constraint Enforcement:**The database uses foreign key constraints to ensure referential integrity. Make sure that insertions follow the proper sequence (e.g., insert into parent tables before child tables).
- **Data Types:**The script utilizes appropriate MySQL data types such as `VARCHAR`, `TEXT`, `DATE`, `TIMESTAMP`, and `DECIMAL` to ensure that data is stored efficiently and accurately.
- **Future Enhancements:**
  Consider adding indices on frequently queried columns (like `isbn` for the `book` table or `email` for the `customer` table) to improve performance. Additional features such as stored procedures for order processing or triggers for automatic order history logging can further enhance the functionality of the database.

**Group Leader:** Michelle Rufaro Samuriwo
**Collaborator:** Fiona Wangui Njuguna
**Collaborator:** Abiodun Moses Kajogbola

## Diagram Source

[Download the Draw.io Diagram File](./Book library.drawio)
