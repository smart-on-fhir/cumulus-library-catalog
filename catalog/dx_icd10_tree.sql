-- https://www.nlm.nih.gov/research/umls/sourcereleasedocs/current/ICD10CM/stats.html

drop    table if exists MRCONSO__icd10cm;
create  table           MRCONSO__icd10cm as
select * from MRCONSO where SAB='ICD10CM';

call create_index('MRREL__icd10cm', 'CUI1');
call create_index('MRREL__icd10cm', 'CUI2');

drop    table if exists MRREL__icd10cm;
create  table           MRREL__icd10cm as
select * from MRREL where SAB='ICD10CM';

select REL, RELA, count(distinct CUI1) cnt_cui from MRREL__icd10cm  group by REL, RELA ;
--    +-----+------+---------+
--    | REL | RELA | cnt_cui |
--    +-----+------+---------+
--    | CHD | NULL |   22829 |
--    | PAR | NULL |   95019 |
--    | RQ  | NULL |   18141 |
--    +-----+------+---------+

-- ########## ICD10 Chapter "Diseases of the Circulatory System (I00–I99)"

create or replace view catalog__icd10_chapter as
select  distinct R.*, C.CUI, C.TTY, C.CODE, C.STR
from    MRREL__icd10cm R,
        MRCONSO__icd10cm C
where   C.TTY in ('HT', 'PT')
and     R.CUI1!=R.CUI2
and     R.CUI1='C2880081'
and     R.CUI2=C.CUI
order by C.CODE asc;

select CUI1, CUI2, CODE, STR from catalog__icd10_chapter where TTY = 'PT';
--    +----------+----------+-------+-----------------------------------------------------------+
--    | CUI1     | CUI2     | CODE  | STR                                                       |
--    +----------+----------+-------+-----------------------------------------------------------+
--    | C2880081 | C1314803 | H57.9 | Unspecified disorder of eye and adnexa                    |
--    | C2880081 | C0728936 | I99.9 | Unspecified disorder of circulatory system                |
--    | C2880081 | C0035204 | J98.9 | Respiratory disorder, unspecified                         |
--    | C2880081 | C0178298 | L98.9 | Disorder of the skin and subcutaneous tissue, unspecified |
--    +----------+----------+-------+-----------------------------------------------------------+

-- ########## ICD10 BLOCK "Hypertensive Diseases (I10–I16)"

create or replace view catalog__icd10_block as
select  distinct R.*, C.CUI, C.TTY, C.CODE, C.STR
from    MRREL__icd10cm R,
        MRCONSO__icd10cm C,
        catalog__icd10_chapter PAR
where   C.TTY in ('HT', 'PT')
and     R.REL='CHD'
and     R.CUI1!=R.CUI2
and     R.CUI1=PAR.CUI
and     R.CUI2=C.CUI
order by C.CODE asc;

select CUI1, CUI2, TTY, CODE, STR from catalog__icd10_block where TTY = 'PT';

select TTY, count(distinct CUI1) cnt_cui, count(distinct code) cnt_code from catalog__icd10_block group by TTY ;

--    select REL, count(distinct CUI1) cnt_cui, count(distinct code) cnt_code from catalog__icd10_block group by REL ;
--    +-----+---------+----------+
--    | REL | cnt_cui | cnt_code |
--    +-----+---------+----------+
--    | CHD |      22 |      402 |
--    | PAR |      22 |        8 |
--    | RQ  |       5 |        8 |
--    +-----+---------+----------+

--    select STYPE1, STYPE2, TTY, count(distinct CUI1) cnt_cui, count(distinct code) cnt_code from catalog__icd10_block group by STYPE1, STYPE2, TTY ;
--    +--------+--------+---------+----------+
--    | STYPE1 | STYPE2 | cnt_cui | cnt_code |
--    +--------+--------+---------+----------+
--    | AUI    | SDUI   |       1 |        3 |
--    | SDUI   | AUI    |       4 |        5 |
--    | SDUI   | SDUI   |      22 |      405 |
--    +--------+--------+---------+----------+

-- ########## ICD10 category "Hypertensive heart disease I11 "

create or replace view catalog__icd10_category as
select  distinct R.*, C.CUI, C.TTY, C.CODE, C.STR
from    MRREL__icd10cm R,
        MRCONSO__icd10cm C,
        catalog__icd10_block PAR
where   C.TTY in ('HT', 'PT')
and     R.REL = 'CHD'
and     R.CUI1!=R.CUI2
and     R.CUI1 = PAR.CUI
and     R.CUI2 = C.CUI
order by C.CODE asc;

select TTY, count(distinct CUI1) cnt_cui, count(distinct code) cnt_code from catalog__icd10_block group by TTY ;

select * from catalog__icd10_category where CODE like 'I1%';

--  select REL, count(distinct CUI1) cnt_cui, count(distinct code) cnt_code from catalog__icd10_category group by REL ;
--    +-----+---------+----------+
--    | REL | cnt_cui | cnt_code |
--    +-----+---------+----------+
--    | CHD |     288 |     2940 |
--    | PAR |     300 |      174 |
--    | RQ  |      72 |      101 |
--    +-----+---------+----------+

-- ########## ICD10 code "Hypertensive heart and chronic kidney disease without heart failure (I13.1)"
create or replace view catalog__icd10_code as
select  distinct R.*, C.CUI, C.TTY, C.CODE, C.STR
from    MRREL__icd10cm R,
        MRCONSO__icd10cm C,
        catalog__icd10_category PAR
where   True
and     R.REL = 'CHD'
and     R.CUI1!=R.CUI2
and     R.CUI1 = PAR.CUI
and     R.CUI2 = C.CUI
order by C.CODE asc;

select TTY, count(distinct CUI1) cnt_cui, count(distinct code) cnt_code from catalog__icd10_code group by TTY ;

select CUI1, CUI2, TTY, CODE, STR from catalog__icd10_code where TTY = 'HT' and CODE like 'I10%';

-- ########## ICD10 code precise code (2 digit level of precision)
create or replace view catalog__icd10_code2 as
select  distinct R.*, C.CUI, C.TTY, C.CODE, C.STR
from    MRREL__icd10cm R,
        MRCONSO__icd10cm C,
        catalog__icd10_code PAR
where   True
and     R.REL = 'CHD'
and     R.CUI1!=R.CUI2
and     R.CUI1 = PAR.CUI
and     R.CUI2 = C.CUI
order by C.CODE asc;

select TTY, count(distinct CUI1) cnt_cui, count(distinct code) cnt_code from catalog__icd10_code2 group by TTY ;

select CUI1, CUI2, TTY, CODE, STR from catalog__icd10_code2 where TTY = 'HT' and CODE like 'I10%';
