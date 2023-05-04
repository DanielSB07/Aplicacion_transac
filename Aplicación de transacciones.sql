create database transacciones;

use transacciones;

create table clientes(
id int primary key,
nombre varchar(50) not null,
apellido varchar(50) not null,
telefono varchar (11) not null
);

create table cuenta (
  id_cliente int primary key,
  num_cuenta int,
  saldo int
);

create table transferencias (
  id int primary key,
  cuenta_origen int,
  cuenta_destino int,
  monto int,
  fecha datetime
);

insert into clientes(id, nombre, apellido, telefono) values 
(1001, 'Santiago', 'Barreto', 3021569987),
(1002, 'Karen', 'Sanchez', 3221478585);

insert into cuenta(id_cliente, num_cuenta, saldo) values 
(101, 55667788, 500000),
(102, 55443322, 200000),
(103, 56557789, 50000);

DELIMITER $$
CREATE PROCEDURE transferir(
	IN id int,
    IN cuenta_origen INT,
    IN cuenta_destino INT,
    IN monto INT
)
BEGIN
    DECLARE saldo_origen INT;
    DECLARE saldo_destino INT;

    START TRANSACTION;

    SELECT saldo INTO saldo_origen FROM cuenta WHERE num_cuenta = cuenta_origen FOR UPDATE;
    SELECT saldo INTO saldo_destino FROM cuenta WHERE num_cuenta = cuenta_destino FOR UPDATE;

    IF saldo_origen < monto THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saldo insuficiente';
    ELSE
        UPDATE cuenta SET saldo = saldo_origen - monto WHERE num_cuenta = cuenta_origen;
        UPDATE cuenta SET saldo = saldo_destino + monto WHERE num_cuenta = cuenta_destino;

        INSERT INTO transferencias(id, cuenta_origen, cuenta_destino, monto, fecha)
        VALUES(id, cuenta_origen, cuenta_destino, monto, NOW());

        COMMIT;
    END IF;
END$$
DELIMITER ;

CALL transferir(101, 56557789, 56557789, 50000);

select * from cuenta;
select * from transferencias;
