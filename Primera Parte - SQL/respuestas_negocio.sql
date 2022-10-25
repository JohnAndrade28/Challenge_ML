/*Listar los usuarios que cumplan años el día de hoy cuya cantidad de ventas realizadas en enero 2020 sea superior a 1500. */
SELECT 	 O.IDENTIFICACION_VENDEDOR
		,C.NOMBRE
		,C.APELLIDO 
		,SUM(O.CANTIDAD) CANT_VENTAS
		,SUM(O.PRECIO) TOTAL_VENTAS
		,DATE(O.FVENTA) FECHA_VENTA
FROM ORDEN O
LEFT JOIN CUSTOMER C ON O.IDENTIFICACION_VENDEDOR = C.IDENTIFICACION 
where day(C.FNACIMIENTO)=day(NOW()) and month(C.FNACIMIENTO)=month(NOW())
AND DATE(O.FVENTA) BETWEEN '20220101' AND '20200131'
group by O.IDENTIFICACION_VENDEDOR
		,C.NOMBRE
		,C.APELLIDO 
having SUM(O.CANTIDAD) > 1500
order by CANT_VENTAS desc




/*Por cada mes del 2020, se solicita el top 5 de usuarios que más vendieron($) en la categoría CELULARES. Se requiere el mes y año de análisis,
 nombre y apellido del vendedor, cantidad de ventas realizadas, cantidad de productos vendidos y el monto total transaccionado.*/

select mes,anio, nombre, apellido, CANT_VENTAS,CANT_PRODUCTOS_VENDIDOS,TOTAL_TRANSACCIONADO, RANKING
from 
( 
	SELECT 	 O.IDENTIFICACION_VENDEDOR ID_VENDEDOR
			,C.NOMBRE
			,C.APELLIDO 
			,COUNT(*) CANT_VENTAS
			,SUM(O.CANTIDAD) CANT_PRODUCTOS_VENDIDOS
			,SUM(O.PRECIO)*O.CANTIDAD TOTAL_TRANSACCIONADO
			,MONTH(O.FVENTA) as mes
			,YEAR(O.FVENTA) as anio
			,ROW_NUMBER() OVER(PARTITION BY MONTH(FVENTA) ORDER BY SUM(O.PRECIO) * O.CANTIDAD DESC ) RANKING
	FROM ORDEN O
	LEFT JOIN CUSTOMER C ON O.IDENTIFICACION_VENDEDOR = C.IDENTIFICACION
	LEFT JOIN ITEM I ON O.ID_ITEM  = I.ID_ITEM
	LEFT JOIN CATEGORY CA ON I.ID_CATEGORIA = CA.ID_CATEGORIA 
	where CA.NOMBRE = 'CELULARES'
	and YEAR(O.FVENTA) = 2020
	group by O.IDENTIFICACION_VENDEDOR
			,C.NOMBRE
			,C.APELLIDO
			,MONTH(O.FVENTA)
			,YEAR(O.FVENTA)
)A
where RANKING <=5
ORDER by MES, RANKING



GO


/*
Se solicita poblar una nueva tabla con el precio y estado de los Ítems a fin del día.
Tener en cuenta que debe ser reprocesable. Vale resaltar que en la tabla Item,
vamos a tener únicamente el último estado informado por la PK definida. (Se puede
resolver a través de StoredProcedure)
*/
Create TABLE PRECIO_ESTADO_ITEMS(
PRODUCTO VARCHAR (50),
PRECIO INT,
ESTADO INT);

CREATE PROCEDURE `tabla_PRECIO_ESTADO_ITEMS`
@DIA
insert into PRECIO_ESTADO_ITEMS 
SELECT I.PRODUCTO , O.PRECIO, I.ESTADO 
FROM orden O 
LEFT JOIN ITEM I ON O.ID_ORDEN = I.ID_ITEM 
where I.PRODUCTO is not NULL 
AND DATE(O.FVENTA) = @DIA
		   
