--Fitness Center Membership and attendance analysis

create database Fitness_Center;
use fitness_Center;
CREATE TABLE Membership_Plans (
    plan_id INT PRIMARY KEY,
    plan_name VARCHAR(100),
    duration VARCHAR(30),
    fee DECIMAL(10,2),
    duration_months INT,
    benefits VARCHAR(255)
);
CREATE TABLE Trainers (
    trainer_id INT PRIMARY KEY,
    trainer_name VARCHAR(100),
    specialization VARCHAR(100),
    experience_years INT,
    shift VARCHAR(30)
);
CREATE TABLE Members (
    member_id INT PRIMARY KEY,
    member_name VARCHAR(100),
    gender VARCHAR(20),
    age INT,
    city VARCHAR(50),
    join_date DATE,
    plan_id INT,
    trainer_id INT,
    membership_end_date DATE,
    membership_status VARCHAR(30),

    FOREIGN KEY (plan_id)
        REFERENCES Membership_Plans(plan_id),

    FOREIGN KEY (trainer_id)
        REFERENCES Trainers(trainer_id)
);
CREATE TABLE Memberships (
    membership_id INT PRIMARY KEY,
    member_id INT,
    plan_id INT,
    start_date DATE,
    end_date DATE,
    status VARCHAR(30),

    FOREIGN KEY (member_id)
        REFERENCES Members(member_id),

    FOREIGN KEY (plan_id)
        REFERENCES Membership_Plans(plan_id)
);
CREATE TABLE Attendance (
    attendance_id INT PRIMARY KEY,
    member_id INT,
    attendance_date DATE,
    check_in_time TIME,
    duration_minutes INT,
    workout_type VARCHAR(100),
    trainer_id INT,
    attendance_status VARCHAR(30),

    FOREIGN KEY (member_id)
        REFERENCES Members(member_id),

    FOREIGN KEY (trainer_id)
        REFERENCES Trainers(trainer_id)
);
SHOW TABLES;
SELECT * FROM attendance;
SELECT * FROM members;
SELECT * FROM Membership_Plans;
SELECT * FROM Memberships;
SELECT * FROM trainers;

#1 Aggregate Functions.
-- 1. Find the total number of members.
SELECT COUNT(*) AS total_members
FROM Members;


-- 2. Find the average age of members.
SELECT AVG(age) AS average_age
FROM Members;


-- 3. Find the youngest and oldest member.
SELECT MIN(age) AS youngest_age,
       MAX(age) AS oldest_age
FROM Members;


-- 4. Count the number of members in each city.
SELECT city, COUNT(*) AS total_members
FROM Members
GROUP BY city;


-- 5. Count members according to their membership status.
SELECT membership_status, COUNT(*) AS total_members
FROM Members
GROUP BY membership_status;


-- 6. Find the average experience of all trainers.
SELECT AVG(experience_years) AS average_experience
FROM Trainers;


-- 7. Find the total number of attendance records.
SELECT COUNT(*) AS total_attendance
FROM Attendance;


-- 8. Find the average workout duration.
SELECT AVG(duration_minutes) AS average_duration
FROM Attendance;


-- 9. Find the total workout duration for each workout type.
SELECT workout_type,
       SUM(duration_minutes) AS total_duration
FROM Attendance
GROUP BY workout_type;


-- 10. Count attendance records for each workout type.
SELECT workout_type,
       COUNT(*) AS total_attendance
FROM Attendance
GROUP BY workout_type;


#2. JOINS

-- 11. Display member names with their membership plan names.
SELECT member_name,
       plan_name
FROM Members m
JOIN Membership_Plans p
ON plan_id = plan_id;


-- 12. Display member names with their trainer names.
SELECT member_name,
       trainer_name
FROM Members m
JOIN Trainers t
ON trainer_id = trainer_id;


-- 13. Display members with their plan name and plan fee.
SELECT member_name,
       plan_name,
       fee
FROM Members m
JOIN Membership_Plans p
ON plan_id = plan_id;


-- 14. Display membership details with member names.
DESCRIBE Members;
DESCRIBE Memberships;
SELECT member_name,
       member_id,
      ms.plan_id,
       start_date,
       end_date,
       status
FROM Memberships AS ms
JOIN Members AS m
ON member_id =member_id;


-- 15. Display members along with their trainer and membership plan.
SELECT member_name,
       trainer_name,
       plan_name
FROM Members m
JOIN Trainers t
ON trainer_id = trainer_id
JOIN Membership_Plans p
ON plan_id = plan_id;

#3.SUBQUERY

-- 16. Find members whose age is greater than the average age.
SELECT member_name, age
FROM Members
WHERE age > (
    SELECT AVG(age)
    FROM Members
);


    -- 17 Find attendance records with duration greater than the average duration.
SELECT member_id,
       duration_minutes
FROM Attendance
WHERE duration_minutes > (
    SELECT AVG(duration_minutes)
    FROM Attendance
);


-- 18. Find the most expensive membership plan.
SELECT plan_name, fee
FROM Membership_Plans
WHERE fee = (
    SELECT MAX(fee)
    FROM Membership_Plans
);


-- 19. Find members who are using the most expensive membership plan.
SELECT member_name, plan_id
FROM Members
WHERE plan_id = (
    SELECT plan_id
    FROM Membership_Plans
    WHERE fee = (
        SELECT MAX(fee)
        FROM Membership_Plans
    )
);


-- 20. Find trainers whose experience is greater than average experience.
SELECT trainer_name, experience_years
FROM Trainers
WHERE experience_years > (
    SELECT AVG(experience_years)
    FROM Trainers
);


#4.WINDOW FUNCTION

-- 21. Rank members according to their age from highest to lowest.
SELECT member_name,
       age,
       RANK() OVER (ORDER BY age DESC) AS age_rank
FROM Members;


-- 22. Give a serial number to each member.
SELECT member_name,
       ROW_NUMBER() OVER (ORDER BY member_name) AS sr_no
FROM Members;


-- 23. Rank trainers according to their experience.
SELECT trainer_name,
       experience_years,
       RANK() OVER (ORDER BY experience_years DESC) AS experience_rank
FROM Trainers;


-- 24. Rank attendance records according to workout duration.
SELECT member_id,
       workout_type,
       duration_minutes,
       RANK() OVER (ORDER BY duration_minutes DESC) AS duration_rank
FROM Attendance;

-- 25. Show each member and the total number of members having the same plan.
SELECT member_name,
       plan_id,
       COUNT(*) OVER (PARTITION BY plan_id) AS members_in_same_plan
FROM Members;


-- 26. Show each member and their age rank within their city.
SELECT member_name,
       city,
       age,
       RANK() OVER (
           PARTITION BY city
           ORDER BY age DESC
       ) AS city_age_rank
FROM Members;


-- 27. Show each workout type with its total duration using a window function.
SELECT member_id,+
       workout_type,
       duration_minutes,
       SUM(duration_minutes) OVER (
           PARTITION BY workout_type
       ) AS total_workout_duration
FROM Attendance;

-- 28. Show each membership plan with the average fee of all plans.
SELECT plan_name,
       fee,
       AVG(fee) OVER () AS average_plan_fee
FROM Membership_Plans;

-- 29. Find the number of members handled by each trainer.
DESCRIBE Trainers;
SELECT trainer_name,
       COUNT(*) AS total_members
FROM Trainers AS t
LEFT JOIN Members AS m
ON trainer_id = m.trainer_id
GROUP BY trainer_id, trainer_name; 


#5. LEFT JOIN + GROUP BY
-- 30. Find the total attendance duration for each member.
SELECT member_name,
       SUM(duration_minutes) AS total_duration
FROM Members m
JOIN Attendance a
ON member_id = member_id
GROUP BY member_id, member_name;