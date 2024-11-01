-- Drop database if it exists and create a new onesql
DROP DATABASE IF EXISTS schedula;
CREATE DATABASE schedula;
USE schedula;

-- Table: teams
CREATE TABLE teams (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: users
CREATE TABLE users (
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	team_id INT ,
	google_id VARCHAR(255) UNIQUE,
	picture VARCHAR(2048),
	display_name VARCHAR(255),
	user_role VARCHAR(10) NOT NULL,
	first_name VARCHAR(255) NOT NULL,
	middle_name VARCHAR(255),
	last_name VARCHAR(255) NOT NULL,
	password VARCHAR(255) NOT NULL,
	email VARCHAR(255) UNIQUE,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (team_id) REFERENCES teams(id)
);

-- Table: shift_types
CREATE TABLE shift_types (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  team_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (team_id) REFERENCES teams(id),
  UNIQUE (name)
);

-- Table: schedules
CREATE TABLE schedules (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  team_id INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  published BOOLEAN NOT NULL,
  rating INT,
  notes VARCHAR(1024),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (team_id) REFERENCES teams(id),
  UNIQUE (team_id, start_date, end_date)
);

-- Table: shifts
CREATE TABLE shifts (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  schedule_id INT NOT NULL,
  shift_type_id INT NOT NULL,
  shift_name VARCHAR(255) NOT NULL,
  date DATE NOT NULL,
  required_count INT NOT NULL,
  actual_count INT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (schedule_id) REFERENCES schedules(id),
  FOREIGN KEY (shift_type_id) REFERENCES shift_types(id)
);

-- Table: time_ranges
CREATE TABLE time_ranges (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  shift_id INT NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (shift_id) REFERENCES shifts(id)
);

-- Table: constraints
CREATE TABLE constraints (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  team_id INT NOT NULL,
  shift_type_id INT NOT NULL,
  next_id INT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (team_id) REFERENCES teams(id),
  FOREIGN KEY (shift_type_id) REFERENCES shift_types(id),
  FOREIGN KEY (next_id) REFERENCES constraints(id)
);

-- Table: constraint_time_ranges
CREATE TABLE constraint_time_ranges (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  constraint_id INT NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (constraint_id) REFERENCES constraints(id)
);

-- Table: preferences
CREATE TABLE preferences (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  notes VARCHAR(1024),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  UNIQUE (user_id, start_date, end_date)
);

-- Updated Table: daily_preferences
CREATE TABLE daily_preferences (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  preference_id INT NOT NULL,
  date DATE NOT NULL,
  shift_type_id INT NOT NULL,
  preference_level INT NOT NULL, -- e.g., 1 (low) to 5 (high)
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (preference_id) REFERENCES preferences(id),
  FOREIGN KEY (shift_type_id) REFERENCES shift_types(id),
  UNIQUE (preference_id, date, shift_type_id)
);

-- Table: vacations
CREATE TABLE vacations (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  UNIQUE (user_id, start_date, end_date)
);

-- Table: schedule_likes
CREATE TABLE schedule_likes (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  schedule_id INT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (schedule_id) REFERENCES schedules(id),
  UNIQUE (user_id, schedule_id)
);

-- Table: shift_likes
CREATE TABLE shift_likes (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  shift_id INT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (shift_id) REFERENCES shifts(id),
  UNIQUE (user_id, shift_id)
);

-- Table: user_shifts
CREATE TABLE user_shifts (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  shift_id INT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (shift_id) REFERENCES shifts(id),
  UNIQUE (user_id, shift_id)
);

-- Table: attendance
CREATE TABLE attendance (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  shift_id INT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (shift_id) REFERENCES shifts(id)
);

-- Table: late
CREATE TABLE late (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  shift_id INT NOT NULL,
  comment VARCHAR(1024) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (shift_id) REFERENCES shifts(id)
);

-- Table: events
CREATE TABLE events (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  team_id INT NOT NULL,
  event_participants INT,
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP NOT NULL,
  location_id INT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (team_id) REFERENCES teams(id)
);

-- Table: event_participants
CREATE TABLE event_participants (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  event_id INT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (event_id) REFERENCES events(id)
);

-- Table: locations
CREATE TABLE locations (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  event_id INT NOT NULL,
  longitude DECIMAL(9,6),
  latitude DECIMAL(9,6),
  FOREIGN KEY (event_id) REFERENCES events(id)
);

-- Table: remarks
CREATE TABLE remarks (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  schedule_id INT NOT NULL,
  content VARCHAR(1024) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (schedule_id) REFERENCES schedules(id)
);

-- Table: feedback
CREATE TABLE feedback (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  content VARCHAR(1024) NOT NULL,
  sentiment VARCHAR(50),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE expired (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    token TEXT NOT NULL,              -- Using TEXT instead of VARCHAR for larger tokens
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_created_at (created_at),  -- Index for faster cleanup queries
    INDEX idx_token (token(255))        -- Index first 255 characters of token for lookups
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: template_schedules
CREATE TABLE template_schedules (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  team_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  notes TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (team_id) REFERENCES teams(id)
);

-- Table: template_shifts
CREATE TABLE template_shifts (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  template_schedule_id INT NOT NULL,
  shift_type_id INT NOT NULL,
  shift_name VARCHAR(255) NOT NULL,
  required_count INT NOT NULL,
  day_of_week INT NOT NULL, -- 0 for Sunday, 1 for Monday, etc.
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (template_schedule_id) REFERENCES template_schedules(id),
  FOREIGN KEY (shift_type_id) REFERENCES shift_types(id)
);

-- Table: template_time_ranges
CREATE TABLE template_time_ranges (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  template_shift_id INT NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (template_shift_id) REFERENCES template_shifts(id)
);

-- Table: template_constraints
CREATE TABLE template_constraints (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  template_schedule_id INT NOT NULL,
  shift_type_id INT NOT NULL,
  next_shift_type_id INT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (template_schedule_id) REFERENCES template_schedules(id),
  FOREIGN KEY (shift_type_id) REFERENCES shift_types(id),
  FOREIGN KEY (next_shift_type_id) REFERENCES shift_types(id)
);

-- Insert into teams
INSERT INTO teams (name) VALUES ("700");

-- Insert multiple users with specified roles
INSERT INTO users (id, team_id, user_role, first_name, middle_name, last_name, password, email, created_at) VALUES
-- Admin
(2, 1, 'admin', 'Sarah', NULL, 'Johnson', '$2b$12$5M7tsBOu46jTUKJdl6hp7e.PuWzsOTlmIag5hqcbAetbjq8QtzFFa', 'sarah.j@gmail.com', '2024-10-21 10:00:00'),

-- Chiefs
(3, 1, 'chief', 'Michael', 'James', 'Smith', '$2b$12$5M7tsBOu46jTUKJdl6hp7e.PuWzsOTlmIag5hqcbAetbjq8QtzFFa', 'michael.s@gmail.com',  '2024-10-21 10:15:00'),
(4, 1, 'chief', 'Emily', NULL, 'Davis', '$2b$12$5M7tsBOu46jTUKJdl6hp7e.PuWzsOTlmIag5hqcbAetbjq8QtzFFa', 'emily.d@gmail.com', '2024-10-21 10:30:00'),

-- Supervisors
(5, 1, 'supervisor', 'David', NULL, 'Wilson', '$2b$12$5M7tsBOu46jTUKJdl6hp7e.PuWzsOTlmIag5hqcbAetbjq8QtzFFa', 'david.w@gmail.com', '2024-10-21 11:00:00'),
(6, 1, 'supervisor', 'Lisa', 'Marie', 'Brown', '$2b$12$5M7tsBOu46jTUKJdl6hp7e.PuWzsOTlmIag5hqcbAetbjq8QtzFFa', 'lisa.b@gmail.com', '2024-10-21 11:30:00'),
(7, 1, 'supervisor', 'James', NULL, 'Taylor', '$2b$12$5M7tsBOu46jTUKJdl6hp7e.PuWzsOTlmIag5hqcbAetbjq8QtzFFa', 'james.t@gmail.com', '2024-10-21 12:00:00'),

-- Managers
(8, 1, 'manager', 'Jessica', 'Ann', 'Martinez', '$2b$12$5M7tsBOu46jTUKJdl6hp7e.PuWzsOTlmIag5hqcbAetbjq8QtzFFa', 'jessica.m@gmail.com',  '2024-10-21 12:30:00'),
(9, 1, 'manager', 'Robert', NULL, 'Anderson', '$2b$12$5M7tsBOu46jTUKJdl6hp7e.PuWzsOTlmIag5hqcbAetbjq8QtzFFa', 'robert.a@gmail.com', '2024-10-21 13:00:00'),
(10, 1, 'manager', 'Michelle', NULL, 'Thomas', '$2b$12$5M7tsBOu46jTUKJdl6hp7e.PuWzsOTlmIag5hqcbAetbjq8QtzFFa', 'michelle.t@gmail.com',  '2024-10-21 13:30:00'),

-- Regular Users
(11, 1, 'user', 'William', 'John', 'Garcia', '$2b$12$5M7tsBOu46jTUKJdl6hp7e.PuWzsOTlmIag5hqcbAetbjq8QtzFFa', 'william.g@gmail.com',  '2024-10-21 14:00:00'),
(12, 1, 'user', 'Jennifer', NULL, 'Miller', '$2b$12$5M7tsBOu46jTUKJdl6hp7e.PuWzsOTlmIag5hqcbAetbjq8QtzFFa', 'jennifer.m@gmail.com',  '2024-10-21 14:30:00'),
(13, 1, 'user', 'Christopher', 'Lee', 'Wong', '$2b$12$5M7tsBOu46jTUKJdl6hp7e.PuWzsOTlmIag5hqcbAetbjq8QtzFFa', 'chris.w@gmail.com',  '2024-10-21 15:00:00'),
(14, 1, 'user', 'Amanda', NULL, 'Lopez', '$2b$12$5M7tsBOu46jTUKJdl6hp7e.PuWzsOTlmIag5hqcbAetbjq8QtzFFa', 'amanda.l@gmail.com', '2024-10-21 15:30:00'),
(15, 1, 'user', 'Daniel', NULL, 'Lee', '$2b$12$5M7tsBOu46jTUKJdl6hp7e.PuWzsOTlmIag5hqcbAetbjq8QtzFFa', 'daniel.l@gmail.com',  '2024-10-21 16:00:00'),
(16, 1, 'user', 'Rachel', 'Anne', 'Kim', '$2b$12$5M7tsBOu46jTUKJdl6hp7e.PuWzsOTlmIag5hqcbAetbjq8QtzFFa', 'rachel.k@gmail.com',  '2024-10-21 16:30:00'),
(17, 1, 'user', 'Kevin', NULL, 'Chen', '$2b$12$5M7tsBOu46jTUKJdl6hp7e.PuWzsOTlmIag5hqcbAetbjq8QtzFFa', 'kevin.c@gmail.com', '2024-10-21 17:00:00'),
(18, 1, 'user', 'Maria', NULL, 'Rodriguez', '$2b$12$5M7tsBOu46jTUKJdl6hp7e.PuWzsOTlmIag5hqcbAetbjq8QtzFFa', 'maria.r@gmail.com',  '2024-10-21 17:30:00'),
(19, 1, 'user', 'Thomas', 'William', 'Wilson', '$2b$12$5M7tsBOu46jTUKJdl6hp7e.PuWzsOTlmIag5hqcbAetbjq8QtzFFa', 'thomas.w@gmail.com', '2024-10-21 18:00:00'),
(20, 1, 'user', 'Sophie', NULL, 'Park', '$2b$12$5M7tsBOu46jTUKJdl6hp7e.PuWzsOTlmIag5hqcbAetbjq8QtzFFa', 'sophie.p@gmail.com',  '2024-10-21 18:30:00');


-- Start transaction to ensure data consistency
START TRANSACTION;

-- Create additional shift types
INSERT INTO shift_types (id, name, team_id) VALUES 
(1, 'Regular Staff', 1),
(2, 'Supervisor', 1),
(3, 'Senior Specialist', 1),
(4, 'On-Call Staff', 1),
(5, 'Emergency Response', 1)
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Create template schedule
INSERT INTO template_schedules (team_id, name, start_date, end_date, notes) 
VALUES (
    1, 
    'Hospital Complex Schedule', 
    '2024-10-24', 
    '2024-10-30', 
    'Complex weekly schedule with varying staff requirements, multiple shift types, and specialized weekend coverage'
);

SET @template_schedule_id = LAST_INSERT_ID();

-- Regular Staff - Weekday Morning Shifts (4 staff on Mon-Fri, 3 on weekends)
INSERT INTO template_shifts (template_schedule_id, shift_type_id, shift_name, required_count, day_of_week)
SELECT 
    @template_schedule_id,
    1,
    'Regular Morning',
    CASE 
        WHEN day BETWEEN 1 AND 5 THEN 4  -- Mon-Fri
        ELSE 3                           -- Sat-Sun
    END,
    day
FROM (
    SELECT 0 AS day UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6
) days;

-- Regular Staff - Peak Hours (additional staff during busy hours)
INSERT INTO template_shifts (template_schedule_id, shift_type_id, shift_name, required_count, day_of_week)
SELECT 
    @template_schedule_id,
    1,
    'Peak Hours',
    CASE 
        WHEN day BETWEEN 1 AND 5 THEN 2  -- Mon-Fri
        WHEN day = 6 THEN 3              -- Saturday
        ELSE 2                           -- Sunday
    END,
    day
FROM (
    SELECT 0 AS day UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6
) days;

-- Senior Specialist Coverage (varying requirements)
INSERT INTO template_shifts (template_schedule_id, shift_type_id, shift_name, required_count, day_of_week)
SELECT 
    @template_schedule_id,
    3,
    'Senior Specialist',
    CASE 
        WHEN day BETWEEN 1 AND 4 THEN 2  -- Mon-Thu
        WHEN day = 5 THEN 3              -- Friday
        ELSE 1                           -- Weekends
    END,
    day
FROM (
    SELECT 0 AS day UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6
) days;

-- Emergency Response Team (24/7 coverage)
INSERT INTO template_shifts (template_schedule_id, shift_type_id, shift_name, required_count, day_of_week)
SELECT 
    @template_schedule_id,
    5,
    'Emergency Response',
    CASE 
        WHEN day IN (5, 6) THEN 2        -- Fri-Sat
        ELSE 1                           -- Other days
    END,
    day
FROM (
    SELECT 0 AS day UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6
) days;

-- On-Call Staff (night coverage)
INSERT INTO template_shifts (template_schedule_id, shift_type_id, shift_name, required_count, day_of_week)
SELECT 
    @template_schedule_id,
    4,
    'Night On-Call',
    1,
    day
FROM (
    SELECT 0 AS day UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6
) days;

-- Insert time ranges with more complex patterns
-- Regular Morning
INSERT INTO template_time_ranges (template_shift_id, start_time, end_time)
SELECT 
    id,
    '07:00',
    '15:30'
FROM template_shifts 
WHERE template_schedule_id = @template_schedule_id 
AND shift_name = 'Regular Morning';

-- Peak Hours (overlapping shifts)
INSERT INTO template_time_ranges (template_shift_id, start_time, end_time)
SELECT 
    id,
    '10:00',
    '18:30'
FROM template_shifts 
WHERE template_schedule_id = @template_schedule_id 
AND shift_name = 'Peak Hours';

-- Senior Specialist (split shifts)
INSERT INTO template_time_ranges (template_shift_id, start_time, end_time)
SELECT 
    id,
    '08:00',
    '12:00'
FROM template_shifts 
WHERE template_schedule_id = @template_schedule_id 
AND shift_name = 'Senior Specialist';

INSERT INTO template_time_ranges (template_shift_id, start_time, end_time)
SELECT 
    id,
    '13:00',
    '17:00'
FROM template_shifts 
WHERE template_schedule_id = @template_schedule_id 
AND shift_name = 'Senior Specialist';

-- Emergency Response (24-hour coverage in 12-hour shifts)
INSERT INTO template_time_ranges (template_shift_id, start_time, end_time)
SELECT 
    id,
    '07:00',
    '19:00'
FROM template_shifts 
WHERE template_schedule_id = @template_schedule_id 
AND shift_name = 'Emergency Response';

-- Night On-Call
INSERT INTO template_time_ranges (template_shift_id, start_time, end_time)
SELECT 
    id,
    '23:00',
    '07:00'
FROM template_shifts 
WHERE template_schedule_id = @template_schedule_id 
AND shift_name = 'Night On-Call';

-- Add complex constraints
-- Cannot work night shift followed by any morning shift
INSERT INTO template_constraints (template_schedule_id, shift_type_id, next_shift_type_id)
SELECT DISTINCT
    @template_schedule_id,
    ts1.shift_type_id,
    ts2.shift_type_id
FROM template_shifts ts1
CROSS JOIN template_shifts ts2
WHERE ts1.template_schedule_id = @template_schedule_id 
AND ts2.template_schedule_id = @template_schedule_id
AND ts1.shift_name IN ('Night On-Call', 'Emergency Response')
AND ts2.shift_name IN ('Regular Morning', 'Senior Specialist');

-- Maximum one Emergency Response shift per 48 hours
INSERT INTO template_constraints (template_schedule_id, shift_type_id, next_shift_type_id)
SELECT DISTINCT
    @template_schedule_id,
    shift_type_id,
    shift_type_id
FROM template_shifts
WHERE template_schedule_id = @template_schedule_id 
AND shift_name = 'Emergency Response';

-- Verify the data
SELECT 'Complex Template Schedule Created:' as message;
SELECT * FROM template_schedules WHERE id = @template_schedule_id;

SELECT 'Complex Shifts Created:' as message;
SELECT 
    ts.*, 
    st.name as shift_type_name,
    CASE 
        WHEN day_of_week = 0 THEN 'Sunday'
        WHEN day_of_week = 1 THEN 'Monday'
        WHEN day_of_week = 2 THEN 'Tuesday'
        WHEN day_of_week = 3 THEN 'Wednesday'
        WHEN day_of_week = 4 THEN 'Thursday'
        WHEN day_of_week = 5 THEN 'Friday'
        WHEN day_of_week = 6 THEN 'Saturday'
    END as day_name
FROM template_shifts ts
JOIN shift_types st ON ts.shift_type_id = st.id
WHERE template_schedule_id = @template_schedule_id
ORDER BY day_of_week, shift_name;

SELECT 'Time Ranges Created:' as message;
SELECT 
    tr.*, 
    ts.shift_name,
    st.name as shift_type_name
FROM template_time_ranges tr
JOIN template_shifts ts ON tr.template_shift_id = ts.id
JOIN shift_types st ON ts.shift_type_id = st.id
WHERE ts.template_schedule_id = @template_schedule_id
ORDER BY ts.day_of_week, ts.shift_name, tr.start_time;

COMMIT;
