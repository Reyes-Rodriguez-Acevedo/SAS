**********COMPARACION SINEX-MLD (PROD1) VS OIML MOVIMIENTOS CERTIFICACION(TEST1)**************;

********************************************;
*********   CONEXIÓN A SINEX-MLD   *********;
********************************************;
*https://support.sas.com/techsup/technote/ts581.pdf;

data two;
set div.muestra_prod1(keep=nb_archivo 
		co_archivo st_archivo st_proc_archivo fe_registro);
	f2r='D:\Datos\Divisas\Mld\Muestra\'||nb_archivo;
	format f2r char41.;
	*drop nb_archivo;
run;
/*f2r='D:\Datos\Divisas\Mld\Muestra\'||nb_archivo => tiene 41 caracteres d/c
'D:\Datos\Divisas\Mld\Muestra\' tiene 29 caracteres || (concatenado con)
nb_archivo que tiene 12 caracteres;
*/

data one;
set two;
infile dummy filevar=f2r end=done encoding="Unicode";
do while(not done);
    nb_archivo=(substr(left(f2r),30,12));
	co_archivo=co_archivo;
	st_archivo=st_archivo;
	st_proc_archivo=st_proc_archivo;
	fe_hora_conexion=fe_registro;
	Input
		@1		co_institucion_1 $3.
		@4		fe_movimiento_1 $8.
		@12		co_referencia_1 $10.
		@22		co_concepto_1 $3.
		@25		nb_razon_social_1 $40.
		@65		co_clave_alfab_1 $1.
		@66		nu_ci_rif_mld_1 $14.
		@80		in_tipo_operacion_1 $1.
		@81		co_instrumento_1 $1.
		@82		co_moneda_1 $3.
		@85		mo_movimiento_1 $14.
		@99		ts_cambio_bs_div_1 $13.
		@112	ts_cambio_div_1 $13.
		@125	hora_valor_1 $4.
		@129	fecha_valor_1 $8.
		@137	co_activ_econ_1 $2.
		@139	co_entidad_1 $2.
		@141	co_ciudad_1 $2.;
	output;
end;
run;


data tres;
set one;

co_institucion=co_institucion_1/1;
format co_institucion commax8.;
fe_movimiento_2=mdy(mod(int(fe_movimiento_1/100),100),mod(fe_movimiento_1,100),int(fe_movimiento_1/10000));
format fe_movimiento_2 ddmmyy10.;
co_referencia=co_referencia_1;
format co_referencia varying45.;
co_concepto=co_concepto_1/1;
format co_concepto commax3.;
nb_razon_social=nb_razon_social_1;
format nb_razon_social varying180.;
co_clave_alfab=co_clave_alfab_1;
format co_clave_alfab char3.;
nu_ci_rif_mld=nu_ci_rif_mld_1;
format nu_ci_rif_mld varying60.;
in_tipo_operacion=in_tipo_operacion_1/1;
format in_tipo_operacion commax3.;
co_instrumento=co_instrumento_1;
format co_instrumento varying6.;
co_moneda=co_moneda_1;
format co_moneda char9.;
mo_movimiento=mo_movimiento_1/100;
format mo_movimiento commax14.2;
ts_cambio_bs_div=ts_cambio_bs_div_1/100000000;
format ts_cambio_bs_div commax9.8;
ts_cambio_div=ts_cambio_div_1/100000000;
format ts_cambio_div commax9.8;
hora_valor=hms(int(hora_valor_1/100),mod(hora_valor_1,100),0);
format hora_valor Time8.;
fecha_valor_2=mdy(mod(int(fecha_valor_1/100),100),mod(fecha_valor_1,100),int(fecha_valor_1/10000));
format fecha_valor_2 ddmmyy10.;
co_activ_econ=co_activ_econ_1/1;
format co_activ_econ commax2.;
co_entidad=co_entidad_1;
format co_entidad varying9.;
co_ciudad=co_ciudad_1;
format co_ciudad varying12.;

hora_movimiento=hms(0,0,0);
format hora_valor Time8.;
fe_movimiento=dhms(fe_movimiento_2, 0, 0, hora_movimiento);
format fe_movimiento datetime19.;
fe_valor=dhms(fecha_valor_2, 0, 0, hora_valor);
format fe_valor datetime19.;
format nb_archivo varying36.;

format co_archivo commax12.;
format st_archivo varying3.;
format st_proc_archivo varying3.;
format fe_hora_conexion datetime19.;

run;


proc sort 
	data=tres out=cuatro;
	by fe_hora_conexion nb_archivo;
run;

Data cuatro;
   set cuatro;
	count + 1;
	by fe_hora_conexion nb_archivo;
	if first.nb_archivo then count = 1;
run;

Data cinco;
   set cuatro (keep=count co_institucion co_referencia co_concepto 
	nb_razon_social co_clave_alfab nu_ci_rif_mld in_tipo_operacion 
	co_instrumento co_moneda mo_movimiento ts_cambio_bs_div ts_cambio_div 
	co_activ_econ co_entidad co_ciudad fe_movimiento fe_valor nb_archivo 
	co_archivo st_archivo st_proc_archivo fe_hora_conexion);
run;

proc sort 
	data=cinco;
	by fe_hora_conexion nb_archivo count;
run;

Data div.Sinex_muestra;
   set cinco;
    id=Compress(Compbl(fe_hora_conexion||'-'||nb_archivo||'-'||count)); 
	format id char50.;
run;	
/*se cambio el formato de id de char176. que tenia por defecto
http://analisisydecision.es/trucos-sas-eliminacion-de-espacios-en-blanco/
data ejemplo;
palabra=" EJEMPLO DE ELIMINACIÓN DE BLANCOS CON SAS ";
uso_compress=compress(palabra);
uso_trimn=trimn(palabra);
uso_trimn_left=trimn(left(palabra));
uso_compbl=compbl(palabra);
length uso_rxchange $50.;
rx=rxparse("' ' to ' '"); drop rx;
call rxchange (rx,length(palabra),palabra,uso_rxchange);
run;

La variable palabra tiene tanto espacios por la derecha como por la izquierda y entre las palabras que no son necesarios. La función COMPRESS elimina todos los espacios en blanco. Con TRIMN y LEFT eliminamos los espacios en blanco al inicio y al final de palabra pero mantenemos los espacios en blanco entre palabras.
COMPBL (compress blank) parece más adecuada para eliminar los espacios en blanco sobrantes entre las palabras. La función de reconocimiento de patrones RXCHANGE (que necesita el patrón previamente con RXPARSE) sustituye dos espacios por uno sólo, el resultado no parece muy satisfactorio; esto mismo podríamos hacerlo con la función TRANWRD. A ver si algún lector encuentra un patrón adecuado para
estas funciones.
*/

proc sort 
	data=div.Sinex_muestra; 
	by id;
run;


********************************************;
************   TRANSFORMACIÓN   ************;
********************************************;

Data Sinex_muestra;
	set div.Sinex_muestra (keep= id mo_movimiento 
	co_clave_alfab nu_ci_rif_mld nb_razon_social fe_movimiento fe_valor 
	ts_cambio_div ts_cambio_bs_div co_concepto co_moneda co_institucion 
	co_referencia in_tipo_operacion co_instrumento co_activ_econ co_entidad co_ciudad 
	fe_hora_conexion nb_archivo co_archivo st_archivo st_proc_archivo);
run;

Data Sinex_prod1;
set Sinex_muestra;

mo_movimiento_prod1=mo_movimiento;
	format mo_movimiento_prod1 commax14.2;
	drop mo_movimiento;
co_clave_alfab_prod1=co_clave_alfab;
	format co_clave_alfab_prod1 char3.;
	drop co_clave_alfab;
nu_ci_rif_mld_prod1=nu_ci_rif_mld;
	format nu_ci_rif_mld_prod1 varying60.;
	drop nu_ci_rif_mld;
nb_razon_social_prod1=nb_razon_social;
	format nb_razon_social_prod1 varying180.;
	drop nb_razon_social;
fe_movimiento_prod1=fe_movimiento;
	format fe_movimiento_prod1 datetime19.;
	drop fe_movimiento;
fe_valor_prod1=fe_valor;
	format fe_valor_prod1 datetime19.;
	drop fe_valor;
ts_cambio_div_prod1=ts_cambio_div;
	format ts_cambio_div_prod1 commax9.8;
	drop ts_cambio_div;
ts_cambio_bs_div_prod1=ts_cambio_bs_div;
	format ts_cambio_bs_div_prod1 commax9.8;
	drop ts_cambio_bs_div;
co_concepto_prod1=co_concepto;
	format co_concepto_prod1 commax3.;
	drop co_concepto;
co_moneda_prod1=co_moneda;
	format co_moneda_prod1 char9.;
	drop co_moneda;
co_institucion_prod1=co_institucion;
	format co_institucion_prod1 commax8.;
	drop co_institucion;

co_referencia_prod1=co_referencia;
	format co_referencia_prod1 varying45.;
	drop co_referencia;
in_tipo_operacion_prod1=in_tipo_operacion;
	format in_tipo_operacion_prod1 commax3.;
	drop in_tipo_operacion;
co_instrumento_prod1=co_instrumento;
	format co_instrumento_prod1 varying6.;
	drop co_instrumento;
co_activ_econ_prod1=co_activ_econ;
	format co_activ_econ_prod1 commax2.;
	drop co_activ_econ;
co_entidad_prod1=co_entidad;
	format co_entidad_prod1 varying9.;
	drop co_entidad;
co_ciudad_prod1=co_ciudad;
	format co_ciudad_prod1 varying12.;
	drop co_ciudad;

fe_hora_conexion_prod1=fe_hora_conexion;
	format fe_hora_conexion_prod1 datetime19.;
	drop fe_hora_conexion;
nb_archivo_prod1=nb_archivo;
	format nb_archivo_prod1 varying36.;
	drop nb_archivo;
co_archivo_prod1=co_archivo;
	format co_archivo_prod1 commax12.;
	drop co_archivo;
st_archivo_prod1=st_archivo;
	format st_archivo_prod1 varying3.;
	drop st_archivo;
st_proc_archivo_prod1=st_proc_archivo;
	format st_proc_archivo_prod1 varying3.;
	drop st_proc_archivo;

run;

proc sort data=Sinex_prod1;
   by id;
run;


********************************************;
*******   CONEXIÓN A CERTIFICACIÓN   *******;
********************************************;

Data movimientos_certificacion_full;
	set div.movimientos_certificacion_full (keep= id mo_movimiento nu_oper_movim 
	co_clave_alfab nu_ci_rif_mld nb_razon_social fe_movimiento fe_valor 
	ts_cambio_div ts_cambio_bs_div co_concepto co_moneda co_institucion 
	co_referencia in_tipo_operacion co_instrumento co_activ_econ co_entidad co_ciudad 
	fe_hora_conexion nb_archivo co_archivo st_archivo st_proc_archivo);
	id_1=Compress(id);
	format id_1 char50.;
	drop id;
run;
*se cambio el formato de id de char38. que tenia por defecto;

Data movimientos_certificacion_full;
set movimientos_certificacion_full;

mo_movimiento_test1=mo_movimiento;
	format mo_movimiento_test1 commax14.2;
	drop mo_movimiento;
co_clave_alfab_test1=co_clave_alfab;
	format co_clave_alfab_test1 char3.;
	drop co_clave_alfab;
nu_ci_rif_mld_test1=nu_ci_rif_mld;
	format nu_ci_rif_mld_test1 varying60.;
	drop nu_ci_rif_mld;
nb_razon_social_test1=nb_razon_social;
	format nb_razon_social_test1 varying180.;
	drop nb_razon_social;
fe_movimiento_test1=fe_movimiento;
	format fe_movimiento_test1 datetime19.;
	drop fe_movimiento;
fe_valor_test1=fe_valor;
	format fe_valor_test1 datetime19.;
	drop fe_valor;
ts_cambio_div_test1=ts_cambio_div;
	format ts_cambio_div_test1 commax9.8;
	drop ts_cambio_div;
ts_cambio_bs_div_test1=ts_cambio_bs_div;
	format ts_cambio_bs_div_test1 commax9.8;
	drop ts_cambio_bs_div;
co_concepto_test1=co_concepto;
	format co_concepto_test1 commax3.;
	drop co_concepto;
co_moneda_test1=co_moneda;
	format co_moneda_test1 char9.;
	drop co_moneda;
co_institucion_test1=co_institucion;
	format co_institucion_test1 commax8.;
	drop co_institucion;

co_referencia_test1=co_referencia;
	format co_referencia_test1 varying45.;
	drop co_referencia;
in_tipo_operacion_test1=in_tipo_operacion;
	format in_tipo_operacion_test1 commax3.;
	drop in_tipo_operacion;
co_instrumento_test1=co_instrumento;
	format co_instrumento_test1 varying6.;
	drop co_instrumento;
co_activ_econ_test1=co_activ_econ;
	format co_activ_econ_test1 commax2.;
	drop co_activ_econ;
co_entidad_test1=co_entidad;
	format co_entidad_test1 varying9.;
	drop co_entidad;
co_ciudad_test1=co_ciudad;
	format co_ciudad_test1 varying12.;
	drop co_ciudad;

fe_hora_conexion_test1=fe_hora_conexion;
	format fe_hora_conexion_test1 datetime19.;
	drop fe_hora_conexion;
nb_archivo_test1=nb_archivo;
	format nb_archivo_test1 varying36.;
	drop nb_archivo;
co_archivo_test1=co_archivo;
	format co_archivo_test1 commax12.;
	drop co_archivo;
st_archivo_test1=st_archivo;
	format st_archivo_test1 varying3.;
	drop st_archivo;
st_proc_archivo_test1=st_proc_archivo;
	format st_proc_archivo_test1 varying3.;
	drop st_proc_archivo;

nu_oper_movim_test1=nu_oper_movim;
	format nu_oper_movim_test1 commax12.;
	drop nu_oper_movim; 

id=Compress(id_1);
	drop id_1;
	format id char50.;

run;

proc sort data=movimientos_certificacion_full;
   by id;
run;


********   principales variables   *********;

********************************************;
*************   mo_movimiento   ************;
********************************************;

data mo_movimiento_prod1;
set Sinex_prod1 (keep= id mo_movimiento_prod1);
run;

proc sort data=mo_movimiento_prod1;
   by id;
run;

data mo_movimiento_test1;
set movimientos_certificacion_full (keep= id mo_movimiento_test1
	fe_hora_conexion_test1 nb_archivo_test1 nu_oper_movim_test1 co_archivo_test1 st_archivo_test1 st_proc_archivo_test1);
run;

proc sort data=mo_movimiento_test1;
   by id;
run;

data mo_movimiento_m;
	merge mo_movimiento_prod1(in=a) mo_movimiento_test1(in=b);
	by id;
	if a=1;
run;

data mo_movimiento_m;
set mo_movimiento_m;
	mo_movimiento_dif=mo_movimiento_prod1-mo_movimiento_test1;
	format mo_movimiento_dif commax14.2;
run;

data mo_movimiento_gt_1 mo_movimiento_lt_1 mo_movimiento_eq_1;
set mo_movimiento_m;
	if mo_movimiento_dif>1 then output mo_movimiento_gt_1;
	if mo_movimiento_dif<-1 then output mo_movimiento_lt_1;
	if mo_movimiento_dif=>-1 and mo_movimiento_dif<=1 and mo_movimiento_dif^=0 then output mo_movimiento_eq_1;
run;

proc export data=mo_movimiento_gt_1
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\mo_movimiento_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="mo_movimiento_gt_1";
run;

proc export data=mo_movimiento_lt_1
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\mo_movimiento_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="mo_movimiento_lt_1";
run;

proc export data=mo_movimiento_eq_1
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\mo_movimiento_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="mo_movimiento_eq_1";
run;


********************************************;
************   co_clave_alfab   ************;
********************************************;

data co_clave_alfab_prod1;
set Sinex_prod1 (keep= id co_clave_alfab_prod1);
run;

proc sort data=co_clave_alfab_prod1;
   by id;
run;

data co_clave_alfab_test1;
set movimientos_certificacion_full (keep= id co_clave_alfab_test1
	fe_hora_conexion_test1 nb_archivo_test1 nu_oper_movim_test1 co_archivo_test1 st_archivo_test1 st_proc_archivo_test1);
run;

proc sort data=co_clave_alfab_test1;
   by id;
run;

data co_clave_alfab_m;
	merge co_clave_alfab_prod1(in=a) co_clave_alfab_test1(in=b);
	by id;
	if a=1;
run;

data co_clave_alfab_m;
set co_clave_alfab_m;
	co_clave_alfab_dif=0;
	if co_clave_alfab_prod1^=co_clave_alfab_test1 then co_clave_alfab_dif=1;
	format co_clave_alfab_dif commax1.;
run;

data co_clave_alfab_m_1;
set co_clave_alfab_m;
	if co_clave_alfab_dif^=0;
run;

proc export data=co_clave_alfab_m_1
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\co_clave_alfab_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="diferencia";
run;


********************************************;
************   nu_ci_rif_mld   *************;
********************************************;

data nu_ci_rif_mld_prod1;
set Sinex_prod1 (keep= id nu_ci_rif_mld_prod1);
run;

proc sort data=nu_ci_rif_mld_prod1;
   by id;
run;

data nu_ci_rif_mld_test1;
set movimientos_certificacion_full (keep= id nu_ci_rif_mld_test1
	fe_hora_conexion_test1 nb_archivo_test1 nu_oper_movim_test1 co_archivo_test1 st_archivo_test1 st_proc_archivo_test1);
run;

proc sort data=nu_ci_rif_mld_test1;
   by id;
run;

data nu_ci_rif_mld_m;
	merge nu_ci_rif_mld_prod1(in=a) nu_ci_rif_mld_test1(in=b);
	by id;
	if a=1;
run;

data nu_ci_rif_mld_m;
set nu_ci_rif_mld_m;
	nu_ci_rif_mld_dif=0;
	if nu_ci_rif_mld_prod1^=nu_ci_rif_mld_test1 then nu_ci_rif_mld_dif=1;
	format nu_ci_rif_mld_dif commax1.;
run;

data nu_ci_rif_mld_m_1;
set nu_ci_rif_mld_m;
	if nu_ci_rif_mld_dif^=0;
run;

proc export data=nu_ci_rif_mld_m_1
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\nu_ci_rif_mld_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="diferencia";
run;


********************************************;
***********   nb_razon_social   ************;
********************************************;

data nb_razon_social_prod1;
set Sinex_prod1 (keep= id nb_razon_social_prod1);
run;

proc sort data=nb_razon_social_prod1;
   by id;
run;

data nb_razon_social_test1;
set movimientos_certificacion_full (keep= id nb_razon_social_test1
	fe_hora_conexion_test1 nb_archivo_test1 nu_oper_movim_test1 co_archivo_test1 st_archivo_test1 st_proc_archivo_test1);
run;

proc sort data=nb_razon_social_test1;
   by id;
run;

data nb_razon_social_m;
	merge nb_razon_social_prod1(in=a) nb_razon_social_test1(in=b);
	by id;
	if a=1;
run;

data nb_razon_social_m;
set nb_razon_social_m;
	nb_razon_social_dif=0;
	if nb_razon_social_prod1^=nb_razon_social_test1 then nb_razon_social_dif=1;
	format nb_razon_social_dif commax1.;
run;

data nb_razon_social_m_1;
set nb_razon_social_m;
	if nb_razon_social_dif^=0;
run;

proc export data=nb_razon_social_m_1
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\nb_razon_social_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="diferencia";
run;


********************************************;
*************   fe_movimiento   ************;
********************************************;

data fe_movimiento_prod1;
set Sinex_prod1 (keep= id fe_movimiento_prod1);
run;

proc sort data=fe_movimiento_prod1;
   by id;
run;

data fe_movimiento_test1;
set movimientos_certificacion_full (keep= id fe_movimiento_test1
	fe_hora_conexion_test1 nb_archivo_test1 nu_oper_movim_test1 co_archivo_test1 st_archivo_test1 st_proc_archivo_test1);
run;

proc sort data=fe_movimiento_test1;
   by id;
run;

data fe_movimiento_m;
	merge fe_movimiento_prod1(in=a) fe_movimiento_test1(in=b);
	by id;
	if a=1;
run;

data fe_movimiento_m;
set fe_movimiento_m;
	fe_movimiento_dif=fe_movimiento_prod1-fe_movimiento_test1;
	format fe_movimiento_dif commax20.;
run;

data fe_movimiento_gt_0 fe_movimiento_lt_0;
set fe_movimiento_m;
	if fe_movimiento_dif>0 then output fe_movimiento_gt_0;
	if fe_movimiento_dif<0 then output fe_movimiento_lt_0;
run;

proc export data=fe_movimiento_gt_0
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\fe_movimiento_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="fe_movimiento_gt_0";
run;

proc export data=fe_movimiento_lt_0
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\fe_movimiento_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="fe_movimiento_lt_0";
run;


********************************************;
***************   fe_valor   ***************;
********************************************;

data fe_valor_prod1;
set Sinex_prod1 (keep= id fe_valor_prod1);
run;

proc sort data=fe_valor_prod1;
   by id;
run;

data fe_valor_test1;
set movimientos_certificacion_full (keep= id fe_valor_test1
	fe_hora_conexion_test1 nb_archivo_test1 nu_oper_movim_test1 co_archivo_test1 st_archivo_test1 st_proc_archivo_test1);
run;

proc sort data=fe_valor_test1;
   by id;
run;

data fe_valor_m;
	merge fe_valor_prod1(in=a) fe_valor_test1(in=b);
	by id;
	if a=1;
run;

data fe_valor_m;
set fe_valor_m;
	fe_valor_dif=fe_valor_prod1-fe_valor_test1;
	format fe_valor_dif commax20.;
run;

data fe_valor_gt_0 fe_valor_lt_0;
set fe_valor_m;
	if fe_valor_dif>0 then output fe_valor_gt_0;
	if fe_valor_dif<0 then output fe_valor_lt_0;
run;

proc export data=fe_valor_gt_0
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\fe_valor_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="fe_valor_gt_0";
run;

proc export data=fe_valor_lt_0
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\fe_valor_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="fe_valor_lt_0";
run;


********************************************;
*************   ts_cambio_div   ************;
********************************************;

data ts_cambio_div_prod1;
set Sinex_prod1 (keep= id ts_cambio_div_prod1);
run;

proc sort data=ts_cambio_div_prod1;
   by id;
run;

data ts_cambio_div_test1;
set movimientos_certificacion_full (keep= id ts_cambio_div_test1
	fe_hora_conexion_test1 nb_archivo_test1 nu_oper_movim_test1 co_archivo_test1 st_archivo_test1 st_proc_archivo_test1);
run;

proc sort data=ts_cambio_div_test1;
   by id;
run;

data ts_cambio_div_m;
	merge ts_cambio_div_prod1(in=a) ts_cambio_div_test1(in=b);
	by id;
	if a=1;
run;

data ts_cambio_div_m;
set ts_cambio_div_m;
	ts_cambio_div_dif=ts_cambio_div_prod1-ts_cambio_div_test1;
	format ts_cambio_div_dif commax9.8;
run;

data ts_cambio_div_gt_0 ts_cambio_div_lt_0;
	set ts_cambio_div_m;
		if ts_cambio_div_dif>0 then output ts_cambio_div_gt_0;
		if ts_cambio_div_dif<0 then output ts_cambio_div_lt_0;
run;

proc export data=ts_cambio_div_gt_0
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\ts_cambio_div_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="ts_cambio_div_gt_0";
run;

proc export data=ts_cambio_div_lt_0
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\ts_cambio_div_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="ts_cambio_div_lt_0";
run;


********************************************;
***********   ts_cambio_bs_div   ***********;
********************************************;

data ts_cambio_bs_div_prod1;
set Sinex_prod1 (keep= id ts_cambio_bs_div_prod1);
run;

proc sort data=ts_cambio_bs_div_prod1;
   by id;
run;

data ts_cambio_bs_div_test1;
set movimientos_certificacion_full (keep= id ts_cambio_bs_div_test1
	fe_hora_conexion_test1 nb_archivo_test1 nu_oper_movim_test1 co_archivo_test1 st_archivo_test1 st_proc_archivo_test1);
run;

proc sort data=ts_cambio_bs_div_test1;
   by id;
run;

data ts_cambio_bs_div_m;
	merge ts_cambio_bs_div_prod1(in=a) ts_cambio_bs_div_test1(in=b);
	by id;
	if a=1;
run;

data ts_cambio_bs_div_m;
set ts_cambio_bs_div_m;
	ts_cambio_bs_div_dif=ts_cambio_bs_div_prod1-ts_cambio_bs_div_test1;
	format ts_cambio_bs_div_dif commax9.8;
run;

data ts_cambio_bs_div_gt_0 ts_cambio_bs_div_lt_0;
	set ts_cambio_bs_div_m;
		if ts_cambio_bs_div_dif>0 then output ts_cambio_bs_div_gt_0;
		if ts_cambio_bs_div_dif<0 then output ts_cambio_bs_div_lt_0;
run;

proc export data=ts_cambio_bs_div_gt_0
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\ts_cambio_bs_div_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="ts_cambio_bs_div_gt_0";
run;

proc export data=ts_cambio_bs_div_lt_0
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\ts_cambio_bs_div_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="ts_cambio_bs_div_lt_0";
run;


********************************************;
*************   co_concepto   **************;
********************************************;

data co_concepto_prod1;
set Sinex_prod1 (keep= id co_concepto_prod1);
run;

proc sort data=co_concepto_prod1;
   by id;
run;

data co_concepto_test1;
set movimientos_certificacion_full (keep= id co_concepto_test1
	fe_hora_conexion_test1 nb_archivo_test1 nu_oper_movim_test1 co_archivo_test1 st_archivo_test1 st_proc_archivo_test1);
run;

proc sort data=co_concepto_test1;
   by id;
run;

data co_concepto_m;
	merge co_concepto_prod1(in=a) co_concepto_test1(in=b);
	by id;
	if a=1;
run;

data co_concepto_m;
set co_concepto_m;
	co_concepto_dif=co_concepto_prod1-co_concepto_test1;
	format co_concepto_dif commax3.;
run;

data co_concepto_gt_0 co_concepto_lt_0;
	set co_concepto_m;
		if co_concepto_dif>0 then output co_concepto_gt_0;
		if co_concepto_dif<0 then output co_concepto_lt_0;
run;

proc export data=co_concepto_gt_0
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\co_concepto_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="co_concepto_gt_0";
run;

proc export data=co_concepto_lt_0
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\co_concepto_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="co_concepto_lt_0";
run;


********************************************;
**************   co_moneda   ***************;
********************************************;

data co_moneda_prod1;
set Sinex_prod1 (keep= id co_moneda_prod1);
run;

proc sort data=co_moneda_prod1;
   by id;
run;

data co_moneda_test1;
set movimientos_certificacion_full (keep= id co_moneda_test1
	fe_hora_conexion_test1 nb_archivo_test1 nu_oper_movim_test1 co_archivo_test1 st_archivo_test1 st_proc_archivo_test1);
run;

proc sort data=co_moneda_test1;
   by id;
run;

data co_moneda_m;
	merge co_moneda_prod1(in=a) co_moneda_test1(in=b);
	by id;
	if a=1;
run;

data co_moneda_m;
set co_moneda_m;
	co_moneda_dif=0;
	if co_moneda_prod1^=co_moneda_test1 then co_moneda_dif=1;
	format co_moneda_dif commax1.;
run;

data co_moneda_m_1;
set co_moneda_m;
	if co_moneda_dif^=0;
run;

proc export data=co_moneda_m_1
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\co_moneda_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="diferencia";
run;


********************************************;
************   co_institucion   ************;
********************************************;

data co_institucion_prod1;
set Sinex_prod1 (keep= id co_institucion_prod1);
run;

proc sort data=co_institucion_prod1;
   by id;
run;

data co_institucion_test1;
set movimientos_certificacion_full (keep= id co_institucion_test1
	fe_hora_conexion_test1 nb_archivo_test1 nu_oper_movim_test1 co_archivo_test1 st_archivo_test1 st_proc_archivo_test1);
run;

proc sort data=co_institucion_test1;
   by id;
run;

data co_institucion_m;
	merge co_institucion_prod1(in=a) co_institucion_test1(in=b);
	by id;
	if a=1;
run;

data co_institucion_m;
set co_institucion_m;
	co_institucion_dif=co_institucion_prod1-co_institucion_test1;
	format ts_cambio_div_dif commax8.;
run;

data co_institucion_gt_0 co_institucion_lt_0;
	set co_institucion_m;
		if co_institucion_dif>0 then output co_institucion_gt_0;
		if co_institucion_dif<0 then output co_institucion_lt_0;
run;

proc export data=co_institucion_gt_0
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\co_institucion_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="co_institucion_gt_0";
run;

proc export data=co_institucion_lt_0
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\co_institucion_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="co_institucion_lt_0";
run;



***********   otras variables   ************;

********************************************;
************   co_referencia   *************;
********************************************;

data co_referencia_prod1;
set Sinex_prod1 (keep= id co_referencia_prod1);
run;

proc sort data=co_referencia_prod1;
   by id;
run;

data co_referencia_test1;
set movimientos_certificacion_full (keep= id co_referencia_test1
	fe_hora_conexion_test1 nb_archivo_test1 nu_oper_movim_test1 co_archivo_test1 st_archivo_test1 st_proc_archivo_test1);
run;

proc sort data=co_referencia_test1;
   by id;
run;

data co_referencia_m;
	merge co_referencia_prod1(in=a) co_referencia_test1(in=b);
	by id;
	if a=1;
run;

data co_referencia_m;
set co_referencia_m;
	co_referencia_dif=0;
	if co_referencia_prod1^=co_referencia_test1 then co_referencia_dif=1;
	format co_referencia_dif commax1.;
run;

data co_referencia_m_1;
set co_referencia_m;
	if co_referencia_dif^=0;
run;

proc export data=co_referencia_m_1
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\co_referencia_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="diferencia";
run;


********************************************;
**********   in_tipo_operacion   ***********;
********************************************;

data in_tipo_operacion_prod1;
set Sinex_prod1 (keep= id in_tipo_operacion_prod1);
run;

proc sort data=in_tipo_operacion_prod1;
   by id;
run;

data in_tipo_operacion_test1;
set movimientos_certificacion_full (keep= id in_tipo_operacion_test1
	fe_hora_conexion_test1 nb_archivo_test1 nu_oper_movim_test1 co_archivo_test1 st_archivo_test1 st_proc_archivo_test1);
run;

proc sort data=in_tipo_operacion_test1;
   by id;
run;

data in_tipo_operacion_m;
	merge in_tipo_operacion_prod1(in=a) in_tipo_operacion_test1(in=b);
	by id;
	if a=1;
run;

data in_tipo_operacion_m;
set in_tipo_operacion_m;
	in_tipo_operacion_dif=in_tipo_operacion_prod1-in_tipo_operacion_test1;
	format in_tipo_operacion_dif commax3.;
run;

data in_tipo_operacion_gt_0 in_tipo_operacion_lt_0;
	set in_tipo_operacion_m;
		if in_tipo_operacion_dif>0 then output in_tipo_operacion_gt_0;
		if in_tipo_operacion_dif<0 then output in_tipo_operacion_lt_0;
run;

proc export data=in_tipo_operacion_gt_0
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\in_tipo_operacion_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="in_tipo_operacion_gt_0";
run;

proc export data=in_tipo_operacion_lt_0
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\in_tipo_operacion_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="in_tipo_operacion_lt_0";
run;


********************************************;
************   co_instrumento   ************;
********************************************;

data co_instrumento_prod1;
set Sinex_prod1 (keep= id co_instrumento_prod1);
run;

proc sort data=co_instrumento_prod1;
   by id;
run;

data co_instrumento_test1;
set movimientos_certificacion_full (keep= id co_instrumento_test1
	fe_hora_conexion_test1 nb_archivo_test1 nu_oper_movim_test1 co_archivo_test1 st_archivo_test1 st_proc_archivo_test1);
run;

proc sort data=co_instrumento_test1;
   by id;
run;

data co_instrumento_m;
	merge co_instrumento_prod1(in=a) co_instrumento_test1(in=b);
	by id;
	if a=1;
run;

data co_instrumento_m;
set co_instrumento_m;
	co_instrumento_dif=0;
	if co_instrumento_prod1^=co_instrumento_test1 then co_instrumento_dif=1;
	format co_instrumento_dif commax1.;
run;

data co_instrumento_m_1;
set co_instrumento_m;
	if co_instrumento_dif^=0;
run;

proc export data=co_instrumento_m_1
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\co_instrumento_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="diferencia";
run;


********************************************;
************   co_activ_econ   *************;
********************************************;

data co_activ_econ_prod1;
set Sinex_prod1 (keep= id co_activ_econ_prod1);
run;

proc sort data=co_activ_econ_prod1;
   by id;
run;

data co_activ_econ_test1;
set movimientos_certificacion_full (keep= id co_activ_econ_test1
	fe_hora_conexion_test1 nb_archivo_test1 nu_oper_movim_test1 co_archivo_test1 st_archivo_test1 st_proc_archivo_test1);
run;

proc sort data=co_activ_econ_test1;
   by id;
run;

data co_activ_econ_m;
	merge co_activ_econ_prod1(in=a) co_activ_econ_test1(in=b);
	by id;
	if a=1;
run;

data co_activ_econ_m;
set co_activ_econ_m;
	co_activ_econ_dif=co_activ_econ_prod1-co_activ_econ_test1;
	format co_activ_econ_dif commax2.;
run;

data co_activ_econ_gt_0 co_activ_econ_lt_0;
	set co_activ_econ_m;
		if co_activ_econ_dif>0 then output co_activ_econ_gt_0;
		if co_activ_econ_dif<0 then output co_activ_econ_lt_0;
run;

proc export data=co_activ_econ_gt_0
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\co_activ_econ_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="co_activ_econ_gt_0";
run;

proc export data=co_activ_econ_lt_0
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\co_activ_econ_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="co_activ_econ_lt_0";
run;


********************************************;
**************   co_entidad   **************;
********************************************;

data co_entidad_prod1;
set Sinex_prod1 (keep= id co_entidad_prod1);
run;

proc sort data=co_entidad_prod1;
   by id;
run;

data co_entidad_test1;
set movimientos_certificacion_full (keep= id co_entidad_test1
	fe_hora_conexion_test1 nb_archivo_test1 nu_oper_movim_test1 co_archivo_test1 st_archivo_test1 st_proc_archivo_test1);
run;

proc sort data=co_entidad_test1;
   by id;
run;

data co_entidad_m;
	merge co_entidad_prod1(in=a) co_entidad_test1(in=b);
	by id;
	if a=1;
run;

data co_entidad_m;
set co_entidad_m;
	co_entidad_dif=0;
	if co_entidad_prod1^=co_entidad_test1 then co_entidad_dif=1;
	format co_entidad_dif commax1.;
run;

data co_entidad_m_1;
set co_entidad_m;
	if co_entidad_dif^=0;
run;

proc export data=co_entidad_m_1
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\co_entidad_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="diferencia";
run;


********************************************;
**************   co_ciudad   **************;
********************************************;

data co_ciudad_prod1;
set Sinex_prod1 (keep= id co_ciudad_prod1);
run;

proc sort data=co_ciudad_prod1;
   by id;
run;

data co_ciudad_test1;
set movimientos_certificacion_full (keep= id co_ciudad_test1
	fe_hora_conexion_test1 nb_archivo_test1 nu_oper_movim_test1 co_archivo_test1 st_archivo_test1 st_proc_archivo_test1);
run;

proc sort data=co_ciudad_test1;
   by id;
run;

data co_ciudad_m;
	merge co_ciudad_prod1(in=a) co_ciudad_test1(in=b);
	by id;
	if a=1;
run;

data co_ciudad_m;
set co_ciudad_m;
	co_ciudad_dif=0;
	if co_ciudad_prod1^=co_ciudad_test1 then co_ciudad_dif=1;
	format co_ciudad_dif commax1.;
run;

data co_ciudad_m_1;
set co_ciudad_m;
	if co_ciudad_dif^=0;
run;

proc export data=co_ciudad_m_1
	OUTFILE= "D:\Datos\Divisas\Mld\Muestreo\co_ciudad_muestra_20160511.xlsx"
	DBMS=EXCEL2010 REPLACE;
	SHEET="diferencia";
run;
