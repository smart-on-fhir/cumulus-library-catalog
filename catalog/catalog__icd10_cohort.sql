-- Note: these ICD10CM codes have status "deleted"
--    select distinct code, code_display
--    from core__condition
--    where system = 'http://hl7.org/fhir/sid/icd-10-cm'
--    and code not in (select distinct code from UMLS.catalog__icd10_tree)

-- ####################################################
drop    table if exists catalog__icd10_cohort;

create  table           catalog__icd10_cohort as
with ICD10 as
(
    select  distinct
            code,
            code_display,
            subject_ref,
            encounter_ref
    from    core__condition
    where   system = 'http://hl7.org/fhir/sid/icd-10-cm'
)
select  distinct
        tree.CUI1,
        tree.CUI2,
        tree.depth,
        tree.CODE_len,
        ICD10.code,
        ICD10.code_display,
        P.gender,
        P.race_display,
        P.ethnicity_display,
        E.age_at_visit,
        E.class_code,
        E.servicetype_display,
        ICD10.subject_ref,
        ICD10.encounter_ref
from    ICD10,
        core__encounter as E,
        core__patient   as P,
        UMLS.catalog__icd10_tree as tree
where   ICD10.code = tree.CODE
and     ICD10.encounter_ref = E.encounter_ref
and     ICD10.subject_ref = P.subject_ref;



