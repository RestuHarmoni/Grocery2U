-- Grocery2U by RH v1.3.12
-- MVP RLS fix for Supabase QA
-- Purpose: allow frontend/admin inserts during MVP testing.
-- Run this after database/007_family_profiles_supabase_write_fix.sql

-- Disable RLS on operational MVP tables so the anon frontend can write during QA.
-- WARNING: This is for MVP/closed testing only. Re-enable proper RLS before public production.

ALTER TABLE IF EXISTS public.access_codes DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.access_code_uses DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.app_users DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.families DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.family_members DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.family_profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.shopping_lists DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.shopping_list_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.master_categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.master_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.receipts DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.claims DISABLE ROW LEVEL SECURITY;

-- Ensure family_profiles has expected columns used by v1.3.11+
ALTER TABLE IF EXISTS public.family_profiles
  ADD COLUMN IF NOT EXISTS avatar text,
  ADD COLUMN IF NOT EXISTS status text DEFAULT 'active',
  ADD COLUMN IF NOT EXISTS created_at timestamptz DEFAULT now();

-- Optional safety index for faster profile lookup
CREATE INDEX IF NOT EXISTS idx_family_profiles_family_id ON public.family_profiles(family_id);

-- Quick QA query after run:
-- select relname, relrowsecurity from pg_class where relname in ('family_profiles','access_codes','app_users','families');
