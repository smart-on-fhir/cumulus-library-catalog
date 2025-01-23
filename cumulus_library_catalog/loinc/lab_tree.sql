-- Attributes ##################################################################

drop    table if exists catalog.MRSAT_loinc;
create  table           catalog.MRSAT_loinc as
select  *
from    umls.MRSAT
where   SAB = 'LNC';

drop    table if exists catalog.MRSAT_loinc_panel;
create  table           catalog.MRSAT_loinc_panel as
select  *
from    catalog.MRSAT_loinc
where   ATN = 'PANEL_TYPE' and ATV='Panel';

drop    table if exists catalog.MRSAT_loinc_part;
create  table           catalog.MRSAT_loinc_part as
select  *
from    catalog.MRSAT_loinc
where   ATN = 'PART_TYPE' and ATV in ('COMPONENT', 'CLASS');

drop    table if exists catalog.MRSAT_loinc_component;
create  table           catalog.MRSAT_loinc_component as
select  *
from    catalog.MRSAT_loinc
where   ATN = 'LOINC_COMPONENT';

drop    table if exists catalog.MRSAT_loinc_consumer;
create  table           catalog.MRSAT_loinc_consumer as
select  *
from    catalog.MRSAT_loinc
where   ATN = 'CONSUMER_NAME';

drop    table if exists catalog.MRSAT_loinc_

-- LOINC Group ##################################################################
select distinct
    groupid as loinc_group_id,
    loincnumber as loinc_child_code
from "loinc_groups"."group_loinc_terms"
where category = 'Flowsheet - laboratory';

-- Concepts ##################################################################

drop   table if exists   catalog.MRCONSO_loinc;
create table             catalog.MRCONSO_loinc AS
select distinct C.*
from    umls.MRCONSO as C
where   C.SAB in ('LNC');

drop    table if exists catalog.MRCONSO_loinc_lab;
create  table           catalog.MRCONSO_loinc_lab as
select  distinct C.*
from    catalog.MRCONSO_loinc C,
        catalog.MRSAT_loinc A
where   A.ATN = 'LCN'
and     A.ATV='1'
and     C.CODE=A.CODE;

-- Preferred Terms ###########################################################

drop    table if exists catalog.loinc_pref_term;
create  table           catalog.loinc_pref_term as
select  distinct CUI,CODE,TTY,STR
from    catalog.MRCONSO_loinc_lab
where   TTY='DN';

-- Hierarchy #################################################################

drop    table if exists catalog.MRREL_loinc;
create  table           catalog.MRREL_loinc as
select  *
from    umls.MRREL
where   SAB = 'LNC'
AND     REL IN ('CHD', 'RN')
OR      RELA IN ('has_aggregation_view', 'has_class', 'has_component', 'has_parent_group', 'measures');

drop    table if exists catalog.MRREL_loinc_part;
create  table           catalog.MRREL_loinc_part as
select  R.*
from    catalog.MRREL_loinc as R,
        catalog.MRSAT_loinc_part as P
where   R.CUI1 = P.CUI;

drop    table if exists catalog.MRREL_loinc_panel;
create  table           catalog.MRREL_loinc_panel as
select  R.*
from    catalog.MRREL_loinc as R,
        catalog.MRSAT_loinc_panel as P
where   R.CUI1 = P.CUI;

drop    table if exists catalog.MRREL_loinc_component;
create  table           catalog.MRREL_loinc_component as
select  R.*
from    catalog.MRREL_loinc as R,
        catalog.MRSAT_loinc_component as C
where   R.CUI1 = C.CUI;
