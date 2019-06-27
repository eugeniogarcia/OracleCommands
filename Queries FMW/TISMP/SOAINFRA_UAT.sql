select ( CASE WHEN ci.STATE=0 THEN 'STATE_INITIATED'
WHEN ci.STATE=1 THEN 'STATE_OPEN_RECOVERY'
WHEN ci.STATE=2 THEN 'STATE_OPEN_SUSPENDED'
WHEN ci.STATE=3 THEN 'STATE_OPEN_FAULTED'
WHEN ci.STATE=4 THEN 'STATE_CLOSED_PENDING_CANCEL'
WHEN ci.STATE=5 THEN 'STATE_CLOSED_COMPLETED'
WHEN ci.STATE=6 THEN 'STATE_CLOSED_FAULTED'
WHEN ci.STATE=7 THEN 'STATE_CLOSED_CANCELLED'
WHEN ci.STATE=8 THEN 'STATE_CLOSED_ABORTED'
WHEN ci.STATE=9 THEN 'STATE_CLOSED_STALE'
WHEN ci.STATE=10 THEN 'STATE_CLOSED_ROLLED_BACK'
ELSE NULL
END) AS STATE, COUNT(*) from UAT_SOAINFRA.CUBE_INSTANCE ci
where 1=1
--and FLOW_ID='3323131'
and COMPOSITE_NAME='INT_029_CMM_ELL_CONDITIONMEASUREMENT_CRE_BES'
AND CREATION_DATE > TO_DATE('26/06/2017 19:47:00','dd/mm/yyyy hh24:mi:ss')
AND CREATION_DATE < TO_DATE('26/06/2017 20:47:00','dd/mm/yyyy hh24:mi:ss')
GROUP BY STATE ;

select ci.flow_id,ci.CIKEY,( CASE WHEN ci.STATE=0 THEN 'STATE_INITIATED'
WHEN ci.STATE=1 THEN 'STATE_OPEN_RECOVERY'
WHEN ci.STATE=2 THEN 'STATE_OPEN_SUSPENDED'
WHEN ci.STATE=3 THEN 'STATE_OPEN_FAULTED'
WHEN ci.STATE=4 THEN 'STATE_CLOSED_PENDING_CANCEL'
WHEN ci.STATE=5 THEN 'STATE_CLOSED_COMPLETED'
WHEN ci.STATE=6 THEN 'STATE_CLOSED_FAULTED'
WHEN ci.STATE=7 THEN 'STATE_CLOSED_CANCELLED'
WHEN ci.STATE=8 THEN 'STATE_CLOSED_ABORTED'
WHEN ci.STATE=9 THEN 'STATE_CLOSED_STALE'
WHEN ci.STATE=10 THEN 'STATE_CLOSED_ROLLED_BACK'
ELSE NULL
END) AS STATE, ci.CREATION_DATE ,ci.MODIFY_DATE, ci.MODIFY_DATE- ci.CREATION_DATE from UAT_SOAINFRA.CUBE_INSTANCE ci
where 1=1
--and FLOW_ID='3323131'
and COMPOSITE_NAME='INT_029_CMM_ELL_CONDITIONMEASUREMENT_CRE_BES'
AND CREATION_DATE > TO_DATE('26/06/2017 19:47:00','dd/mm/yyyy hh24:mi:ss')
AND CREATION_DATE < TO_DATE('26/06/2017 20:47:00','dd/mm/yyyy hh24:mi:ss')
order by ci.CREATION_DATE 
--GROUP BY STATE 
;

select * FROM 
UAT_SOAINFRA.CUBE_INSTANCE ci,
UAT_SOAINFRA.SCA_COMMON_FAULT cf
WHERE 1 = 1
and cf.CIKEY=ci.cikey
--and BPI.CONVERSATION_ID not in (select CONVERSATION_ID FROM PROD_SOAINFRA.BPEL_PROCESS_INSTANCES where state=5);
and ci.flow_id='2171073';


--Errores de la ejecucion
select FAULT_NAME,cf.ERROR_MESSAGE,cf.EXCEPTION_TRACE FROM 
UAT_SOAINFRA.SCA_COMMON_FAULT cf
WHERE 1 = 1
and cf.id in( 
select flow_id from UAT_SOAINFRA.SCA_FLOW_INSTANCE
where 1=1
AND CREATED_TIME> TO_DATE('28/06/2017 18:03:00','dd/mm/yyyy hh24:mi:ss'))
order by cf.CREATION_DATE desc;


--instancias
select flow_id,composite_name, creation_date,modify_date,modify_date-creation_date from UAT_SOAINFRA.CUBE_INSTANCE
where 1=1
and creation_date>TO_DATE('28/06/2017 18:03:00','dd/mm/yyyy hh24:mi:ss')
--and composite_name like 'DWF%'
order by MODIFY_DATE desc;

--Instancias (totales)
select count(flow_id) from UAT_SOAINFRA.CUBE_INSTANCE
where 1=1
and creation_date>TO_DATE('28/06/2017 19:14:00','dd/mm/yyyy hh24:mi:ss')
--and composite_name like 'DWF%'
order by MODIFY_DATE desc;



select composite from UAT_SOAINFRA.SCA_ENTITY where id=40696;

--Executions
select flow_id,composite,created_time,UPDATED_TIME, UPDATED_TIME-created_time , active_component_instances,recoverable_faults,composite_sca_entity_id 
from UAT_SOAINFRA.SCA_FLOW_INSTANCE, UAT_SOAINFRA.SCA_ENTITY comp
where 1=1
and comp.id=UAT_SOAINFRA.SCA_FLOW_INSTANCE.COMPOSITE_SCA_ENTITY_ID
--and composite like 'Work%'
AND CREATED_TIME> TO_DATE('28/06/2017 19:14:00','dd/mm/yyyy hh24:mi:ss')
order by UPDATED_TIME desc;


--Executions with errors
select fi.flow_id,composite,fi.created_time,fi.UPDATED_TIME, fi.UPDATED_TIME-fi.created_time , fi.active_component_instances,fi.recoverable_faults,fi.composite_sca_entity_id, 
cf.fault_name,cf.error_message,cf.exception_trace
from UAT_SOAINFRA.SCA_FLOW_INSTANCE fi, UAT_SOAINFRA.SCA_ENTITY comp,UAT_SOAINFRA.SCA_COMMON_FAULT cf
where 1=1
and cf.id=fi.flow_id
and comp.id=fi.COMPOSITE_SCA_ENTITY_ID
and composite like 'Work%'
AND CREATED_TIME> TO_DATE('28/06/2017 19:14:00','dd/mm/yyyy hh24:mi:ss')
order by UPDATED_TIME desc;

select * FROM 
UAT_SOAINFRA.SCA_COMMON_FAULT cf
WHERE 1 = 1
and cf.id='2201405';
