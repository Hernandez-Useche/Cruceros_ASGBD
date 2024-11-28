USE Cruceros_ASGBD;
GO

--Se crea proceso almacenado
CREATE OR ALTER PROC Contadores.InsertarNuevaFactura
	@id_promocion INT,
	@precio DECIMAL(10,2),
	@metodo_pago NVARCHAR(30),
	@fecha_emision DATE
AS
BEGIN
	INSERT INTO Factura
	(id_promocion,precio,metodo_pago,fecha_emision)
	VALUES
	(@id_promocion,@precio,@metodo_pago,@fecha_emision);
END;
GO

--Se crea nuevo rol y se le otorga permiso de ejecución sobre todos los objetos del esquema
DROP ROLE IF EXISTS JefeContador;
GO

CREATE ROLE JefeContador;
GO

GRANT EXECUTE ON SCHEMA::[Contadores] TO JefeContador;
GO

--Se crea usuario para realizar prueba y se le otorga el rol de JefeContador
DROP USER IF EXISTS JefeContadorUno;
GO

CREATE USER JefeContadorUno WITHOUT LOGIN;
GO

ALTER ROLE JefeContador
ADD MEMBER JefeContadorUno;
GO

--Ejecutamos pruebas como JefeContadorUno
EXECUTE AS USER = 'JefeContadorUno';
GO

--No deja Insertar valores sobre la tabla, ya que no tiene permisos para ello
--INSERT INTO Factura(id_promocion,precio,metodo_pago,fecha_emision)
--VALUES (1,998,'Tarjeta de débito','2024-10-19');
--GO

--Pero si deja Insertar valores por medio del procedimiento almacenado
EXEC Contadores.InsertarNuevaFactura
	@id_promocion = 1,
	@precio = 998,
	@metodo_pago = 'Tarjeta de débito',
	@fecha_emision = '2024-10-19';
GO

--Se restaura contexto de ejecución
REVERT;
GO

--Se observa que se agregó el valor correctamente
SELECT * FROM Factura;
GO