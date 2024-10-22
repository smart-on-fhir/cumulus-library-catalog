-- https://www.nlm.nih.gov/research/umls/sourcereleasedocs/current/ICD10CM/stats.html

drop    table if exists MRREL__icd10cm;
drop    table if exists MRCONSO__icd10cm;
drop    table if exists catalog__icd10_tree;
drop    view  if exists catalog__icd10_chapter;
drop    view  if exists catalog__icd10_block;
drop    view  if exists catalog__icd10_category;
drop    view  if exists catalog__icd10_code5;
drop    view  if exists catalog__icd10_code6;
drop    view  if exists catalog__icd10_code7;
drop    view  if exists catalog__icd10_code8;

drop    table if exists MRCONSO__icd10cm;
create  table           MRCONSO__icd10cm
select  *, length(CODE) as CODE_len from MRCONSO C where SAB='ICD10CM';

call create_index('MRCONSO__icd10cm', 'CUI');

drop    table if exists MRREL__icd10cm;
create  table           MRREL__icd10cm as
select * from MRREL where SAB='ICD10CM';

call create_index('MRREL__icd10cm', 'CUI1');
call create_index('MRREL__icd10cm', 'CUI2');

select REL, RELA, count(distinct CUI1) cnt_cui from MRREL__icd10cm  group by REL, RELA ;
--    +-----+------+---------+
--    | REL | RELA | cnt_cui |
--    +-----+------+---------+
--    | CHD | NULL |   22829 |
--    | PAR | NULL |   95019 |
--    | RQ  | NULL |   18141 |
--    +-----+------+---------+

-- ########## ICD10 Chapter N00-N99 | Diseases of the genitourinary system (N00-N99)

create or replace view catalog__icd10_chapter as
select  distinct R.*, C.CUI, C.TTY, C.CODE_len, C.CODE, C.STR
from    MRREL__icd10cm R,
        MRCONSO__icd10cm C
where   C.TTY  in ('HT')
and     C.CODE like '%-%'
and     R.CUI1='C2880081'
and     R.CUI2=C.CUI
order by C.CODE asc;

select CUI1, TTY, CUI2, CODE, STR from catalog__icd10_chapter where CODE like 'N%';
--    +----------+-----+----------+---------+------------------------------------------------+
--    | CUI1     | TTY | CUI2     | CODE    | STR                                            |
--    +----------+-----+----------+---------+------------------------------------------------+
--    | C2880081 | HT  | C0080276 | N00-N99 | Diseases of the genitourinary system (N00-N99) |
--    +----------+-----+----------+---------+------------------------------------------------+


--    select CUI1, CUI2, CODE, STR from catalog__icd10_chapter where TTY = 'PT';
--    +----------+----------+-------+-----------------------------------------------------------+
--    | CUI1     | CUI2     | CODE  | STR                                                       |
--    +----------+----------+-------+-----------------------------------------------------------+
--    | C2880081 | C1314803 | H57.9 | Unspecified disorder of eye and adnexa                    |
--    | C2880081 | C0728936 | I99.9 | Unspecified disorder of circulatory system                |
--    | C2880081 | C0035204 | J98.9 | Respiratory disorder, unspecified                         |
--    | C2880081 | C0178298 | L98.9 | Disorder of the skin and subcutaneous tissue, unspecified |
--    +----------+----------+-------+-----------------------------------------------------------+

-- ########## ICD10 BLOCK N10-N16 | Renal tubulo-interstitial diseases (N10-N16)

create or replace view catalog__icd10_block as
select  distinct R.*, C.CUI, C.TTY, C.CODE_len, C.CODE, C.STR
from    MRREL__icd10cm R,
        MRCONSO__icd10cm C,
        catalog__icd10_chapter PAR
where   C.TTY in ('HT')
and     R.REL='CHD'
and     C.CODE like '%-%' -- or C.CODE_len = 3)
and     R.CUI1=PAR.CUI
and     R.CUI2=C.CUI
order by C.CODE asc;

select CUI1, TTY, CUI2, CODE, STR from catalog__icd10_block where CODE like 'N%';

--    +----------+-----+----------+---------+-----------------------------------------------------------------------------------------------------------------------+
--    | CUI1     | TTY | CUI2     | CODE    | STR                                                                                                                   |
--    +----------+-----+----------+---------+-----------------------------------------------------------------------------------------------------------------------+
--    | C0080276 | HT  | C0268731 | N00-N08 | Glomerular diseases (N00-N08)                                                                                         |
--    | C0080276 | HT  | C0041349 | N10-N16 | Renal tubulo-interstitial diseases (N10-N16)                                                                          |
--    | C0080276 | HT  | C2902950 | N17-N19 | Acute kidney failure and chronic kidney disease (N17-N19)                                                             |
--    | C0080276 | HT  | C0451641 | N20-N23 | Urolithiasis (N20-N23)                                                                                                |
--    | C0080276 | HT  | C0156258 | N25-N29 | Other disorders of kidney and ureter (N25-N29)                                                                        |
--    | C0080276 | HT  | C0178288 | N30-N39 | Other diseases of the urinary system (N30-N39)                                                                        |
--    | C0080276 | HT  | C0178288 | N39     | Other disorders of urinary system                                                                                     |
--    | C0080276 | HT  | C2977265 | N40-N53 | Diseases of male genital organs (N40-N53)                                                                             |
--    | C0080276 | HT  | C0006145 | N60-N65 | Disorders of breast (N60-N65)                                                                                         |
--    | C0080276 | HT  | C0242172 | N70-N77 | Inflammatory diseases of female pelvic organs (N70-N77)                                                               |
--    | C0080276 | HT  | C0269150 | N80-N98 | Noninflammatory disorders of female genital tract (N80-N98)                                                           |
--    | C0080276 | HT  | C2903153 | N99     | Intraoperative and postprocedural complications and disorders of genitourinary system, not elsewhere classified       |
--    | C0080276 | HT  | C2903153 | N99-N99 | Intraoperative and postprocedural complications and disorders of genitourinary system, not elsewhere classified (N99) |
--    +----------+-----+----------+---------+-----------------------------------------------------------------------------------------------------------------------+


--    select TTY, STYPE1, STYPE2, count(*) cnt from catalog__icd10_block group by TTY, STYPE1, STYPE2;
--    select CUI1, TTY, CUI2, CODE, STR from catalog__icd10_block where TTY = 'HT';
--    select CUI1, TTY, CUI2, CODE, STR from catalog__icd10_block where TTY = 'PT';
--    select TTY, count(distinct CUI1) cnt_cui, count(distinct code) cnt_code from catalog__icd10_block group by TTY ;

--        select REL, count(distinct CUI1) cnt_cui, count(distinct code) cnt_code from catalog__icd10_block group by REL ;
--        +-----+---------+----------+
--        | REL | cnt_cui | cnt_code |
--        +-----+---------+----------+
--        | CHD |      22 |      402 |
--        | PAR |      22 |        8 |
--        | RQ  |       5 |        8 |
--        +-----+---------+----------+
--
--        select STYPE1, STYPE2, TTY, count(distinct CUI1) cnt_cui, count(distinct code) cnt_code from catalog__icd10_block group by STYPE1, STYPE2, TTY ;
--        +--------+--------+---------+----------+
--        | STYPE1 | STYPE2 | cnt_cui | cnt_code |
--        +--------+--------+---------+----------+
--        | AUI    | SDUI   |       1 |        3 |
--        | SDUI   | AUI    |       4 |        5 |
--        | SDUI   | SDUI   |      22 |      405 |
--        +--------+--------+---------+----------+
--
--     ########## ICD10 category N13  | Obstructive and reflux uropathy
--
    create or replace view catalog__icd10_category as
    select  distinct R.*, C.CUI, C.TTY, C.CODE_len, C.CODE, C.STR
    from    MRREL__icd10cm R,
            MRCONSO__icd10cm C,
            catalog__icd10_block PAR
    where   C.TTY in ('HT', 'PT')
    and     C.CODE_len = 3
    and     R.REL = 'CHD'
    and     R.CUI1 = PAR.CUI
    and     R.CUI2 = C.CUI
    order by C.CODE asc;

select CUI1, TTY, CUI2, CODE, STR from catalog__icd10_category where CODE like 'N1%';
--    +----------+-----+----------+------+--------------------------------------------------------------------------+
--    | CUI1     | TTY | CUI2     | CODE | STR                                                                      |
--    +----------+-----+----------+------+--------------------------------------------------------------------------+
--    | C0041349 | PT  | C0520575 | N10  | Acute pyelonephritis                                                     |
--    | C0041349 | HT  | C0238304 | N11  | Chronic tubulo-interstitial nephritis                                    |
--    | C0041349 | PT  | C0477743 | N12  | Tubulo-interstitial nephritis, not specified as acute or chronic         |
--    | C0041349 | HT  | C0477732 | N13  | Obstructive and reflux uropathy                                          |
--    | C0041349 | HT  | C0451754 | N14  | Drug- and heavy-metal-induced tubulo-interstitial and tubular conditions |
--    | C0041349 | HT  | C0495054 | N15  | Other renal tubulo-interstitial diseases                                 |
--    | C0041349 | PT  | C0451749 | N16  | Renal tubulo-interstitial disorders in diseases classified elsewhere     |
--    | C2902950 | HT  | C0022660 | N17  | Acute kidney failure                                                     |
--    | C2902950 | HT  | C1561643 | N18  | Chronic kidney disease (CKD)                                             |
--    | C2902950 | PT  | C0035078 | N19  | Unspecified kidney failure                                               |
--    +----------+-----+----------+------+--------------------------------------------------------------------------+

--    select TTY, count(distinct CUI1) cnt_cui, count(distinct code) cnt_code from catalog__icd10_category group by TTY ;
--
--      select REL, count(distinct CUI1) cnt_cui, count(distinct code) cnt_code from catalog__icd10_category group by REL ;
--        +-----+---------+----------+
--        | REL | cnt_cui | cnt_code |
--        +-----+---------+----------+
--        | CHD |     288 |     2940 |
--        | PAR |     300 |      174 |
--        | RQ  |      72 |      101 |
--        +-----+---------+----------+
--
--  ########## ICD10 code N13.7 | Vesicoureteral-reflux
    create or replace view catalog__icd10_code5 as
    select  distinct R.*, C.CUI, C.TTY, C.CODE_len, C.CODE, C.STR
    from    MRREL__icd10cm R,
            MRCONSO__icd10cm C,
            catalog__icd10_category PAR
    where   C.TTY in ('HT', 'PT')
    and     C.CODE like '%.%'
    and     (C.CODE_len = 5 or C.CODE like '%.%X%') -- Sequella
    and     R.REL = 'CHD'
    and     R.CUI1 = PAR.CUI
    and     R.CUI2 = C.CUI
    order by C.CODE asc;

    select CUI1, TTY, CUI2, CODE, STR from catalog__icd10_code5 where CODE like 'N1%';

--    +----------+-----+----------+-------+-----------------------------------------------------------------------------+
--    | CUI1     | TTY | CUI2     | CODE  | STR                                                                         |
--    +----------+-----+----------+-------+-----------------------------------------------------------------------------+
--    | C0238304 | PT  | C0451718 | N11.0 | Nonobstructive reflux-associated chronic pyelonephritis                     |
--    | C0238304 | PT  | C0403389 | N11.1 | Chronic obstructive pyelonephritis                                          |
--    | C0238304 | PT  | C0477729 | N11.8 | Other chronic tubulo-interstitial nephritis                                 |
--    | C0238304 | PT  | C0238304 | N11.9 | Chronic tubulo-interstitial nephritis, unspecified                          |
--    | C0477732 | PT  | C0495049 | N13.0 | Hydronephrosis with ureteropelvic junction obstruction                      |
--    | C0477732 | PT  | C0869069 | N13.1 | Hydronephrosis with ureteral stricture, not elsewhere classified            |
--    | C0477732 | PT  | C0451770 | N13.2 | Hydronephrosis with renal and ureteral calculous obstruction                |
--    | C0477732 | HT  | C0477730 | N13.3 | Other and unspecified hydronephrosis                                        |
--    | C0477732 | PT  | C0521620 | N13.4 | Hydroureter                                                                 |
--    | C0477732 | PT  | C2902939 | N13.5 | Crossing vessel and stricture of ureter without hydronephrosis              |
--    | C0477732 | PT  | C0034216 | N13.6 | Pyonephrosis                                                                |
--    | C0477732 | HT  | C0042580 | N13.7 | Vesicoureteral-reflux                                                       |
--    | C0477732 | PT  | C0477731 | N13.8 | Other obstructive and reflux uropathy                                       |
--    | C0477732 | PT  | C0477732 | N13.9 | Obstructive and reflux uropathy, unspecified                                |
--    | C0451754 | PT  | C0149938 | N14.0 | Analgesic nephropathy                                                       |
--    | C0451754 | HT  | C0451767 | N14.1 | Nephropathy induced by other drugs, medicaments and biological substances   |
--    | C0451754 | PT  | C0495053 | N14.2 | Nephropathy induced by unspecified drug, medicament or biological substance |
--    | C0451754 | PT  | C0451769 | N14.3 | Nephropathy induced by heavy metals                                         |
--    | C0451754 | PT  | C0869068 | N14.4 | Toxic nephropathy, not elsewhere classified                                 |
--    | C0495054 | PT  | C0004698 | N15.0 | Balkan nephropathy                                                          |
--    | C0495054 | PT  | C0156253 | N15.1 | Renal and perinephric abscess                                               |
--    | C0495054 | PT  | C0477735 | N15.8 | Other specified renal tubulo-interstitial diseases                          |
--    | C0495054 | PT  | C0041349 | N15.9 | Renal tubulo-interstitial disease, unspecified                              |
--    | C0022660 | PT  | C2902951 | N17.0 | Acute kidney failure with tubular necrosis                                  |
--    | C0022660 | PT  | C2902952 | N17.1 | Acute kidney failure with acute cortical necrosis                           |
--    | C0022660 | PT  | C0574786 | N17.2 | Acute kidney failure with medullary necrosis                                |
--    | C0022660 | PT  | C0477745 | N17.8 | Other acute kidney failure                                                  |
--    | C0022660 | PT  | C0022660 | N17.9 | Acute kidney failure, unspecified                                           |
--    | C1561643 | PT  | C2316401 | N18.1 | Chronic kidney disease, stage 1                                             |
--    | C1561643 | PT  | C1561639 | N18.2 | Chronic kidney disease, stage 2 (mild)                                      |
--    | C1561643 | HT  | C1561640 | N18.3 | Chronic kidney disease, stage 3 (moderate)                                  |
--    | C1561643 | PT  | C1561641 | N18.4 | Chronic kidney disease, stage 4 (severe)                                    |
--    | C1561643 | PT  | C2316810 | N18.5 | Chronic kidney disease, stage 5                                             |
--    | C1561643 | PT  | C2316810 | N18.5 | Chronic kidney disease, stage 5                                             |
--    | C1561643 | PT  | C2316810 | N18.6 | End stage renal disease                                                     |
--    | C1561643 | PT  | C2316810 | N18.6 | End stage renal disease                                                     |
--    | C1561643 | PT  | C1561643 | N18.9 | Chronic kidney disease, unspecified                                         |
--    +----------+-----+----------+-------+-----------------------------------------------------------------------------+


--  ########## ICD10 code N13.72 | Vesicoureteral-reflux with reflux nephropathy without hydroureter
    create or replace view catalog__icd10_code6 as
    select  distinct R.*, C.CUI, C.TTY, C.CODE_len, C.CODE, C.STR
    from    MRREL__icd10cm R,
            MRCONSO__icd10cm C,
            catalog__icd10_code5 PAR
    where   C.TTY in ('HT', 'PT')
    and     C.CODE like '%.%'
    and     (C.CODE_len = 6 or C.CODE like '%.%X%') -- Sequella
    and     R.REL = 'CHD'
    and     R.CUI1 = PAR.CUI
    and     R.CUI2 = C.CUI
    order by C.CODE asc;

    select STYPE1, STYPE2, CUI1, TTY, CUI2, CODE, STR from catalog__icd10_code6 where CODE like 'N1%';

--    +--------+--------+----------+-----+----------+--------+---------------------------------------------------------------------------+
--    | STYPE1 | STYPE2 | CUI1     | TTY | CUI2     | CODE   | STR                                                                       |
--    +--------+--------+----------+-----+----------+--------+---------------------------------------------------------------------------+
--    | SDUI   | SDUI   | C0477730 | PT  | C0020295 | N13.30 | Unspecified hydronephrosis                                                |
--    | SDUI   | SDUI   | C0477730 | PT  | C2902938 | N13.39 | Other hydronephrosis                                                      |
--    | SDUI   | SDUI   | C0042580 | PT  | C0042580 | N13.70 | Vesicoureteral-reflux, unspecified                                        |
--    | SDUI   | SDUI   | C0477732 | PT  | C0042580 | N13.70 | Vesicoureteral-reflux, unspecified                                        |
--    | SDUI   | SDUI   | C0042580 | PT  | C2902942 | N13.71 | Vesicoureteral-reflux without reflux nephropathy                          |
--    | SDUI   | SDUI   | C0042580 | HT  | C2902945 | N13.72 | Vesicoureteral-reflux with reflux nephropathy without hydroureter         |
--    | SDUI   | SDUI   | C0042580 | HT  | C2902948 | N13.73 | Vesicoureteral-reflux with reflux nephropathy with hydroureter            |
--    | SDUI   | SDUI   | C0451767 | PT  | C4055183 | N14.11 | Contrast-induced nephropathy                                              |
--    | SDUI   | SDUI   | C0451767 | PT  | C0451767 | N14.19 | Nephropathy induced by other drugs, medicaments and biological substances |
--    | SDUI   | SDUI   | C1561640 | PT  | C5384800 | N18.30 | Chronic kidney disease, stage 3 unspecified                               |
--    | SDUI   | SDUI   | C1561640 | PT  | C3839533 | N18.31 | Chronic kidney disease, stage 3a                                          |
--    | SDUI   | SDUI   | C1561640 | PT  | C3839870 | N18.32 | Chronic kidney disease, stage 3b                                          |
--    +--------+--------+----------+-----+----------+--------+---------------------------------------------------------------------------+


--  ########## ICD10 code N13.721 | Vesicoureteral-reflux with reflux nephropathy without hydroureter, unilateral
    create or replace view catalog__icd10_code7 as
    select  distinct R.*, C.CUI, C.TTY, C.CODE_len, C.CODE, C.STR
    from    MRREL__icd10cm R,
            MRCONSO__icd10cm C,
            catalog__icd10_code6 PAR
    where   C.TTY in ('HT', 'PT')
    and     C.CODE like '%.%'
    and     (C.CODE_len = 7 or C.CODE like '%.%X%') -- Sequella
    and     C.CODE like '%.%'
    and     R.REL = 'CHD'
    and     R.CUI1 = PAR.CUI
    and     R.CUI2 = C.CUI
    order by C.CODE asc;

    select CUI1, TTY, CUI2, CODE, STR from catalog__icd10_code7 where CODE like 'N1%';
--    +----------+-----+----------+---------+--------------------------------------------------------------------------------+
--    | CUI1     | TTY | CUI2     | CODE    | STR                                                                            |
--    +----------+-----+----------+---------+--------------------------------------------------------------------------------+
--    | C2902945 | PT  | C2902943 | N13.721 | Vesicoureteral-reflux with reflux nephropathy without hydroureter, unilateral  |
--    | C2902945 | PT  | C2902944 | N13.722 | Vesicoureteral-reflux with reflux nephropathy without hydroureter, bilateral   |
--    | C0042580 | PT  | C2902945 | N13.729 | Vesicoureteral-reflux with reflux nephropathy without hydroureter, unspecified |
--    | C2902945 | PT  | C2902945 | N13.729 | Vesicoureteral-reflux with reflux nephropathy without hydroureter, unspecified |
--    | C2902948 | PT  | C2902946 | N13.731 | Vesicoureteral-reflux with reflux nephropathy with hydroureter, unilateral     |
--    | C2902948 | PT  | C2902947 | N13.732 | Vesicoureteral-reflux with reflux nephropathy with hydroureter, bilateral      |
--    | C0042580 | PT  | C2902948 | N13.739 | Vesicoureteral-reflux with reflux nephropathy with hydroureter, unspecified    |
--    | C2902948 | PT  | C2902948 | N13.739 | Vesicoureteral-reflux with reflux nephropathy with hydroureter, unspecified    |
--    +----------+-----+----------+---------+--------------------------------------------------------------------------------+


--  ########## ICD10 code E13.3513 | specified diabetes mellitus with proliferative diabetic retinopathy with macular edema, bilateral
    create or replace view catalog__icd10_code8 as
    select  distinct R.*, C.CUI, C.TTY, C.CODE_len, C.CODE, C.STR
    from    MRREL__icd10cm R,
            MRCONSO__icd10cm C,
            catalog__icd10_code7 PAR
    where   C.TTY in ('HT', 'PT')
    and     C.CODE like '%.%'
    and     (C.CODE_len = 8 or C.CODE like '%.%X%') -- Sequella
    and     C.CODE like '%.%'
    and     R.REL = 'CHD'
    and     R.CUI1 = PAR.CUI
    and     R.CUI2 = C.CUI
    order by C.CODE asc;

    select CUI1, TTY, CUI2, CODE, STR from catalog__icd10_code8 where CODE like 'E13.351%';
--    +----------+-----+----------+----------+---------------------------------------------------------------------------------------------------------------+
--    | CUI1     | TTY | CUI2     | CODE     | STR                                                                                                           |
--    +----------+-----+----------+----------+---------------------------------------------------------------------------------------------------------------+
--    | C2874148 | PT  | C4268149 | E13.3511 | Other specified diabetes mellitus with proliferative diabetic retinopathy with macular edema, right eye       |
--    | C2874148 | PT  | C4268150 | E13.3512 | Other specified diabetes mellitus with proliferative diabetic retinopathy with macular edema, left eye        |
--    | C2874148 | PT  | C4268151 | E13.3513 | Other specified diabetes mellitus with proliferative diabetic retinopathy with macular edema, bilateral       |
--    | C2874148 | PT  | C4268152 | E13.3519 | Other specified diabetes mellitus with proliferative diabetic retinopathy with macular edema, unspecified eye |
--    +----------+-----+----------+----------+---------------------------------------------------------------------------------------------------------------+


--    --  ########## ICD10 code (no matches)
--    create or replace view catalog__icd10_code9 as
--    select  distinct R.*, C.CUI, C.TTY, C.CODE, C.STR
--    from    MRREL__icd10cm R,
--            MRCONSO__icd10cm C,
--            catalog__icd10_code8 PAR
--    where   C.TTY in ('HT', 'PT')
--    and     C.CODE_len = 8
--    and     C.CODE like '%.%'
--    and     R.REL = 'CHD'
--    and     R.CUI1!=R.CUI2
--    and     R.CUI1 = PAR.CUI
--    and     R.CUI2 = C.CUI
--    order by C.CODE asc;
--
--    select STYPE1, STYPE2, CUI1, TTY, CUI2, CODE, STR from catalog__icd10_code9;

drop    table if exists catalog__icd10_tree;
create  table           catalog__icd10_tree
select *, 1 as depth from catalog__icd10_chapter
UNION
select *, 2 as depth from catalog__icd10_block
UNION
select *, 3 as depth from catalog__icd10_category
UNION
select *, 5 as depth from catalog__icd10_code5
UNION
select *, 6 as depth from catalog__icd10_code6
UNION
select *, 7 as depth from catalog__icd10_code7
UNION
select *, 8 as depth from catalog__icd10_code8
;

select      depth, CODE_len,
            REL, STYPE1, STYPE2, TTY,
            count(distinct CODE) cnt_code,
            count(distinct CUI)  cnt_cui
from        catalog__icd10_tree
group by    depth, CODE_len, REL, STYPE1, STYPE2, TTY
order by    depth, CODE_len, REL, STYPE1, STYPE2, TTY;

--    +-------+----------+-----+--------+--------+-----+----------+---------+
--    | depth | CODE_len | REL | STYPE1 | STYPE2 | TTY | cnt_code | cnt_cui |
--    +-------+----------+-----+--------+--------+-----+----------+---------+
--    |     1 |        7 | CHD | SDUI   | SDUI   | HT  |       22 |      22 |
--    |     2 |        3 | CHD | SDUI   | SDUI   | HT  |       27 |      27 |
--    |     2 |        7 | CHD | SDUI   | SDUI   | HT  |      296 |     296 |
--    |     3 |        3 | CHD | SDUI   | SDUI   | HT  |     1701 |    1700 |
--    |     3 |        3 | CHD | SDUI   | SDUI   | PT  |      216 |     216 |
--    |     5 |        5 | CHD | SDUI   | SDUI   | HT  |     4642 |    4638 |
--    |     5 |        5 | CHD | SDUI   | SDUI   | PT  |     5418 |    5396 |
--    |     6 |        6 | CHD | SDUI   | SDUI   | HT  |     7373 |    7365 |
--    |     6 |        6 | CHD | SDUI   | SDUI   | PT  |     6968 |    6964 |
--    |     7 |        7 | CHD | SDUI   | SDUI   | HT  |     9536 |    9535 |
--    |     7 |        7 | CHD | SDUI   | SDUI   | PT  |    10301 |   10295 |
--    |     8 |        8 | CHD | SDUI   | SDUI   | PT  |    40034 |   40034 |
--    +-------+----------+-----+--------+--------+-----+----------+---------+


select      REL, STYPE1, STYPE2, TTY,
            count(distinct CODE) cnt_code,
            count(distinct CUI)  cnt_cui
from        catalog__icd10_tree
group by    REL, STYPE1, STYPE2, TTY
order by    REL, STYPE1, STYPE2, TTY;
--    +-----+--------+--------+-----+----------+---------+
--    | REL | STYPE1 | STYPE2 | TTY | cnt_code | cnt_cui |
--    +-----+--------+--------+-----+----------+---------+
--    | CHD | SDUI   | SDUI   | HT  |    23570 |   22840 |
--    | CHD | SDUI   | SDUI   | PT  |    62937 |   62898 |
--    +-----+--------+--------+-----+----------+---------+

select      REL, STYPE1, STYPE2,
            count(distinct CUI2)  cnt_cui2
from        MRREL__icd10cm
group by    REL, STYPE1, STYPE2
order by    REL, STYPE1, STYPE2;
--    +-----+--------+--------+----------+
--    | REL | STYPE1 | STYPE2 | cnt_cui2 |
--    +-----+--------+--------+----------+
--    | CHD | SDUI   | SDUI   |    95019 |
--    | PAR | SDUI   | SDUI   |    22829 |
--    | RQ  | AUI    | SDUI   |     6968 |
--    | RQ  | SDUI   | AUI    |    12437 |
--    +-----+--------+--------+----------+

drop    table if exists catalog__icd10_missing;
create  table           catalog__icd10_missing
select      distinct TTY, CODE_len, CUI, CODE, STR
from        MRCONSO__icd10cm C
where       C.CUI != 'C2880081' -- root
and         C.CODE not in (select distinct CODE from catalog__icd10_tree)
order by    CODE, TTY;

select * from catalog__icd10_missing where CODE like 'N%' order by CODE_len;

--    source /Users/andy/2024/cumulus-library-catalog/catalog/dx_icd10_tree.sql


