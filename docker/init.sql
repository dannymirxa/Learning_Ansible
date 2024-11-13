CREATE TABLE public.employees (
	employeeid serial PRIMARY KEY,
	firstname varchar(50) NULL,
	lastname varchar(50) NULL,
	birthdate date NULL,
	hiredate timestamp NULL,
	salary numeric(10, 2) NULL,
	isactive bool NULL,
	email varchar(100) NULL,
	phonenumber BIGINT NULL
);

INSERT INTO public.employees
(firstname, lastname, birthdate, hiredate, salary, isactive, email, phonenumber)
VALUES
('John', 'Doe', '1985-05-15', '2020-01-10 09:00:00.000', 75000.00, true, 'john.doe@example.com', 1234567890),
('Jane', 'Smith', '1990-07-20', '2019-03-15 10:30:00.000', 82000.00, true, 'jane.smith@example.com', 2345678901),
('Charlie', 'Brown', '1992-04-30', '2023-09-01 09:15:30.000', 58000.00,	true, 'charlie.brown@example.com', 3216540987),
('Alice', 'Johnson', '1988-11-30', '2021-06-25 08:45:00.000', 68000.00, false, 'alice.johnson@example.com', 3456789012),
('Emily', 'Chen', '1992-06-15', '2018-03-01 09:00:00.000', 60000.00, true, 'emily.chen@example.com', 1987654321);