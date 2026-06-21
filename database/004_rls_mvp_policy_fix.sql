-- Grocery2U by RH v1.3.7
-- MVP RLS Policy Fix
-- Purpose: allow the current username/password frontend MVP to write/read required data
-- using the Supabase anon key. This is for MVP/QA only.
-- Run after:
-- 001_supabase_schema.sql
-- 002_admin_username_password.sql
-- 003_access_codes.sql

-- Access code generator + register validation
ALTER TABLE IF EXISTS public.access_codes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "grocery2u_mvp_access_codes_all" ON public.access_codes;
CREATE POLICY "grocery2u_mvp_access_codes_all"
ON public.access_codes
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- Access code usage log
ALTER TABLE IF EXISTS public.access_code_uses ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "grocery2u_mvp_access_code_uses_all" ON public.access_code_uses;
CREATE POLICY "grocery2u_mvp_access_code_uses_all"
ON public.access_code_uses
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- App users register/login
ALTER TABLE IF EXISTS public.app_users ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "grocery2u_mvp_app_users_all" ON public.app_users;
CREATE POLICY "grocery2u_mvp_app_users_all"
ON public.app_users
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- Families
ALTER TABLE IF EXISTS public.families ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "grocery2u_mvp_families_all" ON public.families;
CREATE POLICY "grocery2u_mvp_families_all"
ON public.families
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- Family members
ALTER TABLE IF EXISTS public.family_members ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "grocery2u_mvp_family_members_all" ON public.family_members;
CREATE POLICY "grocery2u_mvp_family_members_all"
ON public.family_members
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- Shopping lists
ALTER TABLE IF EXISTS public.shopping_lists ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "grocery2u_mvp_shopping_lists_all" ON public.shopping_lists;
CREATE POLICY "grocery2u_mvp_shopping_lists_all"
ON public.shopping_lists
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- Shopping list items
ALTER TABLE IF EXISTS public.shopping_list_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "grocery2u_mvp_shopping_list_items_all" ON public.shopping_list_items;
CREATE POLICY "grocery2u_mvp_shopping_list_items_all"
ON public.shopping_list_items
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- Master categories/items
ALTER TABLE IF EXISTS public.master_categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "grocery2u_mvp_master_categories_all" ON public.master_categories;
CREATE POLICY "grocery2u_mvp_master_categories_all"
ON public.master_categories
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);

ALTER TABLE IF EXISTS public.master_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "grocery2u_mvp_master_items_all" ON public.master_items;
CREATE POLICY "grocery2u_mvp_master_items_all"
ON public.master_items
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- Receipts
ALTER TABLE IF EXISTS public.receipts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "grocery2u_mvp_receipts_all" ON public.receipts;
CREATE POLICY "grocery2u_mvp_receipts_all"
ON public.receipts
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- Admin tables used by username/password admin MVP
ALTER TABLE IF EXISTS public.admin_users ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "grocery2u_mvp_admin_users_all" ON public.admin_users;
CREATE POLICY "grocery2u_mvp_admin_users_all"
ON public.admin_users
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);

ALTER TABLE IF EXISTS public.admin_sessions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "grocery2u_mvp_admin_sessions_all" ON public.admin_sessions;
CREATE POLICY "grocery2u_mvp_admin_sessions_all"
ON public.admin_sessions
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- Optional views/tables if they exist
ALTER TABLE IF EXISTS public.app_limits ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "grocery2u_mvp_app_limits_all" ON public.app_limits;
CREATE POLICY "grocery2u_mvp_app_limits_all"
ON public.app_limits
FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);
