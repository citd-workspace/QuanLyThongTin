-- 1. Tạo 6 Login ở mức Server
CREATE LOGIN u1 WITH PASSWORD = 'P@ssword1';
CREATE LOGIN u2 WITH PASSWORD = 'P@ssword2';
CREATE LOGIN u3 WITH PASSWORD = 'P@ssword3';
CREATE LOGIN u4 WITH PASSWORD = 'P@ssword4';
CREATE LOGIN u5 WITH PASSWORD = 'P@ssword5';
CREATE LOGIN u6 WITH PASSWORD = 'P@ssword6';
GO

-- 2. Tạo 6 User tương ứng ở mức Database
CREATE USER u1 FOR LOGIN u1;
CREATE USER u2 FOR LOGIN u2;
CREATE USER u3 FOR LOGIN u3;
CREATE USER u4 FOR LOGIN u4;
CREATE USER u5 FOR LOGIN u5;
CREATE USER u6 FOR LOGIN u6;
GO

-- 3. Tạo 3 Database Role
CREATE ROLE r1;
CREATE ROLE r2;
CREATE ROLE r3;
GO

-- 4. Thêm User vào các Role tương ứng
ALTER ROLE r1 ADD MEMBER u1;

ALTER ROLE r2 ADD MEMBER u2;
ALTER ROLE r2 ADD MEMBER u3;

ALTER ROLE r3 ADD MEMBER u4;
ALTER ROLE r3 ADD MEMBER u5;
ALTER ROLE r3 ADD MEMBER u6;
GO

-- 5. Thực hiện phân quyền
-- A. Gán Database Role cho r2 và r3 (cấp Database)
ALTER ROLE db_owner ADD MEMBER r2;
ALTER ROLE db_accessadmin ADD MEMBER r2;

ALTER ROLE db_owner ADD MEMBER r3;
ALTER ROLE db_accessadmin ADD MEMBER r3;
GO

-- B. Gán quyền SysAdmin cho các Login tương ứng của r1 và r3 (cấp Server)
ALTER SERVER ROLE sysadmin ADD MEMBER u1; -- u1 thuộc r1
ALTER SERVER ROLE sysadmin ADD MEMBER u4; -- u4 thuộc r3
ALTER SERVER ROLE sysadmin ADD MEMBER u5; -- u5 thuộc r3
ALTER SERVER ROLE sysadmin ADD MEMBER u6; -- u6 thuộc r3
GO

-- Kiểm tra thành viên của Database Role (r1, r2, r3, db_owner, db_accessadmin):
SELECT
    r.name AS RoleName,
    m.name AS MemberName
FROM sys.database_role_members drm
JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON drm.member_principal_id = m.principal_id
ORDER BY r.name;
GO

-- Kiểm tra thành viên của Server Role (sysadmin):
SELECT
    r.name AS ServerRoleName,
    m.name AS MemberLogin
FROM sys.server_role_members srm
JOIN sys.server_principals r ON srm.role_principal_id = r.principal_id
JOIN sys.server_principals m ON srm.member_principal_id = m.principal_id
WHERE r.name = 'sysadmin'
ORDER BY r.name;
GO