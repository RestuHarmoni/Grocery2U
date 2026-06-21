-- Grocery2U by RH v1.3.3
-- Access Code / Referral Code system untuk follower campaign.
-- Format kod: RH-A7K9X2
-- 1 kod boleh digunakan sehingga max_family family. Default: 50 family.

create extension if not exists pgcrypto;

create table if not exists access_codes (
  id uuid primary key default gen_random_uuid(),
  code text unique not null check (code ~ '^RH-[A-Z0-9]{6}$'),
  campaign_name text not null default 'RH Follower Campaign',
  max_family int not null default 50 check (max_family > 0 and max_family <= 500),
  used_count int not null default 0 check (used_count >= 0),
  status text not null default 'active' check (status in ('active','disabled','expired')),
  created_by_admin_id uuid references admin_users(id),
  created_at timestamptz default now(),
  expires_at timestamptz
);

create table if not exists access_code_uses (
  id uuid primary key default gen_random_uuid(),
  access_code_id uuid not null references access_codes(id) on delete cascade,
  user_id uuid references app_users(id),
  family_id uuid references families(id),
  username text,
  used_at timestamptz default now()
);

create index if not exists idx_access_codes_code on access_codes(code);
create index if not exists idx_access_codes_status on access_codes(status);
create index if not exists idx_access_code_uses_code_id on access_code_uses(access_code_id);

alter table app_users
  add column if not exists access_code_id uuid references access_codes(id),
  add column if not exists access_code text;

-- Semak kod semasa register. 1 kod boleh register sehingga max_family family/user registrations.
-- Cara guna dari trusted backend / Edge Function:
-- select grocery2u_use_access_code('RH-A7K9X2', 'username_baru', 'user_uuid', null);
create or replace function grocery2u_use_access_code(
  p_code text,
  p_username text,
  p_user_id uuid,
  p_family_id uuid default null
)
returns uuid as $$
declare
  v_code_id uuid;
  v_max_family int;
  v_used_count int;
begin
  select id, max_family, used_count
  into v_code_id, v_max_family, v_used_count
  from access_codes
  where upper(code) = upper(trim(p_code))
    and status = 'active'
    and (expires_at is null or expires_at > now())
  for update;

  if v_code_id is null then
    raise exception 'Access code tidak sah atau tidak aktif';
  end if;

  if v_used_count >= v_max_family then
    raise exception 'Access code telah mencapai had penggunaan';
  end if;

  update access_codes
  set used_count = used_count + 1
  where id = v_code_id;

  insert into access_code_uses(access_code_id, user_id, family_id, username)
  values(v_code_id, p_user_id, p_family_id, lower(trim(p_username)));

  update app_users
  set access_code_id = v_code_id,
      access_code = upper(trim(p_code))
  where id = p_user_id;

  return v_code_id;
end;
$$ language plpgsql security definer;

create or replace view admin_access_code_monitor as
select
  c.id,
  c.code,
  c.campaign_name,
  c.max_family,
  c.used_count,
  greatest(c.max_family - c.used_count, 0) as remaining_family,
  c.status,
  c.created_at,
  c.expires_at,
  round(case when c.max_family = 0 then 0 else (c.used_count::numeric / c.max_family::numeric) * 100 end, 2) as usage_percent
from access_codes c
order by c.created_at desc;

-- Nota:
-- Generate kod di Admin Page: RH-XXXXXX.
-- Jangan expose service_role key ke browser.
