--Main FUNCTION
CREATE OR REPLACE FUNCTION get_sequence(nom Text)  Returns integer as
$$
DECLARE 
	nom_sequence VARCHAR(512);
	max_id Integer;
	req VARCHAR(512) ;
	req1 VARCHAR(512) ;
	req2 VARCHAR(512);
	req3 TEXT ;
	req4 TEXT ;
	a int ; 
BEGIN
		req3 := 'SELECT count(*) FROM '|| nom ;
		EXECUTE req3 INTO a ;
		
		if a >0 THEN
			req := 'SELECT max(id) FROM '|| nom ;
			EXECUTE  req INTO max_id ; 
				
			req1 := ' SELECT pg_get_serial_sequence(''' || nom || ''',''id'')'    ;
			EXECUTE req1 INTO nom_sequence ; 
			
			--Select * from nom_sequence ;
			req2 := ' ALTER SEQUENCE '  || nom_sequence || ' RESTART WITH ' || max_id + 1;
			EXECUTE req2  ;
			Return 1;
		ELSE
			return -1 ;	
		END IF;
	

END ;
$$
LANGUAGE 'plpgsql' ; 

--select * from get_sequence('ir_act_client');For TestING
 -- Function: public.generer_sequence()

-- DROP FUNCTION public.generer_sequence();

CREATE OR REPLACE FUNCTION public.generer_sequence()
  RETURNS Integer AS
$$
DECLARE 
	req3 Text ;
	req4 Text ;
	response text[] ;
	i text ;
	j integer ;
	a integer ;
BEGIN
	j := 0 ;
	
	req3 :=' ((select array_agg(tc.table_name::text)  
		from  
			information_schema.table_constraints tc,  
			information_schema.key_column_usage kc  
		where 
			tc.constraint_type = ''PRIMARY KEY'' 
			and kc.table_name = tc.table_name and kc.table_schema = tc.table_schema
			and kc.constraint_name = tc.constraint_name
			and tc.table_name NOT LIKE ''ir_%''
		order by 1

		))' ;
	EXECUTE req3 Into response  ;	


	FOREACH i IN ARRAY( response)
	LOOP
		EXECUTE FORMAT('SELECT * FROM get_sequence(''%I'')',i) ;
	
	END LOOP ;
	Return 1;
END;
$$
  LANGUAGE plpgsql ;
select * from generer_sequence() ;

