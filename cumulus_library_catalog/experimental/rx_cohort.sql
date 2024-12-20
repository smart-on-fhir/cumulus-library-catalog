-- ####################################################
drop    table if exists catalog.rx_cohort;

create  table           catalog.rx_cohort as
with RX as
(
    select  distinct
            category_display,
            medication_code,
            medication_display,
            subject_ref,
            encounter_ref
    from    core__medicationrequest
    where   medication_system = 'http://www.nlm.nih.gov/research/umls/rxnorm'
)
select  distinct
        tree.CUI1,
        tree.CUI2,
        tree.RXCUI2,
        RX.medication_code,
        RX.medication_display,
        P.gender,
        P.race_display,
        P.ethnicity_display,
        E.age_at_visit,
        E.class_code,
        E.servicetype_display,
        RX.subject_ref,
        RX.encounter_ref,
        tree.medrt_display
from    RX,
        core__encounter as E,
        core__patient   as P,
        catalog.rx_tree_rxnorm as tree
where   RX.medication_code = tree.CODE2
and     RX.encounter_ref = E.encounter_ref
and     RX.subject_ref = P.subject_ref;



