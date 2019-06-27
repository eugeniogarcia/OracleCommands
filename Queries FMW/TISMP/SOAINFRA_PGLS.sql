select * from  PROD_SOAINFRA.sca_flow_instance sfi
 WHERE sfi.FLOW_ID in ('4790546','4753778','4790547'); 
select * from  PROD_SOAINFRA.cube_instance sfi
 WHERE sfi.FLOW_ID ='3362797'; 
select * from  PROD_SOAINFRA.mediator_resequencer_message 
where sequence_id='11163711';

update PROD_SOAINFRA.mediator_group_status gs set status=0 where gs.GROUP_ID ='000000008774';

select * from  PROD_SOAINFRA.mediator_group_status gs where gs.GROUP_ID ='Consume_Message-0';
select status from  PROD_SOAINFRA.mediator_group_status gs where gs.GROUP_ID ='Consume_Message-0';

-- Flujos instanciados. Uno por cada flow id
select sfi.ecid from  PROD_SOAINFRA.sca_flow_instance sfi
 WHERE sfi.FLOW_ID in ('4065462'); 
select * from  PROD_SOAINFRA.cube_instance sfi;
 WHERE sfi.FLOW_ID in ('3934057'); 
 
--Nombre composite
select se.ID,se.composite from PROD_SOAINFRA.SCA_ENTITY se
where 1=1
AND se.ID in 
('300257','300126','320105','300092','300410');

select * from PROD_SOAINFRA.SCA_ENTITY se
where 1=1
and se.TYPE='composite'
and composite like 'WorkPackEventProcessor%';

select component_name, count(component_name) total from PROD_SOAINFRA.CUBE_INSTANCE
where SCA_PARTITION_ID='210001'
and creation_date>sysdate-7
and COMPONENTTYPE= 'bpel'
group by component_name
order by total desc;


--Total of EWS calls
select ra.MSG_GUID, TO_char(ra.LOCALHOST_TIMESTAMP,'DD/mm/YYYY HH24:MI:SS') TIMESTAMP, rd.DATA_VALUE ,ra.STATE, ra.MSG_LABELS,ra.INBOUND_SERVICE_NAME  
FROM PROD_SOAINFRA.wli_qs_report_attribute ra,PROD_SOAINFRA.WLI_QS_REPORT_DATA rd 
where 1 = 1
and ra.MSG_GUID =rd.MSG_GUID 
and (
ra.INBOUND_SERVICE_NAME like '%EES%' or
ra.INBOUND_SERVICE_NAME like '%EWS%' or
ra.INBOUND_SERVICE_NAME like '%ERS%' 
)
and ra.DB_TIMESTAMP> TO_DATE('09/08/2017 11:57:00','dd/mm/yyyy hh24:mi:ss')
and ra.DB_TIMESTAMP< TO_DATE('09/08/2017 11:58:59','dd/mm/yyyy hh24:mi:ss')
--and ra.MSG_LABELS like '%163488%'
order by ra.msg_guid,  ra.DB_TIMESTAMP desc;

-- errors in composites that use tx
select * from PROD_SOAINFRA.SCA_COMMON_FAULT SCF
WHERE 1=1 
and scf.retry_count>3
AND scf.OWNER_CIKEY IN(
select ci.CIKEY from PROD_SOAINFRA.CUBE_INSTANCE ci
where 1=1
and ci.composite_name in (
'DWFPWOService',
'WorkPackEventProcessor',
'INT_085_CMM_ELL_WOSTATUS_MOD_BAS',
'INT_168_FR_ELL_ASSET_PHOTO_BAS',
'INT_060_CMM_ELL_CATALOGUEITEM_MOD_BES',
'INT_031_CMM_ELL_PPI_CRE_BAS',
'INT_029_CMM_ELL_CONDITIONMEASUREMENT_CRE_BES',
'INT_027_CMM_ELL_WORKORDERFAULT_MOD_BAS',
'INT_026_CMM_ELL_WORKORDERDEFECT_MOD_BAS',
'INT_025_CMM_ELL_WORKORDERNOTFIXED_CRE_BAS',
'INT_024_CMM_ELL_WORKORDERFIXED_CRE_BAS',
'DWFModifyEventProcessor'
)
and ci.MODIFY_DATE > TO_DATE('14/07/2017 08:58:00','dd/mm/yyyy hh24:mi:ss') and ci.MODIFY_DATE < TO_DATE('14/07/2017 09:01:00','dd/mm/yyyy hh24:mi:ss')
);


--Interfaces using tx
--select * from PROD_SOAINFRA.CUBE_INSTANCE ci
select ci.composite_name,count(ci.flow_id) from PROD_SOAINFRA.CUBE_INSTANCE ci
where 1=1
and ci.composite_name in (
'DWFPWOService',
'WorkPackEventProcessor',
'INT_085_CMM_ELL_WOSTATUS_MOD_BAS',
'INT_168_FR_ELL_ASSET_PHOTO_BAS',
'INT_060_CMM_ELL_CATALOGUEITEM_MOD_BES',
'INT_031_CMM_ELL_PPI_CRE_BAS',
'INT_029_CMM_ELL_CONDITIONMEASUREMENT_CRE_BES',
'INT_027_CMM_ELL_WORKORDERFAULT_MOD_BAS',
'INT_026_CMM_ELL_WORKORDERDEFECT_MOD_BAS',
'INT_025_CMM_ELL_WORKORDERNOTFIXED_CRE_BAS',
'INT_024_CMM_ELL_WORKORDERFIXED_CRE_BAS',
'DWFModifyEventProcessor'
)
and ci.MODIFY_DATE > TO_DATE('14/07/2017 08:54:00','dd/mm/yyyy hh24:mi:ss') and ci.MODIFY_DATE < TO_DATE('14/07/2017 09:02:00','dd/mm/yyyy hh24:mi:ss')
group by ci.composite_name;


--Flows with a lot of retries
select sca.flow_id,sum(sca.RETRY_COUNT) total from  PROD_SOAINFRA.SCA_COMMON_FAULT sca
 WHERE 1=1
 and sca.RETRY_COUNT>10
and sca.sca_partition_id in('210002','290001','290002','290003','290004','290005')
group by sca.flow_id
order by total desc;

--instancias en running
select fi.FLOW_ID,fi.CONVERSATION_ID, scae.COMPOSITE,TO_char(fi.CREATED_TIME,'dd/mm/yyyy hh24:mi:ss') creado,TO_char(fi.UPDATED_TIME,'dd/mm/yyyy hh24:mi:ss') actualizado,fi.COMPOSITE_SCA_ENTITY_ID,fi.ecid, fi.ACTIVE_COMPONENT_INSTANCES,fi.RECOVERABLE_FAULTS 
from PROD_SOAINFRA.sca_flow_instance fi, PROD_SOAINFRA.SCA_ENTITY scae
WHERE 1=1
--and fi.COMPOSITE_SCA_ENTITY_ID  IN ('300439','300474','300501','320018','320061','330001','340001','300229','300243','300257')
AND scae.id=fi.COMPOSITE_SCA_ENTITY_ID
and fi.RECOVERABLE_FAULTS=0 
and fi.ACTIVE_COMPONENT_INSTANCES>0
--and fi.FLOW_ID='3960514'
AND fi.CREATED_TIME > TO_DATE('28/05/2017 00:00:00','dd/mm/yyyy hh24:mi:ss');
order by actualizado desc;

--Payloads OSB
--total of requests
select count(ra.MSG_GUID)
FROM PROD_SOAINFRA.wli_qs_report_attribute ra,PROD_SOAINFRA.WLI_QS_REPORT_DATA rd 
where 1 = 1
and ra.MSG_GUID =rd.MSG_GUID 
and ra.INBOUND_SERVICE_NAME LIKE '%138%'
and ra.DB_TIMESTAMP> TO_DATE('28/07/2017 00:00:00','dd/mm/yyyy hh24:mi:ss')
and ra.DB_TIMESTAMP< TO_DATE('28/07/2017 23:59:59','dd/mm/yyyy hh24:mi:ss');

--total of errors
select count(ra.MSG_GUID)/2
FROM PROD_SOAINFRA.wli_qs_report_attribute ra,PROD_SOAINFRA.WLI_QS_REPORT_DATA rd 
where 1 = 1
and state='ERROR'
and ra.MSG_GUID =rd.MSG_GUID 
and ra.INBOUND_SERVICE_NAME LIKE '%138%'
and ra.DB_TIMESTAMP> TO_DATE('31/07/2017 00:00:00','dd/mm/yyyy hh24:mi:ss')
and ra.DB_TIMESTAMP< TO_DATE('01/08/2017 23:59:59','dd/mm/yyyy hh24:mi:ss');


--Payloads OSB
--select ra.MSG_GUID, TO_char(ra.LOCALHOST_TIMESTAMP,'DD/mm/YYYY HH24:MI:SS') TIMESTAMP, rd.DATA_VALUE ,ra.STATE, ra.MSG_LABELS,ra.INBOUND_SERVICE_NAME  
select *

FROM PROD_SOAINFRA.wli_qs_report_attribute ra,PROD_SOAINFRA.WLI_QS_REPORT_DATA rd 
where 1 = 1
--and state='ERROR'
and ra.MSG_GUID =rd.MSG_GUID 
--and ra.INBOUND_SERVICE_NAME LIKE '%138%'
and ra.INBOUND_SERVICE_NAME LIKE '%EWSTaskMultiAssigneeService%'
--and ra.MSG_LABELS like '%188202%'
and ra.DB_TIMESTAMP> TO_DATE('31/07/2017 08:00:00','dd/mm/yyyy hh24:mi:ss')
and ra.DB_TIMESTAMP< TO_DATE('10/07/2017 10:00:00','dd/mm/yyyy hh24:mi:ss')
order by ra.DB_TIMESTAMP asc;

--Payloads OSB
select ra.MSG_GUID, TO_char(ra.LOCALHOST_TIMESTAMP,'DD/mm/YYYY HH24:MI:SS') TIMESTAMP, rd.DATA_VALUE ,ra.STATE, ra.MSG_LABELS,ra.INBOUND_SERVICE_NAME  
--select  ra.INBOUND_SERVICE_NAME
FROM PROD_SOAINFRA.wli_qs_report_attribute ra,PROD_SOAINFRA.WLI_QS_REPORT_DATA rd 
where 1 = 1
and ra.MSG_GUID =rd.MSG_GUID 
--and ra.STATE ='REQUEST'
--and ra.STATE ='ERROR'
--and ra.STATE ='RESPONSE'
--AND (UPPER(ra.INBOUND_SERVICE_NAME) LIKE '%138%' or UPPER(ra.INBOUND_SERVICE_NAME) LIKE '%EWSWORKORDERTASKSERVICE%')
--and ra.INBOUND_SERVICE_NAME LIKE '%EWSTransactionService%'
--and ra.INBOUND_SERVICE_NAME LIKE '%EWSCondMeasurementService%'
--and ra.INBOUND_SERVICE_NAME = 'Pipeline$INT_104_EAG_CMM_WORKORDER_CRE_BES$ProxyService$Pipeline_CreateWorkOrderEAGLESToCMMBESV1'
--and ra.INBOUND_SERVICE_NAME = 'Pipeline$INT_024_FR_SCRIPTRESULTS_ROUTE_BES$ProxyServices$Pipeline_RouteScriptResultsFDCSToFusionBESV1'
--and ra.INBOUND_SERVICE_NAME ='Pipeline$INT_024_FR_SCRIPTRESULTS_ROUTE_BES$ProxyServices$Pipeline_RouteScriptResultsFDCSToFusionBESV1'

and (
ra.INBOUND_SERVICE_NAME = 'Pipeline$INT_024_FR_SCRIPTRESULTS_ROUTE_BES$ProxyServices$Pipeline_RouteScriptResultsFDCSToFusionBESV1' or
ra.INBOUND_SERVICE_NAME = 'Pipeline$INT_025_FR_CMM_WORKORDERNOTFIXED_CRE_BES$Pipeline_CreateWorkOrderNOTFixedToFusionBES' or
ra.INBOUND_SERVICE_NAME = 'Pipeline$INT_024_FR_CMM_WORKORDERFIXED_CRE_BES$Pipeline_CreateWorkOrderFixedToFusionBES' or
ra.INBOUND_SERVICE_NAME = 'Pipeline$INT_026_FR_CMM_WORKORDERDEFECT_MOD_BES$Pipeline_ModifyWorkOrderDefectFDCSToFusionBESV1'  or
ra.INBOUND_SERVICE_NAME = 'Pipeline$INT_027_FR_CMM_WORKORDERDEFECT_MOD_BES$Pipeline_ModifyWorkOrderDefectFDCSToFusionBESV1' )

--and (ra.INBOUND_SERVICE_NAME LIKE '%StdText%' or ra.INBOUND_SERVICE_NAME LIKE '%EWSCondMeasurementService%')
--and ra.INBOUND_SERVICE_NAME LIKE '%Transaction%'
--and ra.INBOUND_SERVICE_NAME LIKE '%EWSTaskMultiAssigneeService%'
--and ra.INBOUND_SERVICE_NAME LIKE '%ERS%'
and ra.msg_labels like '%4203027%'

--and ra.msg_labels like '%c87b50bf-5c1e-45d3-ac2b-a5bcd357da72%'
--and ra.MSG_GUID in ('uuid:eb40424ead89a8c9:5017f70f:15d11a69823:-7ec5','uuid:eb40424ead89a8c9:5017f70f:15d11a69823:-7ec6')
--and ra.MSG_GUID like 'uuid:eb40424ead89a8c9:5017f70f:15d11a69823%'
--AND ra.DB_TIMESTAMP > TRUNC(SYSDATE-7)
and ra.DB_TIMESTAMP> TO_DATE('08/08/2017 00:00:00','dd/mm/yyyy hh24:mi:ss')
--and ra.DB_TIMESTAMP< TO_DATE('04/08/2017 23:59:59','dd/mm/yyyy hh24:mi:ss')
--order by  substr(ra.MSG_GUID,0,LENGTH(ra.MSG_GUID)-6),ra.DB_TIMESTAMP asc;
order by ra.msg_guid,  ra.DB_TIMESTAMP desc;


--Reports OSB
select MSG_GUID, TO_char(LOCALHOST_TIMESTAMP,'DD/mm/YYYY HH24:MI:SS') TIMESTAMP, STATE, MSG_LABELS  FROM PROD_SOAINFRA.wli_qs_report_attribute ra
where 1 = 1
AND UPPER(ra.INBOUND_SERVICE_NAME) LIKE '%138%'
--and ra.msg_labels like '%188983%'
AND DB_TIMESTAMP > TRUNC(SYSDATE-1)
order by  substr(MSG_GUID,0,LENGTH(MSG_GUID)-6),ra.DB_TIMESTAMP asc;
--order by ra.msg_guid,  ra.DB_TIMESTAMP desc;


--EWS executed
--select *
--select ra.msg_GUID, TO_char(ra.DB_TIMESTAMP,'DD/mm/YYYY HH24:MI:SS') TIMESTAMP, ra.INBOUND_SERVICE_NAME,ra.state,ra.MSG_LABELS,ra.ERROR_REASON,ra.ERROR_DETAILS,ra.ERROR_CODE
select ra.msg_GUID, TO_char(ra.DB_TIMESTAMP,'DD/mm/YYYY HH24:MI:SS') TIMESTAMP, ra.INBOUND_SERVICE_NAME, ra.MSG_LABELS
FROM PROD_SOAINFRA.wli_qs_report_attribute ra
where 1=1
and state='REQUEST'
and (ra.INBOUND_SERVICE_NAME like '%EWS%' or ra.INBOUND_SERVICE_NAME like '%ERS%' or ra.INBOUND_SERVICE_NAME like '%EES%') 
and
(
((ra.DB_TIMESTAMP> TO_DATE('29/06/2017 08:30:00','dd/mm/yyyy hh24:mi:ss')) and (ra.DB_TIMESTAMP< TO_DATE('29/06/2017 08:45:00','dd/mm/yyyy hh24:mi:ss')))
--or
--((ra.DB_TIMESTAMP> TO_DATE('27/06/2017 11:34:00','dd/mm/yyyy hh24:mi:ss')) and (ra.DB_TIMESTAMP< TO_DATE('27/06/2017 12:10:00','dd/mm/yyyy hh24:mi:ss')))
)
--order by  substr(ra.MSG_GUID,0,LENGTH(ra.MSG_GUID)-6),ra.DB_TIMESTAMP asc;
order by  ra.DB_TIMESTAMP desc;

--EWS executed (DWF)
select sfi.ECID,sfi.FLOW_ID,se.composite,sfi.CREATED_TIME,sfi.UPDATED_TIME from PROD_SOAINFRA.SCA_FLOW_INSTANCE sfi, PROD_SOAINFRA.SCA_ENTITY se
where 1=1
and se.id=sfi.COMPOSITE_SCA_ENTITY_ID
and
(
((sfi.UPDATED_TIME> TO_DATE('03/07/2017 03:00:00','dd/mm/yyyy hh24:mi:ss')) and (sfi.UPDATED_TIME< TO_DATE('03/07/2017 04:00:00','dd/mm/yyyy hh24:mi:ss')))
or
((sfi.UPDATED_TIME> TO_DATE('03/07/2017 03:00:00','dd/mm/yyyy hh24:mi:ss')) and (sfi.UPDATED_TIME< TO_DATE('03/07/2017 04:00:00','dd/mm/yyyy hh24:mi:ss')))
)
AND sfi.COMPOSITE_SCA_ENTITY_ID in ('220136','240089','220018','220065','220051','220207')
order by sfi.UPDATED_TIME desc;


--Estado de JOBs
select JOB_ID,ESS_PARENT_ID,DESCRIPTION,SUCCEEDED_COUNT,FAILED_COUNT,TOTAL_COUNT,decode(state,1,'RUNNING',5,'COMPLETE',3,'WAIT',2,'2',4,'4') STATUS,MODIFIED_DATE  
from PROD_SOAINFRA.BULK_RECOVERY_JOB 
where creation_date > TO_DATE('08/08/2017 13:00:00','dd/mm/yyyy hh24:mi:Ss')
--and creation_date < TO_DATE('01/06/2017 23:59:59','dd/mm/yyyy hh24:mi:Ss')
AND state < 5
order by modified_date desc;
--order by creation_date desc;


--Resequencer en error, message in error, split by message status
--Saca tantas filas por resequencing group y componente, como estados de mensahe hay (en error)
--y desde cuendo
select  to_char(CREATION_DATE,'YYYY-MM-DD HH24:MI:SS') Message_Time, 
m.FLOW_ID,
m.SEQUENCE_ID,
decode(gs.status ,0,'READY',1,'LOCKED',3,'ERRORED',4,'TIMED_OUT',6,'GROUP_ERROR',null) GROUP_STATUS,
  decode(m.status ,0,'READY',2,'PROCESSED',3,'ERRORED',4,'TIMED_OUT',5,'ABORTED',null) MSG_STATUS,gs.GROUP_ID,gs.component_dn
from PROD_SOAINFRA.mediator_group_status gs, PROD_SOAINFRA.mediator_resequencer_message m
where m.group_id = gs.group_id
and m.owner_id = gs.id
and gs.status >0 and m.status>2
group by gs.status, m.status, gs.component_dn,gs.GROUP_ID,m.FLOW_ID,CREATION_DATE,m.SEQUENCE_ID
order by gs.group_id,m.FLOW_ID,CREATION_DATE,gs.component_dn;

select  count(m.FLOW_ID)
from PROD_SOAINFRA.mediator_group_status gs, PROD_SOAINFRA.mediator_resequencer_message m
where m.group_id = gs.group_id
and m.owner_id = gs.id
and gs.status >0 and m.status>2;


--Resequencer detallado
--Listado de mensajes bloqueados en un resequencer y por resequencing group, flow id
select  to_char(CREATION_DATE,'YYYY-MM-DD HH24:MI:SS') Fault_Time,
 m.FLOW_ID,m.SEQUENCE_ID,
 decode(gs.status ,0,'READY',1,'LOCKED',3,'ERRORED',4,'TIMED_OUT',6,'GROUP_ERROR',null) GROUP_STATUS,
  decode(m.status ,0,'READY',2,'PROCESSED',3,'ERRORED',4,'TIMED_OUT',5,'ABORTED',null) MSG_STATUS,
  gs.GROUP_ID,gs.component_dn
from PROD_SOAINFRA.mediator_group_status gs, PROD_SOAINFRA.mediator_resequencer_message m
where m.group_id = gs.group_id
and m.owner_id = gs.id
--and gs.status=1
and gs.status >0 and m.status!=2 
group by gs.status, m.status, gs.component_dn,gs.GROUP_ID,m.FLOW_ID,m.SEQUENCE_ID,CREATION_DATE
order by gs.group_id,m.FLOW_ID,CREATION_DATE,gs.component_dn, gs.status;

--running vs resequencer
SELECT   SFI.FLOW_ID, RESEQ.SEQUENCE_ID, RESEQ.GROUP_ID, RESEQ.GROUP_STATUS, RESEQ.MSG_STATUS, SE.COMPOSITE, TO_CHAR(SFI.CREATED_TIME,'dd/mm/yyyy hh24:mi:ss') CREATION_DATE
, TO_CHAR(SFI.UPDATED_TIME,'dd/mm/yyyy hh24:mi:ss') UPDATED_DATE, SFI.ACTIVE_COMPONENT_INSTANCES, SFI.RECOVERABLE_FAULTS
FROM
  PROD_SOAINFRA.SCA_FLOW_INSTANCE SFI
  ,( SELECT
    MRM.FLOW_ID
  , MRM.SEQUENCE_ID
  , MGS.GROUP_ID
  , DECODE (MGS.STATUS ,0,'READY',1,'LOCKED',3,'ERRORED',4,'TIMED_OUT',6,'GROUP_ERROR',NULL) GROUP_STATUS
  , DECODE(MRM.STATUS ,0,'READY',2,'PROCESSED',3,'ERRORED',4,'TIMED_OUT',5,'ABORTED',NULL) MSG_STATUS
  FROM PROD_SOAINFRA.MEDIATOR_RESEQUENCER_MESSAGE MRM
  , PROD_SOAINFRA.MEDIATOR_GROUP_STATUS MGS
  WHERE MRM.OWNER_ID = MGS.ID) RESEQ
, PROD_SOAINFRA.SCA_ENTITY SE
WHERE 1 = 1 
AND SFI.FLOW_ID = RESEQ.FLOW_ID (+)
AND SE.ID=SFI.COMPOSITE_SCA_ENTITY_ID
AND SFI.RECOVERABLE_FAULTS = 0
AND SFI.ACTIVE_COMPONENT_INSTANCES > 0
AND SFI.SCA_PARTITION_ID IN ('210002','290001','290002','290003','290004','290005')
AND SFI.CREATED_TIME > TO_DATE('28/05/2017 00:00:00','dd/mm/yyyy hh24:mi:ss');


--Instancias en error
select sca.FLOW_ID,se.COMPOSITE,se.name,sca.RETRY_COUNT,sca.COMPONENT_TYPE,sca.FAULT_NAME,sca.ERROR_MESSAGE,sca.exception_trace,sca.MODIFY_DATE
from PROD_SOAINFRA.SCA_COMMON_FAULT sca ,PROD_SOAINFRA.SCA_ENTITY se
where 
se.ID=sca.SCA_ENTITY_ID and
sca.flow_id in (
(select  
m.FLOW_ID
from PROD_SOAINFRA.mediator_group_status gs, PROD_SOAINFRA.mediator_resequencer_message m
where m.group_id = gs.group_id
and m.owner_id = gs.id
and gs.status >0 and m.status>2)
union
(select flow_id from PROD_SOAINFRA.SCA_FLOW_INSTANCE 
where RECOVERABLE_FAULTS>0 and ACTIVE_COMPONENT_INSTANCES>0
AND CREATED_TIME > TO_DATE('28/05/2017 00:00:00','dd/mm/yyyy hh24:mi:ss')
and sca_partition_id in('210002','290001','290002','290003','290004','290005')
)
)
order by sca.FLOW_ID,sca.MODIFY_DATE desc;


----------------------------------------------------------------------------------------
--Resequencer en error
--Saca una fila por resequencing group y componente, indicando cuantos mensajes estan acumulados y desde cuendo
select  to_char(LAST_RECEIVED_TIME,'YYYY-MM-DD HH24:MI:SS') Fault_Time, 
decode(gs.status ,0,'READY',1,'LOCKED',3,'ERRORED',4,'TIMED_OUT',6,'GROUP_ERROR',null) GROUP_STATUS,
  count(1) TOTAL, gs.GROUP_ID,gs.component_dn
from PROD_SOAINFRA.mediator_group_status gs, PROD_SOAINFRA.mediator_resequencer_message m
where m.group_id = gs.group_id
and m.owner_id = gs.id
and gs.status >0 and m.status!=2
group by gs.status, gs.component_dn, gs.GROUP_ID,LAST_RECEIVED_TIME
order by gs.group_id,gs.component_dn, gs.status;


--Resequencer en error, split by message status
--Saca tantas filas por resequencing group y componente, como estados de mensahe hay, indicando cuantos mensahes estan acumulados 
--y desde cuendo
select  to_char(LAST_RECEIVED_TIME,'YYYY-MM-DD HH24:MI:SS') Fault_Time,
 to_char(LAST_RECEIVED_TIME,'YYYY-MM-DD HH24:MI:SS') Fault_Time, 
 decode(gs.status ,0,'READY',1,'LOCKED',3,'ERRORED',4,'TIMED_OUT',6,'GROUP_ERROR',null) GROUP_STATUS,
  decode(m.status ,0,'READY',2,'PROCESSED',3,'ERRORED',4,'TIMED_OUT',5,'ABORTED',null) MSG_STATUS,
  count(1) TOTAL, gs.GROUP_ID,gs.component_dn
from PROD_SOAINFRA.mediator_group_status gs, PROD_SOAINFRA.mediator_resequencer_message m
where m.group_id = gs.group_id
and m.owner_id = gs.id
and gs.status >0 and m.status!=2
group by gs.status, m.status, gs.component_dn, gs.GROUP_ID,LAST_RECEIVED_TIME
order by gs.group_id,gs.component_dn, gs.status;



---------------------------------------------------------

-- Instancias en error. Podemos habilitar que recupere tambien informacion de sensores
-- En muchos casos veremos dos mensajes de error. Esto es porque el mensaje que se arroja en la referencia en muchas ocasiones
-- lo gestionaremos y haremos un throw, con lo que un segundo mensaje es capturado, esta vez a nivel de BPEL
SELECT  ci.FLOW_ID FLOW_ID,
ci.ECID ECID,
( CASE WHEN ci.STATE=0 THEN 'STATE_INITIATED'
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
END) AS STATE,
--ssv.SENSOR_NAME, --ENABLE SENSORS
--ssv.STRING_VALUE, --ENABLE SENSORS
(SELECT se.COMPOSITE from PROD_SOAINFRA.SCA_ENTITY se WHERE se.ID = nvl(scf.OWNER_SCA_ENTITY_ID,se.ID)) COMPOSITE,
scf.COMPONENT_TYPE COMPONENT_TYPE,
scf.JNDI_LOCATION JNDI_LOCATION,
scf.ERROR_MESSAGE ERROR_MESSAGE,
scf.EXCEPTION_TRACE EXCEPTION_TRACE,
ci.CREATION_DATE
FROM PROD_SOAINFRA.SCA_COMMON_FAULT scf
, PROD_SOAINFRA.CUBE_INSTANCE ci
, PROD_SOAINFRA.SCA_FLOW_INSTANCE sfi
--, PROD_SOAINFRA.SCA_SENSOR_VALUE ssv --ENABLE SENSORS
WHERE 1=1
AND scf.FLOW_ID = ci.FLOW_ID --MAIN JOIN BETWEEN THE FLOW EXECUTIONS AND FAULT TABLES
AND sfi.FLOW_ID = ci.FLOW_ID
AND scf.OWNER_CIKEY = ci.CIKEY
--AND scf.RETRY_COUNT = ( SELECT MAX(scf2.RETRY_COUNT) FROM PROD_SOAINFRA.SCA_COMMON_FAULT scf2 WHERE scf2.FLOW_ID (+) = ci.FLOW_ID) --FOR AVOIDING DUPLICATED ERROR MESSAGES
--AND (ci.STATE !=5 OR (ci.state='5' AND sfi.RECOVERABLE_FAULTS != 0 )) -- FLOWS NOT IN COMPLETED STATYS
--AND (ci.STATE !=5 AND sfi.RECOVERABLE_FAULTS != 0 AND sfi.ACTIVE_COMPONENT_INSTANCES!=0)
--AND ((sfi.RECOVERABLE_FAULTS != 0 AND sfi.ACTIVE_COMPONENT_INSTANCES!=0 and ci.state!=9) 
--OR (sfi.ADMIN_STATE=2)
--OR (sfi.unhandled_faults > 0))
--AND ssv.FLOW_ID = ci.FLOW_ID --ENABLE SENSORS
--AND scf.CREATION_DATE BETWEEN TO_DATE('24/04/2017 00:00:01','dd/mm/yyyy HH24:MI:SS') AND TO_DATE('25/04/2017 00:00:00','dd/mm/yyyy HH24:MI:SS' ) --FILTER BY CREATION_DATE
--AND ssv.SENSOR_NAME = 'EquipmentNum' --ENABLE SENSORS
--AND ssv.STRING_VALUE = '000002115630' --ENABLE SENSORS
--AND ci.FLOW_ID =  
--AND scf.ERROR_MESSAGE LIKE '%ORA-02049%' or scf.ERROR_MESSAGE LIKE '%OSB-380002%' --FILTER BY SPECIFIC ERROR
--AND ci.CREATION_DATE > TO_DATE('29/05/2017 00:00:00','dd/mm/yyyy hh24:mi:ss')
--AND ci.CREATION_DATE > sysdate -1
AND ci.flow_id=3323131
--AND ci.CREATION_DATE BETWEEN TO_DATE('28/05/2017 00:00:00','dd/mm/yyyy hh24:mi:ss') AND TO_DATE('29/05/2017 00:00:00','dd/mm/yyyy hh24:mi:ss')
ORDER BY ci.FLOW_ID, ci.CIKEY;


--Flujos abortados
SELECT  ci.FLOW_ID FLOW_ID,
( CASE WHEN ci.STATE=0 THEN 'STATE_INITIATED'
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
END) AS STATE,
-- Habilita sensores
--ssv.SENSOR_NAME, --ENABLE SENSORS
--ssv.STRING_VALUE, --ENABLE SENSORS
ci.COMPOSITE_NAME COMPOSITE
FROM PROD_SOAINFRA.CUBE_INSTANCE ci
, PROD_SOAINFRA.SCA_FLOW_INSTANCE sfi
-- Habilita sensores
--, FOF_SOAINFRA.SCA_SENSOR_VALUE ssv --ENABLE SENSORS
WHERE 1=1
AND sfi.FLOW_ID = ci.FLOW_ID
AND sfi.ADMIN_STATE = 2
-- Habilita sensores
--AND ssv.FLOW_ID = ci.FLOW_ID --ENABLE SENSORS
--AND ssv.SENSOR_NAME = 'EquipmentNum' --ENABLE SENSORS
--AND ssv.STRING_VALUE = '000002115630' --ENABLE SENSORS

--Filtra por flow id
--AND ci.FLOW_ID =  	801716 --FILTER BY FLOW_ID

--Filtra por fecha
AND ci.CREATION_DATE > SYSDATE - 7;

----------------------------------------------------------------------------------------

--Sensores

--Sensores de flujos que tienen algun error con el mensaje "unique"
select SENSOR_NAME, STRING_VALUE,clob_value from PROD_SOAINFRA.SCA_SENSOR_VALUE; 

--Sensores del 116
select * from PROD_SOAINFRA.SCA_SENSOR_VALUE where 1=1
and composite_sca_entity_id in(  
select ID from PROD_SOAINFRA.SCA_ENTITY se where composite like '%116%' and type='composite') 
and string_value ='W0000569';

select * from PROD_SOAINFRA.SCA_SENSOR_VALUE where 1=1
and composite_sca_entity_id in(  
select ID from PROD_SOAINFRA.SCA_ENTITY se where composite like '%82%' and type='composite') 
and string_value ='04252431';

--Busca flows de con una referencia
select * from PROD_SOAINFRA.SCA_FLOW_INSTANCE
where flow_id in(
select flow_id from PROD_SOAINFRA.SCA_SENSOR_VALUE where 1=1
and composite_sca_entity_id in(  
select ID from PROD_SOAINFRA.SCA_ENTITY se where type='composite') 
and string_value  in ('XX_TE_Z5_3WWP_527781','EA_TE_Z4_3SWX_342227','EA_TE_Z3_3WWX_532102','NL_TE_Z5_3SWX_341628-2'));
--Busca flows con una referencia
select * from PROD_SOAINFRA.SCA_SENSOR_VALUE where 1=1
and composite_sca_entity_id in(  
select ID from PROD_SOAINFRA.SCA_ENTITY se where type='composite') 
and string_value  in ('XX_TE_Z5_3WWP_527781','EA_TE_Z4_3SWX_342227','EA_TE_Z3_3WWX_532102','NL_TE_Z5_3SWX_341628-2');

--Cambios en funcion de sensor
select sfi.UPDATED_TIME,sensor.flow_id, se.COMPOSITE from PROD_SOAINFRA.SCA_SENSOR_VALUE sensor, PROD_SOAINFRA.SCA_ENTITY se,PROD_SOAINFRA.sca_flow_instance sfi  where 1=1
and sensor.composite_sca_entity_id=se.ID
and sensor.flow_id=sfi.flow_id
and string_value like '%4247057%';


where flow_id in (select flow_id from PROD_SOAINFRA.sca_common_fault where error_message like '%unique%');

--WO y sensores
select fi.FLOW_ID,fi.CONVERSATION_ID, scae.COMPOSITE,TO_char(fi.UPDATED_TIME,'dd/mm/yyyy hh24:mi:ss') actualizado,pi.STATE,pi.STATE_TEXT,fi.COMPOSITE_SCA_ENTITY_ID,fi.ecid, fi.ACTIVE_COMPONENT_INSTANCES,fi.RECOVERABLE_FAULTS 
,se.SENSOR_NAME, se.STRING_VALUE,se.clob_value
from PROD_SOAINFRA.sca_flow_instance fi, PROD_SOAINFRA.BPEL_PROCESS_INSTANCES pi, PROD_SOAINFRA.SCA_ENTITY scae, PROD_SOAINFRA.SCA_SENSOR_VALUE se
WHERE 1=1
and fi.COMPOSITE_SCA_ENTITY_ID  IN ('300439','300474','300501','320018','320061','330001','340001','300229','300243','300257')
AND scae.id=fi.COMPOSITE_SCA_ENTITY_ID
and pi.CONVERSATION_ID=fi.CONVERSATION_ID
and se.FLOW_ID =fi.FLOW_ID
and se.FLOW_ID =4926786
order by actualizado desc
;

--WO y sensores (sin informacion de la vista de proceso. A veces no tiene registros)
select fi.FLOW_ID,fi.CONVERSATION_ID, scae.COMPOSITE,TO_char(fi.UPDATED_TIME,'dd/mm/yyyy hh24:mi:ss') actualizado,fi.COMPOSITE_SCA_ENTITY_ID,fi.ecid, fi.ACTIVE_COMPONENT_INSTANCES,fi.RECOVERABLE_FAULTS 
,se.SENSOR_NAME, se.STRING_VALUE,se.clob_value
from PROD_SOAINFRA.sca_flow_instance fi, PROD_SOAINFRA.SCA_ENTITY scae, PROD_SOAINFRA.SCA_SENSOR_VALUE se
WHERE 1=1
and fi.COMPOSITE_SCA_ENTITY_ID  IN ('300439','300474','300501','320018','320061','330001','340001','300229','300243','300257')
AND scae.id=fi.COMPOSITE_SCA_ENTITY_ID
and se.FLOW_ID =fi.FLOW_ID
order by actualizado desc;


--WO SIN sensores
select fi.FLOW_ID,fi.CONVERSATION_ID, scae.COMPOSITE,TO_char(fi.UPDATED_TIME,'dd/mm/yyyy hh24:mi:ss') actualizado,pi.STATE,pi.STATE_TEXT,fi.COMPOSITE_SCA_ENTITY_ID,fi.ecid, fi.ACTIVE_COMPONENT_INSTANCES,fi.RECOVERABLE_FAULTS 
from PROD_SOAINFRA.sca_flow_instance fi, PROD_SOAINFRA.BPEL_PROCESS_INSTANCES pi, PROD_SOAINFRA.SCA_ENTITY scae
WHERE 1=1
and fi.COMPOSITE_SCA_ENTITY_ID  IN ('300439','300474','300501','320018','320061','330001','340001','300229','300243','300257')
AND scae.id=fi.COMPOSITE_SCA_ENTITY_ID
-- and fi.FLOW_ID>4876502
and pi.CONVERSATION_ID=fi.CONVERSATION_ID
order by actualizado desc;


--WO SIN sensores (sin informacion de la vista de proceso. A veces no tiene registros)
select fi.FLOW_ID,fi.CONVERSATION_ID, scae.COMPOSITE,TO_char(fi.UPDATED_TIME,'dd/mm/yyyy hh24:mi:ss') actualizado,fi.COMPOSITE_SCA_ENTITY_ID,fi.ecid, fi.ACTIVE_COMPONENT_INSTANCES,fi.RECOVERABLE_FAULTS 
from PROD_SOAINFRA.sca_flow_instance fi, PROD_SOAINFRA.SCA_ENTITY scae
WHERE 1=1
and fi.COMPOSITE_SCA_ENTITY_ID  IN ('300439','300474','300501','320018','320061','330001','340001','300229','300243','300257')
AND scae.id=fi.COMPOSITE_SCA_ENTITY_ID
-- and fi.FLOW_ID>4876502
order by actualizado desc;

select * from PROD_SOAINFRA.sca_flow_instance fi
where fi.FLOW_ID='4610936';
select * from PROD_SOAINFRA.BPEL_PROCESS_INSTANCES pi
where pi.CONVERSATION_ID ='urn:84d22e0c-5d6b-11e7-8dc8-ca7c934a250c';

-- Script IDs received from FR
select ra.MSG_GUID, TO_char(ra.LOCALHOST_TIMESTAMP,'DD/mm/YYYY HH24:MI:SS') TIMESTAMP, rd.DATA_VALUE ,ra.STATE, ra.MSG_LABELS,ra.INBOUND_SERVICE_NAME  
--select  ra.INBOUND_SERVICE_NAME
FROM PROD_SOAINFRA.wli_qs_report_attribute ra,PROD_SOAINFRA.WLI_QS_REPORT_DATA rd 
where 1 = 1
and ra.MSG_GUID =rd.MSG_GUID 
--and ra.STATE ='REQUEST'
--and ra.STATE ='ERROR'
--and ra.INBOUND_SERVICE_NAME ='Pipeline$INT_024_FR_SCRIPTRESULTS_ROUTE_BES$ProxyServices$Pipeline_RouteScriptResultsFDCSToFusionBESV1'
and (
ra.INBOUND_SERVICE_NAME = 'Pipeline$INT_024_FR_SCRIPTRESULTS_ROUTE_BES$ProxyServices$Pipeline_RouteScriptResultsFDCSToFusionBESV1' or
ra.INBOUND_SERVICE_NAME = 'Pipeline$INT_025_FR_CMM_WORKORDERNOTFIXED_CRE_BES$Pipeline_CreateWorkOrderNOTFixedToFusionBES' or
ra.INBOUND_SERVICE_NAME = 'Pipeline$INT_024_FR_CMM_WORKORDERFIXED_CRE_BES$Pipeline_CreateWorkOrderFixedToFusionBES' or
ra.INBOUND_SERVICE_NAME = 'Pipeline$INT_026_FR_CMM_WORKORDERDEFECT_MOD_BES$Pipeline_ModifyWorkOrderDefectFDCSToFusionBESV1'  or
ra.INBOUND_SERVICE_NAME = 'Pipeline$INT_027_FR_CMM_WORKORDERDEFECT_MOD_BES$Pipeline_ModifyWorkOrderDefectFDCSToFusionBESV1' )
and ra.DB_TIMESTAMP> TO_DATE('28/05/2017 00:00:00','dd/mm/yyyy hh24:mi:ss')
and ra.DB_TIMESTAMP< TO_DATE('06/07/2017 18:00:00','dd/mm/yyyy hh24:mi:ss')
--order by  substr(ra.MSG_GUID,0,LENGTH(ra.MSG_GUID)-6),ra.DB_TIMESTAMP asc;
order by ra.msg_guid,  ra.DB_TIMESTAMP desc;


select * from PROD_SOAINFRA.SCA_ENTITY se
where 1=1
and (se.composite like '%02%')
and type='composite';

--Sensores de un flow id
select * from PROD_SOAINFRA.SCA_SENSOR_VALUE; 
where component_name like '%82';
where flow_id ='3410144';

----------------------------------------------------------------------------------------------

--Mensajes 
select CONV_ID,
MESSAGE_GUID,COMPOSITE_NAME,COMPONENT_NAME,COMPONENT_TYPE,PARTNER_LINK,OPERATION_NAME,
( CASE WHEN dlv_type =1 THEN 'Invoke'
WHEN dlv_type=2 THEN 'Callback'
ELSE NULL
END) Type,
( CASE WHEN state =0 THEN 'Unresolved'
WHEN state =1 THEN 'Resolved'
WHEN state =2 THEN 'Handled'
WHEN state =3 THEN 'Cancelled'
WHEN state =4 THEN 'Max recover'
ELSE NULL
END) Status, 
RECOVER_COUNT,
RECEIVE_DATE
from PROD_SOAINFRA.dlv_message
where 
--flow_id='1760785'
flow_id='4869846'
order by RECEIVE_DATE;


--Mensaje OSBs
SELECT ra.MSG_LABELS, ra.INBOUND_SERVICE_NAME, ra.ERROR_DETAILS, rd.DATA_VALUE FROM PROD_SOAINFRA.wli_qs_report_attribute ra, PROD_SOAINFRA.WLI_QS_REPORT_DATA rd 
WHERE  ra.MSG_GUID = rd.MSG_GUID 
AND ra.STATE='ERROR' -- Filtrar por tipo de report
AND ra.MSG_LABELS LIKE '%STOCKCODE_FAULT%' -- Filtrar por report key
AND ra.INBOUND_SERVICE_NAME LIKE '%INT_061%' -- Filtrar por nombre del pipeline
AND ra.ERROR_DETAILS LIKE '%Logon failed%'; -- Filtrar por error


--Instancias incluyendo el CONV_ID
select FLOW_ID,CIKEY,MODIFY_DATE,
( CASE WHEN STATE=0 THEN 'STATE_INITIATED'
WHEN STATE=1 THEN 'STATE_OPEN_RUNNING/RECOVERY'
WHEN STATE=2 THEN 'STATE_OPEN_SUSPENDED'
WHEN STATE=3 THEN 'STATE_OPEN_FAULTED'
WHEN STATE=4 THEN 'STATE_CLOSED_PENDING_CANCEL'
WHEN STATE=5 THEN 'STATE_CLOSED_COMPLETED'
WHEN STATE=6 THEN 'STATE_CLOSED_FAULTED'
WHEN STATE=7 THEN 'STATE_CLOSED_CANCELLED'
WHEN STATE=8 THEN 'STATE_CLOSED_ABORTED'
WHEN STATE=9 THEN 'STATE_CLOSED_STALE'
WHEN STATE=10 THEN 'STATE_CLOSED_ROLLED_BACK'
ELSE NULL
END) AS STATE,
PARENT_ID,CONVERSATION_ID CONV_ID,ECID,COMPOSITE_NAME,COMPONENT_NAME
from PROD_SOAINFRA.CUBE_INSTANCE 
where flow_id='3717018'
order by MODIFY_DATE;

---------------------------------------------------------------------------------------------

--Tamano de Payload de un flow id o ecid
select dlv.composite_name COMPOSITE_NAME, dlv.flow_id FLOW_ID,xml.document_type, dbms_lob.getlength(xml.document) docsize from
PROD_SOAINFRA.xml_document xml,
PROD_SOAINFRA.document_dlv_msg_ref dlv_ref,
PROD_SOAINFRA.dlv_message dlv
where 1=1
--Filtra por fecha
--xml.DOC_PARTITION_DATE > sysdate - 6
and xml.document_id = dlv_ref.document_id
and dlv.message_guid = dlv_ref.MESSAGE_GUID
--Por flowid
and dlv.flow_id = 4878311
--Por ecid
--and dlv_ref.MESSAGE_GUID='e31ce1a3-3b07-11e7-b44e-0e5db3dd8b0a'
 order by docsize desc;


--Listado de documentos
select xml.DOC_PARTITION_DATE ,dlv.composite_name COMPOSITE_NAME, dlv.flow_id FLOW_ID,xml.document_type, xml.DOCUMENT, xml.DOCUMENT_ID  from
PROD_SOAINFRA.xml_document xml,
PROD_SOAINFRA.document_dlv_msg_ref dlv_ref,
PROD_SOAINFRA.dlv_message dlv
where 1=1
--xml.DOC_PARTITION_DATE > sysdate - 6
and xml.document_id = dlv_ref.document_id
and dlv.message_guid = dlv_ref.MESSAGE_GUID
and dlv.flow_id = 4878311
--and dlv.composite_name like '%INT_029%'
order by xml.DOC_PARTITION_DATE ;

select * from PROD_SOAINFRA.dlv_message dlv;

--Payload en resequencer
select MRM.FLOW_ID, MRM.COMPONENT_DN, MP.NAME, MP.TYPE, MP.BIN FROM PROD_SOAINFRA.MEDIATOR_RESEQUENCER_MESSAGE MRM, PROD_SOAINFRA.MEDIATOR_PAYLOAD MP
WHERE 1 = 1
AND MRM.ID = MP.OWNER_ID
and mp.type='payload'
--and MRM.COMPONENT_DN like '%INT_038_ELL_CMM_ASSET_MOD_BAS%'
AND MRM.FLOW_ID = 3718011;


-------------------------------------------------------------------------------------------

--SELECT CI.CIKEY AS CIKEY,CI.LOG AS LOG FROM UAT_SOAINFRA.AUDIT_TRAIL CI;

--Para usar en la EM API
--instancias de un composite generadas en un rango horario
SELECT TO_char(CPST_INST_CREATED_TIME, 'YYYY-MM-DD HH24:MI:SS') from PROD_SOAINFRA.CUBE_INSTANCE where COMPOSITE_NAME = 'INT_038_ELL_CMM_ASSET_MOD_BAS' 
and TO_char(CPST_INST_CREATED_TIME, 'YYYY-MM-DD HH24:MI:SS')>'2017-05-17 14:00:00' 
--and TO_char(CPST_INST_CREATED_TIME, 'YYYY-MM-DD HH24:MM:SS')<'2017-05-17 16:00:00' 
ORDER BY CPST_INST_CREATED_TIME desc;
--where CMPST_ID in(SELECT ID from FOF_SOAINFRA.SCA_ENTITY where COMPOSITE like 'INT_038%');
--where COMPONENT_NAME like 'INT_038%';

--Composite definition y particion
SELECT se.ID,se.label,par.NAME,se.composite,se.name activity,se.type,se.revision from PROD_SOAINFRA.SCA_ENTITY se,PROD_SOAINFRA.SCA_PARTITION par
where par.ID=se.SCA_PARTITION_ID
and composite like 'INT_104%'
and type='composite'
and state='active';


-- Flujos instanciados. Uno por cada flow id
select sfi.flow_id
,      sfi.flow_correlation_id
,      sfi.ecid
,      sfi.composite_sca_entity_id
,      sfi.title
,      sfi.active_component_instances
,      sfi.recoverable_faults
,      sfi.created_time
,      sfi.updated_time
from  PROD_SOAINFRA.sca_flow_instance sfi
 WHERE sfi.FLOW_ID = 3295958 
order by sfi.created_time;

-- Actividades y human activities cerradas o abiertas
select wft.instanceid
,      wft.processname
,      wft.accesskey
,      wft.createddate
,      wft.updateddate
,      wft.componentname
,      wft.compositename
,      wft.conversationid
,      wft.componenttype
,      wft.activityname
,      wft.activityid
,      wft.component_instance_id
,      wft.state
from   PROD_SOAINFRA.wftask wft
where  wft.flow_id = 3034147
order by wft.updateddate;


--Definicion de BPMs
select bcp.domainname
,      bcp.compositename
,      bcp.revision
,      bcp.processname
,      bcp.processid
,      bcp.scalabel
,      bcp.compositedn
,      bcp.creationdate
,      bcp.undeploydate
,      bcp.migrationstatus
from  PROD_SOAINFRA.bpm_cube_process bcp
where  1=1
--and bcp.compositename = 'FlowState'
order by bcp.processname
,        bcp.creationdate;



-- Flujos instanciados. Uno por cada flow id
select sfi.flow_id
,      sfi.flow_correlation_id
,      sfi.ecid
,      sfi.composite_sca_entity_id
,      sfi.title
,      sfi.active_component_instances
,      sfi.recoverable_faults
,      sfi.created_time
,      sfi.updated_time;
select *
from  PROD_SOAINFRA.sca_flow_instance sfi
 --WHERE sfi.FLOW_ID = 807309 
order by sfi.created_time;

select composite from PROD_SOAINFRA.SCA_ENTITY
where id=20049;

SELECT COMPOSITE_NAME,
( CASE WHEN STATE=0 THEN 'STATE_INITIATED'
WHEN STATE=1 THEN 'STATE_OPEN_RECOVERY'
WHEN STATE=2 THEN 'STATE_OPEN_SUSPENDED'
WHEN STATE=3 THEN 'STATE_OPEN_FAULTED'
WHEN STATE=4 THEN 'STATE_CLOSED_PENDING_CANCEL'
WHEN STATE=5 THEN 'STATE_CLOSED_COMPLETED'
WHEN STATE=6 THEN 'STATE_CLOSED_FAULTED'
WHEN STATE=7 THEN 'STATE_CLOSED_CANCELLED'
WHEN STATE=8 THEN 'STATE_CLOSED_ABORTED'
WHEN STATE=9 THEN 'STATE_CLOSED_STALE'
WHEN STATE=10 THEN 'STATE_CLOSED_ROLLED_BACK'
ELSE NULL
END) AS STATE,
COUNT(*)
FROM PROD_SOAINFRA.CUBE_INSTANCE
WHERE 1 = 1
--AND NVL(UPPER(PARENT_ID),'PADRE') NOT LIKE 'BPEL%'
AND CREATION_DATE > SYSDATE - 100
GROUP BY COMPOSITE_NAME, STATE
ORDER BY COMPOSITE_NAME;



--------------------------------------------------------------------------------
-- Cuadro de mando
SELECT 
BPI.COMPOSITE_NAME
--, SFI.FLOW_ID
,(CASE
WHEN BPI.COMPOSITE_NAME='INT_031_CMM_ELL_PPI_CRE_BAS' THEN 'PPI Changes received from Field Reach'
WHEN BPI.COMPOSITE_NAME='DWFEmailNotification' THEN 'Email notifications'
WHEN BPI.COMPOSITE_NAME='DWFModifyEventProcessor' THEN 'Changes from SAP PI'
WHEN BPI.COMPOSITE_NAME='ERROR_RESUBMISSION_BES' THEN 'Resubmissions performed'
WHEN BPI.COMPOSITE_NAME='INT_024_CMM_ELL_WORKORDERFIXED_CRE_BAS' THEN 'Fixed WO created'
WHEN BPI.COMPOSITE_NAME='INT_025_CMM_ELL_WORKORDERNOTFIXED_CRE_BAS' THEN 'Non Fixed WO created'
WHEN BPI.COMPOSITE_NAME='INT_026_CMM_ELL_WORKORDERDEFECT_MOD_BAS' THEN 'Defect WO modified'
WHEN BPI.COMPOSITE_NAME='INT_027_CMM_ELL_WORKORDERFAULT_MOD_BAS' THEN 'Fault WO modified'
WHEN BPI.COMPOSITE_NAME='INT_029_CMM_ELL_CONDITIONMEASUREMENT_CRE_BES' THEN 'Condition Monitoring Requests Received from FR'
WHEN BPI.COMPOSITE_NAME='INT_032_ELL_CMM_EMPLOYEE_CRE_BES' THEN 'Employee created'
WHEN BPI.COMPOSITE_NAME='INT_033_ELL_CMM_EMPLOYEE_MOD_BES' THEN 'Employee modified (1st tail)'
WHEN BPI.COMPOSITE_NAME='INT_037_ELL_CMM_ASSET_CRE_BAS' THEN 'Asset Created'
WHEN BPI.COMPOSITE_NAME='INT_038_ELL_CMM_ASSET_MOD_BAS' THEN 'Asset Modified'
WHEN BPI.COMPOSITE_NAME='INT_039_ELL_CMM_ASSET_DEL_BAS' THEN 'Asset Deleted'
WHEN BPI.COMPOSITE_NAME='INT_043_ELL_CMM_WORKREQUEST_MOD_BAS' THEN 'Work Request Modified'
WHEN BPI.COMPOSITE_NAME='INT_048_ELL_CMM_TABLEREFDATA_CRE_MOD_DEL_BES' THEN 'Changes in Ref Codes received'
WHEN BPI.COMPOSITE_NAME='INT_049_ELL_FUSION_EMPRESOURCE_CRE_BAS' THEN 'Employee modified (2nd tail)'
WHEN BPI.COMPOSITE_NAME='INT_050_ELL_CMM_ABSENCE_CRE_BAS' THEN 'Files received with Employee absence creations'
WHEN BPI.COMPOSITE_NAME='INT_060_CMM_ELL_CATALOGUEITEM_MOD_BES' THEN 'Catalogue modifications (not price)'
WHEN BPI.COMPOSITE_NAME='INT_064_ELL_CMM_REQ_MOD_BAS' THEN 'Work order tasks materials requirements sent to SAP PI'
WHEN BPI.COMPOSITE_NAME='INT_066_CMM_ELL_REQ_MOD_BAS' THEN 'Materials purchase orders or stock issues'
WHEN BPI.COMPOSITE_NAME='INT_072_FUS_CMM_REQUESTOR_BAS' THEN 'Creation and Modifications of Gas Grantor'
WHEN BPI.COMPOSITE_NAME='INT_077_TOG_CMM_SHUTDOWN_MOD_BES' THEN 'Files received from TOGA'
WHEN BPI.COMPOSITE_NAME='INT_082_ELL_WORKORDER_MOD_BAS' THEN 'Work Orders Modifications '
WHEN BPI.COMPOSITE_NAME='INT_083_CMM_WORKORDER_MOD_BAS' THEN 'Work Orders modifications sent to Uptime'
WHEN BPI.COMPOSITE_NAME='INT_085_UPT_CMM_WOSTATUS_MOD_BAS' THEN 'Work Order updates from Uptime'
WHEN BPI.COMPOSITE_NAME='INT_104_EAG_CMM_WORKORDER_CRE_BAS' THEN 'Fixed and non Fixed WO sent from Eagles'
WHEN BPI.COMPOSITE_NAME='INT_106_SRP_CMM_WORKORDER_CRE_BAS' THEN 'Non Fixed WO created (Sightings from SRP)'
WHEN BPI.COMPOSITE_NAME='INT_107_SRP_CMM_WORKORDER_CRE_BAS' THEN 'Non Fixed WO created (Vantage Points from SRP)'
WHEN BPI.COMPOSITE_NAME='INT_109_CONDITION_MONITORING_CREATION_BAS' THEN 'Condition Monitoring Files received'
WHEN BPI.COMPOSITE_NAME='INT_109_GENERIC_EMAIL_BAS' THEN 'emails sent from MyCalendar'
WHEN BPI.COMPOSITE_NAME='INT_116_ELL_CMM_WORKPACK_MOD_BAS' THEN 'Work Packs created'
WHEN BPI.COMPOSITE_NAME='INT_168_FR_ELL_ASSET_PHOTO_BAS' THEN 'Asset Photo received'
WHEN BPI.COMPOSITE_NAME='WorkPackEventProcessor' THEN 'Work Flows started'
END) AS DESCRIPTION
, BPI.STATE_TEXT
, COUNT (*)
FROM PROD_SOAINFRA.BPEL_PROCESS_INSTANCES BPI
, PROD_SOAINFRA.SCA_FLOW_INSTANCE SFI
WHERE 1 = 1
AND BPI.CONVERSATION_ID = SFI.CONVERSATION_ID
AND BPI.STATE_TEXT = 'closed.completed'
AND BPI.COMPOSITE_NAME IN (
'INT_031_CMM_ELL_PPI_CRE_BAS',
'DWFEmailNotification',
'DWFModifyEventProcessor',
'ERROR_RESUBMISSION_BES',
'INT_024_CMM_ELL_WORKORDERFIXED_CRE_BAS',
'INT_025_CMM_ELL_WORKORDERNOTFIXED_CRE_BAS',
'INT_026_CMM_ELL_WORKORDERDEFECT_MOD_BAS',
'INT_027_CMM_ELL_WORKORDERFAULT_MOD_BAS',
'INT_029_CMM_ELL_CONDITIONMEASUREMENT_CRE_BES',
'INT_032_ELL_CMM_EMPLOYEE_CRE_BES',
'INT_033_ELL_CMM_EMPLOYEE_MOD_BES',
'INT_037_ELL_CMM_ASSET_CRE_BAS',
'INT_038_ELL_CMM_ASSET_MOD_BAS',
'INT_039_ELL_CMM_ASSET_DEL_BAS',
'INT_043_ELL_CMM_WORKREQUEST_MOD_BAS',
'INT_048_ELL_CMM_TABLEREFDATA_CRE_MOD_DEL_BES',
'INT_049_ELL_FUSION_EMPRESOURCE_CRE_BAS',
'INT_050_ELL_CMM_ABSENCE_CRE_BAS',
'INT_060_CMM_ELL_CATALOGUEITEM_MOD_BES',
'INT_064_ELL_CMM_REQ_MOD_BAS',
'INT_066_CMM_ELL_REQ_MOD_BAS',
'INT_072_FUS_CMM_REQUESTOR_BAS',
'INT_077_TOG_CMM_SHUTDOWN_MOD_BES',
'INT_082_ELL_WORKORDER_MOD_BAS',
'INT_083_CMM_WORKORDER_MOD_BAS',
'INT_085_UPT_CMM_WOSTATUS_MOD_BAS',
'INT_104_EAG_CMM_WORKORDER_CRE_BAS',
'INT_106_SRP_CMM_WORKORDER_CRE_BAS',
'INT_107_SRP_CMM_WORKORDER_CRE_BAS',
'INT_109_CONDITION_MONITORING_CREATION_BAS',
'INT_109_GENERIC_EMAIL_BAS',
'INT_116_ELL_CMM_WORKPACK_MOD_BAS',
'INT_168_FR_ELL_ASSET_PHOTO_BAS',
'WorkPackEventProcessor')
AND BPI.CREATION_DATE > TO_DATE('28/05/2017 00:00:00','dd/mm/yyyy hh24:mi:ss')
GROUP BY BPI.COMPOSITE_NAME, BPI.STATE_TEXT
ORDER BY BPI.COMPOSITE_NAME;