drop    table if exists rxnorm.medrt_tree_leaf;
create  table           rxnorm.medrt_tree_leaf AS
select  distinct
        R.CUI1,
        R.CODE1,
        R.TTY1,
        R.CUI2,
        R.SAB2,
        R.CODE2,
        R.TTY2,
        cui_rxcui.RXCUI as RXCUI2,
        label.str as STR_parent
from    rxnorm.medrt_drugs      as R,
        rxnorm.medrt_rxcui      as cui_rxcui,
        rxnorm.medrt_code_str   as label
where   SAB1 = 'MED-RT'
and     R.CUI1 = label.CUI
and     R.CUI2 = cui_rxcui.CUI;

-- ####################################################
--
-- group by CUBE patient demographics
create  or replace view catalog__rx_cohort_leaf_cube_patient as
with powerset as
(
    select  count(distinct subject_ref) as cnt,
            STR_parent,
            age_at_visit,
            gender,
            race_display,
            ethnicity_display
    from    catalog__rx_cohort
    group by CUBE(STR_parent, age_at_visit, gender, race_display, ethnicity_display)
)
select * from powerset where cnt >= 10;

-- ####################################################
--
-- group by CUBE encounter setting
create  or replace view catalog__icd10_cohort_block_cube_encounter as
with powerset as
(
    select  count(distinct encounter_ref) as cnt,
            icd10_block_display,
            class_code, servicetype_display
    from    catalog__icd10_cohort_block
    group by CUBE(icd10_block_display, class_code, servicetype_display)
)
select * from powerset where cnt >= 10;