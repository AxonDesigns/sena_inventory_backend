DROP DATABASE inventory;

CREATE DATABASE IF NOT EXISTS inventory;

USE inventory;

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

INSERT INTO
    users (
        name,
        citizen_id,
        email,
        password,
        phone_number,
        role_id
    )
VALUES (
        'Brayan Stiven Hernández Camacho',
        '1005037761',
        'acciol400@gmail.com',
        'acciol4004003131',
        '3133391218',
        1
    );