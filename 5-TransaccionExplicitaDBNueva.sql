USE Cruceros_ASGBD;
GO

--Creando Tablas
DROP TABLE IF EXISTS Pasajero;
GO
CREATE TABLE Pasajero(
	id_pasajero INT NOT NULL IDENTITY(1,1),
	nombre VARCHAR(30) NOT NULL,
	PRIMARY KEY (id_pasajero)
);
GO

DROP TABLE IF EXISTS Reserva;
GO
CREATE TABLE Reserva(
	id_reserva INT NOT NULL IDENTITY(1,1),
	id_factura INT NOT NULL,
	PRIMARY KEY (id_reserva),
	FOREIGN KEY (id_factura) REFERENCES Factura (id_factura)
);
GO

DROP TABLE IF EXISTS Servicio_a_bordo;
GO
CREATE TABLE Servicio_a_bordo(
	id_servicio INT NOT NULL IDENTITY (1,1),
	nombre NVARCHAR(30) NOT NULL,
	precio DECIMAL (10,2) NOT NULL,
	PRIMARY KEY (id_servicio)
);
GO

DROP TABLE IF EXISTS Reserva_Pasajero;
GO
CREATE TABLE Reserva_Pasajero(
	id_reserva INT NOT NULL,
	id_pasajero INT NOT NULL,
	FOREIGN KEY (id_reserva) REFERENCES Reserva (id_reserva),
	FOREIGN KEY (id_pasajero) REFERENCES Pasajero (id_pasajero)
);
GO

--Insertando datos
INSERT INTO Pasajero (nombre) VALUES ('PasajeroUno');
GO

INSERT INTO Reserva (id_factura) VALUES (1);
GO

INSERT INTO Servicio_a_bordo VALUES ('Servicio de prueba',30);
GO

INSERT INTO Reserva_Pasajero VALUES (1,1);
GO

BEGIN TRY
    -- Iniciar la transacción
    BEGIN TRANSACTION;

    -- Declaración de variables
    DECLARE @IdPasajero INT = 1;-- ID del pasajero que compra el servicio
	DECLARE @IdReserva INT; --ID de la reserva asociada al pasajero
    DECLARE @IdServicio INT = 1; -- ID del servicio que se compra
    DECLARE @PrecioServicio DECIMAL(10, 2); -- Precio del servicio que se compra

	-- Obtener el precio del servicio
    SELECT @PrecioServicio = precio 
	FROM Servicio_a_bordo 
	WHERE id_servicio = @IdServicio;

	 -- Verificar si el servicio existe
    IF @PrecioServicio IS NULL
    BEGIN;
        THROW 50001, 'El servicio especificado no existe.', 1;
    END;

	--Obtener idReserva asociada al pasajero
	SELECT @IdReserva = id_reserva 
	FROM Reserva_Pasajero 
	WHERE id_pasajero = @IdPasajero;

	-- Verificar si el pasajero existe
    IF @IdReserva IS NULL
    BEGIN;
        THROW 50002, 'El pasajero no existe o no tiene reserva', 1;
    END;

    -- Actualizar el monto total de la factura de la reserva sumando el precio del servicio
    UPDATE Factura
    SET precio = precio + @PrecioServicio
    WHERE id_factura = (SELECT id_factura FROM Reserva WHERE id_reserva = @IdReserva)

    -- Si todo ha salido bien, confirmar la transacción
    COMMIT;
    
END TRY
BEGIN CATCH
    -- Si ocurre un error, revertir la transacción
    ROLLBACK;
	THROW;
END CATCH;

--Viendo resultado
--SELECT * FROM Factura;