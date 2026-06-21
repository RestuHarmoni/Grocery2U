-- Grocery2U by RH v1.3.6
-- Access Code / Referral Code system untuk follower campaign.
-- Format kod: RH-A7K9X2
-- 1 kod boleh digunakan sehingga max_family family. Default: 50 family.
-- Safe migration: boleh run walaupun table access_codes lama sudah wujud.

create extension if not exists pgcrypto;

create table if not exists access_codes (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  created_at timestamptz default now()
);

-- Migration guard untuk database yang sudah ada table access_codes versi lama.
alter table access_codes
  add column if not exists campaign_name text not null default 'RH Follower Campaign',
  add column if not exists max_family int not null default 50,
  add column if not exists used_count int not null default 0,
  add column if not exists status text not null default 'active',
  add column if not exists created_by_admin_id uuid,
  add column if not exists expires_at timestamptz;

-- Buang constraint lama jika wujud, kemudian tambah constraint baru yang selamat.
alter table access_codes drop constraint if exists access_codes_code_check;
alter table access_codes drop constraint if exists access_codes_max_family_check;
alter table access_codes drop constraint if exists access_codes_used_count_check;
alter table access_codes drop constraint if exists access_codes_status_check;

alter table access_codes
  add constraint access_codes_code_check check (code ~ '^RH-[A-Z0-9]{6}$'),
  add constraint access_codes_max_family_check check (max_family > 0 and max_family <= 500),
  add constraint access_codes_used_count_check check (used_count >= 0),
  add constraint access_codes_status_check check (status in ('active','disabled','expired'));

-- Tambah foreign key admin jika table admin_users wujud dan constraint belum ada.
do $$
begin
  if exists (select 1 from information_schema.tables where table_name = 'admin_users') then
    if not exists (
      select 1 from pg_constraint where conname = 'access_codes_created_by_admin_id_fkey'
    ) then
      alter table access_codes
        add constraint access_codes_created_by_admin_id_fkey
        foreign key (created_by_admin_id) references admin_users(id);
    end if;
  end if;
end $$;

create table if not exists access_code_uses (
  id uuid primary key default gen_random_uuid(),
  access_code_id uuid not null references access_codes(id) on delete cascade,
  user_id uuid,
  family_id uuid,
  username text,
  used_at timestamptz default now()
);

-- Tambah foreign key uses jika table berkaitan wujud.
do $$
begin
  if exists (select 1 from information_schema.tables where table_name = 'app_users') then
    if not exists (select 1 from pg_constraint where conname = 'access_code_uses_user_id_fkey') then
      alter table access_code_uses
        add constraint access_code_uses_user_id_fkey
        foreign key (user_id) references app_users(id);
    end if;
  end if;

  if exists (select 1 from information_schema.tables where table_name = 'families') then
    if not exists (select 1 from pg_constraint where conname = 'access_code_uses_family_id_fkey') then
      alter table access_code_uses
        add constraint access_code_uses_family_id_fkey
        foreign key (family_id) references families(id);
    end if;
  end if;
end $$;

create index if not exists idx_access_codes_code on access_codes(code);
create index if not exists idx_access_codes_status on access_codes(status);
create index if not exists idx_access_code_uses_code_id on access_code_uses(access_code_id);

-- Tambah column app_users jika table wujud.
do $$
begin
  if exists (select 1 from information_schema.tables where table_name = 'app_users') then
    alter table app_users
      add column if not exists access_code_id uuid references access_codes(id),
      add column if not exists access_code text;
  end if;
end $$;

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

  if exists (select 1 from information_schema.tables where table_name = 'app_users') then
    update app_users
    set access_code_id = v_code_id,
        access_code = upper(trim(p_code))
    where id = p_user_id;
  end if;

  return v_code_id;
end;
$$ language plpgsql security definer;

drop view if exists admin_access_code_monitor;
create view admin_access_code_monitor as
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


-- v1.3.5: Atomic register user + redeem access code from frontend.
-- This fixes register success in UI but no record in Supabase.
create or replace function grocery2u_register_user_with_access_code(
  p_username text,
  p_pin_hash text,
  p_full_name text,
  p_code text
)
returns jsonb as $$
declare
  v_user_id uuid;
  v_code_id uuid;
  v_max_family int;
  v_used_count int;
  v_username text;
begin
  v_username := lower(trim(p_username));

  if v_username is null or length(v_username) < 3 then
    raise exception 'Username mesti sekurang-kurangnya 3 aksara';
  end if;

  if p_pin_hash is null or length(trim(p_pin_hash)) < 4 then
    raise exception 'PIN/password mesti sekurang-kurangnya 4 aksara';
  end if;

  if exists (select 1 from app_users where username = v_username) then
    raise exception 'Username sudah wujud';
  end if;

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

  insert into app_users(username, pin_hash, full_name, access_code_id, access_code)
  values(v_username, trim(p_pin_hash), coalesce(nullif(trim(p_full_name), ''), v_username), v_code_id, upper(trim(p_code)))
  returning id into v_user_id;

  update access_codes
  set used_count = used_count + 1
  where id = v_code_id;

  insert into access_code_uses(access_code_id, user_id, username)
  values(v_code_id, v_user_id, v_username);

  return jsonb_build_object(
    'ok', true,
    'user_id', v_user_id,
    'username', v_username,
    'access_code_id', v_code_id,
    'access_code', upper(trim(p_code))
  );
end;
$$ language plpgsql security definer;

-- Optional helper: monitor user registered with codes.
drop view if exists admin_user_access_code_monitor;
create view admin_user_access_code_monitor as
select
  u.id as user_id,
  u.username,
  u.full_name,
  u.access_code,
  u.created_at as registered_at,
  c.campaign_name,
  c.max_family,
  c.used_count
from app_users u
left join access_codes c on c.id = u.access_code_id
order by u.created_at desc;


-- v1.3.6: Frontend/Admin Supabase write grants for anon key.
-- This allows the current static app to write/read the required tables through PostgREST.
grant usage on schema public to anon, authenticated;
grant select, insert, update on table access_codes to anon, authenticated;
grant select, insert on table access_code_uses to anon, authenticated;
grant select, insert, update on table app_users to anon, authenticated;
grant select, insert, update on table families to anon, authenticated;
grant select, insert, update on table family_members to anon, authenticated;
grant select on table receipts to anon, authenticated;
grant select on table shopping_lists to anon, authenticated;
grant execute on function grocery2u_register_user_with_access_code(text,text,text,text) to anon, authenticated;
grant execute on function grocery2u_use_access_code(text,text,uuid,uuid) to anon, authenticated;

-- Keep RLS off for MVP public beta unless proper per-user auth is implemented.
-- Username+PIN custom auth is handled by app tables, not Supabase Auth.
alter table access_codes disable row level security;
alter table access_code_uses disable row level security;
alter table app_users disable row level security;
alter table families disable row level security;
alter table family_members disable row level security;
