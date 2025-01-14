--  ###################################################################
-- High level view of TTTY and unique strings for `medrt_drugs`
--  Count unique Strings for each TTY type

select
    count(distinct medrt_drugs.cui2)   as cnt_cui2,
    count(distinct lower(medrt_drugs.str2))   as cnt_str2,
    tty2,
    umls_tty2.tty_str as tty_str2
from    medrt_drugs,
        umls.tty_description as umls_tty2
where   medrt_drugs.sab = 'MED-RT'
and     medrt_drugs.tty2 = umls_tty2.tty
group by    tty2,
            umls_tty2.tty_str
order by cnt_cui2  desc;


--  ###################################################################
-- with CUI1 relationships, count TTY/strings for `medrt_drugs`

select
    count(distinct medrt_drugs.cui1)    as cnt_cui1,
    count(distinct medrt_drugs.cui2)    as cnt_cui2,
    count(distinct lower(medrt_drugs.str1))   as cnt_str1,
    count(distinct lower(medrt_drugs.str2))   as cnt_str2,
    tty1, tty2,
    umls_tty1.tty_str as tty_str1,
    umls_tty2.tty_str as tty_str2
from    medrt_drugs,
        umls.tty_description as umls_tty1,
        umls.tty_description as umls_tty2
where   medrt_drugs.tty1 = umls_tty1.tty
and     medrt_drugs.tty2 = umls_tty2.tty
and     medrt_drugs.sab = 'MED-RT'
group by    tty1,
            tty2,
            umls_tty1.tty_str,
            umls_tty2.tty_str
order by cnt_str1 desc, cnt_str2  desc;

--  ###################################################################
--  Every "leaf" node in the MEDRT hierarchy.

drop    table if exists medrt_drugs_leaf;
create table            medrt_drugs_leaf    AS
select  concat(str1, ': ', str2) as medrt_path,
        length(str1) as str1_len,
        length(str2) as str2_len,
        *
from    medrt_drugs
where   str1 not like '%Preparations%'
and     str1 not like '%Amino Acid%'
and     CUI2    not in
        (select distinct CUI1 from medrt_drugs)
order by CUI1, CUI2, str1_len desc, str2_len desc;

--  ###################################################################
--  Keywords are Ingredient, Brand/generic names, and "active substance"

create table    medrt_drugs_keywords    AS
with            keywords_common         AS
(
    select medrt_drugs.*,
        length(str1) as str1_len,
        length(str2) as str2_len
    from medrt_drugs
    where tty2 in (
        'IN', 'PIN',    -- ingredients
        'GN', 'BN',     -- brand/generic name
        'SU')           -- active substance
),
keywords_filtered AS
(
    select *,
            replace(replace(replace(lower(str2), 'drugs'), 'drug'), ',') as keyword
    from    keywords_common
    where   str2_len >=7
    and     str1 not like '%Preparations%'
    and     str1 not like '%Amino Acid%'
    -- and     str1 not like '%Allergenic Extract%'
)
select * from keywords_filtered order by cui1, keyword;

--  ###################################################################
--  Use GPT4 to create synonym keyword list?


What are the medications  associated with the drug class
"Cellular Death Alteration , Decreased Cellular Death".

Your output is a JSON dictionary with {key:value}  pairs
{"ingredient":  [list of ingredients]}
{"generic": [list of generic names]}
{"brand": [list of brand names] }

--  * PE (Physiologic Effects)
--    https://uts.nlm.nih.gov/uts/umls/concept/C1372798

--  ** Organ System Specific Effects
--  https://uts.nlm.nih.gov/uts/umls/concept/C1372766

-- **** Immunologic Activity Alteration
-- https://uts.nlm.nih.gov/uts/umls/concept/C1372077

-- **** Metabolic Activity Alteration
-- https://uts.nlm.nih.gov/uts/umls/concept/C1372744



--    Cardiovascular Activity Alteration
--    Dermatologic Activity Alteration
--    Digestive/GI System Activity Alteration
--    Endocrine Activity Alteration
--    Hemic/Lymphatic Activity Alteration
--    Musculoskeletal Activity Alteration
--    Nervous System Activity Alteration
--    Renal/Urological Activity Alteration
--    Reproductive System Activity Alteration
--    Respiratory/Pulmonary Activity Alteration
--    Special Sensory Systems Activity Alteration


