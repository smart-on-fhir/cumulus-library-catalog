--  ###################################################################
-- High level view of TTTY and unique strings for `medrt_drugs`
--  Count unique Strings for each TTY type

select
    count(distinct medrt_drugs.cui2)   as cnt_cui2,
    count(distinct lower(medrt_drugs.str2))   as cnt_str2,
    tty2,
    umls_tty2.tty_str as tty_str2
from    medrt_drugs,
        umls.tty_description as umls_tty2
where   medrt_drugs.sab = 'MED-RT'
and     medrt_drugs.tty2 = umls_tty2.tty
group by    tty2,
            umls_tty2.tty_str
order by cnt_cui2  desc;


--  ###################################################################
-- with CUI1 relationships, count TTY/strings for `medrt_drugs`

select
    count(distinct medrt_drugs.cui1)    as cnt_cui1,
    count(distinct medrt_drugs.cui2)    as cnt_cui2,
    count(distinct lower(medrt_drugs.str1))   as cnt_str1,
    count(distinct lower(medrt_drugs.str2))   as cnt_str2,
    tty1, tty2,
    umls_tty1.tty_str as tty_str1,
    umls_tty2.tty_str as tty_str2
from    medrt_drugs,
        umls.tty_description as umls_tty1,
        umls.tty_description as umls_tty2
where   medrt_drugs.tty1 = umls_tty1.tty
and     medrt_drugs.tty2 = umls_tty2.tty
and     medrt_drugs.sab = 'MED-RT'
group by    tty1,
            tty2,
            umls_tty1.tty_str,
            umls_tty2.tty_str
order by cnt_str1 desc, cnt_str2  desc;

