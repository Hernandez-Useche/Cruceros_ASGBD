--Se crea tabla que almacene las imágenes
DROP TABLE IF EXISTS Imagen_crucero;
GO

CREATE TABLE Imagen_crucero(
nombre_imagen NVARCHAR(40) NOT NULL, --Nombre de cómo se guardará en DB
id_crucero INT NOT NULL, -- ID Crucero asociado
ruta_archivo_imagen NVARCHAR(100) NOT NULL, --Ruta del archivo guardado localmente
dato_imagen VARBINARY(max), --VARBINARY sirve para lmacenar imágenes u otros archivos binarios grandes
PRIMARY KEY (nombre_imagen),
FOREIGN KEY (id_crucero) REFERENCES Crucero (id_crucero)
);
GO

--Activando opciones avanzadas que permiten que funcione bien el procedimiento posterior
EXEC sp_configure 'show advanced options',1; --Pemite visualización de opciones avanzadas
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

--Creando Procedimiento almacenado Importación imágen
CREATE OR ALTER PROCEDURE dbo.usp_ImportarImagen( --usp= user store procedure
	--Declarando parámetros de entrada del procedimiento
	@NombreImagenDB NVARCHAR(40),
	@IdCrucero INT,
	@RutaCarpeta NVARCHAR(1000),
	@NombreImagenLocal NVARCHAR(1000)
)
AS
BEGIN
	DECLARE @RutaArchivo NVARCHAR(2000)
	DECLARE @tsql NVARCHAR(2000);
	SET NOCOUNT ON --Desactiva conteo de filas afectadas
	SET @RutaArchivo = CONCAT (@RutaCarpeta,'\',@NombreImagenLocal);
	SET @tsql = 'INSERT INTO Imagen_crucero (nombre_imagen, id_crucero, ruta_archivo_imagen, dato_imagen) ' +
    'SELECT ''' + @NombreImagenDB + ''', ' + CAST(@IdCrucero AS NVARCHAR(10)) + ', ''' + @RutaArchivo + ''', * ' +
    'FROM Openrowset (Bulk ''' + @RutaArchivo + ''', Single_Blob) as img';
	EXEC (@tsql)
	SET NOCOUNT OFF
END
GO

--Creando Procedimiento de Exportación de imágen
CREATE OR ALTER PROCEDURE dbo.usp_ExportarImagen(
	--Declarando parámetros de entrada
	@NombreImagenDB NVARCHAR(40), --Nombre Imagen existente en db
	@RutaCarpetaGuardado NVARCHAR (1000), --Ruta carpeta a guardar la imagen
	@NombreImagenExportada NVARCHAR(1000) --Nombre imagen exportada
)
AS
BEGIN
	DECLARE @DatosImagen VARBINARY (max); --Datos de la imagen guardada en la db
	DECLARE @RutaGuardado NVARCHAR (1000); --Ruta completa (Ruta + nombre imagen exportada)
	DECLARE @Obj INT --Objeto que se usará para interactuar con el sistema de archivos

	SET NOCOUNT ON

	--Seleccionando los datos de la imagen guardados en la db
	SELECT @DatosImagen = (
		SELECT convert (VARBINARY(max),dato_imagen,1)
		FROM Imagen_crucero
		WHERE nombre_imagen = @NombreImagenDB
		);

	--Estableciendo ruta de guardado de la imagen a exportar
	SET @RutaGuardado = CONCAT(@RutaCarpetaGuardado,'\',@NombreImagenExportada);

	--Exportación de la imagen con OLE Automation
	BEGIN TRY
		EXEC sp_OACreate 'ADODB.Stream' ,@Obj OUTPUT; --Crea objeto stream: Permite ejecutar acciones y métodos de objetos externos
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
--EXEC dbo.usp_ImportarImagen 'Imagen1',1,'C:\Users\santi\Desktop\Imagenes\Entrada',
--'Crucero.jpg';

--Viendo Que ha importado la imagen correctamente
--SELECT * FROM Imagen_crucero;

--Ejecutando pruebaExportar
--EXEC dbo.usp_ExportarImagen 'Imagen1','C:\Users\santi\Desktop\Imagenes\Salida',
--'Crucero1.jpg';