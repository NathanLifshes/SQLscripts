DECLARE @LoginList TABLE
(
    LoginName NVARCHAR(256),
    [Type] VARCHAR(8),
    [Privilege] VARCHAR(8),
    [Mapped Login Name] NVARCHAR(256),
    WindowsGroupName NVARCHAR(256)
);

DECLARE @WindowsGroupName NVARCHAR(256);

--SQL/Windows Logins

INSERT INTO @LoginList
SELECT name,
       'user',
       'user',
       name,
       ''
FROM sys.server_principals
WHERE type IN ( 'S', 'U' );
DECLARE c1 CURSOR FOR

--Windows Groups

SELECT name
FROM sys.server_principals
WHERE type = 'G';
OPEN c1;
FETCH NEXT FROM c1
INTO @WindowsGroupName;
WHILE @@fetch_status <> -1
BEGIN
    INSERT INTO @LoginList
    (
        LoginName,
        [Type],
        [Privilege],
        [Mapped Login Name],
        WindowsGroupName
    )
    EXEC xp_logininfo @acctname = @WindowsGroupName, @option = 'members';
    FETCH NEXT FROM c1
    INTO @WindowsGroupName;
END;
CLOSE c1;
DEALLOCATE c1;
SELECT LoginName,
       WindowsGroupName
FROM @LoginList;