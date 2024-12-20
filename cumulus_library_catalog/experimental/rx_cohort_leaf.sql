
-- ####################################################
--
-- group by CUBE patient demographics
create  or replace view catalog.rx_cohort_leaf_cube_patient as
with powerset as
(
    select  count(distinct subject_ref) as cnt,
            medrt_display,
            age_at_visit,
            gender,
            race_display,
            ethnicity_display
    from    catalog.rx_cohort
    group by CUBE(medrt_display, age_at_visit, gender, race_display, ethnicity_display)
)
select * from powerset where cnt >= 10;

-- ####################################################
--
-- group by CUBE encounter setting
create  or replace view catalog.icd10_cohort_block_cube_encounter as
with powerset as
(
    select  count(distinct encounter_ref) as cnt,
            icd10_block_display,
            class_code, servicetype_display
    from    catalog.icd10_cohort_block
    group by CUBE(icd10_block_display, class_code, servicetype_display)
)
select * from powerset where cnt >= 10;