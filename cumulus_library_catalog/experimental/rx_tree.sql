drop   table if exists   catalog.MRCONSO_drugs;
create table             catalog.MRCONSO_drugs AS
select distinct C.*
from    umls.MRCONSO as C
where   C.SAB in ('MED-RT',
'ATC','CVX','DRUGBANK','GS','MMSL','MMX','MTHCMSFRF', 'MTHSPL','NDDF','RXNORM','SNOMEDCT_US','USP','VANDF');

drop   table if exists   catalog.MRCONSO_medrt;
create table             catalog.MRCONSO_medrt AS
select distinct C.*
from    umls.MRCONSO as C
where   C.SAB in ('MED-RT');

drop    table if exists   catalog.medrt_pref_term;
create  table             catalog.medrt_pref_term AS
select  distinct CUI,CODE,TTY,STR
from    catalog.MRCONSO_medrt
where   TTY='PT'
UNION
select  distinct CUI,CODE,TTY,STR
from    catalog.MRCONSO_medrt
where   TTY='FN'
and     CUI not in
(select distinct CUI from catalog.MRCONSO_medrt where TTY='PT');

drop    table if exists catalog.mrrel_is_a;
create  table           catalog.mrrel_is_a AS
 select * from umls.MRREL
 WHERE  REL = 'CHD'
 OR    (REL not in ('RB', 'PAR')
        AND
        RELA in ('isa','tradename_of','has_tradename','has_basis_of_strength_substance'));

drop    table if exists catalog.medrt_is_a;
create  table           catalog.medrt_is_a AS
select  distinct
        R.SAB,
        R.RUI,
        R.REL,
        R.RELA,
        R.CUI1,
        R.CUI2
from    catalog.mrrel_is_a    as R
where   STYPE1 = 'SCUI'
and     STYPE2 = 'SCUI'
and     R.SAB in ('MED-RT');

drop    table if exists catalog.medrt_drugs;
create  table           catalog.medrt_drugs AS
select  distinct
        R.SAB,
        R.RUI,
        R.REL,
        R.RELA,
        R.CUI1,
        C1.SAB      as SAB1,
        C1.CODE     as CODE1,
        C1.TTY      as TTY1,
        C1.STR      as STR1,
        R.CUI2,
        C2.SAB      as SAB2,
        C2.CODE     as CODE2,
        C2.TTY      as TTY2,
        C2.STR      as STR2
from    catalog.medrt_is_a  as R,
        catalog.mrconso_drugs as C1,
        catalog.mrconso_drugs as C2
where   C1.CODE != 'NOCODE'
and     C2.CODE != 'NOCODE'
and     R.CUI1 = C1.CUI
and     R.CUI2 = C2.CUI
order by R.CUI1, R.CUI2;

drop    table if exists catalog.medrt_cui;
create  table           catalog.medrt_cui AS
select  distinct CUI1 as CUI, SAB1 as SAB, CODE1 as CODE, TTY1 as TTY from catalog.medrt_drugs
UNION
select  distinct CUI2 as CUI, SAB2 as SAB, CODE2 as CODE, TTY2 as TTY from catalog.medrt_drugs;

--    select SAB, count(*) cnt from catalog.medrt_cui group by SAB order by cnt desc;
--    +-------------+-------+
--    | SAB         | cnt   |
--    +-------------+-------+
--    | SNOMEDCT_US | 20720 |
--    | RXNORM      | 19826 |
--    | MTHSPL      | 13539 |
--    | DRUGBANK    |  9309 |
--    | MED-RT      |  7882 |
--    | NDDF        |  7458 |
--    | MMSL        |  7000 |
--    | GS          |  5188 |
--    | VANDF       |  4864 |
--    | ATC         |  3520 |
--    | USP         |  2365 |
--    | CVX         |    48 |
--    | MMX         |     1 |
--    +-------------+-------+

drop    table if exists catalog.medrt_rxcui;
create  table           catalog.medrt_rxcui AS
select  distinct
        M.CUI, C.SAB, C.CODE, C.TTY, C.RXCUI
from    rxnorm.rxnconso     as C,
        catalog.medrt_cui   as M
where   C.SAB  = M.SAB
and     C.CODE = M.CODE
and     C.TTY  = M.TTY;

--    select count(distinct RXCUI), count(distinct CUI) from catalog.medrt_rxcui;

drop    table if exists catalog.rx_tree_medrt;
create  table           catalog.rx_tree_medrt AS
select  distinct
        R.SAB,
        R.RUI,
        R.REL,
        R.RELA,
        R.CUI1,
        R.SAB1,
        R.CODE1,
        R.TTY1,
        R.CUI2,
        R.SAB2,
        R.CODE2,
        R.TTY2,
        cui_rxcui.RXCUI as RXCUI2
from    catalog.medrt_drugs  as R,
        catalog.medrt_rxcui  as cui_rxcui
where   R.CUI2 = cui_rxcui.CUI;


drop    table if exists catalog.rx_tree_rxnorm;
create  table           catalog.rx_tree_rxnorm AS
select  distinct
        R.CUI1,
        R.CODE1,
        R.TTY1,
        R.CUI2,
        R.SAB2,
        R.CODE2,
        R.TTY2,
        cui_rxcui.RXCUI as RXCUI2,
        parent.str as medrt_display
from    catalog.medrt_drugs     as R,
        catalog.medrt_rxcui     as cui_rxcui,
        catalog.medrt_pref_term as parent
where   SAB1 = 'MED-RT'
and     R.CUI1 = parent.CUI
and     R.CUI2 = cui_rxcui.CUI;
