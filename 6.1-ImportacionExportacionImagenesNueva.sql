--Se crea tabla que almacene im�genes

CREATE TABLE Imagen_crucero(
nombre_imagen NVARCHAR(40) NOT NULL, --Nombre de c�mo se guardar� en DB
ruta_archivo_imagen NVARCHAR(100) NOT NULL, --Ruta del archivo guardado localmente
dato_imagen VARBINARY(max), --VARBINARY sirve para lmacenar im�genes u otros archivos binarios grandes
PRIMARY KEY (nombre_imagen),

);
GO

--Activando opciones avanzadas que permiten que funcione bien el procedimiento posterior
EXEC sp_configure 'show advanced options',1; --Pemite visualizaci�n de opciones avanzadas
GO
RECONFIGURE;
GO
EXEC sp_configure 'Ole Automation Procedures',1; --Habilita procedimientos OLE Automation, permite acceder a recursos externos
GO
RECONFIGURE;
GO

--Dando rol de bulkadmin al usuario que  gestiona la db
ALTER SERVER ROLE bulkadmin ADD MEMBER [W11FP\santi];
GO

--Creando Procedimiento almacenado Importaci�n im�gen
CREATE OR ALTER PROCEDURE dbo.usp_ImportarImagen( --usp= user store procedure
	--Declarando par�metros de entrada del procedimiento
	@NombreImagenDB NVARCHAR(40),
	@RutaCarpeta NVARCHAR(1000),
	@NombreImagenLocal NVARCHAR(1000)
)
AS
BEGIN
	DECLARE @RutaArchivo NVARCHAR(2000)
	DECLARE @tsql NVARCHAR(2000);
	SET NOCOUNT ON --Desactiva conteo de filas afectadas
	SET @RutaArchivo = CONCAT (@RutaCarpeta,'\',@NombreImagenLocal);
	SET @tsql = 'INSERT INTO Imagen_crucero (nombre_imagen,ruta_archivo_imagen, dato_imagen) ' +
    'SELECT ''' + @NombreImagenDB + ''', ''' + @RutaArchivo + ''', * ' +
    'FROM Openrowset (Bulk ''' + @RutaArchivo + ''', Single_Blob) as img';
	EXEC (@tsql)
	SET NOCOUNT OFF
END
GO

--Creando Procedimiento de Exportaci�n de im�gen
CREATE OR ALTER PROCEDURE dbo.usp_ExportarImagen(
	--Declarando par�metros de entrada
	@NombreImagenDB NVARCHAR(40), --Nombre Imagen existente en db
	@RutaCarpetaGuardado NVARCHAR (1000), --Ruta carpeta a guardar la imagen
	@NombreImagenExportada NVARCHAR(1000) --Nombre imagen exportada
)
AS
BEGIN
	DECLARE @DatosImagen VARBINARY (max); --Datos de la imagen guardada en la db
	DECLARE @RutaGuardado NVARCHAR (1000); --Ruta completa (Ruta + nombre imagen exportada)
	DECLARE @Obj INT --Objeto que se usar� para interactuar con el sistema de archivos

	SET NOCOUNT ON

	--Seleccionando los datos de la imagen guardados en la db
	SELECT @DatosImagen = (
		SELECT convert (VARBINARY(max),dato_imagen,1)
		FROM Imagen_crucero
		WHERE nombre_imagen = @NombreImagenDB
		);

	--Estableciendo ruta de guardado de la imagen a exportar
	SET @RutaGuardado = CONCAT(@RutaCarpetaGuardado,'\',@NombreImagenExportada);

	--Exportaci�n de la imagen con OLE Automation
	BEGIN TRY
		EXEC sp_OACreate 'ADODB.Stream' ,@Obj OUTPUT; --Crea objeto stream: Permite ejecutar acciones y m�todos de objetos externos
		EXEC sp_OASetProperty @Obj ,'Type',1; --configura el tipo como binario (1)
		EXEC sp_OAMethod @Obj,'Open'; --Abre el stream
		EXEC sp_OAMethod @Obj, 'Write', NULL, @DatosImagen; --Escribe los datos de la imagen en el stream
		EXEC sp_OAMethod @Obj, 'SaveToFile', NULL, @RutaGuardado,2; --Guarda el stream en el archivo
		EXEC sp_OAMethod @Obj, 'Close'; --Cierra el stream
		EXEC sp_OADESTROY @Obj;--Libera el objeto
	END TRY
	BEGIN CATCH
		EXEC sp_OADestroy @Obj; --Si se produce error asegura que @Obj se destruya
	END CATCH

	SET NOCOUNT OFF
END
GO

--Ejecutando pruebaImportar
--EXEC dbo.usp_ImportarImagen 'Imagen2','C:\Users\santi\Desktop\Imagenes\Entrada',
--'Crucero.jpg';

--Viendo Que ha importado la imagen correctamente
--SELECT * FROM Imagen_crucero;

--Ejecutando pruebaExportar
--EXEC dbo.usp_ExportarImagen 'Imagen2','C:\Users\santi\Desktop\Imagenes\Salida',
--'Crucero2.jpg';