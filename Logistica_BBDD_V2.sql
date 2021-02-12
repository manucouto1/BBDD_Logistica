SET SCHEMA 'logistica';

DROP TABLE IF EXISTS EntregaReparto;
DROP TABLE IF EXISTS LineaReparto;
DROP TABLE IF EXISTS Suministro;
DROP TABLE IF EXISTS LineaNecesidadSuministro;
DROP TABLE IF EXISTS NecesidadesSuministro;
DROP TABLE IF EXISTS Hospital;
DROP TABLE IF EXISTS CentroDistribucion;
DROP TABLE IF EXISTS SlotReparto;
DROP TABLE IF EXISTS Reparto;
DROP TABLE IF EXISTS Camion;
DROP TABLE IF EXISTS Conductor;
DROP TABLE IF EXISTS Entrega;
DROP TABLE IF EXISTS Vuelo;
DROP TABLE IF EXISTS LineaPedido;
DROP TABLE IF EXISTS Pedido;
DROP TABLE IF EXISTS Provedor;
DROP TABLE IF EXISTS Comunidad;
DROP TABLE IF EXISTS Producto;
DROP TABLE IF EXISTS Localidad;



CREATE TABLE Localidad (
    id numeric(6) CONSTRAINT pk_loc PRIMARY KEY  NOT NULL,
    nom VARCHAR(36) NOT NULL,
    pai VARCHAR(36) NOT NULL,
    lat NUMERIC(6,3)  NOT NULL,
    long NUMERIC(6,3) NOT NULL
);

CREATE TABLE Producto (
    cod VARCHAR(12) CONSTRAINT pk_prod PRIMARY KEY  NOT NULL,
    name VARCHAR(24) NOT NULL,
    dcion VARCHAR(65)
);

CREATE TABLE Comunidad (
    n_com VARCHAR(24) CONSTRAINT pk_com PRIMARY KEY  NOT NULL,
    n_res VARCHAR(24) NOT NULL
);

CREATE TABLE Provedor (
    id NUMERIC(4) CONSTRAINT pk_prov PRIMARY KEY  NOT NULL,
    nom VARCHAR(12) NOT NULL
);

CREATE TABLE Pedido (
    cod VARCHAR(12) CONSTRAINT pk_ped PRIMARY KEY  NOT NULL,
    f_comp DATE NOT NULL,
    n_com VARCHAR(24) CONSTRAINT fk_ped_com REFERENCES Comunidad,
    id_prov NUMERIC(4) CONSTRAINT fk_ped_prov REFERENCES Provedor
);

CREATE TABLE LineaPedido (
    cod VARCHAR(12) CONSTRAINT pk_lPed PRIMARY KEY  NOT NULL,
    cant NUMERIC(6) NOT NULL,
    cod_prod VARCHAR(12) CONSTRAINT fk_lp_prod REFERENCES Producto ON DELETE SET NULL ON UPDATE CASCADE NOT NULL,
    cod_ped VARCHAR(12) CONSTRAINT fk_lp_ped REFERENCES Pedido ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

CREATE TABLE Vuelo (
    cod VARCHAR(12) CONSTRAINT pk_vue PRIMARY KEY  NOT NULL,
    f_sal TIMESTAMP NOT NULL,
    f_lle TIMESTAMP NOT NULL,
    id_ori NUMERIC(6) CONSTRAINT fk_v_orig REFERENCES Localidad ON DELETE SET NULL ON UPDATE CASCADE NOT NULL,
    id_des NUMERIC(6) CONSTRAINT fk_v_dest REFERENCES Localidad ON DELETE SET NULL ON UPDATE CASCADE NOT NULL
);

CREATE TABLE Entrega (
    cod VARCHAR(12) CONSTRAINT pk_ent PRIMARY KEY  NOT NULL,
    cant NUMERIC(6) NOT NULL,
    f_ent DATE NOT NULL,
    cod_linPed VARCHAR(12) CONSTRAINT fk_ent_linPed REFERENCES LineaPedido ON DELETE CASCADE,
    cod_vue VARCHAR(12) CONSTRAINT fk_ent_vue REFERENCES Vuelo ON DELETE SET NULL
);

CREATE TABLE Conductor (
    nss VARCHAR(17) CONSTRAINT pk_con PRIMARY KEY NOT NULL,
    nom VARCHAR(12) NOT NULL,
    ape VARCHAR(12) NOT NULL,
    edad NUMERIC(2)
);

CREATE TABLE Camion (
    cod VARCHAR(12) CONSTRAINT pk_cam PRIMARY KEY NOT NULL,
    mat VARCHAR(8) NOT NULL,
    marc VARCHAR(12),
    mod VARCHAR(12),
    cap NUMERIC(6),
    rod NUMERIC(7)
);

CREATE TABLE Reparto (
    n_seg VARCHAR(12) CONSTRAINT pk_rep PRIMARY KEY NOT NULL
);

CREATE TABLE SlotReparto (
    f_ini TIMESTAMP NOT NULL,
    f_fin TIMESTAMP NOT NULL,
    nss_cond VARCHAR(17) CONSTRAINT fk_slr_cond REFERENCES Conductor ON DELETE SET NULL,
    cod_cam VARCHAR(12) CONSTRAINT fk_slr_cam REFERENCES Camion ON DELETE SET NULL,
    n_seg VARCHAR(12) CONSTRAINT fk_slr_rep REFERENCES Reparto ON DELETE CASCADE ,
    PRIMARY KEY (f_ini, f_fin, n_seg)
);

CREATE TABLE CentroDistribucion (
    id NUMERIC(5) PRIMARY KEY NOT NULL,
    loc NUMERIC(6)CONSTRAINT fk_cd_loc REFERENCES Localidad ON DELETE SET NULL,
    h_ape TIME NOT NULL,
    h_cie TIME NOT NULL,
    n_com VARCHAR(24) CONSTRAINT fk_cd_com REFERENCES Comunidad ON DELETE SET NULL NOT NULL
);

CREATE TABLE Hospital (
    id NUMERIC(6) CONSTRAINT pk_hosp PRIMARY KEY NOT NULL,
    n_camas NUMERIC(6),
    loc NUMERIC(6) CONSTRAINT fk_hosp_loc REFERENCES Localidad,
    n_com VARCHAR(24) CONSTRAINT fk_hosp_com REFERENCES Comunidad
);

CREATE TABLE NecesidadesSuministro (
    id numeric(5) CONSTRAINT pk_nSum PRIMARY KEY NOT NULL,
    f_sum TIMESTAMP NOT NULL,
    id_hosp numeric(12) CONSTRAINT fk_nSum_hosp REFERENCES Hospital ON DELETE SET NULL
);

CREATE TABLE LineaNecesidadSuministro (
    cod VARCHAR(12) CONSTRAINT pk_lnSum PRIMARY KEY NOT NULL,
    cant NUMERIC(6) NOT NULL,
    urg VARCHAR(12),
    est VARCHAR(12),
    cod_prod VARCHAR(12) CONSTRAINT fk_nSum_prod REFERENCES Producto ON DELETE CASCADE NOT NULL,
    id_nSum numeric(5) CONSTRAINT pk_nSum_nSum REFERENCES NecesidadesSuministro ON DELETE CASCADE NOT NULL
);

CREATE TABLE Suministro (
    id numeric(5) CONSTRAINT pk_sum PRIMARY KEY NOT NULL,
    f_sum TIMESTAMP NOT NULL,
    est VARCHAR(12),
    id_ns numeric(5) CONSTRAINT pk_nSum REFERENCES NecesidadesSuministro ON DELETE SET NULL,
    id_c_dist numeric(5) CONSTRAINT pk_c_dist REFERENCES CentroDistribucion ON DELETE SET NULL
);

CREATE TABLE LineaReparto(
    cod VARCHAR(12) CONSTRAINT pk_lRep PRIMARY KEY NOT NULL,
    est VARCHAR(12),
    cant numeric (6),
    sal TIMESTAMP NOT NULL,
    lle TIMESTAMP NOT NULL,
    ord numeric(3),
    cod_ent VARCHAR(12) CONSTRAINT  fk_c_ent REFERENCES Entrega ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    id_sum  numeric(5) CONSTRAINT fk_id_sum REFERENCES Suministro ON DELETE SET NULL  ON UPDATE CASCADE ,
    n_seg VARCHAR(12) CONSTRAINT fk_lRep_rep REFERENCES Reparto ON DELETE SET NULL ON UPDATE CASCADE
);



INSERT INTO Localidad VALUES (1,'Ap Madrid', 'Spain', 40.4165000,  -3.7025600);
INSERT INTO Localidad VALUES (2,'Ap Valencia', 'Spain', 39.4697500,  -0.3773900);
INSERT INTO Localidad VALUES (3,'Ap Salvador de Bahía', 'Brasil', -12.9704, -38.5124);
INSERT INTO Localidad VALUES (4,'Ap Ciudad de México', 'Méjico', 19.4284706, -99.1276627);
INSERT INTO Localidad VALUES (5,'Ap Hong Kong', 'China', 22.2500000, 114.1667000);
INSERT INTO Localidad VALUES (6, 'Nave Torrejón de Ardoz', 'Spain', 40.4553500, -3.4697300);
INSERT INTO Localidad VALUES (7, 'Nave Santiago de Compostela', 'Spain', 42.8805200, -8.5456900);
INSERT INTO Localidad VALUES (8, 'Nave Pamplona', 'Spain', 42.8168700, -1.6432300);
INSERT INTO Localidad VALUES (9, 'H Santiago-CHUS',  'Spain', 42.8690833, -8.565305555555556);
INSERT INTO Localidad VALUES (10, 'H Navarra-CHN', 'Spain', 42.806364, -1.668603);
INSERT INTO Localidad VALUES (11, 'H La Paz', 'Spain', 40.480931, -3.687358);

INSERT INTO Producto VALUES ('111aaa', 'Mascarillas','material de uso generico');
INSERT INTO Producto VALUES ('222bbb', 'Respiradores','material para cabinas uci');
INSERT INTO Producto VALUES ('333ccc', 'Gel', 'material de uso generico');

INSERT INTO Comunidad VALUES ('CA Galicia', 'Roman');
INSERT INTO Comunidad VALUES ('CA Madrid', 'Victor');
INSERT INTO Comunidad VALUES ('CF Navarra', 'Juan');

INSERT INTO Provedor VALUES (1, 'Chinacorp');
INSERT INTO Provedor VALUES (2, 'Brasilcorp');
INSERT INTO Provedor VALUES (3, 'Mexicorp');

INSERT INTO Pedido VALUES ('111', '11-03-20', 'CA Galicia', 1 );
INSERT INTO Pedido VALUES ('222', '12-03-20', 'CF Navarra', 2 );
INSERT INTO Pedido VALUES ('333', '01-05-20', 'CA Madrid', 3 );

INSERT INTO LineaPedido VALUES ('1a',  18000, '111aaa', '111');
INSERT INTO LineaPedido VALUES ('1b',  5000, '222bbb', '111');
INSERT INTO LineaPedido VALUES ('1c',  12000, '333ccc', '111');

INSERT INTO LineaPedido VALUES ('2a',  18000, '111aaa', '222');
INSERT INTO LineaPedido VALUES ('2b',  5000, '222bbb', '222');
INSERT INTO LineaPedido VALUES ('2c',  12000, '333ccc', '222');

INSERT INTO LineaPedido VALUES ('3a',  18000, '111aaa', '333');
INSERT INTO LineaPedido VALUES ('3b',  5000, '222bbb', '333');
INSERT INTO LineaPedido VALUES ('3c',  12000, '333ccc', '333');

INSERT INTO Vuelo VALUES ('111aaa', TIMESTAMP '01-05-20 00:34:09', TIMESTAMP '12-03-20 10:34:09', 4, 1);
INSERT INTO Vuelo VALUES ('222bbb', TIMESTAMP '15-03-20 12:34:09', TIMESTAMP '16-03-20 00:34:09', 3, 1);
INSERT INTO Vuelo VALUES ('333ccc', TIMESTAMP '23-06-20 12:34:09', TIMESTAMP '23-06-20 17:34:09', 5, 1);

INSERT INTO Entrega VALUES ('1a', 5000, '11-03-20', '1a', '111aaa');
INSERT INTO Entrega VALUES ('1b', 7000, '12-04-20', '1a', '111aaa');
INSERT INTO Entrega VALUES ('3a', 6000, '12-03-20', '1a', '333ccc');
INSERT INTO Entrega VALUES ('3b', 5000, '11-03-20', '1b', '111aaa');
INSERT INTO Entrega VALUES ('3c', 2000, '11-03-20', '1c', '111aaa');
INSERT INTO Entrega VALUES ('4a', 6000, '12-04-20', '1c', '111aaa');
INSERT INTO Entrega VALUES ('4b', 4000, '12-03-20', '1c', '111aaa');

INSERT INTO Entrega VALUES ('1c', 5000, '11-03-20', '2b', '111aaa');
INSERT INTO Entrega VALUES ('4c', 6500, '11-03-20', '3c', '111aaa');
INSERT INTO Entrega VALUES ('5a', 5500, '11-03-20', '3c', '333ccc');

INSERT INTO Conductor VALUES ('XXIS123456789012', 'Ramon',  'Cajal', 47);
INSERT INTO Conductor VALUES ('XXIS918273645012', 'Raul',  'Cimas', 32);
INSERT INTO Conductor VALUES ('XXIS186754569012', 'Fidel',  'Castro', 21);

INSERT INTO Camion VALUES ('111aaa', 'M0000ZZ', 'Pegaso', '1a', 12000, 738234);
INSERT INTO Camion VALUES ('111bbb', 'M1111ZZ', 'Pegaso', '2b', 6000, 915323);
INSERT INTO Camion VALUES ('222aaa', 'M2222ZZ', 'Mercedes', '1a', 10000, 42905);
INSERT INTO Camion VALUES ('222bbb', 'M3333ZZ', 'Mercedes', '2b', 5000, 23523);

INSERT INTO Reparto VALUES ('111aaa');
INSERT INTO Reparto VALUES ('111bbb');
INSERT INTO Reparto VALUES ('111ccc');

INSERT INTO Reparto VALUES ('111aba');
INSERT INTO Reparto VALUES ('111abb');
INSERT INTO Reparto VALUES ('111abc');

INSERT INTO Reparto VALUES ('111aca');
INSERT INTO Reparto VALUES ('111acb');
INSERT INTO Reparto VALUES ('111acc');

-- TODO Crear todos los slots que harían falta para las entregas
INSERT INTO SlotReparto VALUES ('11-03-20 10:34:09 AM', '12-03-20 10:34:09 AM', 'XXIS186754569012','111aaa','111aaa');
INSERT INTO SlotReparto VALUES ('29-04-20 10:34:09 AM', '02-05-20 10:34:09 AM', 'XXIS918273645012','111aaa','111aaa');
INSERT INTO SlotReparto VALUES ( '01-05-20 00:34:09 AM', '01-05-20 10:34:09 AM', 'XXIS918273645012','111aaa','111aaa');

INSERT INTO SlotReparto VALUES ('11-03-20 10:34:09 AM', '12-03-20 10:34:09 AM', 'XXIS186754569012','111bbb','111bbb');
INSERT INTO SlotReparto VALUES ('12-03-20 10:34:09 AM', '13-03-20 10:34:09 AM', 'XXIS918273645012','111bbb','111bbb');
INSERT INTO SlotReparto VALUES ( '13-03-20 10:34:09 AM', '15-03-20 10:34:09 AM', 'XXIS918273645012','111bbb','111bbb');

INSERT INTO SlotReparto VALUES ('11-03-20 10:34:09 AM', '12-03-20 10:34:09 AM', 'XXIS186754569012','222aaa','111ccc');
INSERT INTO SlotReparto VALUES ('12-03-20 10:34:09 AM', '13-03-20 10:34:09 AM', 'XXIS918273645012','222aaa','111ccc');
INSERT INTO SlotReparto VALUES ( '01-05-20 00:34:09 AM', '01-05-20 10:34:09 AM', 'XXIS918273645012','222aaa','111ccc');

INSERT INTO CentroDistribucion VALUES (1, 6, '07:00:00 AM', '09:00:00 PM', 'CA Madrid');
INSERT INTO CentroDistribucion VALUES (2, 7, '08:00:00 AM', '07:00:00 PM', 'CA Galicia');
INSERT INTO CentroDistribucion VALUES (3, 8, '07:30:00 AM', '09:30:00 PM', 'CF Navarra');

INSERT INTO Hospital VALUES (1, 15000, 9, 'CA Galicia');
INSERT INTO Hospital VALUES (2, 20000, 10, 'CF Navarra');
INSERT INTO Hospital VALUES (3, 40000, 11, 'CA Madrid');

INSERT INTO NecesidadesSuministro VALUES (1,'21-01-20 00:34:09 AM', 1);
INSERT INTO NecesidadesSuministro VALUES (2,'07-02-20 00:34:09 AM', 2);
INSERT INTO NecesidadesSuministro VALUES (3,'15-02-20 00:34:09 AM', 3);
INSERT INTO NecesidadesSuministro VALUES (4,'29-02-20 00:34:09 AM', 1);
INSERT INTO NecesidadesSuministro VALUES (5,'01-05-20 00:34:09 AM', 2);

INSERT INTO Suministro VALUES (1,'21-01-20 00:34:09 AM' ,'completado', 1, 1);
INSERT INTO Suministro VALUES (2,'21-01-20 00:34:09 AM' ,'en almacen', 2, 2);
INSERT INTO Suministro VALUES (3,'21-01-20 00:34:09 AM' ,'en almacen', 3, 3);
INSERT INTO Suministro VALUES (4,'21-01-20 00:34:09 AM' ,'en almacen', 4, 1);
INSERT INTO Suministro VALUES (5,'21-01-20 00:34:09 AM' ,'en almacen', 5, 2);
INSERT INTO Suministro VALUES (6,'21-01-20 00:34:09 AM' ,'en almacen', 1, 3);
INSERT INTO Suministro VALUES (7,'21-01-20 00:34:09 AM' ,'en almacen', 2, 1);
INSERT INTO Suministro VALUES (8,'21-01-20 00:34:09 AM' ,'en almacen', 3, 2);
INSERT INTO Suministro VALUES (9,'21-01-20 00:34:09 AM' ,'en almacen', 4, 3);

INSERT INTO LineaNecesidadSuministro VALUES ('1a', 1000, 'alta', 'pedido', '222bbb',1);
INSERT INTO LineaNecesidadSuministro VALUES ('1b', 1000, 'alta', 'pedido', '111aaa',2);
INSERT INTO LineaNecesidadSuministro VALUES ('3a', 1000, 'alta', 'pendiente', '111aaa',1);
INSERT INTO LineaNecesidadSuministro VALUES ('3b', 1000, 'alta', 'pendiente', '222bbb',2);
INSERT INTO LineaNecesidadSuministro VALUES ('3c', 1000, 'alta', 'pendiente', '333ccc',3);
INSERT INTO LineaNecesidadSuministro VALUES ('4a', 1000, 'alta', 'pendiente', '111aaa',2);
INSERT INTO LineaNecesidadSuministro VALUES ('4b', 1000, 'alta', 'pendiente', '222bbb',3);
INSERT INTO LineaNecesidadSuministro VALUES ('4c', 1000, 'alta', 'pendiente', '333ccc',4);
INSERT INTO LineaNecesidadSuministro VALUES ('5a', 1000, 'alta', 'pendiente', '111aaa',3);
INSERT INTO LineaNecesidadSuministro VALUES ('5b', 1000, 'alta', 'pendiente', '222bbb',4);
INSERT INTO LineaNecesidadSuministro VALUES ('5c', 1000, 'alta', 'pendiente', '333ccc',5);


INSERT INTO LineaReparto VALUES ('1a', 'transito', 1000, '11-03-20 10:34:09 AM', '12-03-20 10:34:09 AM', 3,'1a',1, '111aaa');
INSERT INTO LineaReparto VALUES ('1b', 'en camino', 1000, '29-04-20 10:34:09 AM', '02-05-20 10:34:09 AM', 2, '1b',2, '111aaa');
INSERT INTO LineaReparto VALUES ('1c', 'destino', 1000, '01-05-20 00:34:09 AM', '01-05-20 10:34:09 AM', 1, '3a',3, '111aaa');

INSERT INTO LineaReparto VALUES ('2a', 'transito', 1000, '11-03-20 10:34:09 AM', '12-03-20 10:34:09 AM', 3,'3b',4, '111bbb');
INSERT INTO LineaReparto VALUES ('2b', 'en camino', 1000, '12-03-20 10:34:09 AM', '13-03-20 10:34:09 AM', 2, '3c', 5, '111bbb');
INSERT INTO LineaReparto VALUES ('2c', 'destino', 1000, '13-03-20 10:34:09 AM', '15-03-20 10:34:09 AM', 1, '4a', 6, '111bbb');

INSERT INTO LineaReparto VALUES ('3a', 'transito', 1000, '11-03-20 10:34:09 AM', '12-03-20 10:34:09 AM', 3,'4b', 7, '111ccc');
INSERT INTO LineaReparto VALUES ('3b', 'en camino', 1000, '12-03-20 10:34:09 AM', '12-03-20 10:34:09 AM', 2, '4c', 8, '111ccc');
INSERT INTO LineaReparto VALUES ('3c', 'destino', 1000, '13-03-20 10:34:09 AM', '15-03-20 10:34:09 AM', 1, '5a', 9, '111ccc');

