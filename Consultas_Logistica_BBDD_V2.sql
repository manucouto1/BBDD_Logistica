SET SCHEMA 'logistica';
-- Punto 1

-- 1 Mostra a listaxe completa de compras realizadas ata o momento por todas as
-- administracións: identificador e nome da administración, data da compra, identificador e
-- nome do provedor.

SELECT p.cod, p.n_com, p.f_comp, p.id_prov, pr.nom FROM pedido p
    JOIN provedor pr ON p.id_prov = pr.id
    JOIN comunidad c on p.n_com = c.n_com

WHERE p.f_comp < '01-05-2020';

-- 2 Elixe unha das compras do resultado do punto 1. Mostra a listaxe completa de produtos
-- incluídos na dita compra: identificador/nome do produto, e cantidade adquirida na compra.

SELECT pr.name, lp.cant FROM lineapedido lp
    JOIN pedido p ON lp.cod_ped = p.cod
    JOIN producto pr ON lp.cod_prod = pr.cod
where p.cod = '111';

-- Punto 2

-- 3 Para a compra seleccionada na consulta 2, indica en cantas entregas diferentes foi acordado
-- co provedor dividir a compra realizada.

SELECT count(*) FROM entrega
WHERE cod_linped in (
    SELECT lp.cod FROM lineapedido lp
    JOIN pedido p ON lp.cod_ped = p.cod
    JOIN producto pr ON lp.cod_prod = pr.cod
    WHERE p.cod = '111'
);

-- 4 Para a compra seleccionada na consulta 2, mostra a listaxe prevista de entregas a realizar
-- para cada produto incluído na compra: identificador/nome do produto, data de entrega
-- prevista, e cantidade a entregar.

SELECT e.cod as entrega, w.name as producto, e.cant, e.f_ent FROM entrega e
    JOIN (
        SELECT pr.cod, pr.name, lp.cod as cod_linped  FROM lineapedido lp
            JOIN pedido p ON lp.cod_ped = p.cod
            JOIN producto pr ON lp.cod_prod = pr.cod
        WHERE p.cod = '111'
    ) w ON w.cod_linped = e.cod_linped
ORDER BY w.cod, e.f_ent;

-- 5 Repite a consulta anterior, mostrando esta vez: identificador/nome do produto, data de
-- entrega prevista, cantidade entregada de produto, cantidade total comprada de produto, e
-- proporción entre elas (entregada/comprada).

SELECT e.cod as entrega, w.name as producto, e.cant, 100*round(e.cant / w.cant, 3) as "%_del total", e.f_ent FROM entrega e
    JOIN (
        SELECT pr.cod, pr.name, lp.cod as cod_linped, lp.cant FROM lineapedido lp
            JOIN pedido p ON lp.cod_ped = p.cod
            JOIN producto pr ON lp.cod_prod = pr.cod
        WHERE p.cod = '111'
    ) w ON w.cod_linped = e.cod_linped
ORDER BY w.cod, e.f_ent;

-- Punto 3

-- 6 Mostra todos os voos que están previstos o día 01 de maio de 2020: localidade de orixe,
-- localidade de destino, hora estimada de saída, e hora estimada de chegada.

SELECT cod ,
       (SELECT l1.nom from localidad l1 where id = vuelo.id_ori) as origen,
       (SELECT l1.nom from localidad l1 where id = vuelo.id_des) as destino,
       CAST( f_sal as TIME), CAST( f_sal as TIME) FROM vuelo
WHERE CAST(f_sal as DATE) = '01-05-20';

-- 7 Elixe un dos voos do resultado da consulta 6. Indica a listaxe de produtos que transporta con
-- destino a cada administración: identificador/nome do produto, cantidade transportada.


SELECT CASE WHEN p.name IS NULL THEN 'ERROR Desconocido' ELSE p.name END as producto,
       CASE WHEN sum(e.cant) IS NULL THEN 0 ELSE sum(e.cant) END as cantidad,
       CASE WHEN e.n_com IS NULL THEN 'ERROR Sin Destino' ELSE e.n_com  END as destino
FROM vuelo v
    JOIN (
        SELECT e.cod, c.n_com, e.cant, e.cod_linped, e.cod_vue FROM entrega e
            LEFT JOIN lineareparto l on e.cod = l.cod_ent
            LEFT JOIN suministro on l.id_sum = suministro.id
            LEFT JOIN centrodistribucion ct on suministro.id_c_dist = ct.id
            LEFT JOIN comunidad c on ct.n_com = c.n_com
    ) e  ON e.cod_vue = v.cod
    LEFT JOIN lineapedido lp ON lp.cod = e.cod_linped
    LEFT JOIN producto p ON lp.cod_prod = p.cod
WHERE v.cod = '111aaa'
GROUP BY (producto, destino);

-- 8 . Repite a consulta anterior, mostrando esta vez: identificador/nome do produto, cantidade
-- transportada, identificador do provedor que realiza a entrega e identificador da
-- administración de destino.

SELECT CASE WHEN p.name IS NULL THEN 'ERROR Desconocido' ELSE p.name END as producto,
       CASE WHEN e.cant IS NULL THEN 0 ELSE e.cant END as cantidad,
       CASE WHEN pro.nom IS NULL THEN 'ERROR Desconocido' ELSE pro.nom END as provedor,
       CASE WHEN e.n_com IS NULL THEN 'ERROR Sin Destino' ELSE e.n_com  END as destino

FROM vuelo v
    JOIN (
        SELECT e.cod, c.n_com, e.cant, e.cod_linped, e.cod_vue FROM entrega e
            LEFT JOIN lineareparto l on e.cod = l.cod_ent
            LEFT JOIN suministro on l.id_sum = suministro.id
            LEFT JOIN centrodistribucion ct on suministro.id_c_dist = ct.id
            LEFT JOIN comunidad c on ct.n_com = c.n_com
    ) e  ON e.cod_vue = v.cod
    LEFT JOIN lineapedido lp ON lp.cod = e.cod_linped
    LEFT JOIN producto p ON lp.cod_prod = p.cod
    LEFT JOIN pedido ped ON lp.cod_ped = ped.cod
    LEFT JOIN provedor pro ON ped.id_prov = pro.id
WHERE v.cod = '111aaa';

-- Punto 4

-- 9 Para cada centro hospitalario, indica cantas solicitudes semanais de material leva realizadas
-- en total ate o 01 de maio de 2020, ás 00:00:00h. Mostra: identificador e nome do centro,
-- nome da administración da que depende, e número de solicitudes

SELECT h.id, l.nom as centro, h.n_com as comunidad, count(n.id) as solicitudes FROM hospital h
    JOIN necesidadessuministro n ON h.id = n.id_hosp
    JOIN localidad l on h.loc = l.id
    where n.f_sum < '01-05-20 00:00:00'
GROUP BY (h.id, l.nom, h.n_com);

-- 10 Selecciona un dos centros do resultado da consulta anterior. Mostra o contido de todas as
-- súas solicitudes: data da solicitude, tipo de produto demandado, cantidade demandada.

SELECT ns.id as solicitud, CAST(ns.f_sum AS DATE) as fecha, p.name as producto, p.dcion, lns.cant as cantidad FROM necesidadessuministro ns
    JOIN hospital h on ns.id_hosp = h.id
    LEFT JOIN lineanecesidadsuministro lns on ns.id = lns.id_nsum
    LEFT JOIN producto p on lns.cod_prod = p.cod
WHERE h.id = 3;

-- 11 Selecciona un dos voos do resultado da consulta 6, e indica como se repartiu a carga
-- transportada. Para cada asignación de produtos realizada mostra: identificador/nome de
-- produto, administración de destino, centro hospitalario de destino, cantidade asignada.
SELECT lp.cod_prod, lr.cant, h.n_com, l.nom FROM  lineapedido lp
    LEFT JOIN entrega e ON e.cod_linped = lp.cod
    LEFT JOIN lineareparto lr ON lr.cod_ent = e.cod
    LEFT JOIN suministro s ON lr.id_sum = s.id
    LEFT JOIN necesidadessuministro ns ON s.id_ns = ns.id
    LEFT JOIN hospital h ON ns.id_hosp = h.id
    LEFT JOIN comunidad c ON h.n_com = c.n_com
    LEFT JOIN vuelo v ON e.cod_vue = v.cod
    LEFT JOIN  localidad l on h.loc = l.id
where v.cod = '111aaa';

-- Punto 5

-- 12 Indica os detalles de todas as paradas das rutas de transporte programadas:
-- identificador/nome da ruta, orde/hora programada de parada, comunidade autónoma de
-- parada, centro de distribución da parada.

-- Si se consideran los diferentes repartos como rutas
select  lr.n_seg as seguimiento, lr.cod as parada, w.n_com, w.nom as destino, lr.ord, CAST(lr.sal as TIME), CAST(lr.lle as TIME)  from lineareparto lr
    join suministro s on lr.id_sum = s.id
    join (
        select distinct s.id_ns, cd.n_com, l.nom, l.lat, l.long from  suministro s
        join centrodistribucion cd on s.id_c_dist = cd.id
        join localidad l on cd.loc = l.id
    ) w ON s.id_ns = w.id_ns
ORDER BY lr.n_seg, lr.ord;

--Si se consideran los tramos como rutas, por ejemplo para el reparto 111aaa
select lr.n_seg as seguimiento, lr.cod as parada, w.n_com, w.nom as destino, lr.ord, CAST(lr.sal as TIME), CAST(lr.lle as TIME)  from lineareparto lr
    join suministro s on lr.id_sum = s.id
    join (
        select distinct s.id_ns, cd.n_com, l.nom, l.lat, l.long from  suministro s
        join centrodistribucion cd on s.id_c_dist = cd.id
        join localidad l on cd.loc = l.id
    ) w ON s.id_ns = w.id_ns
where lr.n_seg = '111aaa';

-- 13 Mostra, para cada centro de distribución, o seu identificador, nome, comunidade autónoma
-- e numero de rutas programadas que pasan cada día por el.

select distinct cd.id, lc.nom as nombre, CAST(lr.lle as DATE) dia, cd.n_com, count(lr.ord) from lineareparto lr
    join suministro s on lr.id_sum = s.id
    join centrodistribucion cd on s.id_c_dist = cd.id
    join localidad lc on cd.loc = lc.id
GROUP BY cd.id, nombre, cd.n_com, dia;

-- 14 Selecciona unha das rutas do resultado da consulta 12. Mostra que condutor e que camión
-- fixeron a dita ruta o día 01 de maio de 2020.

SELECT distinct l.n_seg, f_ini, f_fin, coalesce(c.nom, c.ape) nombre, concat(c2.marc,' ', c2.mod) as camion FROM slotreparto slr
    JOIN reparto rp on slr.n_seg = rp.n_seg
    JOIN conductor c on slr.nss_cond = c.nss
    JOIN camion c2 on slr.cod_cam = c2.cod
    JOIN lineareparto l on slr.n_seg = l.n_seg
where (CAST (f_ini as DATE) between CAST (sal as DATE) AND CAST(lle as DATE)
   OR CAST (sal as DATE) = f_ini)
AND l.cod in (
    with ruta as (
        select distinct lr.cod, lr.n_seg, w.id, w.nom as destino, lr.sal, lr.lle from lineareparto lr
            join suministro s on lr.id_sum = s.id
            join centrodistribucion cd on s.id_c_dist = cd.id
            join localidad l on cd.loc = l.id
            join (
                select distinct l.nom, cd.id, s.id_ns, cd.n_com,  l.lat, l.long from  suministro s
                join centrodistribucion cd on s.id_c_dist = cd.id
                join localidad l on cd.loc = l.id
            ) w ON s.id_ns = w.id_ns
    )
SELECT distinct r1.cod from ruta r1
    WHERE r1.n_seg = l.n_seg AND r1.destino = 'Nave Torrejón de Ardoz'
    AND ('01-05-20' BETWEEN CAST (r1.sal as DATE) AND CAST(r1.lle as DATE)
               OR CAST (r1.sal as DATE) = '01-05-20'
               OR CAST (r1.lle as DATE) = '01-05-20'));

-- Hay 2 tramos que corresponden a esa ruta en esas fechas

-- 15 Considerando a mesma ruta da consulta 14, mostra os voos aos que corresponden os
-- produtos transportados.

SELECT l.n_seg, v.cod as vuelo, pro.name, e.cant as vuelo FROM vuelo v
    JOIN entrega e on v.cod = e.cod_vue
    JOIN lineapedido lp on e.cod_linped = lp.cod
    JOIN producto pro on lp.cod_prod = pro.cod
    JOIN lineareparto l on e.cod = l.cod_ent
WHERE l.cod in (
    with ruta as (
        select distinct  lr.cod, lr.n_seg, w.id, w.nom as destino, lr.sal, lr.lle  from lineareparto lr
            join suministro s on lr.id_sum = s.id
            join (
                select distinct l.nom, cd.id, s.id_ns, cd.n_com,  l.lat, l.long from  suministro s
                join centrodistribucion cd on s.id_c_dist = cd.id
                join localidad l on cd.loc = l.id
            ) w ON s.id_ns = w.id_ns
    )
    SELECT distinct r1.cod from ruta r1
    WHERE r1.n_seg = l.n_seg AND r1.destino = 'Nave Torrejón de Ardoz'
    AND ('01-05-20' BETWEEN CAST (r1.sal as DATE) AND CAST(r1.lle as DATE)
               OR CAST (r1.sal as DATE) = '01-05-20'
               OR CAST (r1.lle as DATE) = '01-05-20')
    );

-- 16 Considerando a mesma ruta da consulta 14 mostra os produtos transportados, e a cantidade
-- TOTAL transportada de cada un.

-- Si queremos ver que productos correspondientes a el destino de ese tramo de la ruta seleccionada
SELECT l.n_seg, pro.name, e.cant
    FROM entrega e
    JOIN lineapedido lp on e.cod_linped = lp.cod
    JOIN producto pro on lp.cod_prod = pro.cod
    JOIN lineareparto l on e.cod = l.cod_ent
WHERE l.cod in (
    with ruta as (
        select distinct  lr.cod, lr.n_seg, w.id, w.nom as destino, lr.sal, lr.lle  from lineareparto lr
            join suministro s on lr.id_sum = s.id
            join (
                select distinct l.nom, cd.id, s.id_ns, cd.n_com,  l.lat, l.long from  suministro s
                join centrodistribucion cd on s.id_c_dist = cd.id
                join localidad l on cd.loc = l.id
            ) w ON s.id_ns = w.id_ns
    )
    SELECT distinct r1.cod from ruta r1
    WHERE r1.n_seg = l.n_seg AND r1.destino = 'Nave Torrejón de Ardoz'
    AND ('01-05-20' BETWEEN CAST (r1.sal as DATE) AND CAST(r1.lle as DATE)
               OR CAST (r1.sal as DATE) = '01-05-20'
               OR CAST (r1.lle as DATE) = '01-05-20')
    );


-- Si lo que queremos es ver que productos lleva el camión en ese tramo vemos las lineas de reparto programadas para rutas
-- posteriores pero en el mismo reparto además de los productos de la propia ruta estudiada.
SELECT l.n_seg, pro.name, e.cant
    FROM entrega e
    JOIN lineapedido lp on e.cod_linped = lp.cod
    JOIN producto pro on lp.cod_prod = pro.cod
    JOIN lineareparto l on e.cod = l.cod_ent
WHERE l.cod in (
    with ruta as (
        select distinct  lr.cod, lr.n_seg, w.id, w.nom as destino, lr.sal, lr.lle  from lineareparto lr
            join suministro s on lr.id_sum = s.id
            join (
                select distinct l.nom, cd.id, s.id_ns, cd.n_com,  l.lat, l.long from  suministro s
                join centrodistribucion cd on s.id_c_dist = cd.id
                join localidad l on cd.loc = l.id
            ) w ON s.id_ns = w.id_ns
    )
    SELECT distinct r1.cod from ruta r1
    WHERE r1.n_seg = l.n_seg AND ('01-05-20' BETWEEN CAST (r1.sal as DATE) AND CAST(r1.lle as DATE)
               OR CAST (r1.sal as DATE) = '01-05-20'
               OR CAST (r1.lle as DATE) = '01-05-20'
               OR CAST (r1.sal as DATE) > '01-05-20')
    );


-- 17 Considerando a mesma ruta da consulta 14 mostra a listaxe de produtos entregados en cada
-- centro de distribución no que parou: data de entrega, identificador/nome do centro de
-- distribución, produto entregado, cantidade entregada.
with ruta as (
    select distinct  lr.cod, lr.n_seg, w.id, w.nom as destino, lr.sal, lr.lle  from lineareparto lr
        join suministro s on lr.id_sum = s.id
        join (
            select distinct  cd.id, l.nom, s.id_ns, cd.n_com,  l.lat, l.long from  suministro s
            join centrodistribucion cd on s.id_c_dist = cd.id
            join localidad l on cd.loc = l.id
        ) w ON s.id_ns = w.id_ns
)
SELECT distinct l.n_seg, pro.name, e.cant, l.lle, w.destino
    FROM entrega e
    JOIN lineapedido lp on e.cod_linped = lp.cod
    JOIN producto pro on lp.cod_prod = pro.cod
    JOIN lineareparto l on e.cod = l.cod_ent
    JOIN (
        SELECT distinct r1.cod, r1.n_seg, r1.destino from ruta r1
        WHERE r1.n_seg = '111aaa'
        ) as w on l.n_seg = w.n_seg;

-- B) Escribe 3 consultas (tema libre) que funcionen na túa base de datos:


-- 18 Las consultas 7 y 8 se han hecho con un join exterior de más de 3 tablas para poder ver todos los vuelos
-- Si falta algun producto por identificar, no hay un destino o no hay cantidades se muestra información adecuada

SELECT CASE WHEN p.name IS NULL THEN 'ERROR Desconocido' ELSE p.name END as producto,
       CASE WHEN sum(e.cant) IS NULL THEN 0 ELSE sum(e.cant) END as cantidad,
       CASE WHEN e.n_com IS NULL THEN 'ERROR Sin Destino' ELSE e.n_com  END as destino
FROM vuelo v
    JOIN (
        SELECT e.cod, c.n_com, e.cant, e.cod_linped, e.cod_vue FROM entrega e
            LEFT JOIN lineareparto l on e.cod = l.cod_ent
            LEFT JOIN suministro s on l.id_sum = s.id
            LEFT JOIN centrodistribucion c2 on s.id_c_dist = c2.id
            LEFT JOIN comunidad c on c2.n_com = c.n_com
    ) e  ON e.cod_vue = v.cod
    LEFT JOIN lineapedido lp ON lp.cod = e.cod_linped
    LEFT JOIN producto p ON lp.cod_prod = p.cod
WHERE v.cod = '111aaa'
GROUP BY (producto, destino);

SELECT CASE WHEN pro.nom IS NULL THEN 'ERROR Desconocido' ELSE pro.nom END as provedor,
       CASE WHEN p.name IS NULL THEN 'ERROR Desconocido' ELSE p.name END as producto,
       CASE WHEN e.cant IS NULL THEN 0 ELSE e.cant END as cantidad,
       CASE WHEN e.n_com IS NULL THEN 'ERROR Sin Destino' ELSE e.n_com  END as destino

FROM vuelo v
    JOIN (
        SELECT e.cod, c.n_com, e.cant, e.cod_linped, e.cod_vue FROM entrega e
            LEFT JOIN lineareparto l on e.cod = l.cod_ent
            LEFT JOIN suministro s on l.id_sum = s.id
            LEFT JOIN necesidadessuministro ns ON s.id_ns = ns.id
            LEFT JOIN hospital h on ns.id_hosp = h.id
            LEFT JOIN comunidad c on h.n_com = c.n_com
    ) e  ON e.cod_vue = v.cod
    LEFT JOIN lineapedido lp ON lp.cod = e.cod_linped
    LEFT JOIN producto p ON lp.cod_prod = p.cod
    LEFT JOIN pedido ped ON lp.cod_ped = ped.cod
    LEFT JOIN provedor pro ON ped.id_prov = pro.id
WHERE v.cod = '111aaa';

--19

--20 Consulta con subconsulta de fila.

-- Ya se ha usado en la consulta 16

-- La subconsulta de fila se usa para recuperar solo las lineas de reparto correspondientes a un centro de distribución
-- en una fecha en concreto,

SELECT l.n_seg, pro.name, e.cant
    FROM entrega e
    JOIN lineapedido lp on e.cod_linped = lp.cod
    JOIN producto pro on lp.cod_prod = pro.cod
    JOIN lineareparto l on e.cod = l.cod_ent
WHERE l.cod in (
    with ruta as (
        select distinct  lr.cod, lr.n_seg, w.id, w.nom as destino, lr.sal, lr.lle  from lineareparto lr
            join suministro s on lr.id_sum = s.id
            join (
                select distinct l.nom, cd.id, s.id_ns, cd.n_com,  l.lat, l.long from  suministro s
                join centrodistribucion cd on s.id_c_dist = cd.id
                join localidad l on cd.loc = l.id
            ) w ON s.id_ns = w.id_ns
    )
    SELECT distinct r1.cod from ruta r1
    WHERE r1.n_seg = l.n_seg AND r1.destino = 'Nave Torrejón de Ardoz'
    AND ('01-05-20' BETWEEN CAST (r1.sal as DATE) AND CAST(r1.lle as DATE)
               OR CAST (r1.sal as DATE) = '01-05-20'
               OR CAST (r1.lle as DATE) = '01-05-20')
    );