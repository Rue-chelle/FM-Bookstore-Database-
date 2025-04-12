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

--------------------------------------------------
-- 1. Create Roles and Grant Privileges
--------------------------------------------------

-- (a) Role: bookstore_admin (Full control)
CREATE ROLE 'bookstore_admin';
GRANT ALL PRIVILEGES ON bookstoredb.* TO 'bookstore_admin';

-- (b) Role: bookstore_readonly (Read-only access)
CREATE ROLE 'bookstore_readonly';
GRANT SELECT ON bookstoredb.* TO 'bookstore_readonly';

-- (c) Role: bookstore_book_manager (Manage books, authors, publishers, languages)
CREATE ROLE 'bookstore_book_manager';
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstoredb.book TO 'bookstore_book_manager';
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstoredb.author TO 'bookstore_book_manager';
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstoredb.publisher TO 'bookstore_book_manager';
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstoredb.book_language TO 'bookstore_book_manager';
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstoredb.book_author TO 'bookstore_book_manager';

-- (d) Role: bookstore_customer_manager (Manage customers, addresses, and related tables)
CREATE ROLE 'bookstore_customer_manager';
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstoredb.customer TO 'bookstore_customer_manager';
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstoredb.address TO 'bookstore_customer_manager';
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstoredb.country TO 'bookstore_customer_manager';
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstoredb.address_status TO 'bookstore_customer_manager';
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstoredb.customer_address TO 'bookstore_customer_manager';

-- (e) Role: bookstore_order_manager (Manage orders, order lines, order history, shipping and status)
CREATE ROLE 'bookstore_order_manager';
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstoredb.cust_order TO 'bookstore_order_manager';
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstoredb.order_line TO 'bookstore_order_manager';
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstoredb.order_history TO 'bookstore_order_manager';
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstoredb.shipping_method TO 'bookstore_order_manager';
GRANT SELECT, INSERT, UPDATE, DELETE ON bookstoredb.order_status TO 'bookstore_order_manager';

--------------------------------------------------
-- 2. Create Users and Assign Roles
--------------------------------------------------

-- (a) Admin User
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'Michelle yourpasword';
GRANT 'bookstore_admin' TO 'admin_user'@'localhost';
SET DEFAULT ROLE 'bookstore_admin' TO 'admin_user'@'localhost';

-- (b) Read-only User
CREATE USER 'readonly_user'@'localhost' IDENTIFIED BY 'Abiodun001';
GRANT 'bookstore_readonly' TO 'readonly_user'@'localhost';
SET DEFAULT ROLE 'bookstore_readonly' TO 'readonly_user'@'localhost';

-- (c) Book Manager User
CREATE USER 'book_manager'@'localhost' IDENTIFIED BY 'Fiona your password';
GRANT 'bookstore_book_manager' TO 'book_manager'@'localhost';
SET DEFAULT ROLE 'bookstore_book_manager' TO 'book_manager'@'localhost';

-- (d) Customer Manager User
CREATE USER 'customer_manager'@'localhost' IDENTIFIED BY 'Michelle your password';
GRANT 'bookstore_customer_manager' TO 'customer_manager'@'localhost';
SET DEFAULT ROLE 'bookstore_customer_manager' TO 'customer_manager'@'localhost';

-- (e) Order Manager User
CREATE USER 'order_manager'@'localhost' IDENTIFIED BY 'Abiodun001';
GRANT 'bookstore_order_manager' TO 'order_manager'@'localhost';
SET DEFAULT ROLE 'bookstore_order_manager' TO 'order_manager'@'localhost';



/* Inserting datas */

-- inserting data for book language table
INSERT INTO book_language (language_id, language_name, language_code) VALUES
(1, 'English', 'en'),
(2, 'Spanish', 'es'),
(3, 'French', 'fr'),
(4, 'German', 'de');

-- inserting data for publishers table
INSERT INTO publisher (publisher_id, publisher_name, contact_email, website) VALUES
(1, 'Dream Work', 'guoi@gmail.com', 'www.dreamwork.com'),
(2, 'Penguin Books', 'contact@penguin.com', 'www.penguin.com'),
(3, 'Orbit Press', 'info@orbitpress.co.uk', 'www.orbitpress.co.uk'),
(4, 'HarperCollins', 'enquiries@harpercollins.co.uk', 'www.harpercollins.com'),
(5, 'Macmillan Publishers', 'press.inquiries@macmillan.com', 'us.macmillan.com'),
(6, 'Scholastic Inc.', 'intlschool@scholastic.com', 'www.scholastic.com'),
(7, 'Oxford University Press', 'Publishing.KE@oup.com', 'www.oup.com'),
(8, 'Candlelight Press', 'aboutclp@candlelightpress.com', 'candlelightpress.tumblr.com'),
(9, 'Nova Science Publishers', 'support@novapublishers.com', 'novapublishers.com'),
(10, 'Biblio Publishing', 'Info@BiblioPublishing.com', 'bibliopublishing.com'),
(11, 'Little, Brown and Co.', 'publicity@littlebrown.com', 'www.hachette.com/en/publisher/little-brown-and-company');

-- inserting data for authors table
INSERT INTO author (first_name, last_name, bio, birth_date) VALUES
('John', 'Smith', 'A novelist', '1980-04-23'),
('Harper', 'Lee', 'American Novelist', '1926-04-28'),
('George', 'Orwell', 'English author', '1903-06-25'),
('Jane', 'Austen', 'novelist', '1775-12-16'),
('Herman', 'Melville', 'Author', '1918-08-01'),
('Mitch', 'Albom', 'Journalist and author', '1958-05-23'),
('Isabel', 'Martinez', 'Spanish mystery writer', NULL),
('John Ronald Reuel', 'Tolkien', 'Author', '1892-01-03'),
('Alex', 'Michealides', 'Author and screenwriter', '1977-09-04'),
('Charlotte', 'Bronte', 'English novelist', '1816-04-21'),
('Clive', 'Lewis', 'Author, philosopher', '1898-11-29'),
('Aldous', 'Huxley', 'Writer, Philosopher', '1963-11-26'),
('Oscar', 'Wilde', 'Irish author', '1854-10-16'),
('Georges', 'Simenon', 'British Author', '1903-09-06'),
('F. Scott', 'Fitzgerald', 'Classic writer', '1896-09-24'), 
('Alison', 'Espach', 'Novelist', '1984-09-28'),
('E. B.', 'White', 'Author, poet', '1899-07-11'), 
('Emily', 'Bronte', 'novelist', '1818-07-30'),
('Charles', 'Dickens', 'author', '1812-02-07'),
('Paulo', 'Coelho', 'Author', '1947-08-24'),
('Ray', 'Bradbury', 'author', '1920-08-22'),
('Khaled', 'Hosseini', 'author', '1965-03-03'),
('Mary', 'Shelley', 'novelist', '1797-08-30'),
('Suzanne', 'Collins', 'Author', '1962-08-10'),
('Yann', 'Martel', 'author, philosopher', '1963-06-25'),
('Anthony', 'Burgess', 'novelist, essayist', '1917-02-25'),
('Stephen', 'King', 'Horror novelist', '1947-09-21'),
('Robert Louis', 'Stevenson', 'Author', '1850-11-13'),
('John', 'Green', 'Novelist', '1977-08-24'),
('Victor', 'Hugo', 'author, poet', '1802-02-26'),
('Markus', 'Zusak', 'novelist', '1975-06-23'),
('Kurt', 'Vonnegut', 'author', '1922-11-11'),
('Alice', 'Walker', 'novelist, poet', '1944-02-09'),
('Frances Hodgson', 'Burnett', 'American novelist', '1849-11-24'),
('Toni', 'Morrison', 'novelist', '1931-02-10'),
('Bram', 'Stoker', 'Author', '1847-11-08'), 
('Cormac', 'McCarthy', 'author', '1933-07-20'),
('Sylvia', 'Plath', 'author, poet', '1932-10-27'),
('Lois', 'Lowry', 'novelist', '1937-03-20'),
('Stieg', 'Larsson', 'novelist', '1954-08-15'),
('Madeleine', 'L''Engle', 'novelist', '1918-11-29'),
('Kenneth', 'Grahame', 'novelist', '1859-03-08'),
('Jack', 'London', 'author', '1876-01-12'),
('Roald', 'Dahl', 'Author', '1916-09-13'),
('Carlos Ruiz', 'Zafon', 'Historical author', '1964-09-25'),
('Alexandre', 'Dumas', 'French author', '1802-07-24'), 
('Bernhard', 'Schlink', 'Novelist', '1944-07-06'), 
('Rick', 'Riordan', 'novelist', '1964-06-05'),
('Isabel', 'Allende', 'Author', '1942-08-02'), 
('Voltaire', '', 'Philosopher', '1694-11-21'), 
('Franz', 'Kafka', 'novelist', '1883-07-03'),
('Margaret Wise', 'Brown', 'Poet, novelist', '1910-04-23'),
('Miguel', 'de Cervantes', 'playwright', '1547-09-29'),
('Friedrich', 'Dürrenmatt', 'Author', '1921-02-05'),
('Laura', 'Esquivel', 'Author', '1950-10-30'),
('Albert', 'Camus', 'Novelist', '1913-11-21'),
('Hermann', 'Hesse', 'author', '1877-07-02'), 
('Julio', 'Cortázar', 'Writer', '1914-08-26'),
('Johann Wolfgang', 'von Goethe', 'Writer', '1749-08-28'),
('Juan', 'Rulfo', 'Storyteller', '1917-05-16'),
('Gustave', 'Flaubert', 'Novelist', '1821-12-12'),
('Erich Maria', 'Remarque', 'Novelist', '1898-06-22');

-- Inserting code for complete authors
INSERT INTO author (author_id, first_name, last_name, bio) VALUES
(63, 'Leo', 'Tolstoy', 'Russian novelist'),
(64, 'Fyodor', 'Dostoevsky', 'Russian novelist'),
(65, 'J.D.', 'Salinger', 'American author'),
(66, 'Homer', '', 'Ancient Greek poet'),
(67, 'S.E.', 'Hinton', 'American novelist');

-- inserting data for books table
INSERT INTO book (book_id, title, isbn, publish_date, price, publisher_id, language_id, description) VALUES
(1, 'The great adventure', '12455', '2020-05-15', 20.00, 2, 1, 'Adventure'),
(2, 'To Kill a Mockingbird', '9780060935467', '1960-11-07', 18.00, 1, 1, 'Fiction thriller'),
(3, '1984', '9780451524935', '1949-06-08', 20.00, 3, 1, 'Science fiction'),
(4, 'Pride and Prejudice', '9780141439518', '1813-01-28', 18.00, 5, 1, 'Romance'),
(5, 'Moby Dick', '9781853260087', '1851-10-18', 22.00, 2, 1, 'Adventure'),
(6, 'War and Peace', '9780140447934', '1869-01-03', 30.00, 7, 1, 'Romance'),
(7, 'The Catcher in the Rye', '9780316769488', '1951-07-16', 17.00, 3, 1, 'Drama'),
(8, 'The Lord of the Rings', '9780261102385', '1954-07-29', 25.00, 4, 1, 'Adventure'),
(9, 'Crime and Punishment', '9780486415871', '1866-01-01', 19.00, 6, 1, 'Psychological thriller'),
(10, 'The Hobbit', '9780345339683', '1937-09-21', 16.00, 5, 1, 'Adventure'),
(11, 'The Odyssey', '9780140268867', NULL, 28.00, 7, 1, 'Adventure'),
(12, 'Jane Eyre', '9780142437209', '1847-10-16', 20.00, 9, 1, 'Drama'),
(13, 'Chronicles of Narnia', '9780064471046', '1950-10-16', 12.00, 4, 1, 'Fiction'),
(14, 'Brave New World', '9780060850524', '1932-08-31', 18.00, 3, 1, 'Science fiction'),
(15, 'The Picture of Dorian Gray', '9780141439570', '1890-07-01', 22.00, 2, 1, 'Philosophical fiction'),
(16, 'Maigret in Holland', '97843789499', '1931-05-24', 23.00, 7, 1, 'Crime'),
(17, 'The Great Gatsby', '9780743273565', '1925-04-10', 20.00, 7, 1, 'Classic'), 
(18, 'The wedding people', '978163638734', '2024-09-07', 30.00, 1, 1, 'Romance'),
(19, 'The Adults', '9735738348', '2011-12-19', 15.00, 1, 1, 'Fiction'),
(20, 'Charlotte''s Web', '9780061124952', '1952-10-15', 15.00, 6, 1, 'Fiction'),
(21, 'Animal Farm', '9780451526342', '1945-08-17', 14.00, 3, 1, 'Fiction'),
(22, 'Wuthering Heights', '9780141439556', '1847-12-01', 16.00, 5, 1, 'Romance'),
(23, 'A Tale of Two Cities', '9780141439600', '1859-04-30', 18.00, 9, 1, 'Fiction'),
(24, 'The Alchemist', '9780061122415', '1988-05-01', 20.00, 7, 1, 'Fantasy'),
(25, 'Fahrenheit 451', '9781451673319', '1953-10-19', 17.00, 7, 1, 'Science fiction'),
(26, 'The Kite Runner', '9781594631931', '2003-05-29', 19.00, 6, 1, 'Drama'),
(27, 'Frankenstein', '9780141439471', '1818-01-01', 15.00, 5, 1, 'Science fiction'),
(28, 'The Hunger Games', '9780439023528', '2008-09-14', 22.00, 6, 1, 'Fiction'),
(29, 'Life of Pi', '9780156027328', '2001-09-11', 18.00, 8, 1, 'Adventure'),
(30, 'A Clockwork Orange', '9780393312836', '1962-02-10', 21.00, 10, 1, 'Thriller'),
(31, 'The Shining', '9780307743657', '1977-01-28', 25.00, 11, 1, 'Horror'),
(32, 'Dr. Jekyll and Mr. Hyde', '9780486266886', '1886-01-01', 12.00, 2, 1, 'Horror'),
(33, 'The Fault in Our Stars', '9780142424179', '2012-01-10', 20.00, 6, 1, 'Romance'),
(34, 'Les Misérables', '9780451419439', '1862-01-01', 30.00, 7, 1, 'Drama'),
(35, 'The Book Thief', '9780375842207', '2005-03-14', 19.00, 6, 1, 'Fiction'),
(36, 'Slaughterhouse-Five', '9780385333849', '1969-03-31', 18.00, 3, 1, 'Science fiction'),
(37, 'The Color Purple', '9780156028356', '1982-10-01', 22.00, 11, 1, 'Drama'),
(38, 'The Secret Garden', '9780142437056', '1911-08-01', 16.00, 5, 1, 'Drama'),
(39, 'Beloved', '9781400033416', '1987-09-01', 20.00, 11, 1, 'Drama'),
(40, 'Dracula', '9780141439846', '1897-05-26', 19.00, 10, 1, 'Horror'),
(41, 'The Road', '9780307387899', '2006-09-26', 18.00, 9, 1, 'Science Fiction'),
(42, 'Emma', '9780141439587', '1815-12-23', 17.00, 5, 1, 'Romance'),
(43, 'The Bell Jar', '9780060837020', '1963-01-14', 16.00, 2, 1, 'Psychological drama'),
(44, 'The Giver', '9780544336261', '1993-04-26', 15.00, 6, 1, 'Science fiction'),
(45, 'The Outsiders', '9780142407332', '1967-04-24', 14.00, 6, 1, 'Drama'),
(46, 'The Girl with the Dragon Tattoo', '9780307454546', '2005-08-01', 22.00, 9, 1, 'Mystery thriller'),
(47, 'A Wrinkle in Time', '9780312367541', '1962-01-01', 16.00, 6, 1, 'Fantasy'),
(48, 'The Wind in the Willows', '9780143039099', '1908-10-08', 17.00, 10, 1, 'Fiction'),
(49, 'The Call of the Wild', '9780486264721', '1903-07-01', 15.00, 8, 1, 'Drama'),
(50, 'Matilda', '9780140328721', '1988-10-01', 22.00, 2, 1, 'Fiction'),
(51, 'La Sombra del Viento', '9788408053893', '2001-04-12', 25.00, 2, 2, 'Thriller'),
(52, 'Le Comte de Monte-Cristo', '9782253004221', '1845-08-28', 28.00, 4, 3, 'Drama'),
(53, 'Der Vorleser', '9783257229530', '1995-10-02', 20.00, 7, 4, 'Drama'),
(54, 'The Lightning Thief', '9780786838653', '2005-06-28', 24.00, 10, 1, 'Fantasy'),
(55, 'La Casa de los Espíritus', '9788497592350', '1982-11-01', 26.00, 6, 2, 'Drama'),
(56, 'Candide', '9782070360024', '1759-01-01', 18.00, 7, 3, 'Fiction'), 
(57, 'The Metamorphosis', '9780805209990', '1915-10-01', 17.00, 3, 4, 'Drama'),
(58, 'Goodnight Moon', '9780064430173', '1947-09-03', 14.00, 6, 1, 'Fiction'),
(59, 'Don Quijote de la Mancha', '9788420412148', '1605-01-16', 30.00, 5, 2, 'Adventure'),
(60, 'Die Physiker', '9783257202175', '1962-02-01', 21.00, 7, 4, 'Science fiction'),
(61, 'Como Agua Para Chocolate', '9780385474017', '1989-09-01', 23.00, 3, 2, 'Drama'),
(62, 'L''Étranger', '9782070360369', '1942-06-01', 20.00, 4, 3, 'Psychological thriller'), 
(63, 'La sombra del viento', '9788408172179', '2001-04-12', 30.00, 2, 2, 'Drama'),
(64, 'Der Steppenwolf', '9783518468275', '1927-06-20', 28.00, 5, 4, 'Drama'),
(65, 'Rayuela', '9788437602583', '1963-06-28', 32.00, 3, 2, 'Fiction'),
(66, 'Faust: Der Tragödie erster Teil', '9783150000014', '1808-01-01', 34.00, 11, 4, 'Drama'),
(67, 'Pedro Páramo', '9789681638029', '1955-03-19', 22.00, 2, 2, 'Thriller'),
(68, 'Madame Bovary', '9782070360383', '1856-12-12', 29.00, 4, 3, 'Drama'), 
(69, 'All Quiet on the Western Front', '9783462028354', '1929-01-29', 27.00, 6, 4, 'Thriller');

-- inserting data for book-author joining table
INSERT INTO book_author (book_id, author_id) VALUES
(1, 1),    -- The Great Adventure - John Smith
(2, 2),    -- To Kill a Mockingbird - Harper Lee
(3, 3),    -- 1984 - George Orwell
(4, 4),    -- Pride and Prejudice - Jane Austen
(5, 5),    -- Moby Dick - Herman Melville
(6, 63),   -- War and Peace - Leo Tolstoy 
(7, 65),   -- The Catcher in the Rye - J.D. Salinger 
(8, 8),    -- The Lord of the Rings - J.R.R. Tolkien
(9, 64),   -- Crime and Punishment - Fyodor Dostoevsky 
(10, 8),   -- The Hobbit - J.R.R. Tolkien
(11, 66),  -- The Odyssey - Homer 
(12, 10),  -- Jane Eyre - Charlotte Brontë
(13, 11),  -- Chronicles of Narnia - C.S. Lewis
(14, 12),  -- Brave New World - Aldous Huxley
(15, 13),  -- The Picture of Dorian Gray - Oscar Wilde
(16, 14),  -- Maigret in Holland - Georges Simenon
(17, 15),  -- The Great Gatsby - F. Scott Fitzgerald
(18, 16),  -- The Wedding People - Alison Espach
(19, 16),  -- The Adults - Alison Espach
(20, 17),  -- Charlotte's Web - E.B. White
(21, 3),   -- Animal Farm - George Orwell
(22, 18),  -- Wuthering Heights - Emily Brontë
(23, 19),  -- A Tale of Two Cities - Charles Dickens
(24, 20),  -- The Alchemist - Paulo Coelho
(25, 21),  -- Fahrenheit 451 - Ray Bradbury
(26, 22),  -- The Kite Runner - Khaled Hosseini
(27, 23),  -- Frankenstein - Mary Shelley
(28, 24),  -- The Hunger Games - Suzanne Collins
(29, 25),  -- Life of Pi - Yann Martel
(30, 26),  -- A Clockwork Orange - Anthony Burgess
(31, 27),  -- The Shining - Stephen King
(32, 28),  -- Dr. Jekyll and Mr. Hyde - Robert Louis Stevenson
(33, 29),  -- The Fault in Our Stars - John Green
(34, 30),  -- Les Misérables - Victor Hugo
(35, 31),  -- The Book Thief - Markus Zusak
(36, 32),  -- Slaughterhouse-Five - Kurt Vonnegut
(37, 33),  -- The Color Purple - Alice Walker
(38, 34),  -- The Secret Garden - Frances Hodgson Burnett
(39, 35),  -- Beloved - Toni Morrison
(40, 36),  -- Dracula - Bram Stoker
(41, 37),  -- The Road - Cormac McCarthy
(42, 4),   -- Emma - Jane Austen
(43, 38),  -- The Bell Jar - Sylvia Plath
(44, 39),  -- The Giver - Lois Lowry
(45, 67),  -- The Outsiders - S.E. Hinton 
(46, 40),  -- The Girl with the Dragon Tattoo - Stieg Larsson
(47, 41),  -- A Wrinkle in Time - Madeleine L'Engle
(48, 42),  -- The Wind in the Willows - Kenneth Grahame
(49, 43),  -- The Call of the Wild - Jack London
(50, 44),  -- Matilda - Roald Dahl
(51, 45),  -- La Sombra del Viento - Carlos Ruiz Zafón
(52, 46),  -- Le Comte de Monte-Cristo - Alexandre Dumas
(53, 47),  -- Der Vorleser - Bernhard Schlink
(54, 48),  -- The Lightning Thief - Rick Riordan
(55, 49),  -- La Casa de los Espíritus - Isabel Allende
(56, 50),  -- Candide - Voltaire
(57, 51),  -- The Metamorphosis - Franz Kafka
(58, 52),  -- Goodnight Moon - Margaret Wise Brown
(59, 53),  -- Don Quijote de la Mancha - Miguel de Cervantes
(60, 54),  -- Die Physiker - Friedrich Dürrenmatt
(61, 55),  -- Como Agua Para Chocolate - Laura Esquivel
(62, 56),  -- L'Étranger - Albert Camus
(63, 45),  -- La sombra del viento - Carlos Ruiz Zafón
(64, 57),  -- Der Steppenwolf - Hermann Hesse
(65, 58),  -- Rayuela - Julio Cortázar
(66, 59),  -- Faust - Johann Wolfgang von Goethe
(67, 60),  -- Pedro Páramo - Juan Rulfo
(68, 61),  -- Madame Bovary - Gustave Flaubert
(69, 62);  -- All Quiet on the Western Front - Erich Maria Remarque


-- Inserting data for customer table
INSERT INTO customer (first_name,last_name,email,phone,registered_at) VALUES
("John","Smith","jon@gmail.com",234663738,"2025-04-12 13:14"),
( "Blake",'Joe','joe@gmail.com',236673788,'2013-02-12 21:12'),
( "Tim",'Brian','tim@gmail.com',+4366773788,'2023-02-11 21:32'),
( "Dwan",'Johnson ','dwan44@gmail com',+1236773788,'2001-02-11 11:32'),
("John","Ridder","jack02@gmail.com",6535354647983,"2025-04-12 13:14"),
("Mathis ","Nunes ","nunvea89@gamil.com ",+234663738,"2025-04-12 13:14"),
("Leon ","Balogun","leon909@yhoo.com",2316531238653,"2012-01-13 05:29"),
("Lono",'Messi',"lino789@gmai.com",253253458369,"2025-04-12 11:14"),
("Cristina ","Princess ","Cristina890@gmail.com",1124528769875,"2025-04-12 12:23"),
("Ansu","Fati","fati519@gmail.com",1528563698569,"2025-05-16 13:14"),
("Jack ","Girlish ","jac@gmail.com",2355845685968,"2012-04-11 10:14"),
("Paul ","Walker ","paul510@gmail.com",1234567893,"2025-04-12 13:14"),
("James ","Bound ","James2426@gmail.com",2315963652365,"2020-10-12 09:00"),
("Ayra","Star","star898@gmail.com",2563642539586,"2015-12-01 13:19"),
("David ","Oladapo","davil001@gamil.com",2652833952536,"2025-04-12 11:11"),
("Mosludeem","Job","job2662@yhoo.com",364785945364,"2025-05-12 13:24"),
("Peter","Bright ","peter251@gmail.com",57234663738,"2001-07-09 15:11"),
("Cristian","Rolando ","cru778@gmail.com",356424976455,"2023-03-30 11:30"),
("Luise ","Suarez ","luise682@gmail.com",73234663738,"2024-09-25 13:25"),
("Mike ","obi ","jmk67@gmail.com",23434663738,"2024-11-12 07:29"),
("Peter ","Obi","obi@gmail.com",23434663738,"2024-04-11 13:00"),
("Jagaban","Oloshi ","atiku671@gmail.com",23454663738,"2023-02-12 10:34"),
("Atiku","Ole ","oloshi57@gmail.com",2364663738,"2022-03-01 12:19"),
("Travo ","Chaloba ","travo118@gmail.com",2467663738,"2021-03-01 11:12"),
("Simba","Charamba","Sims@gmail.com",172663738,"2021-03-16 09:13"),
("Lisa","Moyo","Lisa@gmail.com",4444663738,"2022-02-17 08:15"),
("Pure","Salim","salim@gmail.com",9874663738,"2022-05-19 07:17"),
("Tinashe","Chipembere","tina@gmail.com",9884663738,"2021-05-09 08:18"),
("Mirah","Kaguvi","kags@gmail.com",2884663738,"2021-09-12 09:00"),
(30,"Petty","Ndlovu","Pgirl@gmail.com",547349320324,"2020-08-11 08:00");


-- Inserting data for country table
INSERT INTO country (country_name,iso_code) VALUES
('Germany',33-01),
('Zimbabwe',716),
('South Africa',710),
('Zambia',894),
('Ghana',288),
('Nigeria',566),
('Australia',036),
('Kenya',404),
('Lesotho',426),
('Ethiopia',231),
('Namibia',516),
('Egypt',818),
('Niger',562),
('USA',840);

-- Inserting data for address table
INSERT INTO address( street,city, state_province,postal_code,country_id) VALUES
('opoo','Nill','Abuja',2434,6),
('Gills','Harare','Mashonaland',638,2),
('Slovo','Johannesburg','Gauteng',6342,3),
('Tanie','Lusaka','Lusaka Province',34578,4),
('Potrens','Durban','KwaZulu Natal',534,3),
('Tries','Accra','Atlantic coast',6564,5),
('Magert','Jos','Central',558,6),
('Guwi','Bulawayo','Matebeleland',32278,2),
('Chikani','kitwe','Copperland',9876,6),
('Loues','Sydney','New South Wales',123,7),
('Priceton','Nairobi','South Central',388,8),
('Bokeng','Maseru','Caledon',38,9),
('Tsaneu','Addis Ababa','Chaetered City',6382,10),
('Footsport','Windhoek','Central province',29,11),
('Chrisan','Bahir Dar','Amhara Region',2892,12),
('Gosal','Kisumu','Kisumu County',01,13),
('Zakino','Port Harcout','Riverstate',2048,12),
('Betrams','Kensinton','Eastern Cape',274,3),
('Doornfontein','CapeTown ','Western Cape',202,3),
('Avondale','Harare','Mashonaland',991,2),
('Avondale','Marondera','Midlands',111,2),
('Ellis','Johannesburg','Gauteng',234,3),
('Kingsland','Cairo','Cairo Governorate',3455,13),
('Tresslon','Alexandria','Alexandria Governorate',3535,13),
('Aloro','Mekelle','Tigray Region',223,10),
('Hiven','Dire Dawa','Dire Dawa chartered',245,10),
('Batare','Zinder','Mokuwa',546,13),
('Nearvile','Los Angeles','Califonia',224,14),
('Ridgenel','San Francisco','Califonia',245,14),
(30,'Sandynel','San Francisco','Ojuaelgba',132,14);

-- Inserting data for address status table
INSERT INTO address_status(status_name) VALUES 
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current'),
('Current');

-- Inserting data for shipping method table
INSERT INTO shipping_method(method_name, details, cost) VALUES 
('Standard Shipping', NULL, 10),
('Standard Shipping','Office Building',10),
('Standard Shipping',NULL,10),
('Express Shipping','Country Side',20),
('Standard Shipping',NULL,10),
('Standard Shipping',NULL,10),
('Standard Shipping','Country Side',20),
('Express Shipping','Office',20),
('Standard Shipping',NULL,10),
('Standard Shipping',NULL,10),
('Standard Shipping',NULL,10),
('Standard Shipping',NULL,10),
('Standard Shipping',NULL,10),
('Standard Shipping','Office',10),
('Express Shipping',NULL,20),
('Standard Shipping',NULL,10),
('Express Shipping','Office',20),
('Express Shipping','Church',20),
('Express Shipping','Office',20),
('Express Shipping', 'Country Side',20),
('Standard Shipping','school',10),
('Standard Shipping','School',10),
('Standard Shipping',NULL,10),
('Standard Shipping',NUll,10),
('Standard Shipping','Office',10),
('Standard Shipping','Church',10),
('Standard Shipping',NULL,10),
('Express Sshipping',NULL,20),
('Express Sshipping',NULL,20),
('Express Sshipping',NULL,20);

--Inserting data for order status table
INSERT INTO order_status(status_name) VALUES
('Pending'),
('Deliverd'),
('Deliverd'),
('Deliverd'),
('Pending'),
('Deliverd'),
('Deliverd'),
('Deliverd'),
('Deliverd'),
('Pending'),
('Deliverd'),
('Deliverd'),
('Pending'),
('Deliverd'),
('Deliverd'),
('Deliverd'),
('Deliverd'),
('Pending'),
('Pending'),
('Deliverd'),
('Pending'),
('Deliverd'),
('Deliverd'),
('Deliverd'),
('Pending'),
('Pending'),
('Deliverd'),
('Deliverd'),
('Deliverd'),
('Pending');

-- Inserting data for customer order table
INSERT INTO cust_order(customer_id, order_date, shipping_method_id, order_status_id,total_amount) VALUES 
(1,'1999-02-13',1,1, 70),
(2,'1998-05-13',2,2, 20),
(3,'2000-02-02',3,3, 50),
(4,'2001-02-14',4,4, 50),
(5,'2000-05-02',5,5, 100),
(6,'2000-02-03',6,6, 50),
(7,'1999-09-19',7,7, 20),
(8,'2002-08-17',8,8, 100),
(9,'2001-04-14',9,9, 70),
(10,'1998-04-26',10,10, 90),
(11,'2002-07-02',11,11, 34),
(12,'2001-03-04',12,12, 36),
(13,'2002-06-19',13,13, 40),
(14,'2001-06-26',14,14, 30),
(15,'2000-09-30',15,15, 80),
(16,'2001-08-21',16,16, 50),
(17,'1999-04-20',17,17, 40),
(18,'2001-03-12',18,18, 72),
(19,'2000-04-15',19,19, 35),
(20,'2001-06-16',20,20, 72),
(21,'2000-04-15',21,21, 35),
(22,'2001-06-16',22,22, 40),
(23,'2000-02-15',23,23, 26),
(24,'2002-01-28',24,24, 40),
(25,'2000-01-25',25,25, 30),
(26,'2001-06-22',26,26, 40),
(27,'2001-07-30',27,27, 20),
(28,'1998-08-14',28,28, 20),
(29,'1999-08-16',29,29, 30),
(30,'2002-02-10',30,30, 35);

--Insterting data for order line table
INSERT INTO order_line(order_id,book_id,quantity,unit_price) VALUES 
(61,3,2,'30'),
(62,6,1,'10'),
(63,8,2,'20'),
(64,67,3,'10'),
(65,24,3,'30'),
(66,33,2,'20'),
(67,3,1,'10'),
(68,54,4,'20'),
(69,23,2,'30'),
(70,2,4,'20'),
(71,56,1,'24'),
(72,3,1,'26'),
(73,45,1,'30'),
(74,12,2,'10'),
(75,35,3,'20'),
(76,52,2,'20'),
(77,62,2,'10'),
(78,44,2,'26'),
(79,23,1,'15'),
(80,9,1,'20'),
(81,45,1,'16'),
(82,3,1,'30'),
(83,1,2,'20'),
(84,16,3,'30'),
(85,36,2,'10'),
(86,23,4,'10'),
(87,34,3,'20'),
(88,45,1,'15'),
(89,33,2,'10'),
(90,9,3,'20');

--Inserting data Oreder History table
INSERT INTO order_history(order_id,status_id,changed_at,note) VALUES
(61,1,NULL,NULL),
(62,2,NULL,NULL),
(63,3,NULL,NULL),
(64,4,NULL,NULL),
(65,5,NULL,NULL),
(66,6,NULL,NULL),
(67,7,NULL,NULL),
(68,8,NULL,NULL),
(69,9,NULL,NULL),
(70,10,NULL,NULL),
(71,11,NULL,NULL),
(72,12,NULL,NULL),
(73,13,NULL,NULL),
(74,14,NULL,NULL),
(75,15,NULL,NULL),
(76,16,NULL,NULL),
(77,17,NULL,NULL),
(78,18,NULL,NULL),
(79,19,NULL,NULL),
(80,20,NULL,NULL),
(81,21,NULL,NULL),
(82,22,NULL,NULL),
(83,23,NULL,NULL),
(84,24,NULL,NULL),
(85,25,NULL,NULL),
(86,26,NULL,NULL),
(87,27,NULL,NULL),
(88,28,NULL,NULL),
(89,29,NULL,NULL),
(90,30,NULL,NULL);

-- Inserting data customer address table
INSERT INTO customer_address(customer_id,address_id,status_id,added_on) VALUES
(1,1,1,NULL),
(2,2,2,NULL),
(3,3,3,NULL),
(4,4,4,NULL),
(5,5,5,NULL),
(6,6,6,NULL),
(7,7,7,NULL),
(8,8,8,NULL),
(9,9,9,NULL),
(10,10,10,NULL),
(11,11,11,NULL),
(12,12,12,NULL),
(13,13,13,NULL),
(14,14,14,NULL),
(15,15,15,NULL),
(16,16,16,NULL),
(17,17,17,NULL),
(18,18,18,NULL),
(19,19,19,NULL),
(20,20,20,NULL),
(21,21,21,NULL),
(22,22,22,NULL),
(23,23,23,NULL),
(24,24,24,NULL),
(25,25,25,NULL),
(26,26,26,NULL),
(27,27,27,NULL),
(28,28,28,NULL),
(29,29,29,NULL),
(30,30,30,NULL);
