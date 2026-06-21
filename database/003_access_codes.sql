
-- Grocery2U v1.3.2 Access Code System
create table if not exists access_codes (
 id bigserial primary key,
 code varchar(20) unique not null,
 campaign_name text,
 max_family integer default 50,
 used_count integer default 0,
 status varchar(20) default 'active',
 created_at timestamptz default now()
);
