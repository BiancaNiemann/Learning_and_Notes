create sequence SEQ_AUTHOR_UID
    start = 1
    increment = 1
    ORDER
    comment = 'Use this to fill AUTHOR_UID';

//See how the nextval function works
select seq_author_uid.nextval;

show sequences;

select seq_author_uid.nextval, seq_author_uid.nextval ;

create or replace sequence library_card_catalog.public.seq_author_uid
start = 3 
increment = 1 
ORDER
comment = 'Use this to fill in the AUTHOR_UID every time you add a row';

//Add the remaining author records and use the nextval function instead 
//of putting in the numbers
insert into author(author_uid,first_name, middle_name, last_name) 
values
(seq_author_uid.nextval, 'Laura', 'K','Egendorf')
,(seq_author_uid.nextval, 'Jan', '','Grover')
,(seq_author_uid.nextval, 'Jennifer', '','Clapp')
,(seq_author_uid.nextval, 'Kathleen', '','Petelinsek');
