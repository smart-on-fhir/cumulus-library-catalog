-- MEDRT ##################################################################
drop    table if exists mrconso_medrt;
create  table           rxcui_current as
select * from rxnorm.RXNCONSO where SAB='RXNORM';

select tty, count(distinct RXCUI) cnt from mrconso_medrt group by tty order by cnt desc;

-- RXNORM ##################################################################

--    select tty, count(distinct RXCUI) cnt from rxnconso group by tty order by cnt desc;

drop    table if exists rxcui_current;
create  table           rxcui_current as
select * from rxnorm.RXNCONSO where SAB='RXNORM';

select tty, count(distinct RXCUI) cnt from rxcui_current group by tty order by cnt desc;

drop    table if exists rxcui_inactive;
create  table           rxcui_inactive as
select distinct RXCUI from rxnorm.rxnconso where RXCUI not in
    (select distinct rxcui from rxnconso where SAB='RXNORM');

drop    table if exists tty_in;
create  table           tty_in as
select * from rxcui_current where TTY='IN';

drop    table if exists tty_bn;
create  table           tty_bn as
select * from rxcui_current where TTY='BN';

drop    table if exists tty_pt;
create  table           tty_pt as
select * from rxcui_current where TTY='PT';

drop    table if exists tty_psn;
create  table           tty_psn as
select * from rxcui_current where TTY='PSN';

select count(distinct tty_pt.rxcui) from tty_pt;
select count(distinct tty_psn.rxcui) from tty_psn;
select count(distinct tty_psn.rxcui) from tty_psn, tty_pt where tty_psn.RXCUI=tty_pt.RXCUI;

drop    table if exists cui_tty_cnt;
create  table           cui_tty_cnt as
select rxcui, count(distinct tty) cnt
from rxcui_current
group by rxcui
order by cnt desc;

drop    table if exists str_cnt;
create  table           str_cnt as
select str, count(distinct tty) cnt_tty, count(distinct rxcui) cnt_rxcui
from rxcui_current
group by str
order by cnt_rxcui desc, cnt_tty desc;

select * from rxnorm.rxnconso where STR='risperidone 357 MG/ML Prefilled Syringe';