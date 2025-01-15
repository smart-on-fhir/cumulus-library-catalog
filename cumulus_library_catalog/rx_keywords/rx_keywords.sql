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
            lower(str2) as keyword
    from    keywords_common
    where   str2_len >=7
    and     str1 not like '%Preparations%'
    and     str1 not like '%Amino Acid%'
    -- and     str1 not like '%Allergenic Extract%'
)
select * from keywords_filtered order by cui1, keyword;

select distinct tty2, str2 as label
from medrt_drugs_keywords
order by tty2, str2


--  ###################################################################
--  Use GPT4 to create synonym keyword list

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


