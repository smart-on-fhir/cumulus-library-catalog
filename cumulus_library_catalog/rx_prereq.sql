    drop   table if exists   umls.MRCONSO_drugs;
    create table             umls.MRCONSO_drugs
    select distinct C.*
    from    umls.MRCONSO as C
    where   C.SAB in
    ('ATC','CVX','DRUGBANK','GS','MMSL','MMX','MTHCMSFRF', 'MTHSPL','NDDF','RXNORM','SNOMEDCT_US','USP','VANDF','MED-RT');

    call utf8_unicode('umls.MRCONSO_drugs');
    call create_index('umls.MRCONSO_drugs', 'CUI');
    call create_index('umls.MRCONSO_drugs', 'CODE,SAB');
    call create_index('umls.MRCONSO_drugs', 'CODE,SAB,TTY');


    drop    table if exists umls.mrrel_is_a;
    create  table           umls.mrrel_is_a
     select * from umls.MRREL
     WHERE REL = 'CHD'
     OR   RELA in ('isa','tradename_of','has_tradename','has_basis_of_strength_substance')
    ;
    delete from umls.mrrel_is_a where REL in ('RB', 'PAR');

    call utf8_unicode('umls.mrrel_is_a');
    call create_index('umls.mrrel_is_a', 'CUI1');
    call create_index('umls.mrrel_is_a', 'CUI2');
    call create_index('umls.mrrel_is_a', 'SAB');

    drop   table if exists   rxnorm.medrt_code_str;
    create table             rxnorm.medrt_code_str  AS
    select distinct CUI,CODE,STR from umls.mrconso  where SAB = 'MED-RT';

    drop   table if exists   rxnorm.RXNCONSO_ingredient;
    create table             rxnorm.RXNCONSO_ingredient as
    select distinct
            SAB,
            CODE,
            TTY,
            RXCUI,
            length(STR)                as STR_len,
            substring(STR,1,40)        as STR,
            lower(substring(STR,1,40)) as STR_lower
    from    RXNCONSO
    where   length(STR) > 5
    and     TTY in ('IN', 'PIN', 'RXN_IN');

    call utf8_unicode('rxnorm.RXNCONSO_ingredient');
    call create_index('rxnorm.RXNCONSO_ingredient', 'RXCUI');
    call create_index('rxnorm.RXNCONSO_ingredient', 'TTY');
    call create_index('rxnorm.RXNCONSO_ingredient', 'STR');
    call create_index('rxnorm.RXNCONSO_ingredient', 'STR_lower');
