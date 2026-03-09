CREATE DATABASE vottech_institutional;

USE vottech_institutional;

/*
 * Tabela: tabela de instituições
 * authors: Kevin da Costa Vinagre
 * data: 04-03-2026
 */
CREATE TABLE
    institutes (
        id INT PRIMARY KEY AUTO_INCREMENT,
        cnpj VARCHAR(168) NOT NULL,
        name VARCHAR(168) NOT NULL,
        locallat float NOT NULL,
        locallong float NOT NULL
    );

/*
 * Tabela: tabela de coordenadores
 * authors: Kevin da Costa Vinagre
 * data: 04-03-2026
 */
CREATE TABLE
    coordinators (
        id INT PRIMARY KEY AUTO_INCREMENT,
        cpf VARCHAR(11) NOT NULL,
        name VARCHAR(168) NOT NULL,
        email VARCHAR(168) NOT NULL,
        pass TEXT NOT NULL,
        status char(1) NOT NULL DEFAULT 'A'
    );

CREATE TABLE
    coordinators_institutes (
        id INT PRIMARY KEY AUTO_INCREMENT,
        coordinator_id INT NOT NULL,
        institute_id INT NOT NULL,
        CONSTRAINT coordinator_fk FOREIGN KEY (coordinator_id) REFERENCES coordinators (id),
        CONSTRAINT institute_fk FOREIGN KEY (institute_id) REFERENCES institutes (id)
    );

CREATE TABLE
    events (
        id INT PRIMARY KEY AUTO_INCREMENT,
        name VARCHAR(168) NOT NULL,
        description TEXT NOT NULL,
        locallat float NOT NULL,
        locallong float NOT NULL,
        start_date DATE NOT NULL,
        end_date DATE NOT NULL,
        status char(1) NOT NULL DEFAULT 'A'
    );

CREATE TABLE
    events_institutes (
        id INT PRIMARY KEY AUTO_INCREMENT,
        event_id INT NOT NULL,
        institute_id INT NOT NULL,
        CONSTRAINT event_fk FOREIGN KEY (event_id) REFERENCES events (id),
        CONSTRAINT institute_events_fk FOREIGN KEY (institute_id) REFERENCES institutes (id)
    );

CREATE TABLE
    projects (
        id INT PRIMARY KEY AUTO_INCREMENT,
        name VARCHAR(168) NOT NULL,
        description TEXT NOT NULL,
        status char(1) NOT NULL DEFAULT 'A'
    );

CREATE TABLE
    events_projects (
        id INT PRIMARY KEY AUTO_INCREMENT,
        event_id INT NOT NULL,
        project_id INT NOT NULL,
        CONSTRAINT event_projects_fk FOREIGN KEY (event_id) REFERENCES events (id),
        CONSTRAINT project_fk FOREIGN KEY (project_id) REFERENCES projects (id)
    );

INSERT INTO
    institutes (cnpj, name, locallat, locallong) VALUE ('1230123-2312/1', 'FUCAPI', 72.3, 54.5);

INSERT INTO
    coordinators (cpf, name, email, pass) VALUE (
        '01766502220',
        'Kevin da Costa Vinagre',
        'lkevinvinagre@hotmail.com',
        MD5 ('kevin123')
    );

INSERT INTO
    coordinators_institutes (coordinator_id, institute_id) VALUE (1, 1);