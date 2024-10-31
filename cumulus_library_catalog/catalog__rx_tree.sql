--    ### Attribute lookups

--    select ATN, count(distinct RXCUI) cnt from RXNSAT group by ATN order by cnt desc;

--    ### Ingredient concepts per vocab

--    select ATN, count(distinct RXCUI) cnt from RXNSAT group by ATN order by cnt desc;

--      RxNorm Term Types (TTY)
--      https://www.nlm.nih.gov/research/umls/rxnorm/docs/appendix5.html

--    select TTY, SAB, count(distinct RXCUI) cnt from RXNCONSO
--    where TTY in ('IN', 'RXN_IN', 'PIN')
--    group by TTY, SAB order by cnt desc;

--    +--------+----------+-------+
--    | TTY    | SAB      | cnt   |
--    +--------+----------+-------+
--    | IN     | NDDF     | 15347 |
--    | IN     | RXNORM   | 14372 |
--    | IN     | DRUGBANK | 10184 |
--    | IN     | VANDF    |  8340 |
--    | IN     | GS       |  6182 |
--    | IN     | ATC      |  4792 |
--    | PIN    | RXNORM   |  3475 |
--    | IN     | MMSL     |  3327 |
--    | IN     | USP      |  2361 |
--    | RXN_IN | ATC      |    61 |
--    +--------+----------+-------+

--    drop    table if exists umls.mrrel_medrt;
--    create  table           umls.mrrel_medrt
--    select  distinct CUI1, CUI2, REL, RELA, STYPE1, STYPE2
--    from    umls.mrrel_is_a
--    where   SAB    = 'MED-RT'
--    and     STYPE1 = 'SCUI'
--    and     STYPE2 = 'SCUI';
--
--    drop    table if exists umls.mrrel_medrt;
--    create  table           umls.mrrel_medrt
--    select  distinct CUI1, CUI2, REL, RELA, STYPE1, STYPE2
--    from    umls.mrrel_is_a
--    where   SAB    = 'MED-RT'
--    and     STYPE1 = 'SCUI'
--    and     STYPE2 = 'SCUI';

--    create table cui_list as select distinct CUI1 as CUI from MRREL where SAB='MED-RT' UNION select distinct CUI2 as CUI from MRREL where SAB='MED-RT';

--    drop table if exists    rxnorm.RXNCONSO_ingredient;
--    create table            rxnorm.RXNCONSO_ingredient
--
--        select distinct TTY, SAB, CODE, length(STR) as str_len, RXCUI, STR
--        from RXNCONSO
--        where TTY in ('IN', 'RXN_IN', 'PIN', 'MIN')
--        order by RXCUI, TTY, SAB;
--
--        select distinct TTY, SAB, CODE, length(STR) as str_len, RXCUI, STR
--        from    umls.mrconso_drugs D,
--                rxnorm.RXNCONSO C,
--                umls.MRREL R,
--        where R.CUI =

--    drop    table if exists rxnorm.medrt_cui;
--    create  table           rxnorm.medrt_cui AS
--    select  distinct
--            tree.CUI,
--            drug.SAB,
--            drug.CODE,
--            drug.TTY
--    from    umls.mrconso_drugs as tree,
--            umls.mrconso_drugs as drug
--    where   tree.SAB = 'MED-RT'
--    and     tree.CUI = drug.CUI;


drop    table if exists rxnorm.medrt_is_a;
create  table           rxnorm.medrt_is_a AS
select  distinct
        R.SAB,
        R.RUI,
        R.REL,
        R.RELA,
        R.CUI1,
        R.CUI2
from    umls.mrrel_is_a    as R
where   STYPE1 = 'SCUI'
and     STYPE2 = 'SCUI'
and     R.SAB in ('MED-RT');
--    'ATC','CVX','DRUGBANK','GS','MMSL','MMX','MTHCMSFRF', 'MTHSPL','NDDF','RXNORM','SNOMEDCT_US','USP','VANDF';

drop    table if exists rxnorm.medrt_drugs;
create  table           rxnorm.medrt_drugs AS
select  distinct
        R.SAB,
        R.RUI,
        R.REL,
        R.RELA,
        R.CUI1,
        C1.SAB      as SAB1,
        C1.CODE     as CODE1,
        C1.TTY      as TTY1,
        R.CUI2,
        C2.SAB      as SAB2,
        C2.CODE     as CODE2,
        C2.TTY      as TTY2
from    rxnorm.medrt_is_a  as R,
        umls.mrconso_drugs as C1,
        umls.mrconso_drugs as C2
where   C1.CODE != 'NOCODE'
and     C2.CODE != 'NOCODE'
and     R.CUI1 = C1.CUI
and     R.CUI2 = C2.CUI;

--    select SAB1, SAB2, count(distinct RUI) cnt from rxnorm.medrt_drugs group by SAB1, SAB2 order by cnt desc

drop    table if exists rxnorm.medrt_cui;
create  table           rxnorm.medrt_cui AS
select  distinct CUI1 as CUI, SAB1 as SAB, CODE1 as CODE, TTY1 as TTY from rxnorm.medrt_drugs
UNION
select  distinct CUI2 as CUI, SAB2 as SAB, CODE2 as CODE, TTY2 as TTY from rxnorm.medrt_drugs;

call create_index('rxnorm.medrt_cui', 'CUI');
call create_index('rxnorm.medrt_cui', 'SAB');
call create_index('rxnorm.medrt_cui', 'CODE');

--    select SAB, count(*) cnt from rxnorm.medrt_cui group by SAB order by cnt desc;
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

drop    table if exists rxnorm.medrt_rxcui;
create  table           rxnorm.medrt_rxcui AS
select  distinct
        M.CUI, C.SAB, C.CODE, C.TTY, C.RXCUI
from    rxnorm.rxnconso     as C,
        rxnorm.medrt_cui    as M
where   C.SAB  = M.SAB
and     C.CODE = M.CODE
and     C.TTY  = M.TTY;

call create_index('rxnorm.medrt_rxcui', 'CUI');
call create_index('rxnorm.medrt_rxcui', 'SAB');
call create_index('rxnorm.medrt_rxcui', 'CODE');
call create_index('rxnorm.medrt_rxcui', 'TTY');

select count(distinct RXCUI), count(distinct CUI) from rxnorm.medrt_rxcui;

drop    table if exists rxnorm.medrt_tree;
create  table           rxnorm.medrt_tree AS
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
from    rxnorm.medrt_drugs  as R,
        rxnorm.medrt_rxcui  as cui_rxcui
where   R.CUI2 = cui_rxcui.CUI;