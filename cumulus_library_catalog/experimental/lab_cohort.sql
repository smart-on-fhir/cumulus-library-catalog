--    select count(*) cnt, "system", display from
--    -- core__observation_dn_interpretation
--    -- core__observation_component_interpretation
--    -- core__observation_component_valuecodeableconcept
--    core__observation_component_valuequantity
--    group by "system", display  order by cnt

-- ####################################################
drop    table if exists catalog.loinc_cohort;

create  table           catalog.loinc_cohort as
select  distinct
        pref.code    as loinc_code,
        pref.tty     as loinc_tty,
        pref.str     as loinc_str,
        concat(pref.code, ' : ', pref.str) as loinc_display,
--        valuecodeableconcept_code,
--        valuecodeableconcept_system,
--        valuecodeableconcept_display,
--        effectivedatetime_day,
--        effectivedatetime_week,
--        effectivedatetime_month,
--        effectivedatetime_year,
        subject_ref,
        encounter_ref,
        observation_ref
from    core__observation_lab   as lab,
        catalog.loinc_pref_term as pref
where   observation_system = 'http://loinc.org'
and     lab.observation_code = pref.code;

create  or replace view catalog.loinc_cohort_code_cube_patient as
with powerset as
(
    select  count(distinct C.subject_ref) as cnt,
            loinc_display,
            gender,
            race_display,
            ethnicity_display
    from    catalog.loinc_cohort as C,
            core__patient as P
    where   C.subject_ref = P.subject_ref
    group by CUBE(loinc_display, gender, race_display, ethnicity_display)
)
select * from powerset where cnt >= 10;

create  or replace view catalog.loinc_cohort_code_cube_encounter as
with powerset as
(
    select  count(distinct C.subject_ref) as cnt,
            loinc_display,
            class_code, servicetype_display
    from    catalog.loinc_cohort as C,
            core__encounter as E
    where   E.encounter_ref = C.encounter_ref
    group by CUBE(loinc_display, class_code, servicetype_display)
)
select * from powerset where cnt >= 10;