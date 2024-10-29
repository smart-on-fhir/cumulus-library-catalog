-- ####################################################
-- ICD10 CHAPTER
drop    table if exists catalog__icd10_cohort_chapter_cube_pair;

create  or replace view catalog__icd10_cohort_chapter_cube_pair as
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

-- ####################################################
-- ICD10 Block
drop    table if exists catalog__icd10_cohort_block_cube_pair;

create  or replace view catalog__icd10_cohort_block_cube_pair as
with powerset as
(
    select  count(distinct C1.subject_ref) as cnt,
            C1.icd10_block_display,
            C2.icd10_category_display
    from    catalog__icd10_cohort_block as C1,
            catalog__icd10_cohort_category as C2
    where   C1.subject_ref = C2.subject_ref
    group by CUBE(C1.icd10_block_display, C2.icd10_category_display)
)
select * from powerset where cnt >= 10;

-- ####################################################
-- ICD10 category
drop    table if exists catalog__icd10_cohort_category_cube_pair;

create  or replace view catalog__icd10_cohort_category_cube_pair as
with powerset as
(
    select  count(distinct C1.subject_ref) as cnt,
            C1.icd10_category_display,
            C2.icd10_code_par_display
    from    catalog__icd10_cohort_category as C1,
            catalog__icd10_cohort_code as C2
    where   C1.subject_ref = C2.subject_ref
    group by CUBE(C1.icd10_category_display, C2.icd10_code_par_display)
)
select * from powerset where cnt >= 10;

-- ####################################################
-- ICD10 category
drop    table if exists catalog__icd10_cohort_code_cube_pair;

create  or replace view catalog__icd10_cohort_code_cube_pair as
with powerset as
(
    select  count(distinct C1.subject_ref) as cnt,
            C1.icd10_code_par_display as icd10_code_display1,
            C2.icd10_code_par_display as icd10_code_display2
    from    catalog__icd10_cohort_code as C1,
            catalog__icd10_cohort_code as C2
    where   C1.subject_ref = C2.subject_ref
    group by CUBE(C1.icd10_code_par_display, C2.icd10_code_par_display)
)
select * from powerset where cnt >= 10;
