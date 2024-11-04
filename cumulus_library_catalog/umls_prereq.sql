    drop   table if exists   catalog.MRCONSO_drugs;
    create table             catalog.MRCONSO_drugs AS
    select distinct C.*
    from    umls.MRCONSO as C
    where   C.SAB in ('MED-RT',
    'ATC','CVX','DRUGBANK','GS','MMSL','MMX','MTHCMSFRF', 'MTHSPL','NDDF','RXNORM','SNOMEDCT_US','USP','VANDF');

--    call utf8_unicode('umls.MRCONSO_drugs');
--    call create_index('umls.MRCONSO_drugs', 'CUI');
--    call create_index('umls.MRCONSO_drugs', 'CODE,SAB');
--    call create_index('umls.MRCONSO_drugs', 'CODE,SAB,TTY');

    drop    table if exists catalog.mrrel_is_a;
    create  table           catalog.mrrel_is_a AS
     select * from umls.MRREL
     WHERE REL = 'CHD'
     OR   RELA in ('isa','tradename_of','has_tradename','has_basis_of_strength_substance')
    ;
    delete from umls.mrrel_is_a where REL in ('RB', 'PAR');

--    call utf8_unicode('umls.mrrel_is_a');
--    call create_index('umls.mrrel_is_a', 'CUI1');
--    call create_index('umls.mrrel_is_a', 'CUI2');
--    call create_index('umls.mrrel_is_a', 'SAB');

    drop   table if exists   catalog.MRCONSO_loinc;
    create table             catalog.MRCONSO_loinc AS
    select distinct C.*
    from    umls.MRCONSO as C
    where   C.SAB in ('LNC');

