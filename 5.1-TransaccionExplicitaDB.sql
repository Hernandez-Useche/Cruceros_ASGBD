USE Cruceros_ASGBD;
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
