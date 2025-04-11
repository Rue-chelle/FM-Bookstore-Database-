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

/* Inserting sample data */
USE bookstoredb;

-- inserting sample data for book language table
INSERT INTO book_language (language_id, language_name, language_code) VALUES
(1, 'English', 'en'),
(2, 'Spanish', 'es'),
(3, 'French', 'fr'),
(4, 'German', 'de');

-- inserting sample data for publishers table
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

-- inserting sample data for authors table
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

-- code for inserting missing authors
INSERT INTO author (author_id, first_name, last_name, bio) VALUES
(63, 'Leo', 'Tolstoy', 'Russian novelist'),
(64, 'Fyodor', 'Dostoevsky', 'Russian novelist'),
(65, 'J.D.', 'Salinger', 'American author'),
(66, 'Homer', '', 'Ancient Greek poet'),
(67, 'S.E.', 'Hinton', 'American novelist');

-- inserting sample data for books table
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

-- inserting sample data for book-author joining table
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
