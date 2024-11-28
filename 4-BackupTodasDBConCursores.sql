USE Cruceros_ASGBD;
GO

CREATE OR ALTER PROC Backup_all_cursores
    @ruta VARCHAR(256)  -- Parámetro de entrada: Ruta donde se almacenarán los archivos de backup.
AS
BEGIN
	DECLARE 
		@nombreDb VARCHAR(50),        -- Variable que almacenará el nombre de cada base de datos a respaldar.
		@nombreArchivo VARCHAR(256),  -- Variable que almacenará la ruta completa del archivo de backup (incluyendo el nombre del archivo).
		@fechaArchivo VARCHAR(20)    -- Variable para almacenar la fecha actual en formato YYYYMMDD.

	-- Obtener la fecha actual y convertirla al formato YYYYMMDD
	SET @fechaArchivo = CONVERT(VARCHAR(20), GETDATE(), 112)

	--Declaracion de cursor
	DECLARE bc_cursor CURSOR READ_ONLY FOR --READ ONLY ya que solo recorre los nombres, no modifica nada
	SELECT name 
	FROM master.dbo.sysdatabases
	WHERE name NOT IN ('master','model','msdb','tempdb') --Cursor selecciona nombre de todas las db menos las del sistema

	--Apertura del cursor
	OPEN bc_cursor
	FETCH NEXT FROM bc_cursor INTO @nombreDb --Toma el primer nombre de db y lo guarda en la variable

	WHILE @@FETCH_STATUS = 0 --Estado del cursor -> 0 significa que operación es exitosa y que hay filas por procesar
	BEGIN
		SET @nombreArchivo = @ruta + @nombreDb + '_' + @fechaArchivo + '.BAK' --Establece nombre archivo a guardar
		BACKUP DATABASE @nombreDb TO DISK = @nombreArchivo WITH INIT --Ejecuta el comando para hacer el backup

		FETCH NEXT FROM bc_cursor INTO @nombreDb --Obtiene siguiente elemento (nombreDb) y repite proceso (si se puede)
	END
	--Cerrando cursor y liberando memoria
	CLOSE bc_cursor
	DEALLOCATE bc_cursor
END
GO

--Ejemplo de uso
--EXEC dbo.Backup_all_cursores @ruta = 'C:\Users\santi\Desktop\DB_backups\';
--GO