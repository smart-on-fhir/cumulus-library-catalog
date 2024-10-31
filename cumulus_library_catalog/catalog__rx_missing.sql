select distinct RXCUI from RXNCONSO
where SAB='RXNORM'
and RXCUI=CODE
and RXCUI not in (select distinct RXCUI2 from RXNREL);

--    select count(distinct RXCUI) from RXNCONSO where SAB='RXNORM' and RXCUI=CODE;
--    +-----------------------+
--    | count(distinct RXCUI) |
--    +-----------------------+
--    |                222392 |
--    +-----------------------+

--    select count(distinct RXCUI) from RXNCONSO where SAB='RXNORM' and RXCUI=CODE and RXCUI not in
--    ((select distinct RXCUI2 from RXNREL) UNION (select distinct RXCUI1 from RXNREL));
--    +-----------------------+
--    | count(distinct RXCUI) |
--    +-----------------------+
--    |                  9172 |
--    +-----------------------+

-- ### about 4% (9172/222392) of RXCUI have no REL,RELA relationships

