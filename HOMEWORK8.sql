DROP DATABASE IF EXISTS MyFunkDB;
CREATE DATABASE IF NOT EXISTS MyFunkDB;
USE MyFunkDB;

DROP DATABASE IF EXISTS MyFunkDB;
CREATE DATABASE IF NOT EXISTS MyFunkDB;
USE MyFunkDB;

-- Таблиця 1: Співробітники
CREATE TABLE IF NOT EXISTS Employees (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    PhoneNumber VARCHAR(15) NOT NULL
);

-- Таблиця 2: Зарплата та посади
CREATE TABLE IF NOT EXISTS SalaryAndPositions (
    EmployeeID INT PRIMARY KEY,
    Salary DECIMAL(10, 2) NOT NULL,
    Position ENUM('Генеральний директор', 'Менеджер', 'Робітник') NOT NULL,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Таблиця 3: Особиста інформація
CREATE TABLE IF NOT EXISTS PersonalInformation (
    EmployeeID INT PRIMARY KEY,
    MaritalStatus VARCHAR(20) NOT NULL,
    BirthDate DATE NOT NULL,
    Residence VARCHAR(100) NOT NULL,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Вставка даних в таблицю Employees
INSERT INTO Employees (FirstName, LastName, PhoneNumber) VALUES
    ('Іван', 'Петров', '+380991234567'),
    ('Марія', 'Іванова', '+380992345678'),
    ('Олександр', 'Сидоров', '+380993456789'),
    ('Анна', 'Григоренко', '+380994567890'),
    ('Петро', 'Коваленко', '+380995678901');

-- Вставка даних в таблицю SalaryAndPositions
INSERT INTO SalaryAndPositions (EmployeeID, Salary, Position) VALUES
    (1, 50000.00, 'Генеральний директор'),
    (2, 30000.00, 'Менеджер'),
    (3, 20000.00, 'Робітник'),
    (4, 40000.00, 'Менеджер'),
    (5, 25000.00, 'Робітник');

-- Вставка даних в таблицю PersonalInformation
INSERT INTO PersonalInformation (EmployeeID, MaritalStatus, BirthDate, Residence) VALUES
    (1, 'Одружений', '1980-05-15', 'Київ'),
    (2, 'Неодружений', '1992-12-10', 'Львів'),
    (3, 'Одружений', '1985-08-25', 'Харків'),
    (4, 'Неодружений', '1990-04-03', 'Одеса'),
    (5, 'Одружений', '1988-06-20', 'Дніпро');


DELIMITER |

-- Створення процедури вставки даних
CREATE PROCEDURE InsertEmployee(
    IN first_name VARCHAR(50),
    IN last_name VARCHAR(50),
    IN phone_number VARCHAR(15),
    IN salary DECIMAL(10, 2),
    IN position_enum ENUM('Генеральний директор', 'Менеджер', 'Робітник'),
    IN marital_status VARCHAR(20),
    IN birth_date DATE,
    IN residence VARCHAR(100)
)
BEGIN
    DECLARE existing_employee INT;

    -- Перевірка наявності працівника за ім'ям та прізвищем
    SELECT COUNT(*) INTO existing_employee
    FROM Employees
    WHERE FirstName = first_name AND LastName = last_name;

    -- Розпочати транзакцію
    START TRANSACTION;

    -- Вставка даних у таблицю Employees
    INSERT INTO Employees (FirstName, LastName, PhoneNumber)
    VALUES (first_name, last_name, phone_number);

    -- Отримання ідентифікатора нового працівника
    SET @new_employee_id = LAST_INSERT_ID();

    -- Перевірка наявності працівника за ідентифікатором
    IF existing_employee > 0 THEN
        -- Якщо працівник вже існує, відкатити транзакцію
        ROLLBACK;
    ELSE
        -- Вставка даних у таблицю SalaryAndPositions
        INSERT INTO SalaryAndPositions (EmployeeID, Salary, Position)
        VALUES (@new_employee_id, salary, position_enum);

        -- Вставка даних у таблицю PersonalInformation
        INSERT INTO PersonalInformation (EmployeeID, MaritalStatus, BirthDate, Residence)
        VALUES (@new_employee_id, marital_status, birth_date, residence);

        -- Завершення транзакції
        COMMIT;
    END IF;
END |

-- Створення тригера
CREATE TRIGGER before_delete_employee
BEFORE DELETE ON Employees
FOR EACH ROW
BEGIN
    -- Видалення записів з SalaryAndPositions
    DELETE FROM SalaryAndPositions WHERE EmployeeID = OLD.EmployeeID;

    -- Видалення записів з PersonalInformation
    DELETE FROM PersonalInformation WHERE EmployeeID = OLD.EmployeeID;
END;

DELIMITER ;

-- Виклик процедури для вставки даних
CALL InsertEmployee('Василь', 'Онопрієнко', '+380996789012', 30000.00, 'Менеджер', 'Неодружений', '1995-02-28', 'Львів');
