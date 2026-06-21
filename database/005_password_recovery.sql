-- Grocery2U by RH v1.3.8 Password Recovery
-- Run after database/001_supabase_schema.sql, 003_access_codes.sql and 004_rls_mvp_policy_fix.sql.

alter table app_users add column if not exists password_reset_required boolean not null default false;
alter table app_users add column if not exists password_reset_at timestamptz;
alter table app_users add column if not exists password_updated_at timestamptz;
alter table app_users add column if not exists reset_by_admin_username text;

create table if not exists user_password_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references app_users(id) on delete cascade,
  event_type text not null,
  admin_username text,
  created_at timestamptz default now()
);

create or replace function grocery2u_admin_reset_user_password(p_user_id uuid, p_temp_password text, p_admin_username text default 'superadmin')
returns jsonb as $$
begin
  if length(coalesce(p_temp_password,'')) < 6 then
    raise exception 'Password sementara mesti sekurang-kurangnya 6 aksara';
  end if;

  update app_users
  set pin_hash = p_temp_password,
      password_reset_required = true,
      password_reset_at = now(),
      reset_by_admin_username = p_admin_username
  where id = p_user_id;

  if not found then
    raise exception 'User tidak dijumpai';
  end if;

  insert into user_password_events(user_id,event_type,admin_username)
  values (p_user_id,'admin_reset',p_admin_username);

  return jsonb_build_object('ok', true, 'user_id', p_user_id, 'reset_required', true);
end;
$$ language plpgsql security definer;

create or replace function grocery2u_user_force_change_password(p_user_id uuid, p_new_password text)
returns jsonb as $$
begin
  if length(coalesce(p_new_password,'')) < 6 then
    raise exception 'Password baru mesti sekurang-kurangnya 6 aksara';
  end if;

  update app_users
  set pin_hash = p_new_password,
      password_reset_required = false,
      password_updated_at = now(),
      reset_by_admin_username = null
  where id = p_user_id;

  if not found then
    raise exception 'User tidak dijumpai';
  end if;

  insert into user_password_events(user_id,event_type)
  values (p_user_id,'user_force_change');

  return jsonb_build_object('ok', true, 'user_id', p_user_id, 'reset_required', false);
end;
$$ language plpgsql security definer;

create or replace function grocery2u_user_change_password(p_user_id uuid, p_old_password text, p_new_password text)
returns jsonb as $$
declare
  old_match boolean;
begin
  if length(coalesce(p_new_password,'')) < 6 then
    raise exception 'Password baru mesti sekurang-kurangnya 6 aksara';
  end if;

  select exists(select 1 from app_users where id=p_user_id and pin_hash=p_old_password) into old_match;
  if not old_match then
    raise exception 'Password lama tidak tepat';
  end if;

  update app_users
  set pin_hash = p_new_password,
      password_reset_required = false,
      password_updated_at = now(),
      reset_by_admin_username = null
  where id = p_user_id;

  insert into user_password_events(user_id,event_type)
  values (p_user_id,'user_change');

  return jsonb_build_object('ok', true, 'user_id', p_user_id);
end;
$$ language plpgsql security definer;

-- MVP RLS policy for password event audit table.
alter table user_password_events disable row level security;
