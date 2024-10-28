-- ####################################################
-- ICD10 CODE
drop    table if exists catalog__icd10_cohort_chapter_cube_comorbidity;

create  or replace view catalog__icd10_cohort_chapter_cube_comorbidity as
with powerset as
(
    select  count(distinct C1.subject_ref) as cnt,
            C1.icd10_chapter_display as icd10_chapter_display1,
            C2.icd10_chapter_display as icd10_chapter_display2
    from    catalog__icd10_cohort_chapter as C1,
            catalog__icd10_cohort_chapter as C2
    where   C1.icd10_chapter != C2.icd10_chapter
    and     C1.subject_ref = C2.subject_ref
    group by CUBE(C1.icd10_chapter_display, C2.icd10_chapter_display)
)
select * from powerset where cnt >= 10;
