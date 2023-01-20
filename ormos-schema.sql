DROP DATABASE IF EXISTS ormos;

CREATE DATABASE ormos
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci
;

USE ormos;

CREATE TABLE card_name (
    name    VARCHAR(255)    NOT NULL    PRIMARY KEY
);

CREATE TABLE card_oracle (
    id      /*UUID*/ BINARY(16) NOT NULL    PRIMARY KEY,
        -- The `scryfallOracleId` from the *Card (Atomic)* object
    name    VARCHAR(255)        NOT NULL,
    text    TEXT(1023)          NOT NULL,

    FOREIGN KEY (name) REFERENCES card_name (name)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE expansion_type (
    type    VARCHAR(31) NOT NULL    PRIMARY KEY
);

CREATE TABLE expansion (
    code            VARCHAR(7)      NOT NULL    PRIMARY KEY,
        -- The short code (usually three capital letters)
    name            VARCHAR(127)    NOT NULL    UNIQUE,
    release_date    DATE            NOT NULL,
    type            VARCHAR(31)     NOT NULL,

    FOREIGN KEY (type) REFERENCES expansion_type (type)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    INDEX (release_date)
);

CREATE TABLE card_printing (
    id                          /*UUID*/ BINARY(16) NOT NULL    PRIMARY KEY,
        -- The `scryfallId` from the *Card (Set)* object
    oracle_id                   /*UUID*/ BINARY(16) NOT NULL,
    expansion_code              VARCHAR(7)          NOT NULL,
    collector_number            VARCHAR(15)         NOT NULL,

    FOREIGN KEY (oracle_id) REFERENCES card_oracle (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY (expansion_code) REFERENCES expansion (code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    UNIQUE (expansion_code, collector_number)
);

CREATE VIEW card_printing_full AS
    SELECT
        card_oracle.name,
        card_printing.expansion_code,
        card_printing.collector_number,
        card_printing.id,
        card_printing.oracle_id,
        card_oracle.text AS oracle_text
    FROM
        card_printing
        JOIN card_oracle ON card_oracle.id = card_printing.oracle_id
;

CREATE TABLE card (
    id          INT UNSIGNED        NOT NULL    PRIMARY KEY AUTO_INCREMENT,
    printing_id /*UUID*/ BINARY(16) NOT NULL,

    FOREIGN KEY (printing_id) REFERENCES card_printing (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE VIEW card_full AS
    SELECT
        card.id,
        card_oracle.name,
        card_printing.expansion_code,
        card_printing.collector_number,
        card.printing_id,
        card_printing.oracle_id,
        card_oracle.text AS oracle_text
    FROM
        card
        JOIN card_printing ON card_printing.id = card.printing_id
        JOIN card_oracle ON card_oracle.id = card_printing.oracle_id
;

CREATE TABLE format (
    id      INT UNSIGNED    NOT NULL    PRIMARY KEY,
    name    VARCHAR(63)     NOT NULL    UNIQUE
);

CREATE TABLE format_legality (
    format_id   INT UNSIGNED    NOT NULL,
    card_name   VARCHAR(255)    NOT NULL,

    FOREIGN KEY (format_id) REFERENCES format (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY (card_name) REFERENCES card_name (name)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Polyfill from <https://stackoverflow.com/a/58015720>
DELIMITER $$

CREATE FUNCTION BIN_TO_UUID(b BINARY(16), f BOOLEAN)
RETURNS CHAR(36)
DETERMINISTIC
BEGIN
   DECLARE hexStr CHAR(32);
   SET hexStr = HEX(b);
   RETURN LOWER(CONCAT(
        IF(f,SUBSTR(hexStr, 9, 8),SUBSTR(hexStr, 1, 8)), '-',
        IF(f,SUBSTR(hexStr, 5, 4),SUBSTR(hexStr, 9, 4)), '-',
        IF(f,SUBSTR(hexStr, 1, 4),SUBSTR(hexStr, 13, 4)), '-',
        SUBSTR(hexStr, 17, 4), '-',
        SUBSTR(hexStr, 21)
    ));
END$$

CREATE FUNCTION UUID_TO_BIN(uuid CHAR(36), f BOOLEAN)
RETURNS BINARY(16)
DETERMINISTIC
BEGIN
    RETURN UNHEX(CONCAT(
        IF(f,SUBSTRING(uuid, 15, 4),SUBSTRING(uuid, 1, 8)),
        SUBSTRING(uuid, 10, 4),
        IF(f,SUBSTRING(uuid, 1, 8),SUBSTRING(uuid, 15, 4)),
        SUBSTRING(uuid, 20, 4),
        SUBSTRING(uuid, 25)
    ));
END$$

DELIMITER ;
