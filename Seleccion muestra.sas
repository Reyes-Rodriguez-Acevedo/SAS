********************************************;
*******   CONEXIÓN A CERTIFICACIÓN   *******;
********************************************;

Data archivo_test1;
set div.archivo_test1;
	if (st_archivo=5 and st_proc_archivo=1 and co_origen_archivo=3);
nb_archivo=upcase(nb_archivo);
run;

proc sort 
	data=archivo_test1; 
	by co_archivo st_archivo;
run;


Data archivo_test1;
   set archivo_test1;
	count + 1;
	by st_archivo;
	if first.st_archivo then count = 1;
run;

proc means data=archivo_test1 n nway noprint;
       *class co_archivo;
       var co_archivo;
       output out=archivo_test2(drop=_type_ _freq_);
   run;


Data archivo_test3;
   set archivo_test2;
   	estadistica=_STAT_;
   	numero_archivos=co_archivo;
run;

Data archivo_test3;
   set archivo_test3;
   	if estadistica="N";
run;

Data archivo_test3;
   set archivo_test3 (keep=numero_archivos);
run;


Data archivo_test3;
   set archivo_test3;
	k=int(numero_archivos/315);
	aleatorio_entre=1+int((k-1)*ranuni(int(k)));
run;

Data archivo_test4;
   set archivo_test3;
		do i=aleatorio_entre-k to numero_archivos-k;
		i=i+k;
		output;
		end;
run;

Data archivo_test5;
   set archivo_test4;
	count=i;
run;

Data archivo_test5;
   set archivo_test5(keep=count);
run;
