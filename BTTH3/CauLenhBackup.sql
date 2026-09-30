use master
go

BACKUP DATABASE QuanLyDeTai
TO DISK = 'D:\backup\QuanLyDeTaiBackup.bak'
WITH INIT, NAME = 'Full Backup of QuanLyDeTaiBackup';

ALTER DATABASE QuanLyDeTai SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE QuanLyDeTai;

-- restore database
RESTORE DATABASE QuanLyDeTai
FROM DISK = 'D:\backup\QuanLyDeTai.bak'
WITH REPLACE;

CREATE TABLE Employees
(
	EmployeeID INT PRIMARY KEY,
	FirstName VARCHAR (50) NOT NULL,
	LastName VARCHAR (50) NOT NULL,
	BirthDate DATE NOT NULL,
	HireDate DATE NOT NULL
)
GO

CREATE VIEW EmployeeNames
AS
SELECT FirstName, LastName
FROM Employees

INSERT INTO EmployeeNames (FirstName, LastName)
VALUES ('QuanLyThongTin', 'IE103')