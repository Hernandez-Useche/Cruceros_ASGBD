--Se crea una base de datos 
DROP DATABASE IF EXISTS Cruceros_ASGBD;
GO
CREATE DATABASE Cruceros_ASGBD;
GO

USE Cruceros_ASGBD;
GO

--Se crea un esquema para guardar los objetos que se crearán para las pruebas
DROP SCHEMA IF EXISTS Contadores;
GO
CREATE SCHEMA Contadores;
GO

--Se crean las tablas en la DB
DROP TABLE IF EXISTS Promocion;
GO
CREATE TABLE Promocion
(
	id_promocion INT NOT NULL IDENTITY(1,1),
	descripcion NVARCHAR(150) NULL,
	valor_descuento DECIMAL(4,2) NOT NULL,
	fecha_inicio DATE NOT NULL,
	fecha_fin DATE NOT NULL,
	PRIMARY KEY (id_promocion)
);
GO

DROP TABLE IF EXISTS Factura;
GO
CREATE TABLE Factura
(
	id_factura INT NOT NULL IDENTITY(1,1),
	id_promocion INT NULL,
	precio DECIMAL(10,2) NOT NULL,
	metodo_pago NVARCHAR(30) NOT NULL,
	fecha_emision DATE NOT NULL,
	PRIMARY KEY (id_factura),
	FOREIGN KEY (id_promocion) REFERENCES Promocion(id_promocion),
	CHECK (metodo_pago IN ('Tarjeta de débito', 'Tarjeta de crédito','Efectivo','Transferencia','Otros'))
);
GO

--En el documento se exportan datos por medio de un texto plano, en el script se añaden manualmente
INSERT INTO Promocion (descripcion,valor_descuento,fecha_inicio,fecha_fin)
VALUES ('Promoción de prueba',25.00,'2024-11-07','2025-03-02');
GO

INSERT INTO Factura (id_promocion,precio,metodo_pago,fecha_emision)
VALUES
(1,650,'Efectivo','2024-03-02'),
(1,743,'Transferencia','2024-05-01'),
(1,954,'Tarjeta de débito','2024-08-10'),
(NULL,1300,'Tarjeta de crédito','2024-03-10');
GO

--Se crea una vista extrayendo algunos campos de la tabla Factura
DROP VIEW IF EXISTS Contadores.Facturas;
GO
CREATE VIEW Contadores.Facturas
AS
SELECT
	id_factura,precio,metodo_pago
FROM Factura;
GO

--Se crea un rol y se le asigna el permiso de SELECT sobre la VISTA
DROP ROLE IF EXISTS Contador;
GO
CREATE ROLE Contador;
GO

GRANT SELECT ON Contadores.Facturas TO Contador;
GO

--Se crea un usuario y se le asigna el rol Contador
DROP USER IF EXISTS ContadorUno;
GO
CREATE USER ContadorUno WITHOUT LOGIN;
GO

ALTER ROLE Contador
ADD MEMBER ContadorUno;
GO

--Ejecutamos pruebas como ContadorUno
EXECUTE AS USER = 'ContadorUno';
GO
--Se observa que al sentenciar SELECT sobre la tabla nos da un error
--SELECT * FROM Factura;
--GO

--Si se hace un SELECT Sobre la vista podemos observarla sin ningún problema
SELECT * FROM Contadores.Facturas;
GO

--Se restaura el contexto de ejecución
REVERT;
GO