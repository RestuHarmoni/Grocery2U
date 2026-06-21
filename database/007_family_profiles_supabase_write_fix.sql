-- Grocery2U by RH v1.3.11
-- Family Profiles Supabase Write Fix
-- Ensures profile records can be inserted/read by the MVP frontend.

ALTER TABLE families
ADD COLUMN IF NOT EXISTS account_user_id uuid;

UPDATE families
SET account_user_id = created_by
WHERE account_user_id IS NULL AND created_by IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS ux_families_account_user_id
ON families(account_user_id)
WHERE account_user_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS family_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id uuid NOT NULL REFERENCES families(id) ON DELETE CASCADE,
  name text NOT NULL,
  role text NOT NULL DEFAULT 'Ahli',
  avatar text,
  status text NOT NULL DEFAULT 'active',
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_family_profiles_family_id ON family_profiles(family_id);

CREATE OR REPLACE FUNCTION enforce_max_5_family_profiles()
RETURNS trigger AS $$
BEGIN
  IF (
    SELECT count(*)
    FROM family_profiles
    WHERE family_id = NEW.family_id
      AND status <> 'inactive'
  ) >= 5 THEN
    RAISE EXCEPTION 'Maximum 5 profiles per family reached';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_max_5_family_profiles ON family_profiles;
CREATE TRIGGER trg_max_5_family_profiles
BEFORE INSERT ON family_profiles
FOR EACH ROW
EXECUTE FUNCTION enforce_max_5_family_profiles();

-- MVP: custom username/password auth uses anon key, so open these tables for now.
-- Tighten with RPC/service-role later before paid/public scale.
ALTER TABLE families DISABLE ROW LEVEL SECURITY;
ALTER TABLE family_members DISABLE ROW LEVEL SECURITY;
ALTER TABLE family_profiles DISABLE ROW LEVEL SECURITY;

GRANT ALL ON families TO anon, authenticated;
GRANT ALL ON family_members TO anon, authenticated;
GRANT ALL ON family_profiles TO anon, authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

COMMENT ON TABLE family_profiles IS 'Grocery2U v1.3.11 family profiles: 1 family max 5 profiles. Frontend writes to Supabase.';
