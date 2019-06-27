select distinct en.composite from FOF_SOAINFRA.SCA_FLOW_INSTANCE fi, FOF_SOAINFRA.SCA_ENTITY en
where fi.COMPOSITE_SCA_ENTITY_ID=en.ID;

select * from FOF_SOAINFRA.CUBE_INSTANCE ci where 
 ci.FLOW_ID = 807310 ;
 select * from FOF_SOAINFRA.SCA_COMMON_FAULT sca where 
 sca.FLOW_ID = 807309 ;



SELECT CIKEY setComponentInstanceId, CMPST_ID setCompositeInstanceId,ecid setECID from FOF_SOAINFRA.CUBE_INSTANCE
WHERE FLOW_ID='790025';


SELECT * from FOF_SOAINFRA.CUBE_INSTANCE
WHERE FLOW_ID='790025';


--Composite definition y particion
SELECT se.ID,se.label,par.NAME,se.composite,se.name activity,se.type,se.revision from FOF_SOAINFRA.SCA_ENTITY se,FOF_SOAINFRA.SCA_PARTITION par
where par.ID=se.SCA_PARTITION_ID
and composite like 'INT_038%'
--and type='composite'
and state='active';

select distinct flow_id from FOF_SOAINFRA.CUBE_INSTANCE where ecid='426ab9bd-4cca-41e3-8591-953503095994-0346e696';

--instancias de un composite generadas en un rango horario
SELECT TO_char(CPST_INST_CREATED_TIME, 'YYYY-MM-DD HH24:MI:SS') from FOF_SOAINFRA.CUBE_INSTANCE where COMPOSITE_NAME = 'INT_038_ELL_CMM_ASSET_MOD_BAS' 
and TO_char(CPST_INST_CREATED_TIME, 'YYYY-MM-DD HH24:MI:SS')>'2017-05-17 14:00:00' 
--and TO_char(CPST_INST_CREATED_TIME, 'YYYY-MM-DD HH:MM:SS')<'2017-05-17 16:00:00' 
ORDER BY CPST_INST_CREATED_TIME desc;
--where CMPST_ID in(SELECT ID from FOF_SOAINFRA.SCA_ENTITY where COMPOSITE like 'INT_038%');
--where COMPONENT_NAME like 'INT_038%';


--Mensajes 
select CONV_ID,MESSAGE_GUID,COMPOSITE_NAME,COMPONENT_NAME,COMPONENT_TYPE,PARTNER_LINK,OPERATION_NAME,
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
from FOF_SOAINFRA.dlv_message
where 
--flow_id='1760785'
flow_id='806180'
order by RECEIVE_DATE;


--Listado de documentos
select xml.DOC_PARTITION_DATE ,dlv.composite_name COMPOSITE_NAME, dlv.flow_id FLOW_ID,xml.document_type, xml.DOCUMENT, xml.DOCUMENT_ID  from
FOF_SOAINFRA.xml_document xml,
FOF_SOAINFRA.document_dlv_msg_ref dlv_ref,
FOF_SOAINFRA.dlv_message dlv
where 1=1
--xml.DOC_PARTITION_DATE > sysdate - 6
and xml.document_id = dlv_ref.document_id
and dlv.message_guid = dlv_ref.MESSAGE_GUID
and dlv.flow_id = '790025'
--and composite_name='INT_038_ELL_CMM_ASSET_MOD_BAS'
--and xml.document_id='f056f9fa-388f-11e7-a623-ea95d879b90a'
order by xml.DOC_PARTITION_DATE ;


--Listado de documentos
select xml.DOC_PARTITION_DATE ,dlv.composite_name COMPOSITE_NAME, dlv.flow_id FLOW_ID,xml.document_type, xml.DOCUMENT, xml.DOCUMENT_ID, dlv_ref.MESSAGE_GUID MESSAGE_GUID  from
FOF_SOAINFRA.xml_document xml,
FOF_SOAINFRA.document_dlv_msg_ref dlv_ref,
FOF_SOAINFRA.dlv_message dlv
where 1=1
--xml.DOC_PARTITION_DATE > sysdate - 6
and xml.document_id = dlv_ref.document_id
and dlv.message_guid = dlv_ref.MESSAGE_GUID
--and dlv.flow_id = '790025'
and dlv_ref.MESSAGE_GUID='e31ce1a3-3b07-11e7-b44e-0e5db3dd8b0a'
order by xml.DOC_PARTITION_DATE ;



-- Cuadro de mando
SELECT COMPOSITE,
STATUS,
COUNT(*)
FROM ( SELECT
SE.COMPOSITE,
(CASE WHEN SFI.ACTIVE_COMPONENT_INSTANCES = 0 AND SFI.UNHANDLED_FAULTS = 0 AND SFI.RECOVERABLE_FAULTS = 0 THEN 'OK'
ELSE 'FAILED'
END) AS STATUS
FROM FOF_SOAINFRA.SCA_FLOW_INSTANCE SFI,
FOF_SOAINFRA.SCA_ENTITY SE
WHERE 1 = 1
AND SFI.COMPOSITE_SCA_ENTITY_ID = SE.ID
AND SFI.CREATED_TIME > SYSDATE - 15
AND SE.COMPOSITE IN (
--ADD HERE THE INTERFACES TO MONITOR
)
) 
GROUP BY COMPOSITE, STATUS
ORDER BY COMPOSITE, STATUS;

