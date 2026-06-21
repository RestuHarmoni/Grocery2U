-- Grocery2U by RH v1.2.6 Supabase schema
create extension if not exists pgcrypto;
create table if not exists app_users (
  id uuid primary key default gen_random_uuid(),
  username text unique not null,
  pin_hash text not null,
  full_name text,
  created_at timestamptz default now()
);
create table if not exists families (
  id uuid primary key default gen_random_uuid(),
  family_name text not null,
  created_by uuid references app_users(id),
  invite_code text unique,
  created_at timestamptz default now()
);
create table if not exists family_members (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references families(id) on delete cascade,
  user_id uuid references app_users(id) on delete cascade,
  role text default 'member',
  nickname text,
  status text default 'active',
  created_at timestamptz default now(),
  unique(family_id,user_id)
);
create table if not exists master_categories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references app_users(id) on delete cascade,
  name text not null,
  sort_order int default 0,
  is_active boolean default true
);
create table if not exists master_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references app_users(id) on delete cascade,
  category_id uuid references master_categories(id),
  item_name text not null,
  default_unit text,
  is_active boolean default true,
  created_at timestamptz default now()
);
create table if not exists shopping_lists (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references families(id) on delete cascade,
  title text not null,
  created_by_user_id uuid references app_users(id),
  assigned_to_user_id uuid references app_users(id),
  status text default 'draft',
  created_at timestamptz default now(),
  completed_at timestamptz
);
create table if not exists shopping_list_items (
  id uuid primary key default gen_random_uuid(),
  list_id uuid references shopping_lists(id) on delete cascade,
  master_item_id uuid references master_items(id),
  item_name text not null,
  category_name text,
  quantity text,
  note text,
  status text default 'requested',
  replacement_name text,
  updated_at timestamptz default now()
);
create table if not exists receipts (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references families(id) on delete cascade,
  list_id uuid references shopping_lists(id),
  paid_by_user_id uuid references app_users(id),
  store_name text,
  receipt_date date default current_date,
  total_amount numeric(10,2) default 0,
  receipt_file_url text,
  original_file_path text,
  preview_file_path text,
  file_name text,
  mime_type text,
  file_size_bytes bigint default 0,
  claim_status text default 'unpaid',
  claim_paid_at timestamptz,
  created_at timestamptz default now()
);
-- For production, enable RLS and create policies based on family_members.


-- Receipt storage bucket
insert into storage.buckets (id, name, public)
values ('receipts', 'receipts', false)
on conflict (id) do nothing;

-- Suggested path format:
-- receipts/{family_id}/{yyyy}/{mm}/receipt_{receipt_id}.webp
-- Store the file path in receipts.original_file_path / preview_file_path.


-- Admin monitor view for registration dashboard
create or replace view admin_register_monitor as
select
  u.id as user_id,
  u.username,
  u.full_name,
  u.created_at as registered_at,
  count(distinct f.id) as family_created_count,
  count(distinct fm.family_id) as family_joined_count
from app_users u
left join families f on f.created_by = u.id
left join family_members fm on fm.user_id = u.id
group by u.id, u.username, u.full_name, u.created_at;

-- Production note: restrict this view to admin users only with RLS/policies.
