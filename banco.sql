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

CREATE TABLE
    institutes_log (
        id INT AUTO_INCREMENT PRIMARY KEY,
        coordinator_id INT,
        operation_type ENUM ('INSERT', 'UPDATE', 'DELETE'),
        old_data JSON,
        new_data JSON,
        changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        changed_by VARCHAR(100)
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
    coordinators_log (
        id INT AUTO_INCREMENT PRIMARY KEY,
        coordinator_id INT,
        operation_type ENUM ('INSERT', 'UPDATE', 'DELETE'),
        old_data JSON,
        new_data JSON,
        changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        changed_by VARCHAR(100)
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
    events_log (
        id INT AUTO_INCREMENT PRIMARY KEY,
        coordinator_id INT,
        operation_type ENUM ('INSERT', 'UPDATE', 'DELETE'),
        old_data JSON,
        new_data JSON,
        changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        changed_by VARCHAR(100)
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
    projects_log (
        id INT AUTO_INCREMENT PRIMARY KEY,
        coordinator_id INT,
        operation_type ENUM ('INSERT', 'UPDATE', 'DELETE'),
        old_data JSON,
        new_data JSON,
        changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        changed_by VARCHAR(100)
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

/*
 *Procedure Registro de usuario;
 *author: Kevin da Costa Vinagre
 *date: 09-03-2026
 */
DELIMITER $$

CREATE PROCEDURE add_institute(
    IN p_coordinator_id INT,
    IN p_cnpj           VARCHAR(168),
    IN p_name           VARCHAR(168),
    IN p_locallat       FLOAT,
    IN p_locallong      FLOAT,
    IN p_changed_by     VARCHAR(100)
)
BEGIN
    DECLARE coordinator_id_log INT;
    DECLARE new_data_log TEXT;

    INSERT INTO institutes (cnpj, name, locallat, locallong)
    VALUES (p_cnpj, p_name, p_locallat, p_locallong);

    SET coordinator_id_log = LAST_INSERT_ID();

    SET new_data_log = JSON_OBJECT(
        'id',        coordinator_id_log,
        'cnpj',      p_cnpj,
        'name',      p_name,
        'locallat',  p_locallat,
        'locallong', p_locallong
    );

    INSERT INTO institutes_log (
        coordinator_id,
        operation_type,
        old_data,
        new_data,
        changed_by
    )
    VALUES (
        p_coordinator_id,
        'INSERT',
        NULL,
        new_data_log,
        p_changed_by
    );

    SELECT coordinator_id_log AS inserted_id;
END$$

/**
    Teste de chamada da procedure add_institute;
    author: Kevin da Costa Vinagre
    date: 12-03-2026
*/
CALL update_institute(
    1,
    3,
    '1230123-2312/1',
    'FUCAPI',
    7332.3,
    54324.5,
    'Kevin da Costa Vinagre'
);

/**
 Procedure que atualiza os dados de um coordenador;
 autor: Kevin da Costa Vinagre
 data: 12-03-2026 
*/
DELIMITER $$

CREATE PROCEDURE update_institute(
    IN p_coordinator_id INT,
    IN p_institute_id   INT,
    IN p_cnpj           VARCHAR(168),
    IN p_name           VARCHAR(168),
    IN p_locallat       FLOAT,
    IN p_locallong      FLOAT,
    IN p_changed_by     VARCHAR(100)
)
BEGIN
    DECLARE v_old_data TEXT;
    DECLARE v_new_data TEXT;
    
    IF NOT EXISTS (SELECT 1 FROM institutes WHERE id = p_institute_id) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Instituto não encontrado.';
    END IF;

    SELECT JSON_OBJECT(
        'id',        id,
        'cnpj',      cnpj,
        'name',      name,
        'locallat',  locallat,
        'locallong', locallong
    )
    INTO v_old_data
    FROM institutes
    WHERE id = p_institute_id;

    UPDATE institutes
    SET
        cnpj      = p_cnpj,
        name      = p_name,
        locallat  = p_locallat,
        locallong = p_locallong
    WHERE id = p_institute_id;

    SET v_new_data = JSON_OBJECT(
        'id',        p_institute_id,
        'cnpj',      p_cnpj,
        'name',      p_name,
        'locallat',  p_locallat,
        'locallong', p_locallong
    );

    INSERT INTO institutes_log (
        coordinator_id,
        operation_type,
        old_data,
        new_data,
        changed_by
    )
    VALUES (
        p_coordinator_id,
        'UPDATE',
        v_old_data,
        v_new_data,
        p_changed_by
    );

    SELECT ROW_COUNT() AS rows_affected;
END$$

DELIMITER ;

DELIMITER $$
create procedure add_coordinator(
    IN p_cpf VARCHAR(11),
    IN p_name VARCHAR(168),
    IN p_email VARCHAR(168),
    IN p_pass TEXT
)
BEGIN
INSERT INTO coordinators (
    cpf,
    name,
    email,
    pass
)
VALUES (
    p_cpf,
    p_name,
    p_email,
    p_pass
);
END $$
DELIMITER

