-- ####################################################
--
-- ICD10 patient encounters
drop    table if exists catalog__icd10_cohort_category;

create  table       catalog__icd10_cohort_category as
select  distinct
        tree.CUI1,
        tree.CUI2,
        tree.CODE as icd10_category,
        concat('(', tree.CODE, ') ', tree.STR) as icd10_category_display,
        cohort.CODE as icd10_code,
        cohort.class_code,
        cohort.servicetype_display,
        cohort.age_at_visit,
        cohort.gender,
        cohort.race_display,
        cohort.ethnicity_display,
        cohort.subject_ref,
        cohort.encounter_ref
from    catalog__icd10_cohort as cohort,
        UMLS.catalog__icd10_category as tree
where   starts_with(cohort.CODE, tree.CODE);

-- ####################################################
--
-- group by CUBE patient demographics
create  or replace view catalog__icd10_cohort_category_cube_patient as
with powerset as
(
    select  count(distinct subject_ref) as cnt,
            icd10_category_display,
            age_at_visit,
            gender,
            race_display,
            ethnicity_display
    from    catalog__icd10_cohort_category
    group by CUBE(icd10_category_display, age_at_visit, gender, race_display, ethnicity_display)
)
select * from powerset where cnt >= 10;

-- ####################################################
--
-- group by CUBE encounter setting
create  or replace view catalog__icd10_cohort_category_cube_encounter as
with powerset as
(
    select  count(distinct ICD10.encounter_ref) as cnt,
            icd10_category_display,
            class_code, servicetype_display
    from    catalog__icd10_cohort_category as ICD10
    group by CUBE(icd10_category_display, class_code, servicetype_display)
)
select * from powerset where cnt >= 10;