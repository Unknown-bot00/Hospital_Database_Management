-- ============================================================
--  HOSPITAL DATABASE MANAGEMENT SYSTEM
--  MySQL Script: DDL + Data + 15 Query Solutions
-- ============================================================

-- ============================================================
--  SECTION 1: DATABASE CREATION
-- ============================================================

CREATE DATABASE IF NOT EXISTS hospital_db;
USE hospital_db;

-- ============================================================
--  SECTION 2: TABLE DEFINITIONS (DDL)
-- ============================================================

CREATE TABLE IF NOT EXISTS physician (
    employeeid  INT          PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    position    VARCHAR(100) NOT NULL,
    ssn         INT          NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS department (
    departmentid INT          PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    head         INT          NOT NULL,
    FOREIGN KEY (head) REFERENCES physician(employeeid)
);

CREATE TABLE IF NOT EXISTS affiliated_with (
    physician           INT     NOT NULL,
    department          INT     NOT NULL,
    primaryaffiliation  BOOLEAN NOT NULL,
    PRIMARY KEY (physician, department),
    FOREIGN KEY (physician)  REFERENCES physician(employeeid),
    FOREIGN KEY (department) REFERENCES department(departmentid)
);

CREATE TABLE IF NOT EXISTS procedure_list (
    code INT            PRIMARY KEY,
    name VARCHAR(200)   NOT NULL,
    cost DECIMAL(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS trained_in (
    physician              INT  NOT NULL,
    treatment              INT  NOT NULL,
    certificationdate      DATE NOT NULL,
    certificationexpires   DATE NOT NULL,
    PRIMARY KEY (physician, treatment),
    FOREIGN KEY (physician) REFERENCES physician(employeeid),
    FOREIGN KEY (treatment) REFERENCES procedure_list(code)
);

CREATE TABLE IF NOT EXISTS patient (
    ssn         INT          PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    address     VARCHAR(200) NOT NULL,
    phone       VARCHAR(20)  NOT NULL,
    insuranceid INT          NOT NULL,
    pcp         INT          NOT NULL,
    FOREIGN KEY (pcp) REFERENCES physician(employeeid)
);

CREATE TABLE IF NOT EXISTS nurse (
    employeeid INT          PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    position   VARCHAR(100) NOT NULL,
    registered BOOLEAN      NOT NULL,
    ssn        INT          NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS appointment (
    appointmentid   INT          PRIMARY KEY,
    patient         INT          NOT NULL,
    prepnurse       INT,
    physician       INT          NOT NULL,
    startdatetime   DATETIME     NOT NULL,
    enddatetime     DATETIME     NOT NULL,
    examinationroom VARCHAR(10)  NOT NULL,
    FOREIGN KEY (patient)   REFERENCES patient(ssn),
    FOREIGN KEY (prepnurse) REFERENCES nurse(employeeid),
    FOREIGN KEY (physician) REFERENCES physician(employeeid)
);

CREATE TABLE IF NOT EXISTS medication (
    code        INT          PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    brand       VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS prescribes (
    physician   INT  NOT NULL,
    patient     INT  NOT NULL,
    medication  INT  NOT NULL,
    date        DATE NOT NULL,
    appointment INT,
    dose        VARCHAR(50) NOT NULL,
    PRIMARY KEY (physician, patient, medication, date),
    FOREIGN KEY (physician)   REFERENCES physician(employeeid),
    FOREIGN KEY (patient)     REFERENCES patient(ssn),
    FOREIGN KEY (medication)  REFERENCES medication(code),
    FOREIGN KEY (appointment) REFERENCES appointment(appointmentid)
);

CREATE TABLE IF NOT EXISTS room (
    roomnumber  INT          PRIMARY KEY,
    roomtype    VARCHAR(50)  NOT NULL,
    blockfloor  INT          NOT NULL,
    blockcode   INT          NOT NULL,
    unavailable BOOLEAN      NOT NULL
);

CREATE TABLE IF NOT EXISTS stay (
    stayid     INT      PRIMARY KEY,
    patient    INT      NOT NULL,
    room       INT      NOT NULL,
    start_time DATETIME NOT NULL,
    end_time   DATETIME NOT NULL,
    FOREIGN KEY (patient) REFERENCES patient(ssn),
    FOREIGN KEY (room)    REFERENCES room(roomnumber)
);

CREATE TABLE IF NOT EXISTS undergoes (
    patient         INT      NOT NULL,
    procedure_code  INT      NOT NULL,
    stay            INT      NOT NULL,
    date            DATETIME NOT NULL,
    physician       INT      NOT NULL,
    assistingnurse  INT,
    PRIMARY KEY (patient, procedure_code, stay),
    FOREIGN KEY (patient)        REFERENCES patient(ssn),
    FOREIGN KEY (procedure_code) REFERENCES procedure_list(code),
    FOREIGN KEY (stay)           REFERENCES stay(stayid),
    FOREIGN KEY (physician)      REFERENCES physician(employeeid),
    FOREIGN KEY (assistingnurse) REFERENCES nurse(employeeid)
);

CREATE TABLE IF NOT EXISTS on_call (
    nurse       INT      NOT NULL,
    blockfloor  INT      NOT NULL,
    blockcode   INT      NOT NULL,
    oncallstart DATETIME NOT NULL,
    oncallend   DATETIME NOT NULL,
    PRIMARY KEY (nurse, blockfloor, blockcode, oncallstart, oncallend),
    FOREIGN KEY (nurse) REFERENCES nurse(employeeid)
);

-- ============================================================
--  SECTION 3: DATA INSERTION
-- ============================================================

-- physician
INSERT INTO physician VALUES
(1, 'John Dorian',         'Staff internist',                   111111111),
(2, 'Eliot Red',           'Attending Physician',                222222222),
(3, 'Christopher Turk',    'Surgical Attending Physician',       333333333),
(4, 'Percival Cox',        'Senior Attending Physician',         444444444),
(5, 'Bob Kelso',           'Head Chief of Medicine',             555555555),
(6, 'Todd Quinlan',        'Surgical Attending Physician',       666666666),
(7, 'John Wen',            'Surgical Attending Physician',       777777777),
(8, 'Keith Dudemeister',   'MD Resident',                        888888888),
(9, 'Molly Clock',         'Attending Psychiatrist',             999999999);

-- department
INSERT INTO department VALUES
(1, 'General Medicine', 4),
(2, 'Surgery',          7),
(3, 'Psychiatry',       9);

-- affiliated_with
INSERT INTO affiliated_with VALUES
(1, 1, TRUE),
(2, 1, TRUE),
(3, 1, FALSE),
(3, 2, TRUE),
(4, 1, TRUE),
(5, 1, TRUE),
(6, 2, TRUE),
(7, 1, FALSE),
(7, 2, TRUE),
(8, 1, TRUE),
(9, 3, TRUE);

-- procedure_list
INSERT INTO procedure_list VALUES
(1, 'Reverse Rhinopodoplasty',          1500.00),
(2, 'Obtuse Pyloric Recombobulation',   3750.00),
(3, 'Folded Demiophtalmectomy',         4500.00),
(4, 'Complete Walletectomy',           10000.00),
(5, 'Obfuscated Dermogastrotomy',       4899.00),
(6, 'Reversible Pancreomyoplasty',      5600.00),
(7, 'Follicular Demiectomy',              25.00);

-- trained_in
INSERT INTO trained_in VALUES
(3, 1, '2008-01-01', '2008-12-31'),
(3, 2, '2008-01-01', '2008-12-31'),
(3, 5, '2008-01-01', '2008-12-31'),
(3, 6, '2008-01-01', '2008-12-31'),
(3, 7, '2008-01-01', '2008-12-31'),
(6, 2, '2008-01-01', '2008-12-31'),
(6, 5, '2007-01-01', '2007-12-31'),
(6, 6, '2008-01-01', '2008-12-31'),
(7, 1, '2008-01-01', '2008-12-31'),
(7, 2, '2008-01-01', '2008-12-31'),
(7, 3, '2008-01-01', '2008-12-31'),
(7, 4, '2008-01-01', '2008-12-31'),
(7, 5, '2008-01-01', '2008-12-31'),
(7, 6, '2008-01-01', '2008-12-31'),
(7, 7, '2008-01-01', '2008-12-31');

-- nurse
INSERT INTO nurse VALUES
(101, 'Carla Espino',    'Head Nurse', TRUE,  111111110),
(102, 'Laverne Roberts', 'Nurse',      TRUE,  222222220),
(103, 'Paul Flowers',    'Nurse',      FALSE, 333333330);

-- patient
INSERT INTO patient VALUES
(100000001, 'John Smith',         '42 Foobar Lane',      '555-0256', 68476213, 1),
(100000002, 'Grace Ritchie',      '37 Snafu Drive',      '555-0512', 36546321, 2),
(100000003, 'Random J. Patient',  '101 Omgbbq Street',   '555-1204', 65465421, 2),
(100000004, 'Dennis Doe',         '1100 Foobaz Avenue',  '555-2048', 68421879, 3);

-- medication
INSERT INTO medication VALUES
(1, 'Procrastin-X',  'X',                    'N/A'),
(2, 'Thesisin',      'Foo Labs',              'N/A'),
(3, 'Awakin',        'Bar Laboratories',      'N/A'),
(4, 'Crescavitin',   'Baz Industries',        'N/A'),
(5, 'Melioraurin',   'Snafu Pharmaceuticals', 'N/A');

-- appointment
INSERT INTO appointment VALUES
(13216584, 100000001, 101, 1, '2008-04-24 10:00', '2008-04-24 11:00', 'A'),
(26548913, 100000002, 101, 2, '2008-04-24 10:00', '2008-04-24 11:00', 'B'),
(36549879, 100000001, 102, 1, '2008-04-25 10:00', '2008-04-25 11:00', 'A'),
(46846589, 100000004, 103, 4, '2008-04-25 10:00', '2008-04-25 11:00', 'B'),
(59871321, 100000004, NULL, 4, '2008-04-26 10:00', '2008-04-26 11:00', 'C'),
(69879231, 100000003, 103, 2, '2008-04-26 10:00', '2008-04-26 00:00', 'C'),
(76983231, 100000001, NULL, 3, '2008-04-26 10:00', '2008-04-26 00:00', 'C'),
(86213939, 100000004, 102, 9, '2008-04-27 10:00', '2008-04-27 11:00', 'A'),
(93216548, 100000002, 101, 2, '2008-04-27 10:00', '2008-04-27 00:00', 'B');

-- prescribes
INSERT INTO prescribes VALUES
(1, 100000001, 1, '2008-04-24', 13216584, '5'),
(9, 100000002, 2, '2008-04-27', 86213939, '10'),
(9, 100000003, 2, '2008-04-30', NULL,     '5');

-- room
INSERT INTO room VALUES
(101, 'Single', 1, 1, FALSE), (102, 'Single', 1, 1, FALSE), (103, 'Single', 1, 1, FALSE),
(111, 'Single', 1, 2, FALSE), (112, 'Single', 1, 2, TRUE),  (113, 'Single', 1, 2, FALSE),
(121, 'Single', 1, 3, FALSE), (122, 'Single', 1, 3, FALSE), (123, 'Single', 1, 3, FALSE),
(201, 'Single', 2, 1, TRUE),  (202, 'Single', 2, 1, FALSE), (203, 'Single', 2, 1, FALSE),
(211, 'Single', 2, 2, FALSE), (212, 'Single', 2, 2, FALSE), (213, 'Single', 2, 2, TRUE),
(221, 'Single', 2, 3, FALSE), (222, 'Single', 2, 3, FALSE), (223, 'Single', 2, 3, FALSE),
(301, 'Single', 3, 1, FALSE), (302, 'Single', 3, 1, TRUE),  (303, 'Single', 3, 1, FALSE),
(311, 'Single', 3, 2, FALSE), (312, 'Single', 3, 2, FALSE), (313, 'Single', 3, 2, FALSE),
(321, 'Single', 3, 3, TRUE),  (322, 'Single', 3, 3, FALSE), (323, 'Single', 3, 3, FALSE),
(401, 'Single', 4, 1, FALSE), (402, 'Single', 4, 1, TRUE),  (403, 'Single', 4, 1, FALSE),
(411, 'Single', 4, 2, FALSE), (412, 'Single', 4, 2, FALSE), (413, 'Single', 4, 2, FALSE),
(421, 'Single', 4, 3, TRUE),  (422, 'Single', 4, 3, FALSE), (423, 'Single', 4, 3, FALSE);

-- stay
INSERT INTO stay VALUES
(3215, 100000001, 111, '2008-05-01 00:00:00', '2008-05-04 00:00:00'),
(3216, 100000003, 123, '2008-05-03 00:00:00', '2008-05-14 00:00:00'),
(3217, 100000004, 112, '2008-05-02 00:00:00', '2008-05-03 00:00:00');

-- undergoes
INSERT INTO undergoes VALUES
(100000001, 6, 3215, '2008-05-02 00:00:00', 3, 101),
(100000001, 2, 3215, '2008-05-03 00:00:01', 7, 101),
(100000004, 1, 3217, '2008-05-07 00:00:02', 3, 102),
(100000004, 5, 3217, '2008-05-09 00:00:03', 6, NULL),
(100000001, 7, 3217, '2008-05-10 00:00:04', 7, 102),
(100000004, 4, 3217, '2008-05-13 00:00:05', 3, 103);

-- on_call
INSERT INTO on_call VALUES
(101, 1, 1, '2008-11-04 11:00:00', '2008-11-04 19:00:00'),
(101, 1, 2, '2008-11-04 11:00:00', '2008-11-04 19:00:00'),
(102, 1, 3, '2008-11-04 11:00:00', '2008-11-04 19:00:00'),
(103, 1, 1, '2008-11-04 19:00:00', '2008-11-05 03:00:00'),
(103, 1, 2, '2008-11-04 19:00:00', '2008-11-05 03:00:00'),
(103, 1, 3, '2008-11-04 19:00:00', '2008-11-05 03:00:00');

-- ============================================================
--  SECTION 4: QUERY SOLUTIONS
-- ============================================================

-- -------------------------------------------------------
-- Q1: Physicians who are department heads
-- -------------------------------------------------------
SELECT p.employeeid,
       p.name       AS physician_name,
       p.position,
       d.name       AS department_name
FROM   physician p
JOIN   department d ON d.head = p.employeeid;

-- -------------------------------------------------------
-- Q2: Floor and block where room 212 is located
-- -------------------------------------------------------
SELECT roomnumber,
       blockfloor AS floor,
       blockcode  AS block
FROM   room
WHERE  roomnumber = 212;

-- -------------------------------------------------------
-- Q3: Count of unavailable rooms
-- -------------------------------------------------------
SELECT COUNT(*) AS "Number of unavailable rooms"
FROM   room
WHERE  unavailable = TRUE;

-- -------------------------------------------------------
-- Q4: Physician and their affiliated department(s)
-- -------------------------------------------------------
SELECT p.name       AS physician_name,
       d.name       AS department_name,
       aw.primaryaffiliation
FROM   affiliated_with aw
JOIN   physician   p ON p.employeeid  = aw.physician
JOIN   department  d ON d.departmentid = aw.department
ORDER  BY p.employeeid;

-- -------------------------------------------------------
-- Q5: Physicians who have received special training
-- -------------------------------------------------------
SELECT DISTINCT p.employeeid,
                p.name     AS physician_name,
                p.position
FROM   physician  p
JOIN   trained_in t ON t.physician = p.employeeid;

-- -------------------------------------------------------
-- Q6: Patients and the number of physicians they have
--     scheduled appointments with
-- -------------------------------------------------------
SELECT pt.name                         AS patient_name,
       COUNT(DISTINCT a.physician)     AS number_of_physicians
FROM   patient      pt
JOIN   appointment  a  ON a.patient = pt.ssn
GROUP  BY pt.ssn, pt.name
ORDER  BY number_of_physicians DESC;

-- -------------------------------------------------------
-- Q7: Count of unique patients scheduled for room 'C'
-- -------------------------------------------------------
SELECT COUNT(DISTINCT patient) AS unique_patients_in_room_C
FROM   appointment
WHERE  examinationroom = 'C';

-- -------------------------------------------------------
-- Q8: Available rooms per floor per block (sorted by floor, block)
-- -------------------------------------------------------
SELECT blockfloor          AS floor_id,
       blockcode           AS block_id,
       COUNT(*)            AS available_rooms
FROM   room
WHERE  unavailable = FALSE
GROUP  BY blockfloor, blockcode
ORDER  BY blockfloor, blockcode;

-- -------------------------------------------------------
-- Q9: VIEW — patient name, block, floor, room (admitted patients)
-- -------------------------------------------------------
CREATE OR REPLACE VIEW patient_admission_details AS
SELECT pt.name       AS patient_name,
       r.blockfloor  AS floor,
       r.blockcode   AS block,
       r.roomnumber  AS room_number
FROM   patient pt
JOIN   stay    s  ON s.patient    = pt.ssn
JOIN   room    r  ON r.roomnumber = s.room;

-- Query the view:
SELECT * FROM patient_admission_details;

-- -------------------------------------------------------
-- Q10: Patients who underwent a procedure costing > $5,000,
--      along with their primary care physician
-- -------------------------------------------------------
SELECT DISTINCT pt.name           AS patient_name,
                pl.name           AS procedure_name,
                pl.cost,
                ph.name           AS primary_care_physician
FROM   undergoes      u
JOIN   patient        pt ON pt.ssn  = u.patient
JOIN   procedure_list pl ON pl.code = u.procedure_code
JOIN   physician      ph ON ph.employeeid = pt.pcp
WHERE  pl.cost > 5000;

-- -------------------------------------------------------
-- Q11: Patients whose primary care physician is NOT a
--      department head
-- -------------------------------------------------------
SELECT pt.name  AS patient_name,
       ph.name  AS primary_care_physician
FROM   patient    pt
JOIN   physician  ph ON ph.employeeid = pt.pcp
WHERE  ph.employeeid NOT IN (
    SELECT head FROM department
);

-- -------------------------------------------------------
-- Q12: Patients prescribed at least one medication by a
--      physician from the Psychiatry department (subquery)
-- -------------------------------------------------------
SELECT DISTINCT pt.name AS patient_name
FROM   patient pt
WHERE  pt.ssn IN (
    SELECT pr.patient
    FROM   prescribes pr
    WHERE  pr.physician IN (
        SELECT aw.physician
        FROM   affiliated_with aw
        JOIN   department       d  ON d.departmentid = aw.department
        WHERE  d.name = 'Psychiatry'
    )
);

-- -------------------------------------------------------
-- Q13: TRIGGER — prevent inserting an appointment if the
--      physician has no primary affiliation with any dept
-- -------------------------------------------------------
DELIMITER $$

CREATE TRIGGER trg_check_physician_affiliation
BEFORE INSERT ON appointment
FOR EACH ROW
BEGIN
    DECLARE affil_count INT;

    SELECT COUNT(*)
    INTO   affil_count
    FROM   affiliated_with
    WHERE  physician          = NEW.physician
      AND  primaryaffiliation = TRUE;

    IF affil_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Cannot schedule appointment: physician has no primary department affiliation.';
    END IF;
END$$

DELIMITER ;

-- -------------------------------------------------------
-- Q14: Update insurance ID of patients whose PCP is
--      'John Dorian' to 99999999
-- -------------------------------------------------------
UPDATE patient
SET    insuranceid = 99999999
WHERE  pcp = (
    SELECT employeeid
    FROM   physician
    WHERE  name = 'John Dorian'
);

-- Verify:
SELECT name, insuranceid
FROM   patient
WHERE  pcp = (SELECT employeeid FROM physician WHERE name = 'John Dorian');

-- -------------------------------------------------------
-- Q15: Each physician's name, appointment count, and rank
--      (descending order of appointments)
-- -------------------------------------------------------
SELECT p.name                                              AS physician_name,
       COUNT(a.appointmentid)                              AS total_appointments,
       RANK() OVER (ORDER BY COUNT(a.appointmentid) DESC)  AS appointment_rank
FROM   physician   p
LEFT   JOIN appointment a ON a.physician = p.employeeid
GROUP  BY p.employeeid, p.name
ORDER  BY appointment_rank;
