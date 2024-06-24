DROP DATABASE inventory;

CREATE DATABASE IF NOT EXISTS inventory;

USE inventory;

DROP TABLE IF EXISTS files;

CREATE TABLE IF NOT EXISTS files (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    mime_type VARCHAR(255) NOT NULL,
    data LONGBLOB NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

DROP TABLE IF EXISTS roles;

create table roles (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO roles (name) VALUES ('admin'), ('employee');

DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    citizen_id VARCHAR(10) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone_number VARCHAR(10) NOT NULL,
    role_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_role_id FOREIGN KEY (role_id) REFERENCES roles (id),
    CONSTRAINT unique_email UNIQUE (email),
    CONSTRAINT check_email_validity CHECK (
        email regexp '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    ),
    CONSTRAINT check_password_length CHECK (length(password) >= 6)
);

DROP TABLE IF EXISTS departments;

CREATE TABLE IF NOT EXISTS departments (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

DROP TABLE IF EXISTS cities;

CREATE TABLE IF NOT EXISTS cities (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    department_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_department_id FOREIGN KEY (department_id) REFERENCES departments (id)
);

DROP TABLE IF EXISTS location_types;

CREATE TABLE IF NOT EXISTS location_types (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

DROP TABLE IF EXISTS locations;

CREATE TABLE IF NOT EXISTS locations (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    city_id BIGINT NOT NULL,
    location_type_id BIGINT NOT NULL,
    address VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_city_id FOREIGN KEY (city_id) REFERENCES cities (id),
    CONSTRAINT fk_location_type_id FOREIGN KEY (location_type_id) REFERENCES location_types (id)
);

DROP TABLE IF EXISTS product_types;

CREATE TABLE IF NOT EXISTS product_types (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

DROP TABLE IF EXISTS product_states;

CREATE TABLE IF NOT EXISTS product_states (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

DROP TABLE IF EXISTS units;

CREATE TABLE IF NOT EXISTS units (
    id BIGINT NOT NULL AUTO_INCREMENT,
    symbol VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

DROP TABLE IF EXISTS products;

CREATE TABLE IF NOT EXISTS products (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    unit_id BIGINT NOT NULL,
    product_type_id BIGINT NOT NULL,
    product_state_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_product_type_id FOREIGN KEY (product_type_id) REFERENCES product_types (id),
    CONSTRAINT fk_product_state_id FOREIGN KEY (product_state_id) REFERENCES product_states (id),
    CONSTRAINT fk_unit_id FOREIGN KEY (unit_id) REFERENCES units (id)
);

DROP TABLE IF EXISTS product_attachments;

CREATE TABLE IF NOT EXISTS product_attachments (
    id BIGINT NOT NULL AUTO_INCREMENT,
    file_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_product_id FOREIGN KEY (product_id) REFERENCES products (id),
    CONSTRAINT fk_file_id FOREIGN KEY (file_id) REFERENCES files (id)
);

DROP TABLE IF EXISTS suppliers;

CREATE TABLE IF NOT EXISTS suppliers (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    nit_number VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone_number VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

DROP TABLE IF EXISTS transaction_types;

CREATE TABLE IF NOT EXISTS transaction_types (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
);

INSERT INTO
    transaction_types (name)
VALUES ('income'),
    ('expense'),
    ('transfer');

DROP TABLE IF EXISTS transactions;

CREATE TABLE IF NOT EXISTS transactions (
    id BIGINT NOT NULL AUTO_INCREMENT,
    description VARCHAR(255) NOT NULL,
    transaction_type_id BIGINT NOT NULL,
    responsible_id BIGINT NOT NULL,
    source_id BIGINT,
    destination_id BIGINT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_transaction_type_id FOREIGN KEY (transaction_type_id) REFERENCES transaction_types (id),
    CONSTRAINT fk_responsible_id FOREIGN KEY (responsible_id) REFERENCES users (id),
    CONSTRAINT fk_source_id FOREIGN KEY (source_id) REFERENCES users (id),
    CONSTRAINT fk_destination_id FOREIGN KEY (destination_id) REFERENCES users (id)
);

DROP TABLE IF EXISTS transaction_products;

CREATE TABLE IF NOT EXISTS transaction_products (
    id BIGINT NOT NULL AUTO_INCREMENT,
    amount DECIMAL(10, 2) NOT NULL,
    transaction_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_transaction_id FOREIGN KEY (transaction_id) REFERENCES transactions (id),
    CONSTRAINT fk_product_id FOREIGN KEY (product_id) REFERENCES products (id)
);

SELECT
    id,
    citizen_id,
    name,
    email,
    phone_number,
    password,
    role_id,
    created_at,
    updated_at
FROM users
LIMIT 10
OFFSET
    0;