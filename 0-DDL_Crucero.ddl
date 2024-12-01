-- Generado por Oracle SQL Developer Data Modeler 23.1.0.087.0806
--   en:        2024-10-15 14:28:39 CEST
--   sitio:      SQL Server 2012
--   tipo:      SQL Server 2012



CREATE TABLE Cabina 
    (
     id_cabina INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     id_crucero INTEGER NOT NULL , 
     tipo_cabina NVARCHAR (20) NOT NULL , 
     ubicacion_cabina NVARCHAR (30) NOT NULL , 
     estado_cabina NVARCHAR (20) NOT NULL , 
     precio DECIMAL (10,2) NOT NULL 
    )
GO

ALTER TABLE Cabina ADD CONSTRAINT Cabina_PK PRIMARY KEY CLUSTERED (id_cabina)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Crucero 
    (
     id_crucero INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     nombre NVARCHAR (30) NOT NULL , 
     capacidad_maxima INTEGER NOT NULL , 
     tonelaje DECIMAL (10,2) NOT NULL , 
     estado_crucero NVARCHAR (20) NOT NULL 
    )
GO

ALTER TABLE Crucero ADD CONSTRAINT Crucero_PK PRIMARY KEY CLUSTERED (id_crucero)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Empleado 
    (
     id_empleado INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     id_crucero INTEGER NOT NULL , 
     nombre NVARCHAR (80) NOT NULL , 
     cargo NVARCHAR (50) NOT NULL , 
     salario DECIMAL (10,2) NOT NULL , 
     turno NVARCHAR (15) NOT NULL 
    )
GO

ALTER TABLE Empleado ADD CONSTRAINT Empleado_PK PRIMARY KEY CLUSTERED (id_empleado)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Escalas 
    (
     id_itinerario INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     Puerto_Salida INTEGER NOT NULL , 
     numero_parada INTEGER NOT NULL , 
     Puerto_Llegada INTEGER NOT NULL , 
     fecha_salida DATE NOT NULL , 
     fecha_llegada DATE NOT NULL 
    )
GO

ALTER TABLE Escalas ADD CONSTRAINT Escalas_PK PRIMARY KEY CLUSTERED (id_itinerario, Puerto_Salida, numero_parada)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Factura 
    (
     id_factura INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     id_promocion INTEGER , 
     precio DECIMAL (10,2) NOT NULL , 
     metodo_pago NVARCHAR (30) NOT NULL , 
     fecha_emision DATE NOT NULL 
    )
GO

ALTER TABLE Factura ADD CONSTRAINT Factura_PK PRIMARY KEY CLUSTERED (id_factura)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Itinerario 
    (
     id_itinerario INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     id_crucero INTEGER NOT NULL , 
     nombre_itinerario NVARCHAR (30) NOT NULL , 
     fecha_salida DATE NOT NULL , 
     fecha_llegada DATE NOT NULL 
    )
GO

ALTER TABLE Itinerario ADD CONSTRAINT Itinerario_PK PRIMARY KEY CLUSTERED (id_itinerario)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Pasajero 
    (
     id_pasajero INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     nombre NVARCHAR (30) NOT NULL , 
     apellido NVARCHAR (50) NOT NULL , 
     documento_identidad NVARCHAR (20) NOT NULL , 
     nacionalidad NVARCHAR (30) NOT NULL , 
     fecha_nacimiento DATE NOT NULL , 
     email NVARCHAR (75) NOT NULL , 
     telefono NVARCHAR (20) NOT NULL , 
     direccion NVARCHAR (50) NOT NULL 
    )
GO

ALTER TABLE Pasajero ADD CONSTRAINT Pasajero_PK PRIMARY KEY CLUSTERED (id_pasajero)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Promocion 
    (
     id_promocion INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     descripcion NVARCHAR (150) , 
     valor_descuento DECIMAL (4,2) NOT NULL , 
     fecha_inicio DATE NOT NULL , 
     fecha_fin DATE NOT NULL 
    )
GO

ALTER TABLE Promocion ADD CONSTRAINT Promocion_PK PRIMARY KEY CLUSTERED (id_promocion)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Puerto 
    (
     id_puerto INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     nombre NVARCHAR (50) NOT NULL , 
     ciudad NVARCHAR (30) NOT NULL , 
     pais NVARCHAR (30) NOT NULL 
    )
GO

ALTER TABLE Puerto ADD CONSTRAINT Puerto_PK PRIMARY KEY CLUSTERED (id_puerto)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Reserva 
    (
     id_reserva INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     id_crucero INTEGER NOT NULL , 
     id_factura INTEGER NOT NULL , 
     id_cabina INTEGER NOT NULL , 
     fecha_reserva DATE NOT NULL , 
     estado_reserva NVARCHAR (20) NOT NULL 
    )
GO

ALTER TABLE Reserva ADD CONSTRAINT Reserva_PK PRIMARY KEY CLUSTERED (id_reserva)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Reserva_Pasajero 
    (
     id_reserva INTEGER NOT NULL , 
     id_pasajero INTEGER NOT NULL 
    )
GO

ALTER TABLE Reserva_Pasajero ADD CONSTRAINT Reserva_Pasajero_PK PRIMARY KEY CLUSTERED (id_reserva, id_pasajero)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

CREATE TABLE Servicio_a_bordo 
    (
     id_servicio INTEGER NOT NULL IDENTITY NOT FOR REPLICATION , 
     id_crucero INTEGER NOT NULL , 
     nombre NVARCHAR (30) NOT NULL , 
     descripcion NVARCHAR (150) , 
     capacidad_maxima INTEGER , 
     fecha_servicio DATE , 
     precio DECIMAL (10,2) NOT NULL 
    )
GO

ALTER TABLE Servicio_a_bordo ADD CONSTRAINT Servicio_a_bordo_PK PRIMARY KEY CLUSTERED (id_servicio)
     WITH (
     ALLOW_PAGE_LOCKS = ON , 
     ALLOW_ROW_LOCKS = ON )
GO

ALTER TABLE Cabina 
    ADD CONSTRAINT Cabina_Crucero_FK FOREIGN KEY 
    ( 
     id_crucero
    ) 
    REFERENCES Crucero 
    ( 
     id_crucero 
    ) 
    ON DELETE CASCADE 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Empleado 
    ADD CONSTRAINT Empleado_Crucero_FK FOREIGN KEY 
    ( 
     id_crucero
    ) 
    REFERENCES Crucero 
    ( 
     id_crucero 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Escalas 
    ADD CONSTRAINT Escalas_Itinerario_FK FOREIGN KEY 
    ( 
     id_itinerario
    ) 
    REFERENCES Itinerario 
    ( 
     id_itinerario 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Escalas 
    ADD CONSTRAINT Escalas_PuertoLlegada_FK FOREIGN KEY 
    ( 
     Puerto_Llegada
    ) 
    REFERENCES Puerto 
    ( 
     id_puerto 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Escalas 
    ADD CONSTRAINT Escalas_PuertoSalida_FK FOREIGN KEY 
    ( 
     Puerto_Salida
    ) 
    REFERENCES Puerto 
    ( 
     id_puerto 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Factura 
    ADD CONSTRAINT Factura_Promocion_FK FOREIGN KEY 
    ( 
     id_promocion
    ) 
    REFERENCES Promocion 
    ( 
     id_promocion 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Itinerario 
    ADD CONSTRAINT Itinerario_Crucero_FK FOREIGN KEY 
    ( 
     id_crucero
    ) 
    REFERENCES Crucero 
    ( 
     id_crucero 
    ) 
    ON DELETE CASCADE 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Reserva 
    ADD CONSTRAINT Reserva_Cabina_FK FOREIGN KEY 
    ( 
     id_cabina
    ) 
    REFERENCES Cabina 
    ( 
     id_cabina 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Reserva 
    ADD CONSTRAINT Reserva_Crucero_FK FOREIGN KEY 
    ( 
     id_crucero
    ) 
    REFERENCES Crucero 
    ( 
     id_crucero 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Reserva 
    ADD CONSTRAINT Reserva_Factura_FK FOREIGN KEY 
    ( 
     id_factura
    ) 
    REFERENCES Factura 
    ( 
     id_factura 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Reserva_Pasajero 
    ADD CONSTRAINT Reserva_Pasajero_Pasajero_FK FOREIGN KEY 
    ( 
     id_pasajero
    ) 
    REFERENCES Pasajero 
    ( 
     id_pasajero 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Reserva_Pasajero 
    ADD CONSTRAINT Reserva_Pasajero_Reserva_FK FOREIGN KEY 
    ( 
     id_reserva
    ) 
    REFERENCES Reserva 
    ( 
     id_reserva 
    ) 
    ON DELETE CASCADE 
    ON UPDATE NO ACTION 
GO

ALTER TABLE Servicio_a_bordo 
    ADD CONSTRAINT Servicio_a_bordo_Crucero_FK FOREIGN KEY 
    ( 
     id_crucero
    ) 
    REFERENCES Crucero 
    ( 
     id_crucero 
    ) 
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION 
GO



-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            12
-- CREATE INDEX                             0
-- ALTER TABLE                             25
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE DATABASE                          0
-- CREATE DEFAULT                           0
-- CREATE INDEX ON VIEW                     0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE ROLE                              0
-- CREATE RULE                              0
-- CREATE SCHEMA                            0
-- CREATE SEQUENCE                          0
-- CREATE PARTITION FUNCTION                0
-- CREATE PARTITION SCHEME                  0
-- 
-- DROP DATABASE                            0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
