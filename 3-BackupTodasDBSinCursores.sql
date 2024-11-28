USE Cruceros_ASGBD
GO

CREATE OR ALTER PROC Backup_all
    @ruta VARCHAR(256)  -- Parámetro de entrada: Ruta donde se almacenarán los archivos de backup.
AS
DECLARE 
    @nombreDb VARCHAR(50),        -- Variable que almacenará el nombre de cada base de datos a respaldar.
    @nombreArchivo VARCHAR(256),  -- Variable que almacenará la ruta completa del archivo de backup (incluyendo el nombre del archivo).
    @fechaArchivo VARCHAR(20),    -- Variable para almacenar la fecha actual en formato YYYYMMDD.
    @contadorBackup INT           -- Variable para contar cuántas bases de datos se deben respaldar.

-- Crear una tabla temporal para almacenar temporalmente los nombres de las bases de datos que se van a respaldar.
CREATE TABLE [dbo].#backupTemporal(
    idBackup INT IDENTITY (1,1),  -- Campo con un valor autoincremental que servirá para controlar el proceso de respaldo.
    name VARCHAR(200))            -- Campo que almacena el nombre de cada base de datos.

-- Obtener la fecha actual y convertirla al formato YYYYMMDD
SET @fechaArchivo = CONVERT(VARCHAR(20), GETDATE(), 112)

-- Insertar los nombres de todas las bases de datos del servidor, excepto las bases de datos del sistema en la tabla temporal.
INSERT INTO [dbo].#backupTemporal (name)
    SELECT name
    FROM master.dbo.sysdatabases
    WHERE name NOT IN ('master','model','msdb','tempdb')

-- Obtener el número total de bases de datos a respaldar. Este valor se almacena en la variable @contadorBackup.
SELECT TOP 1 @contadorBackup = idBackup
FROM [dbo].#backupTemporal
ORDER BY idBackup DESC  -- El valor más alto de 'idBackup' corresponde al número total de bases de datos en la tabla temporal.

-- Verificar si hay bases de datos que respaldar
IF ((@contadorBackup IS NOT NULL) AND (@contadorBackup > 0))
BEGIN
    DECLARE @backupActual INT  -- Variable para controlar el índice del backup que se está procesando.
    SET @backupActual = 1      -- Inicializamos el contador de backups en 1.
    
    -- Bucle que itera sobre todas las bases de datos listadas en la tabla temporal.
    WHILE (@backupActual <= @contadorBackup)
    BEGIN
        -- Obtener el nombre de la base de datos y generar el nombre del archivo de backup correspondiente.
        SELECT
            @nombreDb = name,  -- Nombre de la base de datos a respaldar.
            @nombreArchivo = @ruta + name + '_' + @fechaArchivo + '.BAK'  -- Ruta completa del archivo de backup.
        FROM [dbo].#backupTemporal
        WHERE idBackup = @backupActual

        -- Ejecutar el comando BACKUP DATABASE para realizar el respaldo de la base de datos actual y guardarlo en el archivo especificado.
        BACKUP DATABASE @nombreDb TO DISK = @nombreArchivo WITH INIT
        
        -- Incrementar el contador para proceder con la siguiente base de datos.
        SET @backupActual = @backupActual + 1
    END
END
GO

--Ejemplo de USO
--EXEC dbo.Backup_all @ruta = 'C:\Users\santi\Desktop\DB_backups\';
--GO
