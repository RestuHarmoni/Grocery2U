-- Grocery2U by RH v1.3.1
-- Access Code / Referral Code system untuk follower campaign.
-- Format kod: RH26-A7K9
-- 1 kod = 1 akaun / 1 family access.

create extension if not exists pgcrypto;

create table if not exists access_code_batches (
  id uuid primary key default gen_random_uuid(),
  batch_name text not null,
  prefix text not null,
  quantity int not null check (quantity > 0),
  source text default 'RH Follower',
  created_by_admin_id uuid references admin_users(id),
  created_at timestamptz default now()
);

create table if not exists access_codes (
  id uuid primary key default gen_random_uuid(),
  batch_id uuid references access_code_batches(id) on delete cascade,
  code text unique not null,
  status text not null default 'available' check (status in ('available','used','expired','disabled')),
  used_by_user_id uuid references app_users(id),
  used_by_username text,
  used_family_id uuid references families(id),
  used_at timestamptz,
  created_at timestamptz default now()
);

create index if not exists idx_access_codes_code on access_codes(code);
create index if not exists idx_access_codes_status on access_codes(status);
create index if not exists idx_access_codes_batch_id on access_codes(batch_id);

alter table app_users
  add column if not exists access_code_id uuid references access_codes(id),
  add column if not exists access_code text;

-- Semak dan lock kod selepas user register.
-- Cara guna dari trusted backend / Edge Function:
-- select grocery2u_use_access_code('RH26-A7K9', 'username_baru', 'user_uuid');
create or replace function grocery2u_use_access_code(
  p_code text,
  p_username text,
  p_user_id uuid
)
returns uuid as $$
declare
  v_code_id uuid;
begin
  select id into v_code_id
  from access_codes
  where upper(code) = upper(trim(p_code))
    and status = 'available'
  for update;

  if v_code_id is null then
    raise exception 'Access code tidak sah atau sudah digunakan';
  end if;

  update access_codes
  set status = 'used',
      used_by_user_id = p_user_id,
      used_by_username = lower(trim(p_username)),
      used_at = now()
  where id = v_code_id;

  update app_users
  set access_code_id = v_code_id,
      access_code = upper(trim(p_code))
  where id = p_user_id;

  return v_code_id;
end;
$$ language plpgsql security definer;

-- View untuk admin monitor conversion kod.
create or replace view admin_access_code_monitor as
select
  b.id as batch_id,
  b.batch_name,
  b.prefix,
  b.quantity,
  b.source,
  b.created_at,
  count(c.id) as total_codes,
  count(c.id) filter (where c.status = 'used') as used_codes,
  count(c.id) filter (where c.status = 'available') as available_codes,
  round(
    case when count(c.id) = 0 then 0
    else (count(c.id) filter (where c.status = 'used')::numeric / count(c.id)::numeric) * 100 end,
    2
  ) as conversion_percent
from access_code_batches b
left join access_codes c on c.batch_id = b.id
group by b.id, b.batch_name, b.prefix, b.quantity, b.source, b.created_at;

-- Nota:
-- Generate kod sebenar boleh dibuat dari Admin Page/Edge Function.
-- Jangan expose service_role key ke browser.
