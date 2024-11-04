-- ####################################################
-- ICD10 CODE
drop    table if exists catalog.icd10_cohort_code;

create  table       catalog.icd10_cohort_code as
select  distinct
        tree.CUI1,
        tree.CUI2,
        tree.code as icd10_code_par,   -- parent
        concat('(', tree.CODE, ') ', tree.STR) as icd10_code_par_display,
        cohort.code as icd10_code_chd,   -- child
        cohort.class_code,
        cohort.servicetype_display,
        cohort.age_at_visit,
        cohort.gender,
        cohort.race_display,
        cohort.ethnicity_display,
        cohort.subject_ref,
        cohort.encounter_ref
from    catalog.icd10_cohort as cohort,
        catalog.icd10_code as tree
where   tree.code_len = 5
and     starts_with(cohort.CODE, tree.CODE);

create  or replace view catalog.icd10_cohort_code_cube_patient as
with powerset as
(
    select  count(distinct subject_ref) as cnt,
            icd10_code_par_display,
            age_at_visit,
            gender,
            race_display,
            ethnicity_display
    from    catalog.icd10_cohort_code
    group by CUBE(icd10_code_par_display, age_at_visit, gender, race_display, ethnicity_display)
)
select * from powerset where cnt >= 10;

create  or replace view catalog.icd10_cohort_code_cube_encounter as
with powerset as
(
    select  count(distinct ICD10.encounter_ref) as cnt,
            icd10_code_par_display,
            class_code, servicetype_display
    from    catalog.icd10_cohort_code as ICD10
    group by CUBE(icd10_code_par_display, class_code, servicetype_display)
)
select * from powerset where cnt >= 10;
