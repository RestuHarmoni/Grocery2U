-- Grocery2U by RH v1.3.13
-- Family profile persistence fix
-- Purpose: ensure family_profiles can be inserted/read by the static MVP app.

ALTER TABLE IF EXISTS public.families
  ADD COLUMN IF NOT EXISTS account_user_id uuid;

UPDATE public.families
SET account_user_id = created_by
WHERE account_user_id IS NULL AND created_by IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_families_account_user_id
ON public.families(account_user_id)
WHERE account_user_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS public.family_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id uuid NOT NULL REFERENCES public.families(id) ON DELETE CASCADE,
  name text NOT NULL,
  role text NOT NULL DEFAULT 'Ahli',
  avatar text,
  status text NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE IF EXISTS public.family_profiles
  ADD COLUMN IF NOT EXISTS avatar text,
  ADD COLUMN IF NOT EXISTS status text DEFAULT 'active',
  ADD COLUMN IF NOT EXISTS created_at timestamptz DEFAULT now();

CREATE INDEX IF NOT EXISTS idx_family_profiles_family_id ON public.family_profiles(family_id);

GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON public.families TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON public.family_members TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.family_profiles TO anon, authenticated;

-- MVP QA only: username/password custom auth does not map to Supabase Auth yet.
ALTER TABLE IF EXISTS public.families DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.family_members DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.family_profiles DISABLE ROW LEVEL SECURITY;

-- QA check:
-- select relname, relrowsecurity from pg_class where relname in ('families','family_members','family_profiles');
