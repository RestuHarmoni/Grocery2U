-- Grocery2U by RH v1.3.0
-- Admin login menggunakan username + password, tanpa email.
-- Run selepas database/001_supabase_schema.sql.

create extension if not exists pgcrypto;

create table if not exists admin_users (
  id uuid primary key default gen_random_uuid(),
  username text unique not null,
  password_hash text not null,
  full_name text,
  role text not null default 'staff' check (role in ('super_admin','admin','staff','support')),
  is_active boolean not null default true,
  created_at timestamptz default now(),
  last_login_at timestamptz
);

create table if not exists admin_sessions (
  id uuid primary key default gen_random_uuid(),
  admin_user_id uuid references admin_users(id) on delete cascade,
  session_token_hash text not null,
  ip_address text,
  user_agent text,
  created_at timestamptz default now(),
  expires_at timestamptz not null,
  revoked_at timestamptz
);

-- Akaun admin awal untuk setup.
-- Username: superadmin
-- Password: grocery2u123
-- WAJIB tukar password selepas login/setup production.
insert into admin_users (username, password_hash, full_name, role, is_active)
values ('superadmin', crypt('grocery2u123', gen_salt('bf')), 'Super Admin', 'super_admin', true)
on conflict (username) do nothing;

-- Helper function untuk tukar password admin dari SQL Editor.
-- Contoh:
-- select grocery2u_change_admin_password('superadmin', 'password_baru_yang_kuat');
create or replace function grocery2u_change_admin_password(p_username text, p_new_password text)
returns void as $$
begin
  if length(coalesce(p_new_password,'')) < 8 then
    raise exception 'Password admin mesti sekurang-kurangnya 8 aksara';
  end if;

  update admin_users
  set password_hash = crypt(p_new_password, gen_salt('bf'))
  where username = lower(trim(p_username));

  if not found then
    raise exception 'Admin username tidak dijumpai: %', p_username;
  end if;
end;
$$ language plpgsql security definer;

-- Nota production:
-- Password hash tidak patut disemak terus dari browser.
-- Untuk production penuh, gunakan Edge Function / backend trusted untuk verify password.
